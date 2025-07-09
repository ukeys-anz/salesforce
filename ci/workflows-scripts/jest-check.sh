#!/bin/bash

set -euo pipefail

CHANGED_FILES_BASE64="$1"
CHECK_JEST_FLAG=false

echo ""
echo "***************************************************************"
echo ""
echo "-------------------- Find files to be checked -----------------------"
echo ""

# Decode the list of changed files (newline-separated)
CHANGED_FILES=$(echo "$CHANGED_FILES_BASE64" | base64 --decode)

allFilesPath=""
while IFS= read -r file_path; do
  if [[ -f "$file_path" ]]; then
    echo "✅ Adding: $file_path"
    CHECK_JEST_FLAG=true
    allFilesPath+="$file_path "
  else
    echo "⚠️ File not found locally (probably deleted): $file_path"
  fi
done <<< "$CHANGED_FILES"

# Remove trailing space
allFilesPath="${allFilesPath%" "}"

echo ""
echo "***************************************************************"
echo "                  Running Jest Check                           "
echo "***************************************************************"
echo ""

if [[ "${CHECK_JEST_FLAG}" != "true" ]]; then
  echo "⚠️ No jest files to check. Skipping jest."
  {
    echo "result<<EOF"
    echo "<p>✅ Jest check passed</p>"
    echo "EOF"
  } >> "$GITHUB_OUTPUT"
  exit 0
fi

echo "⚙️ Running Jest..."
jest_failed=false

# Run Jest
if ! npx jest --coverage --silent --no-warnings > jest.txt 2>&1; then
  jest_failed=true
fi

cat jest.txt

if [[ "$jest_failed" == true ]]; then
  {
    echo "result<<EOF"
    echo "<details><summary>❌ Jest check failed</summary><pre>"

    # Extract output from summary onward, strip ANSI, escape for HTML
    sed -n '/Summary of all failing tests/,$p' jest.txt \
      | grep '^FAIL' \
      | sed -E 's/ *\([^)]*s\) *//g'

    echo "</pre></details>"
    echo "EOF"
  } >> "$GITHUB_OUTPUT"
  echo ""
  echo "❌ Jest check failed."
  exit 1
else
  echo "✅ Jest check passed"
  {
    echo "result<<EOF"
    echo "<p>✅ Jest check passed</p>"
    echo "EOF"
  } >> "$GITHUB_OUTPUT"
fi