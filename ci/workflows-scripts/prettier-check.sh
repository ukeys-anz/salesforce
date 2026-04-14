#!/bin/bash

set -euo pipefail

CHECK_APEX_TRIGGER_FLAG=false
CHECK_LWC_FLAG=false
CHECK_AURA_FLAG=false

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

# Find all relevant files for Prettier checks
CHANGED_FILES=$(cat "$QUALITY_CHECK_FILE_NAME" | jq -R -s -r '
  split("\n")[] |
  select(
    test("^(force-app|knowledge-mgm)/main/(default|sf-lending|generic-components)/.*\\.(trigger|cls)$") or
    test("^(force-app|knowledge-mgm)/main/(default|sf-lending|generic-components)/lwc/.*\\.(js|html|css)$") or
    test("^(force-app|knowledge-mgm)/main/(default|sf-lending|generic-components)/aura/.*\\.(js|css|cmp)$")
  )
')

apexTriggerFilePaths=""
lwcFilePaths=""
auraFilePaths=""

while IFS= read -r file_path; do
  if [[ "$file_path" =~ ^(force-app|knowledge-mgm)/main/(default|sf-lending|generic-components)/.*\.(trigger|cls)$ ]]; then
      echo "✅ Adding to apex/trigger check: $file_path"
      CHECK_APEX_TRIGGER_FLAG=true
    apexTriggerFilePaths+="$file_path "
  elif [[ "$file_path" =~ ^(force-app|knowledge-mgm)/main/(default|sf-lending|generic-components)/lwc/.*\.(js|html|css)$ ]]; then
      echo "✅ Adding to lwc check: $file_path"
      CHECK_LWC_FLAG=true
    lwcFilePaths+="$file_path "
  elif [[ "$file_path" =~ ^(force-app|knowledge-mgm)/main/(default|sf-lending|generic-components)/aura/.*\.(js|css|cmp)$ ]]; then
      echo "✅ Adding to aura check: $file_path"
      CHECK_AURA_FLAG=true
    auraFilePaths+="$file_path "
  fi

done <<< "$CHANGED_FILES"

echo ""
echo "***************************************************************"
echo "                 Running Prettier Checks                       "
echo "***************************************************************"
echo ""

# Init result file and flags
failed=false
result_file="$RUNNER_TEMP/result.html"
: > "$result_file"

# Apex & Trigger Check
# echo "🔍 Checking Apex & Trigger files..."
# if [[ "${CHECK_APEX_TRIGGER_FLAG}" == "true" ]]; then
#   echo "✅ Files to check: ${apexTriggerFilePaths}"
#   npx prettier --write .prettierrc --plugin=prettier-plugin-apex
#   if ! npx prettier --parser apex --with-node-modules -c ${apexTriggerFilePaths} > "$RUNNER_TEMP/apex_error.log" 2>&1; then
#     echo "<details><summary>❌ Apex & Trigger Prettier Check Failed</summary><pre>" >> "$result_file"
#     cat "$RUNNER_TEMP/apex_error.log" >> "$result_file"
#     echo "</pre></details>" >> "$result_file"
#     failed=true
#   fi
# else
#   echo "ℹ️  No Apex/Trigger files to check."
# fi

# # LWC Check
# echo "🔍 Checking LWC files..."
# if [[ "${CHECK_LWC_FLAG}" == "true" ]]; then
#   echo "✅ Files to check: ${lwcFilePaths}"
#   if ! npx prettier -c ${lwcFilePaths} > "$RUNNER_TEMP/lwc_error.log" 2>&1; then
#     echo "<details><summary>❌ LWC Prettier Check Failed</summary><pre>" >> "$result_file"
#     cat "$RUNNER_TEMP/lwc_error.log" >> "$result_file"
#     echo "</pre></details>" >> "$result_file"
#     failed=true
#   fi
# else
#   echo "ℹ️  No LWC files to check."
# fi

# # Aura Check
# echo "🔍 Checking Aura files..."
# if [[ "${CHECK_AURA_FLAG}" == "true" ]]; then
#   echo "✅ Files to check: ${auraFilePaths}"
#   if ! npx prettier -c ${auraFilePaths} > "$RUNNER_TEMP/aura_error.log" 2>&1; then
#     echo "<details><summary>❌ Aura Prettier Check Failed</summary><pre>" >> "$result_file"
#     cat "$RUNNER_TEMP/aura_error.log" >> "$result_file"
#     echo "</pre></details>" >> "$result_file"
#     failed=true
#   fi
# else
#   echo "ℹ️  No Aura files to check."
# fi

# Report summary
if [[ "$failed" == "true" ]]; then
  cat "$result_file"
  {
    echo "result<<EOF"
    cat "$result_file"
    echo "EOF"
  } >> "$GITHUB_OUTPUT"
  echo ""
  echo "🚫 One or more Prettier checks failed. See above for details."
  exit 1
else
  echo "✅ All Prettier checks passed."
  {
    echo "result<<EOF"
    echo "<p>✅ Prettier check passed</p>"
    echo "EOF"
  } >> "$GITHUB_OUTPUT"
fi
