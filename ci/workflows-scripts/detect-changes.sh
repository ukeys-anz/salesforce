#!/bin/bash

set -euo pipefail

echo ""
echo "***************************************************************"
echo ""
echo "----------- Detecting Which Check To Run ------------"
echo ""

if [[ -z "${PR_NUMBER:-}" || -z "${REPO:-}" || -z "${GITHUB_OUTPUT:-}" ]]; then
  echo "❌ Error: PR_NUMBER, REPO, or GITHUB_OUTPUT not set."
  exit 1
fi

# Find a json files of salesforce changed files 
# Filter to not bring removed files.
CHANGED_JSON=$(gh api \
  -H "Accept: application/vnd.github+json" \
  "/repos/$REPO/pulls/$PR_NUMBER/files?per_page=100" \
  --paginate | jq '
    [ .[] 
      | select(.status != "removed") 
      | .filename 
      | select(test("^(force-app|knowledge-mgm)/main/(default|sf-lending)/"))
    ]
  ')

# PMD | Jest | Security: Any file in the relevant file paths
SECURITY_PMD_JEST_NEEDED=$(echo "$CHANGED_JSON" | jq 'length > 0')


# SYSL: Any object file
SYSL_NEEDED=$(echo "$CHANGED_JSON" | jq 'any(.[]; test("/objects/"))')


# ESLint: Any LWC JS files excluding *.test.js
ESLINT_LWC_NEEDED=$(echo "$CHANGED_JSON" | jq 'any(.[]; test("/lwc/.*\\.js$") and (test("\\.test\\.js$") | not))')


# Prettier: True if ESLint needed, else check other source file patterns
if [[ "$ESLINT_LWC_NEEDED" == "true" ]]; then
  PRETTIER_NEEDED=true
else
  # Prettier: Any trigger, class, aura, or lwc source files
  PRETTIER_NEEDED=$(echo "$CHANGED_JSON" | jq 'any(.[]; 
    test("\\.(trigger|cls)$") or
    test("/lwc/.*\\.(js|html|css)$") or
    test("/aura/.*\\.(js|css|cmp)$")
  )')
fi

# Debugs
echo ""
echo "====> Security & Jest & PMD should run: $SECURITY_PMD_JEST_NEEDED"
echo "====> Sysl-related should run: $SYSL_NEEDED"
echo "====> Prettier should run: $PRETTIER_NEEDED"
echo "====> ESLint LWC should run: $ESLINT_LWC_NEEDED"
echo ""

# Set GitHub Actions outputs
{
  echo "security_pmd_jest_needed=$SECURITY_PMD_JEST_NEEDED"
  echo "sysl_needed=$SYSL_NEEDED"
  echo "prettier_needed=$PRETTIER_NEEDED"
  echo "eslint_lwc_needed=$ESLINT_LWC_NEEDED"
} >> "$GITHUB_OUTPUT"

echo ""
echo "***************************************************************"
echo ""
