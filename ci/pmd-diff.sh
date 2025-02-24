#!/bin/bash

rm -rf ./tmpPMD

# shellcheck disable=SC2154
echo ""
echo "*****************************************************"
echo ""
echo "-------- build diff folder for pmd check ---------"
echo ""

SOURCE_DIR="./force-app"
DEPLOY_DIR="./tmpPMD/deploy"

function unzipToDeploy() {
    if [ -f package.zip ]; then
        unzip package.zip -d ${DEPLOY_DIR}
    fi
    # Remove tmpPMD package
    rm -f ./package.zip
}

echo "BRANCH_NAME : $BRANCH_NAME"
## Make a deploy and destroy directories to check the object changes
mkdir -p ${DEPLOY_DIR}

# If any files have changed/been added that require a deployment
DIFFSTARTCOMMAND="git diff -z --ignore-all-space --name-only --diff-filter=d origin/${BRANCH_NAME}..HEAD -- ${SOURCE_DIR}/"
DIFFENDCOMMAND="xargs -0 git archive -o package.zip HEAD"

echo "Diff statement on objects: ${DIFFSTARTCOMMAND} | ${DIFFENDCOMMAND}"
echo ""

CHANGED_FILES=$($DIFFSTARTCOMMAND | wc -w)
echo "Number of changed files on objects: ${CHANGED_FILES}"
echo ""

if [ "${CHANGED_FILES}" -gt "0" ]; then
    echo "Delta deployment requested, commit from head to last ${BRANCH_NAME} tag"
    echo ""
    eval "$($DIFFSTARTCOMMAND | $DIFFENDCOMMAND)"
    unzipToDeploy
    echo ""
fi

allFilesPath=""
tempFile=$(mktemp)  # Create a temporary file

# Ensure the temporary file is cleaned up on exit
trap 'rm -f "$tempFile"' EXIT

if [[ -d ./tmpPMD/deploy ]]; then
    # Use find with -print0 to handle spaces and special characters
    find ./tmpPMD -type f -print0 | while IFS= read -r -d '' f; do
        # Correct prefix removal
        strippedPath="${f/\/tmpPMD\/deploy/}"
        quotedPath=$(printf '"%s"' "$strippedPath")
        escapedPath=$(echo "$quotedPath" | sed 's/\$/\\$/g')
        # Append to the temporary file
        echo "$escapedPath" >> "$tempFile"
    done

    # Read all paths from the temporary file and concatenate them
    while IFS= read -r line; do
        allFilesPath+="$line "
    done < "$tempFile"
fi

# Remove trailing space
allFilesPath=$(echo "$allFilesPath" | sed 's/ $//')
echo CHANGED_FILES="$CHANGED_FILES" >> $GITHUB_ENV
echo allFilesPath="$allFilesPath" >> $GITHUB_ENV
