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

# Find all relevant files for XML Lint check
CHANGED_FILES=$(cat "$QUALITY_CHECK_FILE_NAME" | jq -R -s -r '
  split("\n")[] |
  select(
    test("\\.xml$") and
    ((
      contains(".js") or
      contains(".entitlementProcess") or
      contains(".md-meta") or
      contains("quickstart.xml") or
      contains("warning.xml") or
      contains("ouc-meta.xml")
    ) | not)
  )
')

allFiles=()
while IFS= read -r file_path; do
  echo "✅ Adding: $file_path"
  allFiles+=("$file_path")
done <<< "$CHANGED_FILES"

echo ""
echo "***************************************************************"
echo "                 Running XML Linter Check                      "
echo "***************************************************************"
echo ""

if [[ ${#allFiles[@]} -eq 0 ]]; then
  echo "⚠️ No files to check. Skipping XML Lint."
  {
    echo "result<<EOF"
    echo "<p>✅ XML Lint check passed</p>"
    echo "EOF"
  } >> "$GITHUB_OUTPUT"
  exit 0
fi

# ========== XML Lint CHECK FUNCTION ==========
xml_lint_failed=false

function checkXMLLint() {
  # Convert to JSON string
  tmpfile=$(mktemp)
  printf '%s\n' "${allFiles[@]}" | jq -R . | jq -s . > "$tmpfile"
  failedXMLLintFiles=$(node ci/workflows-scripts/xml-lint.js "$tmpfile")
  if [[ "$failedXMLLintFiles" != '' ]];then
    xml_lint_failed=true
  fi
}

echo "⚙️ Running XML Linting Checker..."
checkXMLLint

if [[ "$xml_lint_failed" == "true" ]]; then
  echo "XML Lint failed on the following files:"
  echo "$failedXMLLintFiles"
  {
      echo "result<<EOF"
      echo "<details><summary>❌ XML Lint check failed</summary><pre>"
      echo "$failedXMLLintFiles"
      echo ""
      echo "* Run: npm run xml:lint -- --fix --gitbase=baseRef --compare=HEAD to fix them"
      echo "* baseRef should be changed to your Base Ref"
      echo "</pre></details>"
      echo "EOF"
  } >> "$GITHUB_OUTPUT"
  echo ""
  echo "❌ XML Lint check failed."
  exit 1
else
  echo "✅ XML Lint check passed"
  {
      echo "result<<EOF"
      echo "<p>✅ XML Lint check passed</p>"
      echo "EOF"
  } >> "$GITHUB_OUTPUT"
fi
