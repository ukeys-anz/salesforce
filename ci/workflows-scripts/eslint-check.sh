#!/bin/bash

set -euo pipefail

echo ""
echo "***************************************************************"
echo ""
echo "-------------------- Find files to be checked -----------------------"
echo ""

# Find all relevant files for ESLint check
QUALITY_CHECK_FILE_NAME="quality-check-${REPO_NAME}-${PR_NUMBER}.txt"

if [[ ! -f "$QUALITY_CHECK_FILE_NAME" ]]; then
  echo "$QUALITY_CHECK_FILE_NAME could not be found"
  exit 1
fi

# Find all relevant non-test LWC JS files
CHANGED_FILES=$(cat "$QUALITY_CHECK_FILE_NAME" | jq -R -s -r '
  split("\n")[] |
  select(
    test("^(force-app|knowledge-mgm)/main/(default|sf-lending)/lwc/.*\\.js$") and
    (test("\\.test\\.js$") | not)
  )
')

allFilesPath=""
while IFS= read -r file_path; do
  echo "✅ Adding: $file_path"
  allFilesPath+="$file_path "
done <<< "$CHANGED_FILES"

echo ""
echo "***************************************************************"
echo "                    Running ESLint Check                       "
echo "***************************************************************"
echo ""

# Skip if there is no relevant files.
if [[ ! -n "$allFilesPath" ]]; then
  echo "✅ ESLint check passed"
    {
      echo "result<<EOF"
      echo "<p>✅ ESLint check passed</p>"
      echo "EOF"
    } >> "$GITHUB_OUTPUT"
  echo ""
  exit 0
fi

echo "⚙️ Running ESLint with .lwc-eslintrc.json..."
eslint_failed=false

eslint_output_file="$RUNNER_TEMP/eslint_output.log"
npx eslint $allFilesPath -c .lwc-eslintrc.json > "$eslint_output_file" 2>&1 || eslint_failed=true

if [[ "$eslint_failed" == "true" ]]; then
  cat "$eslint_output_file"
  {
    echo "result<<EOF"
    echo "<details><summary>❌ ESLint check failed</summary><pre>"
    sed 's/`//g' "$eslint_output_file"
    echo "</pre></details>"
    echo "EOF"
  } >> "$GITHUB_OUTPUT"
  echo ""
  echo "❌ ESLint check failed."
  exit 1
else
  echo "✅ ESLint check passed"
  {
    echo "result<<EOF"
    echo "<p>✅ ESLint check passed</p>"
    echo "EOF"
  } >> "$GITHUB_OUTPUT"
fi