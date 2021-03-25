#!/usr/bin/env bash

source ci/helper.sh

# Do we need a step to manually pull the artifact if deploy is run
# from a different agent from package

# Determine which org to set as the target
[ $GITHUB_EVENT_NAME == "pull_request" ] &&
   SOURCE_BRANCH=$BASE_BRANCH ||
   SOURCE_BRANCH=${GITHUB_REF##*/}

# Determine which branch to use to determine the destination
[ "$GITHUB_EVENT_NAME" = "push" ] &&
   BRANCH=${SOURCE_BRANCH} ||
   BRANCH=${BASE_BRANCH}


# Only run this step if there is an artifact
if [ -d "artefact" ]; then
   deployArtifact ${BUILD_COMMAND} ${ORG_NAME}
fi
