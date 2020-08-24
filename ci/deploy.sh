#!/bin/bash -e

source ci/helper.sh

# Do we need a step to manually pull the artifact if deploy is run
# from a different agent from package

# Determine which org to set as the target
if [ $GITHUB_EVENT_NAME == "pull_request" ]; then
   SOURCE_BRANCH=$BASE_BRANCH
else
   SOURCE_BRANCH=${GITHUB_REF##*/}
fi

[ "$GITHUB_EVENT_NAME" = "push" ] &&
   BRANCH=${SOURCE_BRANCH} ||
   BRANCH=${BASE_BRANCH}
[ "$BRANCH" = "master" ] &&
   ORG_NAME="systest" ||
   ORG_NAME="cmosdev"

# Only run this step if there is an artifact
if [ -d "artefact" ]; then
   deployArtifact ${BUILD_COMMAND} ${ORG_NAME}
fi
