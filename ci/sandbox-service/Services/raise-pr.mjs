import { runCommand } from "./helper.mjs";
import { chdir } from "process";

const findEpicName = (epicBranchName) =>
  epicBranchName.replaceAll("/", "-").replace("epic-", "");

const navigateToNewClonedRepo = (repoAddress) => {
  const repoName = repoAddress
    .replace("https://github.com/anzx/", "")
    .replace("https://github.service.anz/SecurityinChangeCOE/", "")
    .replace(".git", "");
  chdir(`./raise-pr-folder/${repoName}`);
};

const cloneRepo = (repoAddress) => {
  chdir("..");
  runCommand(`
    mkdir raise-pr-folder
    cd raise-pr-folder
    git clone "${repoAddress}"
`);
};

const prBranchName = (epicBranchName) => {
  const currentTime = new Date().getTime();
  const name = findEpicName(epicBranchName);
  const newBranchName = `sf-new-epic-${name}-${currentTime}`;
  return newBranchName;
};

const checkoutBranch = (branchName) =>
  runCommand(`
    git checkout -b ${branchName}
`);

const raisePR = (repoAddress, epicBranchName, branchName) => {
  const name = findEpicName(epicBranchName);
  const commitMessage =
    "Salesforce | New sandbox : " +
    repoAddress.includes("https://github.com/anzx/")
      ? `Secret : h-salesforce-np-${name}`
      : `${epicBranchName}`;
  runCommand(`
        git add .
        git commit -m "${commitMessage}"
        git push origin ${branchName}
    `);
};

const newSecretName = (epicBranchName) =>
  `h-salesforce-np-${findEpicName(epicBranchName)}`;

const secretBody = (newSecretName) =>
  `---
apiVersion: secretmanager.devex.platform.x.anz/v1alpha1
kind: SecretManagerSecret
metadata:
  annotations:
    devex.platform.x.anz/project-id: anz-x-bootstrap-np-487e09
  name: ${newSecretName}
spec:
  labels:
    confidentiality: confidential
    integrity: trusted
    trustlevel: high
  replication:
    userManaged:
      replicas:
        - location: australia-southeast1
---
apiVersion: devex.platform.x.anz/v1alpha1
kind: IAMPolicyMember
spec:
  memberFrom:
    serviceAccountRef:
      name: h-sf-primary-np
  resourceRef:
    apiVersion: secretmanager.devex.platform.x.anz/v1alpha1
    kind: SecretManagerSecret
    name: ${newSecretName}
  role: roles/secretmanager.secretAccessor`;

const newProxyWhitelist = (sandboxName) => `
acl FILTER-sf-harness-delegate-np dstdomain anz--${sandboxName}.sandbox.my.salesforce.com
`;

const updateNPSecretsYamlFile = (filepath, epicBranchName) => {
  const secretName = newSecretName(epicBranchName);
  const newSecretBody = secretBody(secretName);
  runCommand(`
      echo "${newSecretBody}" >> "${filepath}"    
  `);
};

const updateNPWhitelistConfFile = (filepath, sandboxName) => {
  const newWhitelistingProxy = newProxyWhitelist(sandboxName);
  runCommand(`
      echo "${newWhitelistingProxy}" >> "${filepath}"    
  `);
};

const openRaisedPR = (repoAddress, branchName) => {
  const repoAddressToOpen = repoAddress.replace(
    ".git",
    `/compare/master...${branchName}`
  );
  runCommand(`
        open ${repoAddressToOpen} || start ${repoAddressToOpen}
    `);
};

const removeClonedRepo = (rootpath) => {
  chdir(`../..`);
  runCommand(`
    rm -rf raise-pr-folder
  `);
};

export {
  cloneRepo,
  prBranchName,
  navigateToNewClonedRepo,
  checkoutBranch,
  updateNPSecretsYamlFile,
  updateNPWhitelistConfFile,
  raisePR,
  openRaisedPR,
  removeClonedRepo
};
