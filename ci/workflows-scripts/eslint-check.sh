#!/bin/bash

set -euo pipefail

echo ""
echo "***************************************************************"
echo ""
echo "-------------------- Find files to be checked -----------------------"
echo ""

# Find all relevant files for ESLint check
CHANGED_FILES=$(gh api \
  -H "Accept: application/vnd.github+json" \
  "/repos/$REPO/pulls/$PR_NUMBER/files?per_page=100" \
  --paginate | jq -r '
    [.[] | select(.status != "removed") | .filename] |
    .[] | 
    select(
      test("^(force-app|knowledge-mgm)/main/(default|sf-lending)/lwc/.*\\.js$") and
      (test("\\.test\\.js$") | not)
    )
  ')

allFilesPath=""
while IFS= read -r file_path; do
  if [[ -f "$file_path" ]]; then
    echo "✅ Adding: $file_path"
    allFilesPath+="$file_path "
  else
    echo "⚠️  File not found locally (probably deleted): $file_path"
  fi
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
    echo "EOF"
  } >> "$GITHUB_OUTPUT"
fi