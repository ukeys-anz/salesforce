#!/bin/bash

set -euo pipefail

echo ""
echo "***************************************************************"
echo ""
echo "-------------------- Find files to be checked -----------------------"
echo ""

# Find all relevant files for PMD check
CHANGED_FILES=$(gh api \
  -H "Accept: application/vnd.github+json" \
  "/repos/$REPO/pulls/$PR_NUMBER/files?per_page=100" \
  --paginate | jq -r '
    [.[] | select(.status != "removed") | .filename] |
    .[] | 
    select(test("^(force-app|knowledge-mgm)/main/(default|sf-lending)/"))
  ')

allFiles=()
while IFS= read -r file_path; do
  if [[ -f "$file_path" ]]; then
    echo "✅ Adding: $file_path"
    allFiles+=("$file_path")
  else
    echo "⚠️ File not found locally (probably deleted): $file_path"
  fi
done <<< "$CHANGED_FILES"

echo ""
echo "***************************************************************"
echo "                  Running PMD Checks                           "
echo "***************************************************************"
echo ""

if [[ ${#allFiles[@]} -eq 0 ]]; then
  echo "⚠️ No files to check. Skipping PMD."
  {
    echo "result<<EOF"
    echo "<p>✅ PMD check passed</p>"
    echo "EOF"
  } >> "$GITHUB_OUTPUT"
  exit 0
fi

VALIDATION_FAILED=false
WARNING_FAILED=false

if ! ./pmd-bin-7.2.0/bin/pmd check \
      -R ./ci/rulesets/apex/quickstart.xml \
      --no-progress \
      -f summaryhtml \
      --cache ../pmd-cache \
      -d "${allFiles[@]}" > ./pmdValidationReport.html 2>&1; then
  VALIDATION_FAILED=true
fi

if ! ./pmd-bin-7.2.0/bin/pmd check \
      -R ./ci/rulesets/apex/warning.xml \
      --no-progress \
      -f summaryhtml \
      --cache ../pmd-cache \
      -d "${allFiles[@]}" > ./pmdWarningReport.html 2>&1; then
  WARNING_FAILED=true
fi

if [[ "$VALIDATION_FAILED" == "true" ]]; then
  sed 's+Summary+❌ PMD Validation Report ❌+g' ./pmdValidationReport.html > ./pmdReport.html
  echo "<br/>" >> ./pmdReport.html
fi

if [[ "$WARNING_FAILED" == "true" ]]; then
  sed 's+Summary+❗ PMD Warning Report ❗+g' ./pmdWarningReport.html >> ./pmdReport.html
fi

if [[ "$VALIDATION_FAILED" == "true" || "$WARNING_FAILED" == "true" ]]; then
  # Clean up formatting
  sed -i 's+<title>PMD</title>++g' ./pmdReport.html || true
  sed -i 's+PMD report++g' ./pmdReport.html || true
  sed -i 's+Problems found++g' ./pmdReport.html || true
  sed -i 's+No adapter exists.*++g' ./pmdReport.html || true
  
  cat ./pmdReport.html
  
  # Set result as GITHUB_OUTPUT
  {
    echo "result<<EOF"
    echo "<details><summary>⚠️ PMD Check Consideration</summary><pre>"
    cat ./pmdReport.html
    echo "</pre></details>"
    echo "EOF"
  } >> "$GITHUB_OUTPUT"
  echo ""
  if [[ "$VALIDATION_FAILED" == "true" ]]; then
    exit 1
  fi
else
  echo "✅ PMD check passed"
  {
    echo "result<<EOF"
    echo "<p>✅ PMD check passed</p>"
    echo "EOF"
  } >> "$GITHUB_OUTPUT"
fi
