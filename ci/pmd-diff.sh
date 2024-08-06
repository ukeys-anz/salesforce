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
DIFFSTARTCOMMAND="git diff -z --ignore-all-space --name-only --diff-filter=d $(git tag --sort=-creatordate | grep ${BRANCH_NAME} | head -n 1)..HEAD  ${SOURCE_DIR}/"
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
if [[ -d ./tmpPMD/deploy ]];then
    allFiles=$( find ./tmpPMD -type f -print )
    for f in ${allFiles[*]}; do
        allFilesPath="$allFilesPath""${f/\/tmpPMD\/deploy} "
    done
fi

echo allFilesPath="$allFilesPath" >> $GITHUB_ENV
