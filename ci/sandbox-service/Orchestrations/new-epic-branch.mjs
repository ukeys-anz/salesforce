// Create new epic branch for new epic sandbox & create a tag for it

/// Import different functions
import {
  createEpicBranch,
  fetchEverything,
  createTag
} from "../Services/create-epic.mjs";
////////////////

/// Hardcoded username input
NEW_EPIC_BRANCH_NAME = "xxxx";
////////////////

/// functions

const createNewEpicBranchAndTag = (epicBranchName) => {
  createEpicBranch(epicBranchName);
  fetchEverything();
  createTag(epicBranchName);
};
////////////////

/// Run Orchestration

createNewEpicBranchAndTag(NEW_EPIC_BRANCH_NAME);
