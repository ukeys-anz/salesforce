// Raise PR against https://github.com/anzx/platform-harness-delegates.git
// New secret for new sandbox

/// Import different functions from services.
import {
  cloneRepo,
  prBranchName,
  navigateToNewClonedRepo,
  checkoutBranch,
  updateNPSecretsYamlFile,
  raisePR,
  openRaisedPR,
  removeClonedRepo
} from "../Services/raise-pr.mjs";
//////////////

/// Hardcoded epic name.

const EPIC_NAME = "epic/xxxx";
const HARNESS_REPO_ADDRESS =
  "https://github.com/anzx/platform-harness-delegates.git";
const NP_SECRET_YAML_FILE_PATH =
  "delegates/salesforce/primary-np-hshqms.secrets.yaml";
//////////////

/// functions

// this function:
//    - clone the right repo in a specific folder
//    - checkout a branch
//    - update the secret yaml file for non-prod sandboxes
//    - raise the PR
//    - open the PR on browser
//    - remove the cloned repo
const newSecretPR = (reporAddress, epicBranchName, yamlFilePath) => {
  cloneRepo(reporAddress);
  const newBranchName = prBranchName(epicBranchName);
  navigateToNewClonedRepo(reporAddress);
  checkoutBranch(newBranchName);
  updateNPSecretsYamlFile(yamlFilePath, epicBranchName);
  raisePR(reporAddress, epicBranchName, newBranchName);
  openRaisedPR(reporAddress, newBranchName);
  removeClonedRepo(reporAddress);
};

/// Run Orchestration

newSecretPR(HARNESS_REPO_ADDRESS, EPIC_NAME, NP_SECRET_YAML_FILE_PATH);
