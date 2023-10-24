import { execSync } from "child_process";
import {
  renameFile,
  createFolder,
  deleteFolder,
  ignoredFiles,
  salesforceDiffExist,
  logger,
  folderExist
} from "./helper.mjs";

const renameForceignore = () => {
  renameFile(".forceignore", "ci.forceignore");
  renameFile("deploy.forceignore", ".forceignore");
};

const createArtifactFolder = (folderName) => {
  deleteFolder(folderName);
  createFolder(folderName);
};

const findAllChangedFileOnValidate = (folderName, baseRef, ref) => {
  createArtifactFolder(folderName);
  execSync(
    `npx sfdx sgd:source:delta --to origin/${ref} --from origin/${baseRef} --output ${folderName}/ --generate-delta`
  ).toString("utf8");
};

const findAllChangedFileOnDeploy = (folderName, baseRef, tagRef) => {
  createArtifactFolder(folderName);
  execSync(
    `npx sfdx sgd:source:delta --to ${tagRef} --from origin/${baseRef} --output ${folderName}/ --generate-delta`
  ).toString("utf8");
};

const buildArtifactOnValidate = (folderName, baseRef, ref) => {
  renameForceignore();
  createArtifactFolder(folderName);
  execSync(
    `npx sfdx sgd:source:delta --to origin/${ref} --from origin/${baseRef} --output ${folderName}/ --generate-delta -i .forceignore`
  ).toString("utf8");
};

const buildArtifactOnDeploy = (folderName, baseRef, tagRef) => {
  renameForceignore();
  createArtifactFolder(folderName);
  execSync(
    `npx sfdx sgd:source:delta --to ${tagRef} --from origin/${baseRef} --output ${folderName}/ --generate-delta -i .forceignore`
  ).toString("utf8");
};

const artifactFolderExist = (artifactPath) => {
  if (!folderExist(artifactPath + "/package")) {
    process.exit(1);
  }
};

const createDiffOnValidate = (folderName, baseRef, ref) => {
  findAllChangedFileOnValidate(folderName + "-all-files", baseRef, ref);
  buildArtifactOnValidate(folderName, baseRef, ref);
  artifactFolderExist(folderName);
  ignoredFiles(folderName);
  deleteFolder(folderName + "-all-files");
};

const createDiffOnDeploy = (folderName, baseRef, tagRef) => {
  findAllChangedFileOnDeploy(folderName + "-all-files", baseRef, tagRef);
  buildArtifactOnDeploy(folderName, baseRef, tagRef);
  artifactFolderExist(folderName);
  ignoredFiles(folderName);
  deleteFolder(folderName + "-all-files");
};

const zipArtifactory = (artifactPath) => {
  console.log("Zipping Artifact");
  execSync(`zip -r "${artifactPath}.zip" "${artifactPath}"`).toString("utf8");
};

const uploadArtifact = (zipFileName, artifactorySecret) => {
  console.log("Upload Artifact");
  console.log(
    execSync(
      `curl -H "X-JFrog-Art-Api:${artifactorySecret}" -X PUT -T "${zipFileName}.zip" "https://artifactory.gcp.anz/artifactory/anzx-salesforce-releases-np/${zipFileName}.zip"`
    ).toString("utf8")
  );
};

const deleteZipArtifactory = (zipFileName) => {
  console.log("Deleting Artifact Zip file");
  execSync(`rm -f ${zipFileName}.zip`);
};

const uploadToArtifactory = (zipFileName, artifactorySecret, artifactPath) => {
  if (!salesforceDiffExist(artifactPath)) return;
  logger("Upload Artifactory");
  zipArtifactory(artifactPath);
  uploadArtifact(artifactPath, artifactorySecret);
  deleteZipArtifactory(artifactPath);
};

const createAndUploadArtifact = (
  folderName,
  baseRef,
  ref,
  artifactorySecret,
  zipFileName
) => {
  createDiffOnValidate(folderName, baseRef, ref);
  uploadToArtifactory(zipFileName, artifactorySecret, folderName);
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
  createDiffOnDeploy
};

// POINTS
// We should install node and npm package to have access to sf commands

// We should install the SGD plugin before running the node command:
// - echo y | npx sfdx plugins:install https://artifactory.gcp.anz:443/artifactory/api/npm/npmjs-org/sfdx-git-delta/-/sfdx-git-delta-5.25.2.tgz

// On orchesteration we can use the following values comming from github actions
//    baseRef: "${{ github.base_ref }}"
//    ref: "${{ github.head_ref }}"
