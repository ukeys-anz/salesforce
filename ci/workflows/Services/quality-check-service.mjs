import { existsSync, appendFileSync, readFileSync } from "fs";

import {
  createReportFile,
  folderExist,
  downloadFile,
  loggerInStep,
  runCommand,
  runDiffCommand,
  deleteFile,
  createFile
} from "./helper.mjs";
import { execSync } from "child_process";

const findDiffOnPR = (baseRef, headRef) => {
  if (!baseRef || !headRef || !process.env.GITHUB_OUTPUT) {
    loggerInStep(
      `❌ Error on findDiffOnPR: baseRef, headRef or GITHUB_OUTPUT not set...`
    );
    process.exit(1);
  }

  const mergeBase = runCommand(`git merge-base ${baseRef} ${headRef}`);

  if (!mergeBase) {
    loggerInStep(`❌ Error on findDiffOnPR: error on finidng ${mergeBase}...`);
    process.exit(1);
  }

  loggerInStep(`
        Base ref: ${baseRef}
        Head ref: ${headRef}
        Merge base: ${mergeBase}
    `);

  const changedFilesRaw = runDiffCommand(
    `git diff --name-only ${mergeBase} ${headRef}`
  );

  if (!changedFilesRaw) {
    loggerInStep("No changed files detected");
    return [];
  }

  const changedFiles = changedFilesRaw
    .split("\n") // Split by newlines
    .map((f) => f.trim()) // Remove whitespace
    .filter(Boolean); // Filter out empty lines

  return changedFiles;
};

const filterDiff = (changedFiles) => {
  const output = {
    allFiles: [],
    pmdJestSecurityFlag: false,
    syslFlag: false,
    prettierFlag: false,
    eslintFlag: false
  };
  changedFiles.forEach((filePath) => {
    // Step 1: Check if file exists
    if (!existsSync(filePath)) {
      console.warn(`⚠️ File not found locally (probably deleted): ${filePath}`);
      return;
    }
    // Step 2: Match (force-app|knowledge-mgm)/main/(default|sf-lending)
    if (
      /^(force-app|knowledge-mgm)\/main\/(default|sf-lending)/.test(filePath)
    ) {
      console.log(`✅ PMD/Jest/Security File: ${filePath}`);
      output.allFiles.push(filePath);

      // Step 3: Check if file contains /objects/
      if (filePath.includes("/objects/") && !output.syslFlag) {
        console.log(`📁 Sysl check should run: ${filePath}`);
        output.syslFlag = true;
      }

      // Step 4: Check for LWC .js files (not .test.js)
      if (
        /\/lwc\/.*\.js$/.test(filePath) &&
        !/\.test\.js$/.test(filePath) &&
        !output.eslintFlag
      ) {
        console.log(`📦 ESLint LWC check should run: ${filePath}`);
        output.eslintFlag = true;
      }

      // Step 5: Check for Prettier files
      if (
        (/\.(trigger|cls)$/.test(filePath) ||
          /\/lwc\/.*\.(js|html|css)$/.test(filePath) ||
          /\/aura\/.*\.(js|css|cmp)$/.test(filePath)) &&
        !output.prettierFlag
      ) {
        console.log(`🎨 Prettier check should run: ${filePath}`);
        output.prettierFlag = true;
      }
    } else {
      console.log(`🟢 No quality check for this file: ${filePath}`);
    }
  });

  if (output.allFiles.length) {
    output.pmdJestSecurityFlag = true;
  }

  return output;
};

const detectChanges = (baseRef, headRef) => {
  const changedFiles = findDiffOnPR(baseRef, headRef);
  const filteredFiles = filterDiff(changedFiles);
  return filteredFiles;
};

const createDiffFile = (allChangedFiles, filename) => {
  if (!allChangedFiles.length) {
    console.log("No files to be checked...");
    return;
  }
  console.log(`Creating Quality Check file: ${filename}.txt`);
  const allChangedFilesJoined = allChangedFiles.join("\n");
  createReportFile(
    allChangedFilesJoined,
    filename + ".txt",
    "Quality Check changed"
  );
};

