import { execSync } from "child_process";
import { rmSync, mkdirSync, existsSync } from "fs";

const deleteArtifactFolder = (folderName) => {
  return rmSync(folderName, { recursive: true, force: true }, (err) => {
    if (err) {
      console.error(err);
    }
    console.log(`${folderName} is deleted!`);
  });
};

const createArtifactFolder = (folderName) => {
  deleteArtifactFolder(folderName);
  return mkdirSync(folderName, (err) => {
    if (err) {
      console.error(err);
    }
    console.log(`${folderName} is created!`);
  });
};

const buildArtifact = (folderName, baseRef, ref) => {
  createArtifactFolder(folderName);
  execSync(
    `npx sfdx sgd:source:delta --to origin/${baseRef} --from origin/${ref} --output ${folderName}/ --generate-delta -i .forceignore`
  ).toString("utf8");
};

const uploadArtifact = (
  folderName,
  baseRef,
  ref,
  artifactorySecret,
  projectName
) => {
  buildArtifact(folderName, baseRef, ref);
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
  deleteArtifactFolder,
  createArtifactFolder,
  buildArtifact,
  uploadArtifact,
  downloadArtifact
};

// POINTS
// We should install node and npm package to have access to sf commands

// We should install the SGD plugin before running the node command:
// - echo y | npx sfdx plugins:install https://artifactory.gcp.anz:443/artifactory/api/npm/npmjs-org/sfdx-git-delta/-/sfdx-git-delta-5.25.2.tgz

// On orchesteration we can use the following values comming from github actions
//    baseRef: "${{ github.base_ref }}"
//    ref: "${{ github.head_ref }}"
