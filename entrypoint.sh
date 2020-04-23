#!/bin/bash

set -eu

echo '👍 ENTRYPOINT HAS STARTED'
DOKKU_LOCAL_BRANCH=${INPUT_DOKKU-LOCAL-BRANCH:$GITHUB_SHA}
echo ${INPUT_DOKKU-LOCAL-BRANCH}
echo ${DOKKU_LOCAL_BRANCH}

# Setup the SSH environment
mkdir -p ~/.ssh
eval `ssh-agent -s`
ssh-add - <<< "${INPUT_SSH-PRIVATE-KEY}"
ssh-keyscan $INPUT_DOKKU-HOST >> ~/.ssh/known_hosts

# Setup the git environment
git_repo="${INPUT_DOKKU-USER}@${INPUT_DOKKU-HOST}:${INPUT_DOKKU-APP-NAME}"
cd "${GITHUB_WORKSPACE}"
git remote add deploy "${git_repo}"

# Prepare to push to Dokku git repository
REMOTE_REF="${DOKKU_LOCAL_BRANCH}:refs/heads/${INPUT_DOKKU-REMOTE-BRANCH}"

GIT_COMMAND="git push deploy ${REMOTE_REF} ${INPUT_GIT-PUSH-FLAGS}"
echo "GIT_COMMAND=${GIT_COMMAND}"

# Push to Dokku git repository
GIT_SSH_COMMAND="ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no" ${GIT_COMMAND}