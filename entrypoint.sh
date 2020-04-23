#!/bin/bash

set -eu

echo '👍 ENTRYPOINT HAS STARTED'
DOKKU_LOCAL_BRANCH=${INPUT_DOKKU_LOCAL_BRANCH:-$GITHUB_SHA}

echo ${INPUT_DOKKU_LOCAL_BRANCH}

# Setup the SSH environment
mkdir -p ~/.ssh
eval `ssh-agent -s`
ssh-add - <<< "${INPUT_SSH_PRIVATE_KEY}"
ssh-keyscan $INPUT_DOKKU_HOST >> ~/.ssh/known_hosts

# Setup the git environment
git_repo="${INPUT_DOKKU_USER}@${INPUT_DOKKU_HOST}:${INPUT_DOKKU_APP_NAME}"
cd "${GITHUB_WORKSPACE}"
git remote add deploy "${git_repo}"

# Prepare to push to Dokku git repository
REMOTE_REF="${DOKKU_LOCAL_BRANCH}:refs/heads/${INPUT_DOKKU_REMOTE_BRANCH}"

GIT_COMMAND="git push deploy ${REMOTE_REF} ${INPUT_GIT_PUSH_FLAGS}"
echo "GIT_COMMAND=${GIT_COMMAND}"

# Push to Dokku git repository
GIT_SSH_COMMAND="ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no" ${GIT_COMMAND}