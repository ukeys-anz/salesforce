#!/bin/bash

echo ""
echo "*****************************************************"
echo ""
echo "-------- find new sandbox config info ---------"
echo ""

SOURCE_DIR="config/sandbox-config"
DEPLOY_DIR="tmp/deploy"

function unzipToDeploy() {
    if [ -f package.zip ]; then
        unzip package.zip -d "${DEPLOY_DIR}"
    fi
    # Remove tmp package
    rm -f ./package.zip
}

## Make a deploy and destroy directories to check the object changes
mkdir -p "${DEPLOY_DIR}"
BRANCH_NAME=sandbox
# If any files have changed/been added that require a deployment
DIFFSTARTCOMMAND="git diff -z --ignore-all-space --name-only --diff-filter=d $(git tag --sort=-creatordate | grep ${BRANCH_NAME} | head -1)..HEAD  ${SOURCE_DIR}/"
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

count=0
for s in "${DEPLOY_DIR}"/config/sandbox-config/*; do
    if [[ "$count" == 0 ]];then
        # shellcheck disable=SC2034
        sandboxName=$(node -p "report=JSON.parse(require('fs').readFileSync('$s')).sandboxName" )
        # shellcheck disable=SC2034
        email=$(node -p "report=JSON.parse(require('fs').readFileSync('$s')).email" )
        # shellcheck disable=SC2034
        licenseType=$(node -p "report=JSON.parse(require('fs').readFileSync('$s')).licenseType" )
        if [[ "$licenseType" != "Developer" && "$licenseType" != "Developer_Pro" ]];then
            echo ""
            echo "The $licenseType is not a permitted values for License Type."
            echo "It should be either Developer or Developer_Pro"
            exit 1
        fi
        count=$(( count + 1 ))
    fi
done