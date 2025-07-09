#!/bin/bash

set -euo pipefail

echo ""
echo "***************************************************************"
echo ""
echo "----------- Detecting Changed Files ------------"
echo ""

if [[ -z "${PR_NUMBER:-}" || -z "${REPO:-}" || -z "${GITHUB_OUTPUT:-}" ]]; then
  echo "❌ Error: PR_NUMBER, REPO, or GITHUB_OUTPUT not set."
  exit 1
fi

# Get all changed files as a JSON array
CHANGED=$(gh pr view "$PR_NUMBER" --repo "$REPO" --json files --jq '[.files[].path]')

# Filter paths
SECURITY_FILES=$(echo "$CHANGED" | jq -r '.[] | select(startswith("force-app/") or startswith("knowledge-mgm/"))')
SYSL_FILES=$(echo "$CHANGED" | jq -r '.[] | select(test("^force-app/main/default/objects/") or test("^force-app/main/sf-lending/objects/") or test("^knowledge-mgm/main/default/objects/"))')
PMD_FILES=$(echo "$CHANGED" | jq -r '.[] | select(test("^force-app/main/default/") or test("^force-app/main/sf-lending/") or test("^knowledge-mgm/main/default/"))')
PRETTIER_FILES=$(echo "$CHANGED" | jq -r '.[] |
  select(
    test("^force-app/main/default/.*\\.(trigger|cls)$") or
    test("^force-app/main/default/lwc/.*\\.(js|html|css)$") or
    test("^force-app/main/default/aura/.*\\.(js|css|cmp)$") or

    test("^knowledge-mgm/main/default/.*\\.(trigger|cls)$") or
    test("^knowledge-mgm/main/default/lwc/.*\\.(js|html|css)$") or
    test("^knowledge-mgm/main/default/aura/.*\\.(js|css|cmp)$") or

    test("^force-app/main/sf-lending/.*\\.(trigger|cls)$") or
    test("^force-app/main/sf-lending/lwc/.*\\.(js|html|css)$") or
    test("^force-app/main/sf-lending/aura/.*\\.(js|css|cmp)$")
  )'
)
ESLINT_LWC_FILES=$(echo "$CHANGED" | jq -r '.[] |
  select(
    test("^force-app/main/default/lwc/.*\\.js$") or
    test("^force-app/main/sf-lending/lwc/.*\\.js$") or
    test("^knowledge-mgm/main/default/lwc/.*\\.js$")
  )'
)

echo ""
echo "==== Security-related files ===="
echo "$SECURITY_FILES"
echo "========"
echo ""
echo "==== Sysl-related files ===="
echo "$SYSL_FILES"
echo "========"
echo ""
echo "==== PMD-related files ===="
echo "$PMD_FILES"
echo "========"
echo ""
echo "==== Prettier-related files ===="
echo "$PRETTIER_FILES"
echo "========"
echo ""
echo "==== ESLint LWC-related files ===="
echo "$ESLINT_LWC_FILES"
echo "========"
echo ""

# Encode newline-separated strings to base64
SECURITY_ENCODED=$(echo "$SECURITY_FILES" | base64 | tr -d '\n')
SYSL_ENCODED=$(echo "$SYSL_FILES" | base64 | tr -d '\n')
PMD_ENCODED=$(echo "$PMD_FILES" | base64 | tr -d '\n')
PRETTIER_ENCODED=$(echo "$PRETTIER_FILES" | base64 | tr -d '\n')
ESLINT_LWC_ENCODED=$(echo "$ESLINT_LWC_FILES" | base64 | tr -d '\n')

# Set GitHub Actions outputs
{
  echo "security_changed_files=$SECURITY_ENCODED"
  echo "sysl_changed_files=$SYSL_ENCODED"
  echo "pmd_changed_files=$PMD_ENCODED"
  echo "prettier_changed_files=$PRETTIER_ENCODED"
  echo "eslint_lwc_changed_files=$ESLINT_LWC_ENCODED"
  echo "security_needed=$([[ -n "$SECURITY_FILES" ]] && echo true || echo false)"
  echo "sysl_needed=$([[ -n "$SYSL_FILES" ]] && echo true || echo false)"
  echo "pmd_needed=$([[ -n "$PMD_FILES" ]] && echo true || echo false)"
  echo "prettier_needed=$([[ -n "$PRETTIER_FILES" ]] && echo true || echo false)"
  echo "eslint_lwc_needed=$([[ -n "$ESLINT_LWC_FILES" ]] && echo true || echo false)"
} >> "$GITHUB_OUTPUT"

echo ""
echo "***************************************************************"
echo ""
