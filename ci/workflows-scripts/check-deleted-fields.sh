#!/bin/bash
set -euo pipefail


echo ""
echo "***************************************************************"
echo "                     Check Field Removal                       "
echo "***************************************************************"
echo ""

echo "🔍 Checking for deleted *.field-meta.xml files between $BASE_SHA and $HEAD_SHA"
git fetch origin $BASE_SHA || true

# --------------------------
# Function to check deletions between two SHAs in a given path
# --------------------------
check_deleted_fields() {
  local base_sha=$1
  local head_sha=$2
  local path_prefix=$3
  local deleted_files=""

  deleted_files=$(git diff --name-status "$base_sha" "$head_sha" | grep '^D' | awk '{print $2}' | grep '\.field-meta\.xml$' || true)

  # Prepend submodule path if needed
  if [[ -n "$path_prefix" && -n "$deleted_files" ]]; then
    deleted_files=$(echo "$deleted_files" | sed "s|^|$path_prefix/|")
  fi

  echo "$deleted_files"
}

# --------------------------
# Parent Repo Check
# --------------------------
echo "🧩 Checking parent repository..."
deleted_fields_parent=$(check_deleted_fields "$BASE_SHA" "$HEAD_SHA" "")
any_deleted=false

if [[ -n "$deleted_fields_parent" ]]; then
  echo "$deleted_fields_parent"
  any_deleted=true
else
  echo "✅ No deleted field files in parent repo"
fi

# --------------------------
# Submodules Check
# --------------------------
echo "📦 Checking submodules..."
submodules=$(git config --file .gitmodules --get-regexp path | awk '{ print $2 }' || true)
deleted_fields_submodules=""

for submodule_path in $submodules; do
  echo "🔁 Submodule: $submodule_path"

  # Get base commit for submodule from parent repo
  base_commit=$(git ls-tree "$BASE_SHA" "$submodule_path" | awk '{print $3}' || true)

  if [[ -z "$base_commit" ]]; then
    echo "⚠️ Could not find base commit for $submodule_path — skipping"
    continue
  fi

  cd "$submodule_path"
  git fetch origin
  current_commit=$(git rev-parse HEAD)

  deleted=$(check_deleted_fields "$base_commit" "$current_commit" "$submodule_path")

  if [[ -n "$deleted" ]]; then
    echo "$deleted"
    any_deleted=true
    deleted_fields_submodules="${deleted_fields_submodules}"$'\n'"$deleted"
  else
    echo "✅ No deleted field files in $submodule_path"
  fi

  cd - > /dev/null
done

# Cleanup newlines
deleted_fields_parent=$(echo "$deleted_fields_parent" | sed '/^\s*$/d')
deleted_fields_submodules=$(echo "$deleted_fields_submodules" | sed '/^\s*$/d')

# --------------------------
# Output for PR Comment
# --------------------------
echo ""
echo "📝 Result Summary"
echo "======================"

echo "deleted_fields_flag=$any_deleted" >> "$GITHUB_OUTPUT"

echo -e "<h2>🔍🗑️ Field Removal Checker</h2>" > deleted_fields_comment.html

if [[ "$any_deleted" == "true" ]]; then
  echo "❌ fields were deleted."

  echo -e "<details><summary>⚠️ Field metadata files were deleted in this PR</summary><pre>" >> deleted_fields_comment.html

  echo -e "<p>🧩 Parent Repo:</p>" >> deleted_fields_comment.html
  if [[ -n "$deleted_fields_parent" ]]; then
    echo "$deleted_fields_parent" >> deleted_fields_comment.html
  else
    echo "<p>No deleted files in parent repo.</p>" >> deleted_fields_comment.html
  fi
  echo "<p></p>" >> deleted_fields_comment.html
  echo -e "<p>📦 Submodules:</p>" >> deleted_fields_comment.html
  if [[ -n "$deleted_fields_submodules" ]]; then
    echo "$deleted_fields_submodules" >> deleted_fields_comment.html
  else
    echo "<p>No deleted files in submodules.</p>" >> deleted_fields_comment.html
  fi

  if [[ "$TRIGGERED_EVENT" == 'pull_request' ]];then
    echo "<p>❗ Get Lead Engineers approval for field removal ❗</p>" >> deleted_fields_comment.html
  fi

  echo "</pre></details>" >> deleted_fields_comment.html

  echo ""
  cat deleted_fields_comment.html

else
  echo -e "<p>✅ No deleted fields found</p>" >> deleted_fields_comment.html
  echo "✅ No deleted fields detected."
fi
