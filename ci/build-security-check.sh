#!/bin/bash

rm -rf ./tmp

echo ""
echo "***************************************************************"
echo ""
echo "----------- Build Deploy Folder for Security Check ------------"
echo ""

DEPLOY_DIR="./tmp/deploy"

function unzipToDeploy() {
    if [ -f package.zip ]; then
        unzip package.zip -d ${DEPLOY_DIR}
        rm -rf ./package.zip
    fi
}

function checkSpecificMetadata() {
    if [[ -d ./tmp/deploy/force-app/main/default/$1 ]];then
        for fi in ./tmp/deploy/force-app/main/default/$1/*; do
            fieldMetadata=$( cat "$fi" )
            f=$(basename "$fi") && f=${f/.field-meta.xml}
            if [[ $fieldMetadata == *"<field>User.Refresh_Token__c</field>"* ]];then
                echo ""
                echo "Do not grant access to User.Refresh_Token__c, this is for internal system use only"
                echo ""
                echo "Issue Found: $1.$f"
                echo ""
                echo "***************************************************************"
                echo ""
                exit 1
            fi
        done
    fi
}

# Make a deploy and destroy directories to check the profile & permission set changes
mkdir -p ${DEPLOY_DIR}

# Check if there are any profiles & permission sets have changed/been added that require a deployment
# If so, saving changes in package.zip folder
DIFFSTARTCOMMAND="git diff -z --ignore-all-space --name-only --diff-filter=d $(git tag --sort=-creatordate | grep ${BRANCH_NAME} | head -1)..HEAD ./$1/"
DIFFENDCOMMAND="xargs -0 git archive -o package.zip HEAD"

echo "Diff statement on $2: ${DIFFSTARTCOMMAND} | ${DIFFENDCOMMAND}"
echo ""

CHANGED_FILES=$($DIFFSTARTCOMMAND | wc -w)
echo "Number of changed $2: ${CHANGED_FILES}"

if [ "${CHANGED_FILES}" -gt "0" ]; then
    eval "$($DIFFSTARTCOMMAND | $DIFFENDCOMMAND)"
    unzipToDeploy $2
    checkSpecificMetadata $2
    echo ""
    echo "***************************************************************"
    echo ""
fi