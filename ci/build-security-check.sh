#!/bin/bash

rm -rf ./tmp

echo ""
echo "***************************************************************"
echo ""
echo "----------- Build Deploy Folder for Security Check ------------"
echo ""

DEPLOY_DIR="./tmp/deploy"
SECURITY_CHECK_FLAG=false

function unzipToDeploy() {
    if [ -f package.zip ]; then
        unzip package.zip -d ${DEPLOY_DIR}
        rm -rf ./package.zip
    fi
}


function checkSpecificMetadata() {
    if [[ -d ./tmp/deploy/force-app/main/default/$1 ]]; then
        for fi in ./tmp/deploy/force-app/main/default/$1/*; do
            fieldMetadata=$(cat "$fi")
            f=$(basename "$fi") && f=${f/.field-meta.xml/}
            if [[ $fieldMetadata == *"<field>User.Refresh_Token__c</field>"* ]]; then
                echo "❗Do not grant access to User.Refresh_Token__c, this is for internal system use only"
                echo ""
                echo "  • Issue Found: $1.$f"
                echo "________________________________________________________________________"
                echo ""
                SECURITY_CHECK_FLAG=true
            fi
        done
    fi
}

function checkBypassString() {
    if [[ -d ./tmp/deploy/force-app/main/default/$1 ]]; then
        for fi in ./tmp/deploy/force-app/main/default/$1/*; do
            fieldMetadata=$(cat "$fi")
            f=$(basename "$fi") && f=${f/.field-meta.xml/}
            if [[ $fieldMetadata != *"Salesforce_Library_Settings__c"* ]]; then
                echo "❗Bypass String NOT FOUND, Please Add Bypass String for Salesforce_Library_Settings__c to the issued file."
                echo ""
                echo "  • Issue Found: $1.$f"
                echo "________________________________________________________________________"
                echo ""
                SECURITY_CHECK_FLAG=true
            fi
        done
    fi
}

function checkValidationRuleBypass() {
    if [[ -d ./tmp/deploy/force-app/main/default/objects/*/validationRules ]]; then
        for fi in ./tmp/deploy/force-app/main/default/objects/*/validationRules/*; do
            fieldMetadata=$(cat "$fi")
            f=$(basename "$fi") && f=${f/.validationRule-meta.xml/}
            if [[ $fieldMetadata != *"Salesforce_Library_Settings__c.Disable_VRs__c"* ]]; then
                echo "❗Bypass String NOT FOUND,Please Add "'$Setup'".Salesforce_Library_Settings__c.Disable_VRs__c to Error Condition Formula."
                echo ""
                echo "  • Issue Found: $1.$f"
                echo "________________________________________________________________________"
                echo ""
                SECURITY_CHECK_FLAG=true
            fi
        done
    fi
}

# Make a deploy and destroy directories to check the profile & permission set changes
mkdir -p ${DEPLOY_DIR}

DIFF="git diff -z --ignore-all-space --name-only --diff-filter=d $(git tag --sort=-creatordate | grep ${BRANCH_NAME} | head -1)..HEAD ./force-app/"
DIFFENDCOMMAND="xargs -0 git archive -o package.zip HEAD"

echo "Diff statement on files changed: ${DIFF} | ${DIFFENDCOMMAND}"

CHANGED_FILES=$($DIFF | wc -w)
echo "Number of files changed: ${CHANGED_FILES}"

if [ "${CHANGED_FILES}" -gt "0" ]; then
    eval "$($DIFF | $DIFFENDCOMMAND)"
    unzipToDeploy
    echo ""
    echo ""
    echo "________________________________________________________________________"
    checkSpecificMetadata "permissionsets"
    checkSpecificMetadata "profiles"
    checkBypassString "flows"
    checkValidationRuleBypass "validationRules"
fi

if [[ $SECURITY_CHECK_FLAG == true ]]; then
    echo "❌ Security Check Failed with above issues"
    exit 1
else
    echo " ✅ Security Check Passed"
fi