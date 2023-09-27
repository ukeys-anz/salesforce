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
  return mkdirSync(folderName, (err) => {
    if (err) {
      console.error(err);
    }
    console.log(`${folderName} is created!`);
  });
};

const buildArtifact = (folderName, baseRef, ref) => {
  execSync(
    `npx sfdx sgd:source:delta --to origin/${baseRef} --from origin/${ref} --output ${folderName}/ --generate-delta -i .forceignore`
  ).toString("utf8");
};

// This should be used on validation/deployment service -
// - to check if we have any force-app changes, then validate it

const checkIfAnyArtifact = (folderName) => {
  if (!existsSync(`${folderName}/force-app`)) {
    console.error("there is nothing to be deployed");
  } else {
    console.log("there are some changes to be deployed/verified");
  }
};

export {
  deleteArtifactFolder,
  createArtifactFolder,
  buildArtifact,
  checkIfAnyArtifact
};
