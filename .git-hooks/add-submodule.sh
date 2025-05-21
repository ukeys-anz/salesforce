#!/bin/bash

source ".git-hooks/utils.sh"
ensure_gum_installed

echo ""
echo "${YELLOW}-------------${NC}"

# Get URL and Path of the new submodule using gum
url=$(gum input --placeholder "Enter the URL of the new submodule" --prompt "URL: ")
cancel_check
path=$(gum input --placeholder "Enter the path for the new submodule" --prompt "Path: ")
cancel_check

# Ask if the user wants the latest tag from the default branch
latestTagFlag=$(echo -e "Yes\nNo" | gum choose --header="Do you want the latest tag from the default branch?")
cancel_check
LATEST_TAG_FLAG=false
if [[ "$latestTagFlag" == "Yes" ]]; then
  LATEST_TAG_FLAG=true
fi

# Adding the new submodule
rm -rf "$path"
git submodule add --force "$url" "$path"
git submodule update --init

# Change into the submodule directory
cd "$path" || exit

# Fetch all tags
git tag -d $(git tag) > /dev/null 2>&1
git fetch --all > /dev/null 2>&1 || exit

# Choose between using the latest tag or a specific tag
if [[ "$LATEST_TAG_FLAG" != true ]]; then
  branch=$(choose_tag_or_branch)
else
  branch=$(git tag --sort=-creatordate | head -1)
fi


# Checkout the chosen branch or tag
echo "${GREEN}Checking out branch/tag: $branch${NC}"
git checkout "$branch" || exit

# Get the commit hash related to the branch/tag
COMMIT_HASH=$(git rev-parse HEAD)
echo "${YELLOW}Checked out to sha: ${COMMIT_HASH} | tag/branch: ${branch}${NC}"

# Go back to the root folder
cd -

# Add branch/tag to .gitmodules
git config -f .gitmodules submodule."$path".branch "$branch"

# Success message
echo "${GREEN}✔ Submodule added and branch/tag updated successfully!${NC}"
echo "${YELLOW}-------------${NC}"
echo ""
