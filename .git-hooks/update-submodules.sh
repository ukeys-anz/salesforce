#!/bin/bash

source ".git-hooks/utils.sh"
ensure_gum_installed

SUBMODULE_PATH="$1"
RUN_FROM_SUBMODULE_SCRIPT="$2"

echo ""
echo "${YELLOW}-------------${NC}"
echo "${GREEN}Updating submodule: $SUBMODULE_PATH${NC}"

if [ ! -f .gitmodules ]; then
  rm -rf "$SUBMODULE_PATH"
  echo "${YELLOW}! No submodule: $SUBMODULE_PATH on this branch${NC}"
  exit 0
fi

# Extract branch from .gitmodules
found_submodule=false
while IFS= read -r line; do
  if [[ "$line" == *"path = $SUBMODULE_PATH"* ]]; then
    found_submodule=true
  fi

  if [ "$found_submodule" = true ] && [[ "$line" == *"branch ="* ]]; then
    BRANCH=$(echo "$line" | cut -d '=' -f 2 | xargs)
    echo "#$line"
    found_submodule=false
  else
    echo "$line"
  fi
done < .gitmodules > .gitmodules.tmp && mv .gitmodules.tmp .gitmodules

[[ -z "$BRANCH" ]] && {
  echo "${RED}! No branch found for submodule $SUBMODULE_PATH${NC}"
  exit 0
}

if [[ -z $(ls "$SUBMODULE_PATH") ]]; then
  git submodule update --init
fi

cd "$SUBMODULE_PATH" || exit
git tag -d $(git tag) > /dev/null 2>&1
git fetch --all > /dev/null 2>&1 || exit

if [[ "$RUN_FROM_SUBMODULE_SCRIPT" == "true" ]]; then
  echo "${YELLOW}Fetching tags/branches for submodule...${NC}"
  git checkout "$BRANCH" || exit
  echo "${YELLOW}Latest tag: $(git tag --sort=-creatordate | head -1)${NC}"
  BRANCH=$(choose_tag_or_branch)
fi

echo "${GREEN}Checking out branch/tag: $BRANCH${NC}"
git fetch --tags || exit
git checkout "$BRANCH" || exit
git pull origin "$BRANCH" || exit

COMMIT_HASH=$(git rev-parse HEAD)
echo "${YELLOW}Checked out to sha: ${COMMIT_HASH} | tag/branch: ${BRANCH}${NC}"
cd - > /dev/null 2>&1 || exit

# Uncomment the branch line in .gitmodules and update to the selected tag/branch
found_submodule=false
while IFS= read -r line; do
  if [[ "$line" == *"path = $SUBMODULE_PATH"* ]]; then
    found_submodule=true
  fi

  if [ "$found_submodule" = true ] && [[ "$line" == *"#"* ]]; then
    echo -e "\tbranch = $BRANCH"
  else
    echo "$line"
  fi
done < .gitmodules > .gitmodules.tmp && mv .gitmodules.tmp .gitmodules

echo ""
echo "${GREEN}✔ Submodule '$SUBMODULE_PATH' updated to '$BRANCH' successfully!${NC}"
echo "${YELLOW}-------------${NC}"
echo ""
