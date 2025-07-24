#!/bin/bash

set -euo pipefail

echo ""
echo "***************************************************************"
echo "                  Running Jest Check                           "
echo "***************************************************************"
echo ""

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