import { execSync } from "child_process";
import { findAllFiles, folderExist, logger } from "./helper.mjs";

const runCommand = (command) =>
  execSync(command, { stdio: "pipe", maxBuffer: 1024 * 1024 * 100 }).toString(
    "utf-8"
  );

const manualStepsFolderExists = (releaseFolderPath) =>
  folderExist(releaseFolderPath);

const findAllManualStepsFiles = (releaseFolderPath) =>
  findAllFiles(releaseFolderPath);

const findPreDeployStepsFiles = (allManualFilesArray) =>
  allManualFilesArray.filter((manualFiles) =>
    manualFiles.toLowerCase().includes("presteps")
  );

const findPostDeployStepsFiles = (allManualFilesArray) =>
  allManualFilesArray.filter((manualFiles) =>
    manualFiles.toLowerCase().includes("poststeps")
  );

const excludeSpecificFiles = (files, excludeFolders) => {
  const excludeFoldersArray = excludeFolders
    .replaceAll(" ", "")
    .replaceAll("epic/", "")
    .split(",");
  return files.filter(
    (f) =>
      !excludeFoldersArray.some((excludeEpicFolder) =>
        f.toLowerCase().includes(excludeEpicFolder)
      )
  );
};

const preOrPostDeployManualStepFunction = (whichManualSteps) => {
  const funcMap = {
    "pre-deploy": findPreDeployStepsFiles,
    "post-deploy": findPostDeployStepsFiles
  };
  return funcMap[whichManualSteps.toLowerCase()];
};

const findAllManualDeploySteps = (
  releaseFolderPath,
  whichManualSteps,
  excludeFoldernames
) => {
  if (!manualStepsFolderExists(releaseFolderPath)) {
    console.error(`There is no ${whichManualSteps}.`);
    process.exit(1);
  }
  const allFiles = findAllManualStepsFiles(releaseFolderPath);
  const manualFilesFunc = preOrPostDeployManualStepFunction(whichManualSteps);

  const allFilteredFiles = manualFilesFunc(allFiles);
  return excludeFoldernames
    ? excludeSpecificFiles(allFilteredFiles, excludeFoldernames)
    : allFilteredFiles;
};

const runApexFiles = (file, orgAlias) => {
  if (!file.includes(".apex")) return;
  return runCommand(`
        echo "----- From Apex: ${file} -----"
        sf apex run -f ${file} -o ${orgAlias}
        echo "-----"
    `);
};

const runJSFiles = (file, orgAlias) => {
  if (!file.includes(".js") && !file.includes(".mjs")) return;
  return runCommand(`
        echo "----- From javascript: ${file} -----"
        node ${file} ${orgAlias}
        echo "-----"
    `);
};

const runBashFiles = (file, orgAlias) => {
  if (!file.includes(".sh")) return;
  return runCommand(`
        echo "----- From bash script: ${file} -----"
        chmod +x ${file}
        ./${file} ${orgAlias}
        echo "-----"
    `);
};

const runAllManualFiles = (files, orgAlias) => {
  logger("Run All Manual Steps");
  if (!files.length) {
    console.log("There is no manual steps.");
    return;
  }
  files.forEach((f) => {
    const results = [
      runApexFiles(f, orgAlias),
      runJSFiles(f, orgAlias),
      runBashFiles(f, orgAlias)
    ].filter((res) => res);
    console.log(results[0]);
  });
};

const runAllValidManualSteps = (
  releaseFolderPath,
  whichManualSteps,
  excludeFolderNames,
  orgAlias
) => {
  const allValidFiles = findAllManualDeploySteps(
    releaseFolderPath,
    whichManualSteps,
    excludeFolderNames
  );
  logger("All Valid Manual Step Files");
  console.log(allValidFiles.join("\n"));
  runAllManualFiles(allValidFiles, orgAlias);
};

export { findAllManualDeploySteps, runAllValidManualSteps };
