import { execSync } from "child_process";
import {
  renameFile,
  findAllFiles,
  createFolder,
  deleteFolder,
  logger
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

const createDiffOnValidate = (folderName, baseRef, ref) => {
  findAllChangedFileOnValidate(folderName + "-all-files", baseRef, ref);
  buildArtifactOnValidate(folderName, baseRef, ref);

  const allChangedFiles = findAllFiles(folderName + "-all-files");
  const notIgnoredFilesChanges = findAllFiles(folderName);
  const ignoredFilesChanges = [];

  allChangedFiles.forEach((file) => {
    const f = file.replace(folderName + "-all-files", folderName);
    if (!notIgnoredFilesChanges.includes(f)) ignoredFilesChanges.push(f);
  });
  logger(`All Changed files:\n${notIgnoredFilesChanges.join("\n")}`);
  logger(
    `All Ignored files:\n${
      ignoredFilesChanges.length ? ignoredFilesChanges.join("\n") : "None"
    }`
  );
  deleteFolder(folderName + "-all-files");
};

const createDiffOnDeploy = (folderName, baseRef, tagRef) => {
  findAllChangedFileOnDeploy(folderName + "-all-files", baseRef, tagRef);
  buildArtifactOnDeploy(folderName, baseRef, tagRef);

  const allChangedFiles = findAllFiles(folderName + "-all-files");
  const notIgnoredFilesChanges = findAllFiles(folderName);
  const ignoredFilesChanges = [];

  allChangedFiles.forEach((file) => {
    const f = file.replace(folderName + "-all-files", folderName);
    if (!notIgnoredFilesChanges.includes(f)) ignoredFilesChanges.push(f);
  });
  logger(`All Changed files:\n${notIgnoredFilesChanges.join("\n")}`);
  logger(
    `All Ignored files:\n${
      ignoredFilesChanges.length ? ignoredFilesChanges.join("\n") : "None"
    }`
  );
  deleteFolder(folderName + "-all-files");
};

const uploadArtifact = (
  folderName,
  baseRef,
  ref,
  artifactorySecret,
  projectName
) => {
  createDiffOnValidate(folderName, baseRef, ref);
  // Then we should run a gcloud command to upload the artifact to artifactory
  // bash script code:
  //        zip -r "$ref.zip" "$folderName"
  //        curl -H "X-JFrog-Art-Api:$(gcloud secrets versions access projects/"${projectName}"/secrets/"${artifactorySecret}"/versions/latest)" -X PUT -T "$ARTIFACT_NAME.zip" "https://artifactory.gcp.anz/artifactory/anzx-salesforce-releases-np/$ref.zip"
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
  uploadArtifact,
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
