import {
  deleteArtifactFolder,
  createArtifactFolder,
  buildArtifact,
  checkIfAnyArtifact
} from "./artifact-sgd-functions.mjs";

const folderName = "artifact";

const run = async (folderName, baseRef, ref) => {
  deleteArtifactFolder(folderName);
  createArtifactFolder(folderName);
  buildArtifact(folderName, baseRef, ref);
  checkIfAnyArtifact(folderName);
};

// These will take inputs from node command on github action
// args[2] will be github baseRef, args[3] will be github ref
const args = process.argv;
run(folderName, args[2], args[3]);

// We should install node and npm package to have access to sfdx/sf commands

// We should install the SGD plugin before running the node command:
// - echo y | npx sfdx plugins:install https://artifactory.gcp.anz:443/artifactory/api/npm/npmjs-org/sfdx-git-delta/-/sfdx-git-delta-5.25.2.tgz

// The command on github action should be:
// - node ci/workflows/artifact-service/artifact-service.mjs "${{ github.base_ref }}" "${{ github.head_ref }}"

// The command to use for verification is:
// - npx sfdx force:source:deploy -u staging -p artifact -c
// OR:
// - npx sf project deploy validate --source-dir artifact -o staging
