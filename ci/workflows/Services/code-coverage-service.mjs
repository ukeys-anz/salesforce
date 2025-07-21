import { execSync } from "child_process";
import { existsSync, readFileSync } from "fs";
import {
  createDeployCacheFile,
  createFile,
  createReportFile,
  deleteFile,
  downloadFile,
  findNamesAndMembersXML,
  folderExist,
  logger,
  printContextFromFile,
  runCommand,
  runCommandToFile
} from "./helper.mjs";

const NO_APEX_CHANGE = "No Apex Changes";

const generateHTMLContext = (averageCoverage, lowCoverageClasses) => {
  let addElement = "";
  if (lowCoverageClasses === NO_APEX_CHANGE) {
    addElement = '<tr><td colspan="2">🟢 No Apex class has changed.</td></tr>';
  } else if (!lowCoverageClasses.length) {
    addElement =
      '<tr><td colspan="2">✅ All changed Apex classes have at least 95% test coverage.</td></tr>';
  } else {
    addElement = lowCoverageClasses
      .map(
        ({ name, coverage }) =>
          `<tr><td>${name}</td><td>❗ ${coverage.toFixed(2)}%</td></tr>`
      )
      .join("");
  }

  const tableHeader = `<table border="1" cellpadding="6" cellspacing="0" style="border-collapse: collapse;"><thead><tr><th>Class Name</th><th>Coverage</th></tr></thead>`;
  const tableBody = `<tbody><tr><td>Average Coverage</td><td>${averageCoverage}%</td></tr>${addElement}</tbody></table>`;
  const htmlContent =
    "<h2>📊 Apex Code Coverage Summary</h2>" + tableHeader + tableBody;
  return htmlContent;
};

const generateCoverageHTMLReport = (
  averageCoverage,
  lowCoverageClasses,
  fileName = "code-coverage-report.html"
) => {
  console.log(`Creating HTML coverage report: ${fileName}`);
  const htmlContent = generateHTMLContext(averageCoverage, lowCoverageClasses);
  createReportFile(htmlContent.trim(), fileName, "Code Coverage Report");
};

const getChangedApexClasses = (artifactoryPackagePath) => {
  try {
    const allChangesFilesObject = findNamesAndMembersXML(
      artifactoryPackagePath
    );
    const output = allChangesFilesObject["ApexClass"];

    if (!output) {
      console.log("✅ No changed Apex class files found.");
      return [];
    }
    return output;
  } catch (e) {
    console.error("❌ Failed to get changed Apex classes:", e.message);
    process.exit(1);
  }
};

const codeCoverageNewApex = (
  artifactoryPackagePath,
  codeCoverageJsonReport
) => {
  const apexFiles = getChangedApexClasses(artifactoryPackagePath);

  if (!apexFiles.length) return NO_APEX_CHANGE;

  const lowCoverageClasses = [];

  apexFiles.forEach((apexClass) => {
    const report = codeCoverageJsonReport.find((r) => r.name === apexClass);
    if (!report) {
      console.log(`No coverage data found for class: ${apexClass}`);
      return;
    }

    const totalLines = report.numLocations;
    const uncoveredLines = report.numLocationsNotCovered;

    if (totalLines === 0) {
      console.log(`Class ${apexClass} has zero total lines`);
      return;
    }

    const uncoveredPercent = (uncoveredLines / totalLines) * 100;
    const coveragePercent = 100 - uncoveredPercent;

    console.log(`Class ${apexClass} coverage: ${coveragePercent.toFixed(2)}%`);

    if (coveragePercent < 95) {
      lowCoverageClasses.push({ name: apexClass, coverage: coveragePercent });
    }
  });

  return lowCoverageClasses;
};

const codeCoverageAverage = (codeCoverageJsonReport) => {
  const totalLines = codeCoverageJsonReport.reduce(
    (s, v) => s + +v.numLocations,
    0
  );
  const notCoveredLines = codeCoverageJsonReport.reduce(
    (s, v) => s + +v.numLocationsNotCovered,
    0
  );
  if (totalLines === 0) {
    return "0.00";
  }
  const percentage = (
    ((totalLines - notCoveredLines) / totalLines) *
    100
  ).toFixed(2);
  return percentage;
};

const codeCoverage = (
  jobIdFileName,
  artifactoryPackagePath,
  targetOrg,
  anzxCIPackage,
  codeCoverageFileName
) => {
  logger("Code Coverage");
  console.log("jobIdFileName: " + jobIdFileName);
  const pastJobId = printContextFromFile(jobIdFileName, "| Code coverage.");
  if (
    !pastJobId ||
    pastJobId.includes("File not found") ||
    pastJobId.includes("Invalid deploy ID")
  ) {
    console.log("Job Id not found...");
    return;
  }

  console.log("jobId: " + pastJobId);
  createDeployCacheFile(pastJobId, targetOrg, anzxCIPackage, anzxCIPackage);

  const output = runCommand(
    `npx sf project deploy report --job-id ${pastJobId} --json`,
    codeCoverageFileName + ".json",
    "Report JSON"
  );

  if (!output) {
    console.log("Deploy report output is empty or failed.");
    return;
  }

  let reportJson;
  try {
    reportJson = JSON.parse(output);
  } catch (parseError) {
    console.error("Failed to parse JSON output:", parseError.message);
    console.error("Raw output snippet:", output.slice(0, 500));
    return;
  }

  const runTestResult = reportJson?.result?.details?.runTestResult;
  const numTestsRun = runTestResult?.numTestsRun;

  if (!numTestsRun) {
    console.log("No test");
    return;
  }

  const codeCoverageReport = runTestResult.codeCoverage;
  const percentage = codeCoverageAverage(codeCoverageReport);
  const lowCoverage = codeCoverageNewApex(
    artifactoryPackagePath,
    codeCoverageReport
  );
  console.log(`Apex test coverage: ${percentage}%`);
  generateCoverageHTMLReport(
    percentage,
    lowCoverage,
    codeCoverageFileName + ".html"
  );
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
    pastReport.includes("Invalid deploy ID")
  ) {
    console.log("There is no PR Comment HTML file.");
    return;
  }

  return pastReport;
};

const compareReports = (previousComment, CODE_COVERAGE_FILE_NAME) => {
  if (!previousComment) {
    console.warn("No previous PR comment provided. Skipping comparison.");
    return;
  }

  const newReport = printContextFromHTMLFile(CODE_COVERAGE_FILE_NAME + ".html");

  if (!newReport) {
    console.warn(
      "New code coverage file could not be read. Skipping comparison."
    );
    return;
  }

  const isSame = previousComment === newReport;

  createFile(
    isSame,
    `${CODE_COVERAGE_FILE_NAME}-report`,
    "Compare PR comments"
  );
};

const uploadHTMLFile = (
  codeCoverageFileName,
  artifactorySecret,
  repoName,
  comment
) => {
  if (!folderExist(codeCoverageFileName)) {
    console.log(`Could not find ${codeCoverageFileName} file`);
    return;
  }
  console.log(`Upload ${comment} File`);
  console.log(
    execSync(
      `curl -H "Authorization: Bearer ${artifactorySecret}" -X PUT -T "${codeCoverageFileName}" "https://artifactory.gcp.anz/artifactory/${repoName}/${codeCoverageFileName}"`
    ).toString("utf8")
  );
};

//////////////////////////////////

export { codeCoverage, printPreviousPRComment, compareReports, uploadHTMLFile };