const uploadDiffFile = (filename, artifactorySecret, repoName) => {
  if (!folderExist(`${filename}`)) {
    console.log(`${filename} has not been created...`);
    return;
  }
  loggerInStep(`Upload diff file for quality check: ${filename}`);
  console.log(
    execSync(
      `curl -H "Authorization: Bearer ${artifactorySecret}" -X PUT -T "${filename}" "https://artifactory.gcp.anz/artifactory/${repoName}/${filename}"`
    ).toString("utf8")
  );
};

const updateGithubOutput = (flagsObject) => {
  if (!process.env.GITHUB_OUTPUT) {
    console.log("Could not set GITHUB_OUTPUT...");
    process.exit(1);
  }

  for (const [key, value] of Object.entries(flagsObject)) {
    console.log(`${key}=${value}`);
    appendFileSync(process.env.GITHUB_OUTPUT, `${key}=${value}\n`);
  }
  console.log("Debug logs on Github Outputs...");
  console.log(process.env.GITHUB_OUTPUT);
};

const printContextFromFile = (diffFile, comment = "") => {
  if (!existsSync(diffFile)) {
    logger(`There is no diff file: ${comment}`);
    return "";
  }

  try {
    const fileContent = readFileSync(diffFile);
    const filePaths = fileContent.toString("utf8");
    return filePaths;
  } catch (error) {
    console.error(`Failed to read file ${diffFile}:`, error.message);
    return "";
  }
};

const findAllChangedFiles = (
  filename,
  artifactorySecret,
  artifactoryRepoName
) => {
  downloadFile(
    filename,
    artifactorySecret,
    artifactoryRepoName,
    "Diff changed files"
  );
  const allFiles = printContextFromFile(filename, "| Find all changed files.");

  if (
    !allFiles ||
    allFiles.includes("File not found") ||
    allFiles.includes("Props Authentication Token not found")
  ) {
    console.log("There is no diff file.");
    return;
  }

  return allFiles;
};

const printContextFromHTMLFile = (prCommentFile, comment = "") => {
  if (!existsSync(prCommentFile)) {
    logger(`There is no PR Comment HTML file. ${comment}`);
    return "";
  }

  try {
    const buffer = readFileSync(prCommentFile); // returns Buffer by default
    return buffer.toString("utf8"); // decode with UTF-8 encoding
  } catch (err) {
    console.error(`Failed to read file ${prCommentFile}:`, err.message);
    return "";
  }
};

const printPreviousPRComment = (filename, artifactSecret, repoName) => {
  downloadFile(filename, artifactSecret, repoName, "PR Comment HTML");

  const pastReport = printContextFromHTMLFile(
    filename,
    "| Compare PR Comments job."
  );

  deleteFile(filename);

  if (
    !pastReport ||
    pastReport.includes("File not found") ||
    pastReport.includes("Props Authentication Token not found")
  ) {
    console.log("There is no PR Comment HTML file.");
    return;
  }

  return pastReport;
};

const compareReports = (previousComment, newFile, qualityCheckFileName) => {
  if (!previousComment) {
    console.warn("No previous PR comment provided. Skipping comparison.");
    return;
  }

  const newReport = printContextFromHTMLFile(newFile);

  if (!newReport) {
    console.warn("New summary file could not be read. Skipping comparison.");
    return;
  }

  const isSame = previousComment === newReport;

  createFile(isSame, `${qualityCheckFileName}-report`, "Compare PR comments");
};

const uploadHTMLFile = (
  qualityCheckFileName,
  newReportFileName,
  artifactorySecret,
  repoName,
  comment
) => {
  if (!folderExist(newReportFileName)) {
    console.log(`Could not find ${newReportFileName} file`);
    return;
  }
  console.log(`Upload ${comment} File`);
  console.log(
    execSync(
      `curl -H "Authorization: Bearer ${artifactorySecret}" -X PUT -T "${newReportFileName}" "https://artifactory.gcp.anz/artifactory/${repoName}/${qualityCheckFileName}"`
    ).toString("utf8")
  );
};

export {
  findDiffOnPR,
  filterDiff,
  detectChanges,
  createDiffFile,
  updateGithubOutput,
  uploadDiffFile,
  findAllChangedFiles,
  printPreviousPRComment,
  compareReports,
  uploadHTMLFile
};
