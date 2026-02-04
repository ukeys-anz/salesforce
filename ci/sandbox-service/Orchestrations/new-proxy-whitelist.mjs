// Raise PR against https://github.service.anz/SecurityinChangeCOE/CEP-App-Rules
// New proxy whitelisting for new sandbox

/// Import different functions from services.
import {
  cloneRepo,
  prBranchName,
  navigateToNewClonedRepo,
  checkoutBranch,
  updateNPWhitelistConfFile,
  raisePR,
  openRaisedPR,
  removeClonedRepo
} from "../Services/raise-pr.mjs";
//////////////

/// Hardcoded epic name.

const SANDBOX_NAME = "xxxx";
const CEP_REPO_ADDRESS =
  "https://github.service.anz/SecurityinChangeCOE/CEP-App-Rules.git";
const NP_PROXY_FILE_PATH = "non-prod/sf-harness-delegate-np.conf";
//////////////

/// functions

// this function:
//    - clone the right repo in a specific folder
//    - checkout a branch
//    - update the conf file for non-prod sandboxes
//    - raise the PR
//    - open the PR on browser
//    - remove the cloned repo
const newProxyWhitelist = (reporAddress, sandboxName, confFilePath) => {
  cloneRepo(reporAddress);
  const newBranchName = prBranchName(sandboxName);
  navigateToNewClonedRepo(reporAddress);
  checkoutBranch(newBranchName);
  updateNPWhitelistConfFile(confFilePath, sandboxName);
  raisePR(reporAddress, sandboxName, newBranchName);
  openRaisedPR(reporAddress, newBranchName);
  removeClonedRepo(reporAddress);
};

/// Run Orchestration

newProxyWhitelist(CEP_REPO_ADDRESS, SANDBOX_NAME, NP_PROXY_FILE_PATH);
