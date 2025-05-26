#!/bin/sh

RED="\033[1;31m"
GREEN="\033[1;32m"
YELLOW="\033[1;33m"
NC="\033[0m"

# Path to check (you can modify this to be any directory for submodules, e.g., 'force-app/main')
base_path="force-app/main"

# Get all the directories inside the base_path
for folder in "$base_path"/*; do
    echo "Checking $folder..."
    if [ -d "$folder" ]; then
        # Check if the folder has any content using `git ls-tree`
        ls_output=$(git ls-tree HEAD "$folder")

        # If ls_output is empty, the folder is a cached submodule (i.e., no content in the current commit)
        if [ -z "$ls_output" ]; then
        echo "${RED} Removing cached submodule: $folder...${RED}"
        rm -rf "$folder"
        fi
    fi
done

echo ""
echo "${YELLOW}-------------${NC}"