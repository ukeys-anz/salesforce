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
  salesforceIgnoredFileChanges
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
  const allIgnoredDestructiveChanges = salesforceIgnoredDestructiveChanges(
    folderName
  );

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
  execSync(
    `npx sfdx sgd:source:delta --to HEAD --from ${tagRef} --output ${folderName}/ --generate-delta`
  ).toString("utf8");
};

const findAllChangedFileOnDeploy = (folderName, baseRef, tagRef) => {
  createArtifactFolder(folderName);
  execSync(
    `npx sfdx sgd:source:delta --to origin/${baseRef} --from ${tagRef} --output ${folderName}/ --generate-delta`
  ).toString("utf8");
};

const buildArtifactOnValidate = (folderName, tagRef) => {
  renameForceignore();
  createArtifactFolder(folderName);
  execSync(
    `npx sfdx sgd:source:delta --to HEAD --from ${tagRef} --output ${folderName}/ --generate-delta -i .forceignore`
  ).toString("utf8");
};

const buildArtifactOnDeploy = (folderName, baseRef, tagRef) => {
  renameForceignore();
  createArtifactFolder(folderName);
  execSync(
    `npx sfdx sgd:source:delta --to origin/${baseRef} --from ${tagRef} --output ${folderName}/ --generate-delta -i .forceignore`
  ).toString("utf8");
};

const artifactFolderExist = (artifactPath) => {
  if (!folderExist(artifactPath + "/package")) {
    process.exit(1);
  }
};

const createDiffOnValidate = (folderName, tagRef) => {
  findAllChangedFileOnValidate(folderName + "-all-files", tagRef);
  buildArtifactOnValidate(folderName, tagRef);
  artifactFolderExist(folderName);
  printAllChangesAndIgnoredFiles(folderName);
  deleteFolder(folderName + "-all-files");
};

const createDiffOnDeploy = (folderName, baseRef, tagRef) => {
  logger("Build Artifact");
  findAllChangedFileOnDeploy(folderName + "-all-files", baseRef, tagRef);
  buildArtifactOnDeploy(folderName, baseRef, tagRef);
  artifactFolderExist(folderName);
  printAllChangesAndIgnoredFiles(folderName);
  deleteFolder(folderName + "-all-files");
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

const createAndUploadArtifact = (
  folderName,
  tagRef,
  artifactorySecret,
  artifactoryRepoName
) => {
  logger("Build Artifact");
  createDiffOnValidate(folderName, tagRef);
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
  renameForceignore
};
