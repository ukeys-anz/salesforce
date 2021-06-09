#!/usr/bin/env bash

# Access the helper methods
source ci/helper.sh

# Set run variables
SOURCE_DIR="./force-app"
DEPLOY_DIR="./tmp/deploy"
DESTRUCTIVE_DIR="./tmp/destructive"
META_DIR=(classes components pages triggers 'email/unfiled$public' staticresources wave)
BUNDLE_DIR=(aura lwc waveTemplates)
# If SOURCE_BRANCH is specified in the yml, do not overwrite
if [ -z "$SOURCE_BRANCH" ]; then
   [ $GITHUB_EVENT_NAME == "pull_request" ] &&
      SOURCE_BRANCH=$BASE_BRANCH ||
      SOURCE_BRANCH=${GITHUB_REF#refs/heads/}
fi
# If TAG_PREFIX is specified in the yml, do not overwrite
if [ -z "$TAG_PREFIX" ]; then
   TAG_PREFIX="$SOURCE_BRANCH"
fi

## Make a deploy and destroy directories to start building artefacts
mkdir -p tmp
mkdir ${DEPLOY_DIR}
mkdir ${DESTRUCTIVE_DIR}

# If any files have changed/been added that require a deployment, generate an artefact
setBranchDiffCommand false false ${SOURCE_BRANCH} ${TAG_PREFIX}
echo "Dif statement: ${DIFFSTARTCOMMAND} | ${DIFFENDCOMMAND}"
CHANGED_FILES=$($DIFFSTARTCOMMAND | wc -w)
echo "Number of changed files: ${CHANGED_FILES}"
if [ "${CHANGED_FILES}" -gt "0" ]; then
    $($DIFFSTARTCOMMAND | $DIFFENDCOMMAND)
    echo "unzipping"
    unzipDeployPackageandCopyMetaFiles
fi

# If any files have been deleted that need to be deleted, generate an artefact
setBranchDiffCommand true true ${SOURCE_BRANCH} ${TAG_PREFIX}
DELETED_FILES=$($DIFFSTARTCOMMAND | wc -l)
echo "Number of deleted files: ${DELETED_FILES}"
if [ "${DELETED_FILES}" -gt "0" ]; then
    setBranchDiffCommand true false ${SOURCE_BRANCH} ${TAG_PREFIX}
    $($DIFFSTARTCOMMAND | $DIFFENDCOMMAND)
    unzipDestructivePackage
fi

#copy project file and ignore file
copyMandatoryFilesToPackage ${DEPLOY_DIR}
copyMandatoryFilesToPackage ${DESTRUCTIVE_DIR}

# Convert the DX project to a metadata api package and commit the changes to the artefact
CURRENT_DIR=$(pwd)
# This error message means the artifact is empty, either ci changes only, or everything is forceignored
ERROR_MSG="No matching source was found within the package root directory"

# Only generate artefacts where files are found
if [ "${CHANGED_FILES}" -gt "0" ]; then
    cd ${DEPLOY_DIR}
    if result=$(npx sfdx force:source:convert -r ./force-app -d ${CURRENT_DIR}/artefact --loglevel debug 2>&1); then
        echo "Deploy conversion successful"
    else
        if [[ $result == *$ERROR_MSG* ]]; then
            echo "No files found in artifact, all files forceignored or no changes in deployable meta"
            exit 0
        else
            echo $result
            exit 1
        fi        
    fi
    echo "::set-output name=ARTEFACT_GENERATED::true"
    # Return to working DIR
    cd ${CURRENT_DIR}
fi

if [ "${DELETED_FILES}" -gt "0" ]; then
    cd ${DESTRUCTIVE_DIR}

    if result=$(npx sfdx force:source:convert -r ./force-app -d tmp/ --loglevel debug 2>&1); then
        echo "Destroy conversion successful"
    else
        if [[ $result == *$ERROR_MSG* ]]; then
            echo "No files found in destructive artifact, all files forceignored or no changes in deployable meta"
            exit 0
        else
            echo $result
            exit 1
        fi        
    fi
    echo "::set-output name=ARTEFACT_GENERATED::true"
    echo "Creating destroy manifest"
    cd ./tmp/
    if [ ! -d ${CURRENT_DIR}/artefact ]; then
        mkdir ${CURRENT_DIR}/artefact
        echo '<?xml version="1.0" encoding="UTF-8"?><Package xmlns="http://soap.sforce.com/2006/04/metadata"><version>50.0</version></Package>' > ${CURRENT_DIR}/artefact/package.xml
    fi
    mv package.xml ${CURRENT_DIR}/artefact/destructiveChanges.xml
    # Return to working DIR
    cd ${CURRENT_DIR}
fi
