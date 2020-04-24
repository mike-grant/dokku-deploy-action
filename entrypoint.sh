#!/bin/bash

set -eu

SSH_PRIVATE_KEY=$1
DOKKU_HOST=$2
DOKKU_APP_NAME=$3
DOKKU_USER=$4
DOKKU_REMOTE_BRANCH=$5
DOKKU_LOCAL_BRANCH=$6
GIT_PUSH_FLAGS=$7

echo '👍 ENTRYPOINT HAS STARTED'
echo ${DOKKU_LOCAL_BRANCH}

# Setup the SSH environment
mkdir -p ~/.ssh
eval `ssh-agent -s`
ssh-add - <<< "${SSH_PRIVATE_KEY}"
ssh-keyscan $DOKKU_HOST >> ~/.ssh/known_hosts

# Setup the git environment
git_repo="${DOKKU_USER}@${DOKKU_HOST}:${DOKKU_APP_NAME}"
cd "${GITHUB_WORKSPACE}"
git remote add deploy "${git_repo}"

# Prepare to push to Dokku git repository
REMOTE_REF="${DOKKU_LOCAL_BRANCH}:refs/heads/${DOKKU_REMOTE_BRANCH}"

GIT_COMMAND="git push deploy ${REMOTE_REF} ${GIT_PUSH_FLAGS}"
echo "GIT_COMMAND=${GIT_COMMAND}"

# Push to Dokku git repository
GIT_SSH_COMMAND="ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no" ${GIT_COMMAND}