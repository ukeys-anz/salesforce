#!/bin/bash

# Color helpers
GREEN=$(tput setaf 2)
RED=$(tput setaf 1)
YELLOW=$(tput setaf 3)
NC=$(tput sgr0)

REPO_ROOT=$(git rev-parse --show-toplevel)
cp "$REPO_ROOT/.gitmodules" "$REPO_ROOT/.gitmodules.bak"

# Define your cleanup function
cleanup_on_exit() {
  if [[ $? -ne 0 ]]; then
    echo -e "${RED}✖ Cancelled or exited.${NC}"
    REPO_ROOT=$(git rev-parse --show-toplevel)
    cd "$REPO_ROOT" || exit
    if [[ -n "$SUBMODULE_PATH" ]]; then
      echo -e "${YELLOW}↩ Reverting submodule changes for '$SUBMODULE_PATH'...${NC}"

      if [ -f ".gitmodules.bak" ]; then
        mv ".gitmodules.bak" ".gitmodules"
        .git-hooks/update-submodules.sh "$SUBMODULE_PATH"
        echo -e "${YELLOW}✔ .gitmodules reverted.${NC}"
      fi
    fi
    rm -rf .gitmodules.bak
    exit 1
  fi
}

# Trap Ctrl+C or script exit
trap cleanup_on_exit SIGINT SIGTERM EXIT

# Cancel check for gum (Escape key)
cancel_check() {
  if [[ $? -ne 0 ]]; then
    echo ""
    echo -e "${RED}✖ Cancelled by user (Escape pressed).${NC}"

    REPO_ROOT=$(git rev-parse --show-toplevel)
    cd "$REPO_ROOT" || exit
    if [[ -n "$SUBMODULE_PATH" ]]; then
      echo -e "${YELLOW}↩ Reverting submodule changes for '$SUBMODULE_PATH'...${NC}"

      # Restore .gitmodules from backup if available
      if [ -f "$REPO_ROOT/.gitmodules.bak" ]; then
        mv ".gitmodules.bak" ".gitmodules"
        echo -e "${YELLOW}✔ .gitmodules reverted.${NC}"
      else
        echo -e "${RED}⚠ .gitmodules backup not found at $REPO_ROOT/.gitmodules.bak${NC}"
      fi

      # Reset submodule
      for SUBMODULE_PATH in $SUBMODULES; do
        .git-hooks/update-submodules.sh "$SUBMODULE_PATH"
      done
      echo -e "${YELLOW}✔ Submodule '$SUBMODULE_PATH' reverted to original commit.${NC}"
    fi
    rm -rf .gitmodules.bak
    kill -INT $$  # Immediately kill script execution
    exit 1
  fi
}


# Gum auto-installer (macOS or Linux)
ensure_gum_installed() {
  if ! command -v gum >/dev/null 2>&1; then
    echo "🔧 'gum' is not installed. Installing now..."

    if [[ "$OSTYPE" == "darwin"* ]]; then
      if command -v brew >/dev/null 2>&1; then
        brew install gum
      else
        echo "❌ Homebrew not found. Install it first: https://brew.sh/"
        exit 1
      fi

    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
      if command -v curl >/dev/null 2>&1; then
        curl -sSf https://gum.install.sh | sh
      else
        echo "❌ curl is required. Install curl first."
        exit 1
      fi

    else
      echo "❌ Unsupported OS. Install gum manually: https://github.com/charmbracelet/gum"
      exit 1
    fi

    echo "✅ 'gum' installed successfully!"
  fi
}

# Prompt for tag or branch (shared logic)
choose_tag_or_branch() {
  local selected
  tagOrBranch=$(echo -e "Tag\nBranch\nCurrent version" | gum choose --header="How would you like to update the submodule?")
  cancel_check
  [[ -z "$tagOrBranch" ]] && cancel_check

  if [[ "$tagOrBranch" == "Current version" ]]; then
    currentBranch="$BRANCH"
    if [[ -z "$currentBranch" ]]; then
      echo "${RED}✖ No branch configured in .gitmodules for submodule '$SUBMODULE_PATH'.${NC}"
      exit 1
    fi
    echo "$currentBranch"
    return
  fi

  if [[ "$tagOrBranch" == "Tag" ]]; then
    tags=$(git tag --sort=-creatordate | head -n 10)
    if [ -z "$tags" ]; then
      selected=$(gum input --placeholder "Enter tag name manually" --prompt "Enter the tag name: ")
      cancel_check
      [[ -z "$selected" ]] && cancel_check
    else
      selected=$(echo -e "$tags\nOther" | gum choose --header="Choose a tag")
      cancel_check
      [[ -z "$selected" ]] && cancel_check
      if [[ "$selected" == "Other" ]]; then
        selected=$(gum input --placeholder "Enter tag name manually" --prompt "Enter the tag name: ")
        cancel_check
        [[ -z "$selected" ]] && cancel_check
      fi
    fi
  else
    branches=$(git branch -r | sed 's/origin\///' | grep -v HEAD | sort | uniq | head -n 10)
    if [ -z "$branches" ]; then
      selected=$(gum input --placeholder "Enter branch name manually" --prompt "Enter the branch name: ")
      cancel_check
      [[ -z "$selected" ]] && cancel_check
    else
      selected=$(echo -e "$branches\nOther" | gum choose --header="Choose a branch")
      cancel_check
      [[ -z "$selected" ]] && cancel_check
      if [[ "$selected" == "Other" ]]; then
        selected=$(gum input --placeholder "Enter branch name manually" --prompt "Enter the branch name: ")
        cancel_check
        [[ -z "$selected" ]] && cancel_check
      fi
    fi
  fi

  echo "$selected" | xargs
}
