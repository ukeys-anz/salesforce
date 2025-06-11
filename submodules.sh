#!/bin/bash

source ".git-hooks/utils.sh"
ensure_gum_installed

echo ""

# Use gum to present the initial menu
choice=$(gum choose "Update existing submodule(s)" "Add a new submodule")
cancel_check
if [[ "$choice" == "Add a new submodule" ]]; then
  .git-hooks/add-submodule.sh
  exit 0
fi

echo ""
echo "${YELLOW}Updating submodule(s) in progress...${NC}"
echo ""

if [ ! -f .gitmodules ]; then
  echo "${YELLOW}! There is no submodule on this branch"
  exit 0
fi

# Get all submodule paths
SUBMODULES=$(grep -o 'path = [^ ]*' .gitmodules | cut -d ' ' -f 3)

if [ -z "$SUBMODULES" ]; then
  echo "${RED}No submodules found in .gitmodules${NC}"
  exit 1
fi

updateChoice=$(gum choose "Update all submodules" "Update specific submodule")
cancel_check
if [[ "$updateChoice" == "Update specific submodule" ]]; then
  submodulePath=$(echo "$SUBMODULES" | gum choose --no-limit)
  cancel_check
  if [[ -z "$submodulePath" ]]; then
    echo "${RED}! You should choose a submodule path to be updated...${NC}"
    exit 1
  fi
  SUBMODULES="$submodulePath"
fi

RUN_FROM_SUBMODULE_SCRIPT=true
# Call the update script for each selected submodule
for SUBMODULE_PATH in $SUBMODULES; do
  echo "${YELLOW}Updating $SUBMODULE_PATH in progress...${NC}"
  .git-hooks/update-submodules.sh "$SUBMODULE_PATH" "$RUN_FROM_SUBMODULE_SCRIPT"
done
