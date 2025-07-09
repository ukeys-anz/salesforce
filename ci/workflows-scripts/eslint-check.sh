#!/bin/bash

set -euo pipefail

CHANGED_FILES_BASE64="$1"
CHECK_LWC_FLAG=false

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
    echo "Adding: $file_path"
    CHECK_LWC_FLAG=true
    allFilesPath+="$file_path "
  else
    echo "⚠️ File not found locally (probably deleted): $file_path"
  fi
done <<< "$CHANGED_FILES"

echo ""
echo "***************************************************************"
echo "                    Running ESLint Check                       "
echo "***************************************************************"
echo ""

if [[ "${CHECK_LWC_FLAG}" != "true" ]]; then
  echo "⚠️ No LWC files to lint. Skipping ESLint."
  {
    echo "result<<EOF"
    echo "<p>✅ ESLint check passed</p>"
    echo "<br/>"
    echo "EOF"
  } >> "$GITHUB_OUTPUT"
  exit 0
fi

echo "⚙️ Running ESLint with .lwc-eslintrc.json..."
eslint_failed=false

# Capture ESLint output
eslint_output_file="$RUNNER_TEMP/eslint_output.log"
npx eslint ${allFilesPath} -c .lwc-eslintrc.json > "$eslint_output_file" 2>&1 || eslint_failed=true

# Fail the step if ESLint failed
if [[ "$eslint_failed" == "true" ]]; then
  # Output content to console
  cat "$eslint_output_file"

  # Send formatted output back to GitHub Actions
  {
    echo "result<<EOF"
    echo "<details><summary>❌ ESLint check failed</summary><pre>"
    cat "$eslint_output_file"
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
    echo "<br/>"
    echo "EOF"
  } >> "$GITHUB_OUTPUT"
fi
