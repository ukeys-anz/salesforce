#!/bin/bash

set -euo pipefail

DEPLOY_DIR="./tmp/deploy"
CHECK_FLAG=false
SECURITY_FAILED_CHECK_FLAG=false

# Map file paths for lookup
declare -A FILE_MAP

echo ""
echo "*****************************************************"
echo ""
echo "-------- Find files to be checked ---------"
echo ""

# Clean and prepare deploy directory
rm -rf ./tmp
mkdir -p "$DEPLOY_DIR"

QUALITY_CHECK_FILE_NAME="quality-check-${REPO_NAME}-${PR_NUMBER}.txt"

if [[ ! -f "$QUALITY_CHECK_FILE_NAME" ]]; then
  echo "$QUALITY_CHECK_FILE_NAME could not be found"
  exit 1
fi

# Find all relevant files for Security checks
CHANGED_FILES=$(cat "$QUALITY_CHECK_FILE_NAME")

while IFS= read -r file_path; do
  echo "Copying: $file_path"
  CHECK_FLAG=true
  mkdir -p "$DEPLOY_DIR/$(dirname "$file_path")"
  cp "$file_path" "$DEPLOY_DIR/$file_path"
  FILE_MAP["$DEPLOY_DIR/$file_path"]="$file_path"
done <<< "$CHANGED_FILES"

# ========== SECURITY CHECK FUNCTIONS ==========

function checkSpecificMetadata() {
  local metadataType="$1"
  for BASE_DIR in force-app knowledge-mgm; do
    for dir in "$DEPLOY_DIR/$BASE_DIR"/main/*/"$metadataType"; do
      if [[ -d "$dir" ]]; then
        for fi in "$dir"/*; do
          fieldMetadata=$(cat "$fi")
          if [[ $fieldMetadata == *"<field>User.Refresh_Token__c</field>"* ]]; then
            original_path="${FILE_MAP[$fi]}"
            echo "❗Do not grant access to User.Refresh_Token__c"
            echo ""
            echo "  • Issue Found: ${original_path:-$fi}"
            echo "________________________________________________________________________"
            echo ""
            SECURITY_FAILED_CHECK_FLAG=true
          fi
        done
      fi
    done
  done
}

function checkRoleAndSubordinatesInternal() {
  local BASE_DIRS=("force-app" "knowledge-mgm")
  for BASE_DIR in "${BASE_DIRS[@]}"; do
    for SCOPE in "default" "sf-lending" "apis-apex" "generic-components"; do
      SEARCH_DIR="$DEPLOY_DIR/$BASE_DIR/main/$SCOPE"
      if [[ -d "$SEARCH_DIR" ]]; then
        while IFS= read -r -d '' file; do
          if grep -q "roleAndSubordinatesInternal" "$file"; then
            original_path="${FILE_MAP[$file]}"
            echo "❗ Do not use 'roleAndSubordinatesInternal'. Please change it with 'roleAndSubordinates'"
            echo ""
            echo "  • Issue Found: ${original_path:-$file}"
            echo "________________________________________________________________________"
            echo ""
            SECURITY_FAILED_CHECK_FLAG=true
          fi
        done < <(find "$SEARCH_DIR" -type f -print0)
      fi
    done
  done
}

function checkBypassString() {
  local metadataType="$1"
  for BASE_DIR in force-app knowledge-mgm; do
    for dir in "$DEPLOY_DIR/$BASE_DIR"/main/*/"$metadataType"; do
      if [[ -d "$dir" ]]; then
        for fi in "$dir"/*; do
          fieldMetadata=$(cat "$fi")
          if [[ $fieldMetadata != *"Salesforce_Library_Settings__c"* ]]; then
            original_path="${FILE_MAP[$fi]}"
            echo "❗Bypass String NOT FOUND. Please add Bypass String for Salesforce_Library_Settings__c to the file."
            echo ""
            echo "  • Issue Found: ${original_path:-$fi}"
            echo "________________________________________________________________________"
            echo ""
            SECURITY_FAILED_CHECK_FLAG=true
          fi
        done
      fi
    done
  done
}

function checkValidationRuleBypass() {
  for BASE_DIR in force-app knowledge-mgm; do
    for dir in "$DEPLOY_DIR/$BASE_DIR"/main/*/objects/*/validationRules; do
      if [[ -d "$dir" ]]; then
        for fi in "$dir"/*; do
          fieldMetadata=$(cat "$fi")
          if [[ $fieldMetadata != *"Salesforce_Library_Settings__c.Disable_VRs__c"* ]]; then
            original_path="${FILE_MAP[$fi]}"
            echo "❗Bypass String NOT FOUND. Please add "'$Setup'".Salesforce_Library_Settings__c.Disable_VRs__c to the Error Condition Formula."
            echo ""
            echo "  • Issue Found: ${original_path:-$fi}"
            echo "________________________________________________________________________"
            echo ""
            SECURITY_FAILED_CHECK_FLAG=true
          fi
        done
      fi
    done
  done
}

echo ""
echo "***************************************************************"
echo "                 Running Security Checks                       "
echo "***************************************************************"
echo ""

if [[ "$CHECK_FLAG" == true ]]; then
  checkSpecificMetadata "permissionsets" >> result.txt
  checkSpecificMetadata "profiles" >> result.txt
  checkBypassString "flows" >> result.txt
  checkValidationRuleBypass >> result.txt
  checkRoleAndSubordinatesInternal >> result.txt
else
  echo "No files copied — nothing to check."
fi

if [[ "$SECURITY_FAILED_CHECK_FLAG" == true ]]; then
  cat result.txt
  {
    echo "result<<EOF"
    echo "<details><summary>❌ Security Check Failed</summary><pre>"
    cat result.txt
    echo "</pre></details>"
    echo "EOF"
  } >> "$GITHUB_OUTPUT"
  echo ""
  echo "❌ Security Check Failed"
  exit 1
else
  echo "✅ Security Check Passed"
  {
    echo "result<<EOF"
    echo "<p>✅ Security check passed</p>"
    echo "EOF"
  } >> "$GITHUB_OUTPUT"
fi
