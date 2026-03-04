import { execSync } from "child_process";
import {
  renameFile,
  createFolder,
  deleteFolder,
  salesforceDiffExist,
  logger,
  folderExist,
  loggerInStep,
  findAllFiles,
  salesforceIgnoredDestructiveChanges,
  salesforceDestructiveChanges,
  salesforceFileChanges,
  salesforceIgnoredFileChanges,
  addAgentforceToForceignore
} from "./helper.mjs";

const renameForceignore = () => {
  renameFile(".forceignore", "ci.forceignore");
  renameFile("deploy.forceignore", ".forceignore");
};

const createArtifactFolder = (folderName) => {
  deleteFolder(folderName);
  createFolder(folderName);
};

const printAllChangedAndIgnoredFiles = (folderName) => {
  const notIgnoredFilesChanges = salesforceFileChanges(folderName);
  const ignoredFilesChanges = salesforceIgnoredFileChanges(folderName);
  loggerInStep(
    `All Changed Files\n${
      notIgnoredFilesChanges ? notIgnoredFilesChanges : "None"
    }\n`
  );
  loggerInStep(
    `All Ignored Changed Files\n${
      ignoredFilesChanges ? ignoredFilesChanges : "None"
    }`
  );
};

const printAllDestructiveChangesAndIgnoredFiles = (folderName) => {
  const allDestructiveChanges = salesforceDestructiveChanges(folderName);
  const allIgnoredDestructiveChanges =
    salesforceIgnoredDestructiveChanges(folderName);

  loggerInStep(
    `All Destructive Changes\n${
      allDestructiveChanges ? allDestructiveChanges : "None"
    }\n`
  );
  loggerInStep(
    `All Ignored Destructive Changes\n${
      allIgnoredDestructiveChanges ? allIgnoredDestructiveChanges : "None"
    }`
  );
};

const printAllChangesAndIgnoredFiles = (folderName) => {
  printAllChangedAndIgnoredFiles(folderName);
  printAllDestructiveChangesAndIgnoredFiles(folderName);
};

const findAllChangedFileOnValidate = (folderName, tagRef) => {
  createArtifactFolder(folderName);
  execSync(`sf artifact xbuild -f ${folderName} -t ${tagRef}`, {
    encoding: "utf-8"
  });
};

const findAllChangedFileOnDeploy = (folderName, baseRef, tagRef) => {
  createArtifactFolder(folderName);
  execSync(`sf artifact xbuild -f ${folderName} -t ${tagRef} -b ${baseRef}`, {
    encoding: "utf-8"
  });
};

const buildArtifactOnValidate = (folderName, tagRef, baseRef) => {
  renameForceignore();
  addAgentforceToForceignore(baseRef);
  createArtifactFolder(folderName);
  const output = execSync(
    `sf artifact xbuild -f ${folderName} -t ${tagRef} -i .forceignore`,
    {
      encoding: "utf-8"
    }
  ).toString();
  console.log(output);
};

const buildArtifactOnDeploy = (folderName, baseRef, tagRef) => {
  renameForceignore();
  addAgentforceToForceignore(baseRef);
  createArtifactFolder(folderName);
  const output = execSync(
    `sf artifact xbuild -f ${folderName} -t ${tagRef} -b ${baseRef} -i .forceignore`,
    {
      encoding: "utf-8"
    }
  ).toString();
  console.log(output);
};

const artifactFolderExist = (artifactPath) => {
  if (!folderExist(artifactPath + "/package")) {
    process.exit(1);
  }
};

const createDiffOnValidate = (folderName, tagRef, baseRef) => {
  buildArtifactOnValidate(folderName, tagRef, baseRef);
  artifactFolderExist(folderName);
};

const createDiffOnDeploy = (folderName, baseRef, tagRef) => {
  logger("Build Artifact");
  buildArtifactOnDeploy(folderName, baseRef, tagRef);
  artifactFolderExist(folderName);
};

const zipArtifactory = (artifactPath) => {
  loggerInStep("Zipping Artifact");
  execSync(`zip -r "${artifactPath}.zip" "${artifactPath}"`).toString("utf8");
};

const uploadArtifact = (
  zipFileName,
  artifactorySecret,
  artifactoryRepoName
) => {
  loggerInStep("Upload Artifact");
  console.log(
    execSync(
      `curl -H "Authorization: Bearer ${artifactorySecret}" -X PUT -T "${zipFileName}.zip" "https://artifactory.gcp.anz/artifactory/${artifactoryRepoName}/${zipFileName}.zip"`
    ).toString("utf8")
  );
};

const deleteZipArtifactory = (zipFileName) => {
  console.log("Deleting Artifact Zip file");
  execSync(`rm -f ${zipFileName}.zip`);
};

const uploadToArtifactory = (
  artifactorySecret,
  artifactPath,
  artifactoryRepoName
) => {
  if (!salesforceDiffExist(artifactPath)) return;
  logger("Upload Artifactory");
  zipArtifactory(artifactPath);
  uploadArtifact(artifactPath, artifactorySecret, artifactoryRepoName);
  deleteZipArtifactory(artifactPath);
};

const uploadDestructiveToArtifactory = (
  artifactorySecret,
  destructiveDir,
  artifactoryRepoName
) => {
  logger("Upload Destructive Folder");
  if (!folderExist(destructiveDir)) return;
  zipArtifactory(destructiveDir);
  uploadArtifact(destructiveDir, artifactorySecret, artifactoryRepoName);
  deleteZipArtifactory(destructiveDir);
};

const createAndUploadArtifact = (
  folderName,
  tagRef,
  artifactorySecret,
  artifactoryRepoName,
  baseRef
) => {
  logger("Build Artifact");
  createDiffOnValidate(folderName, tagRef, baseRef);
  uploadToArtifactory(artifactorySecret, folderName, artifactoryRepoName);
};

const downloadArtifact = (artifactName, artifactorySecret, projectName) => {
  // We should run a gcloud command to download the artifact from artifactory
  // bash script code:
  // curl -H "X-JFrog-Art-Api:$(gcloud secrets versions access projects/"${projectName}"/secrets/"${artifactorySecret}"/versions/latest)" -O "https://artifactory.gcp.anz/artifactory/anzx-salesforce-releases/${artifactName}.zip"
  // unzip "${artifactName}.zip" -d "."
};

///////////////////////////////////////////

export {
  createArtifactFolder,
  buildArtifactOnValidate,
  createAndUploadArtifact,
  downloadArtifact,
  createDiffOnValidate,
  createDiffOnDeploy,
  uploadToArtifactory,
  uploadDestructiveToArtifactory,
  renameForceignore
};
