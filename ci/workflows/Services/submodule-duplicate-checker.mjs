import { readdirSync, statSync } from "fs";
import { findAllFiles, readFileLines, runSfCommand } from "./helper.mjs";

const isCustomLabel = (filename) => filename.includes(".labels-meta.xml");
const isObjectChange = (filename) => filename.includes("/objects/");
const isSharingRule = (filename) => filename.includes(".sharingRules-meta.xml");
// This will find all files inside submodule.
// Case scenario to use this: to check if there is any duplication on new changes against parent repo
const findAllSubmoduleFiles = (dir, files = {}) => {
  // Get an array of all files and directories in the passed directory using fs.readdirSync
  const fileList = readdirSync(dir);
  // Create the full path of the file/directory by concatenating the passed directory and file/directory name
  for (const file of fileList) {
    const name = `${dir}/${file}`;
    // Check if the current file/directory is a directory using statSync
    if (statSync(name).isDirectory()) {
      // If it is a directory, recursively call the getFiles function with the directory path and the files array
      findAllSubmoduleFiles(name, files);
    } else {
      // Find the index of the last '/'
      const lastSlashIndex = name.lastIndexOf("/");

      // Extract the filename by slicing the string from the character after the last '/'
      let fileName = name.slice(lastSlashIndex + 1);
      if (isCustomLabel(fileName)) {
        files["CustomLabel"] = name;
      }
      if (isSharingRule(fileName)) {
        files["SharingRule"] = name;
      }
      if (isObjectChange(name)) {
        fileName = name.split("/objects/")[1];
      }
      files[fileName] = name;
    }
  }
  return files;
};

const findAllParentFiles = (latestTag) => {
  let changedFiles = [];
  if (!latestTag) {
    changedFiles = [
      ...findAllFiles("force-app"),
      ...findAllFiles("knowledge-mgm")
    ];
    return changedFiles;
  }

  changedFiles = runSfCommand(
    `git diff --name-only --diff-filter=d ${latestTag}..HEAD force-app`
  )
    .toString() // Convert the output to a string
    .trim(); // Remove any extra whitespace or newlines

  // Replace line breaks with commas
  changedFiles = changedFiles.split("\n").join(",");

  // If there’s a trailing comma, remove it
  changedFiles = changedFiles.replace(/,$/, "");
  changedFiles = changedFiles.split(",");

  return changedFiles;
};

// To find the new changes filepath and filename
// input: BASE_REF_LAST_TAG
const findAllNewChanges = (latesTag) => {
  const changedFiles = findAllParentFiles(latesTag);

  const files = {};
  changedFiles.map((f) => {
    // Find the index of the last '/'
    const lastSlashIndex = f.lastIndexOf("/");

    // Extract the filename by slicing the string from the character after the last '/'
    let fileName = f.slice(lastSlashIndex + 1);
    if (isObjectChange(f)) {
      fileName = f.split("/objects/")[1];
    }
    files[fileName] = f;
  });
  return files;
};

// On salesforce, Custom Labels and sharingRules using the same metadata name. To check the duplication -
// - we should find all the custom labels or sharingRules by their full name and check if we have a duplication or not.
const duplicateCheckerInsideFile = (newChangeFilePath, submoduleFilePath) => {
  let duplicatedMsg = "";
  if (!isSharingRule(newChangeFilePath) && !isCustomLabel(newChangeFilePath))
    return duplicatedMsg;
  const submoduleComponentFullName = readFileLines(submoduleFilePath).filter(
    (line) => line.includes("<fullName>")
  );
  const newComponentFullName = readFileLines(newChangeFilePath).filter((line) =>
    line.includes("<fullName>")
  );
  submoduleComponentFullName.forEach((sharedComponent) => {
    if (!newComponentFullName.includes(sharedComponent)) return;
    duplicatedMsg += `<p>${sharedComponent.replace("<fullName>", "").replace("</fullName>", "").replaceAll(" ", "")}</p>`;
  });
  return duplicatedMsg;
};

const findSubmoduleFilePath = (filename, submoduleFilesObj) => {
  const isFileCustomLabelFlag = isCustomLabel(filename);
  const isFileSharingRuleFlag = isSharingRule(filename);
  if (!isFileCustomLabelFlag && !isFileSharingRuleFlag)
    return submoduleFilesObj[filename];
  if (isFileCustomLabelFlag) return submoduleFilesObj["CustomLabel"];
  if (isFileSharingRuleFlag) return submoduleFilesObj["SharingRule"];
};

const notSalesforceChange = (filename) => {
  const notSalesforceCheckerMap = [".git", ".md"];
  return notSalesforceCheckerMap.some((checker) => filename.includes(checker));
};

const createDupCheckerTableContext = (
  filename,
  submoduleFilepath,
  newChangesFilepath,
  insideComponentDuplicate
) =>
  `<tr><td rowspan='2'>${filename}</td><td>${submoduleFilepath}</td><td rowspan='2'>${insideComponentDuplicate}</td></tr><tr><td>${newChangesFilepath}</td></tr>`;
const createDupCheckerTable = (duplicates) =>
  duplicates
    ? "<table><thead><tr><th>File</th><th>Duplicated Paths</th><th>Note</th></tr></thead><tbody>" +
      duplicates +
      "</tbody></table>"
    : "";

// This will check all the duplication between new changes and submodule files.
// inputs: BASE_REF_LAST_TAG, SUBMODULE_PATH
const findDuplications = (lastTag, submodulePath) => {
  let duplicates = "";
  let insideComponentDuplicate = "";
  const newChangesObj = findAllNewChanges(lastTag);
  const submoduleFilesObj = findAllSubmoduleFiles(submodulePath);

  for (let filename in newChangesObj) {
    if (notSalesforceChange(newChangesObj[filename])) continue;

    const submoduleFilepath = findSubmoduleFilePath(
      filename,
      submoduleFilesObj
    );
    if (!submoduleFilepath) continue;

    const newChangesFilepath = newChangesObj[filename];
    if (newChangesFilepath === submoduleFilepath) continue;

    insideComponentDuplicate = duplicateCheckerInsideFile(
      newChangesFilepath,
      submoduleFilepath
    );
    if (
      (isCustomLabel(filename) || isSharingRule(filename)) &&
      !insideComponentDuplicate
    )
      continue;

    duplicates += createDupCheckerTableContext(
      filename,
      submoduleFilepath,
      newChangesFilepath,
      insideComponentDuplicate
    );
  }
  return createDupCheckerTable(duplicates);
};

export { findDuplications };
