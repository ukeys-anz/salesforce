#!/bin/bash

set -euo pipefail

echo ""
echo "***************************************************************"
echo ""
echo "-------------------- Find files to be checked -----------------------"
echo ""

QUALITY_CHECK_FILE_NAME="quality-check-${REPO_NAME}-${PR_NUMBER}.txt"

if [[ ! -f "$QUALITY_CHECK_FILE_NAME" ]]; then
  echo "$QUALITY_CHECK_FILE_NAME could not be found"
  exit 1
fi

# Find all relevant files for Security checks
CHANGED_FILES=$(cat "$QUALITY_CHECK_FILE_NAME" | jq -R -s -r '
  split("\n")[] |
  select(
    test("^(force-app|knowledge-mgm)/main/(default|sf-lending|apis-apex|generic-components)/objects/")
  )
')

# Initialize flags
CHECK_FLAG=false
SYSL_FAILED_CHECK_FLAG=false

# Directory where Sysl-related files will be staged
DEPLOY_DIR="./tmp/sysl"
rm -rf "$DEPLOY_DIR"
mkdir -p "$DEPLOY_DIR"

# Copy relevant files
while IFS= read -r file_path; do
  echo "✅ Found and copying: $file_path"
  CHECK_FLAG=true
  mkdir -p "$DEPLOY_DIR/$(dirname "$file_path")"
  cp "$file_path" "$DEPLOY_DIR/$file_path"
done <<< "$CHANGED_FILES"

# ========== SYSL CHECK FUNCTIONS ==========

function checkFieldBusinessStatus() {
  fieldMetadata=$(cat "$1")
  f=$(basename "$1") && f=${f/.field-meta.xml}
  if [[ $fieldMetadata != *"<businessStatus>"* ]]; then
    echo "$2.$f : Missed businessStatus"
    SYSL_FAILED_CHECK_FLAG=true
  elif [[ $fieldMetadata == *"<businessStatus>Hidden</businessStatus>"* ]]; then
    echo "$2.$f : No Error ---> Hidden field"
  fi
}

function checkFieldMetadataInformation() {
  fieldMetadata=$(cat "$1")
  f=$(basename "$1") && f=${f/.field-meta.xml}
  if [[ $fieldMetadata != *Source* ]]; then echo "$2.$f : Missed complianceGroup | Source"; SYSL_FAILED_CHECK_FLAG=true; fi
  if [[ $fieldMetadata != *Integrity* ]]; then echo "$2.$f : Missed complianceGroup | Integrity"; SYSL_FAILED_CHECK_FLAG=true; fi
  if [[ $fieldMetadata != *Privacy* ]]; then echo "$2.$f : Missed complianceGroup | Privacy"; SYSL_FAILED_CHECK_FLAG=true; fi
  if [[ $fieldMetadata != *"<description>"* && $3 != *"$2.$f"* ]]; then echo "$2.$f : Missed description"; SYSL_FAILED_CHECK_FLAG=true; fi
  if [[ $fieldMetadata != *"<securityClassification>"* ]]; then echo "$2.$f : Missed securityClassification"; SYSL_FAILED_CHECK_FLAG=true; fi
}

function checkPantherIdInformation() {
  if [[ $3 != *"$2.$1"* ]]; then echo "$2.$1 : Missed pantherId"; SYSL_FAILED_CHECK_FLAG=true; fi
}

function syslCheck() {
  for ROOT_DIR in force-app knowledge-mgm; do
    for OBJECTS_DIR in "$DEPLOY_DIR/$ROOT_DIR"/main/*/objects; do
      if [[ -d "$OBJECTS_DIR" ]]; then
        for o in "$OBJECTS_DIR"/*; do
          if [[ -d "$o/fields" ]]; then
            objectName=$(basename "$o")
            pantherIdsField=$(node ./ci/workflows-scripts/sysl-check.js "$objectName" "pantherId")
            manualDescField=$(node ./ci/workflows-scripts/sysl-check.js "$objectName" "manualFieldDesc")
            for f in "$o"/fields/*; do
              checkBusinessStatus=$(checkFieldBusinessStatus "$f" "$objectName")
              if [[ "$checkBusinessStatus" != "" ]]; then echo "$checkBusinessStatus"; fi
              if [[ "$checkBusinessStatus" != *"Hidden"* ]]; then
                checkFieldMetadataInformation "$f" "$objectName" "$manualDescField"
                checkPantherIdInformation "$f" "$objectName" "$pantherIdsField"
              fi
            done
          fi
        done
      fi
    done
  done
}

echo ""
echo "***************************************************************"
echo "                  Running Sysl Checks                          "
echo "***************************************************************"
echo ""

if [[ "$CHECK_FLAG" == true ]]; then
  syslCheck > result.txt
fi

if [[ "$SYSL_FAILED_CHECK_FLAG" == true ]]; then
  cat result.txt
  {
    echo "result<<EOF"
    echo "<details><summary>❌ Sysl Check Failed</summary><pre>"
    cat result.txt
    echo "</pre></details>"
    echo "EOF"
  } >> "$GITHUB_OUTPUT"
  echo ""
  echo "❌ Sysl Check Failed"
  exit 1
else
  echo "✅ Sysl Check Passed"
  {
    echo "result<<EOF"
    echo "<p>✅ Sysl check passed</p>"
    echo "EOF"
  } >> "$GITHUB_OUTPUT"
fi
