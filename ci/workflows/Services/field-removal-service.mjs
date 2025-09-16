import { existsSync, readFileSync } from "fs";
import { execSync } from "child_process";
import {
  createFile,
  deleteFile,
  downloadFile,
  folderExist
} from "./helper.mjs";

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

const compareReports = (previousComment, newFile, fieldRemovalFileName) => {
  if (!previousComment) {
    console.warn("No previous PR comment provided. Skipping comparison.");
    return;
  }

  const newReport = printContextFromHTMLFile(newFile);

  if (!newReport) {
    console.warn("New report file could not be read. Skipping comparison.");
    return;
  }

  const isSame = previousComment === newReport;

  createFile(isSame, `${fieldRemovalFileName}-report`, "Compare PR comments");
};

const uploadHTMLFile = (
  removalFieldFileName,
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
      `curl -H "Authorization: Bearer ${artifactorySecret}" -X PUT -T "${newReportFileName}" "https://artifactory.gcp.anz/artifactory/${repoName}/${removalFieldFileName}"`
    ).toString("utf8")
  );
};

export { printPreviousPRComment, compareReports, uploadHTMLFile };
