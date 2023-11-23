import { exec, execSync } from "child_process";
import {
  runSfCommand,
  printContextFromFile,
  salesforceDiffExist,
  findAllSpecifiedTests,
  findJobIdFromCommand,
  logger,
  createFile,
  uploadFile,
  downloadFile,
  createDeployCacheFile,
  downloadZipFile,
  unzipFile,
  booleanMap
} from "./helper.mjs";

const validateWithoutTest = (targetOrg, artifactPath) => {
  if (!salesforceDiffExist(artifactPath)) return;
  logger("Running Validation | No Test");
  const command = `npx sf project deploy start -o ${targetOrg} --manifest "${artifactPath}/package/package.xml" --post-destructive-changes "${artifactPath}/destructiveChanges/destructiveChanges.xml" --dry-run --ignore-conflicts --async --verbose --json`;
  console.log(command);
  return runSfCommand(command);
};

const validateWithAllTests = (targetOrg, artifactPath) => {
  if (!salesforceDiffExist(artifactPath)) return;
  logger("Running Validation | All Local Tests");
  const command = `npx sf project deploy start -o ${targetOrg} --manifest "${artifactPath}/package/package.xml" --post-destructive-changes "${artifactPath}/destructiveChanges/destructiveChanges.xml" --dry-run --ignore-conflicts --async --verbose --test-level RunLocalTests --json`;
  console.log(command);
  return runSfCommand(command);
};

const validateWithSpecifiedTests = (
  targetOrg,
  artifactPath,
  classFolderPath
) => {
  if (!salesforceDiffExist(artifactPath)) return;
  logger("Running Validation | Specified Tests");
  let command = `npx sf project deploy start -o ${targetOrg} --manifest "${artifactPath}/package/package.xml" --post-destructive-changes "${artifactPath}/destructiveChanges/destructiveChanges.xml" --dry-run --ignore-conflicts --async --verbose --test-level RunSpecifiedTests`;

  const specifiedTestsArray = findAllSpecifiedTests(classFolderPath);
  if (!specifiedTestsArray.length) {
    console.error("ERROR: No Specifed tests found.");
    process.exit(1);
  }

  const allSpecifiedTests = " -t " + specifiedTestsArray.join(" -t ");
  command += allSpecifiedTests + " --json";

  console.log(command);
  return runSfCommand(command);
};

const deployWithoutTest = (targetOrg, artifactPath) => {
  if (!salesforceDiffExist(artifactPath)) return;
  logger("Running Deployment | No Test");
  const command = `npx sf project deploy start -o ${targetOrg} --manifest "${artifactPath}/package/package.xml" --post-destructive-changes "${artifactPath}/destructiveChanges/destructiveChanges.xml" --ignore-conflicts --async --verbose --json`;
  console.log(command);
  return runSfCommand(command);
};

const deployWithAllTests = (targetOrg, artifactPath) => {
  if (!salesforceDiffExist(artifactPath)) return;
  logger("Running Deployment | All Local Tests");
  const command = `npx sf project deploy start -o ${targetOrg} --manifest "${artifactPath}/package/package.xml" --post-destructive-changes "${artifactPath}/destructiveChanges/destructiveChanges.xml" --ignore-conflicts --async --verbose --test-level RunLocalTests --json`;
  console.log(command);
  return runSfCommand(command);
};

const quickDeploy = (
  artifactFolderName,
  artifactorySecret,
  artifactoryRepoName,
  targetOrg
) => {
  downloadZipFile(
    artifactFolderName,
    artifactorySecret,
    artifactoryRepoName,
    "Artifactory"
  );
  unzipFile(artifactFolderName);
  return deployWithoutTest(targetOrg, artifactFolderName);
};

const prodValidationWithAllTests = (
  artifactFolderName,
  artifactorySecret,
  artifactoryRepoName,
  targetOrg
) => {
  downloadZipFile(
    artifactFolderName,
    artifactorySecret,
    artifactoryRepoName,
    "Artifactory"
  );
  unzipFile(artifactFolderName);
  return validateWithAllTests(targetOrg, artifactFolderName);
};

const prodDeploymentWithAllTests = (
  artifactFolderName,
  artifactorySecret,
  artifactoryRepoName,
  targetOrg
) => {
  downloadZipFile(
    artifactFolderName,
    artifactorySecret,
    artifactoryRepoName,
    "Artifactory"
  );
  unzipFile(artifactFolderName);
  return deployWithAllTests(targetOrg, artifactFolderName);
};
const uploadJobId = (
  validationReport,
  fileName,
  artifactorySecret,
  artifactoryRepoName
) => {
  const jobId = findJobIdFromCommand(validationReport);
  if (!jobId) return;
  logger(`Upload Job Id to Artifactory: ${jobId}`);
  createFile(jobId, fileName, "Job Id");
  uploadFile(fileName, artifactorySecret, artifactoryRepoName, "Job Id");
  return jobId;
};

const cancel = (
  jobIdFileName,
  artifactorySecret,
  artifactoryRepoName,
  targetOrg,
  anzxCIPackage
) => {
  logger("Cancel Previous Running Jobs");
  downloadFile(jobIdFileName, artifactorySecret, artifactoryRepoName, "Job Id");
  const pastJobId = printContextFromFile(
    jobIdFileName,
    "| Cancel previous job."
  );
  if (!pastJobId || pastJobId.includes("File not found")) {
    console.log("No Running Job Found.");
    return;
  }

  console.log("Prevoius jobId: " + pastJobId);
  createDeployCacheFile(pastJobId, targetOrg, anzxCIPackage, anzxCIPackage);

  const report = runSfCommand(
    `npx sf project deploy report --job-id ${pastJobId} -o ${targetOrg} --json`
  );

  const prevJobStatus = JSON.parse(report)["result"]["status"];
  if (prevJobStatus !== "InProgress" && prevJobStatus !== "Pending") {
    console.log(`Past job: ${pastJobId} is already completed/canceled!`);
    return;
  }

  const command = `npx sf project deploy cancel --job-id ${pastJobId}`;
  console.log(command);
  runSfCommand(command);
};

const validateProgress = (
  validationReport,
  targetOrg,
  artifactPackage,
  artifactDestructivePackage
) => {
  const jobId = findJobIdFromCommand(validationReport);
  if (!jobId) {
    logger("No Job Id could be found");
    process.exit();
  }

  logger("Validation Progress");

  createDeployCacheFile(
    jobId,
    targetOrg,
    artifactPackage,
    artifactDestructivePackage
  );

  const command = `npx sf project deploy resume --job-id ${jobId}`;
  console.log(command);

  const validateProcess = exec(command);
  validateProcess.stdout.on("data", (data) => {
    try {
      const output = JSON.parse(data);
      if (output.status === 0) {
        console.log("Validation completed successfully");
        deployReport(jobId, "Validation");
      } else if (output.progress) {
        console.log(`Progress: ${output.progress}`);
      } else {
        console.log(data);
      }
    } catch (err) {
      console.log(data);
      deployReport(jobId, "Validation");
    }
  });

  validateProcess.stderr.on("data", (data) => {
    const dataReport = data.toString();
    if (dataReport.toLowerCase().includes("status")) {
      console.error(`Progress: ${data.toString()}`);
    }
  });

  validateProcess.on("close", (code) => {
    if (code !== 0) {
      console.error(`Validation failed with exit code: \n${code}`);
      deployReport(jobId, "Validation");
      process.exit(1);
    }
  });
};

const deployProgress = (
  deploymentCommand,
  targetOrg,
  artifactPackage,
  artifactDestructivePackage
) => {
  const jobId = findJobIdFromCommand(deploymentCommand);
  if (!jobId) process.exit();

  logger("Deployment Progress");

  createDeployCacheFile(
    jobId,
    targetOrg,
    artifactPackage,
    artifactDestructivePackage
  );

  const command = `npx sf project deploy resume --job-id ${jobId}`;
  console.log(command);

  const deployProcess = exec(command);
  deployProcess.stdout.on("data", (data) => {
    try {
      const output = JSON.parse(data);
      if (output.status === 0) {
        console.log("Deployment completed successfully");
        deployReport(jobId, "Deployment");
      } else if (output.progress) {
        console.log(`Progress: ${output.progress}`);
      } else {
        console.log(data);
      }
    } catch (err) {
      console.log(data);
      deployReport(jobId, "Deployment");
    }
  });

  deployProcess.stderr.on("data", (data) => {
    const dataReport = data.toString();
    if (dataReport.toLowerCase().includes("status")) {
      console.error(`Progress: ${data.toString()}`);
    }
  });

  deployProcess.on("close", (code) => {
    if (code !== 0) {
      console.error(`Deployment failed with exit code: \n${code}`);
      deployReport(jobId, "Deployment");
      process.exit(1);
    }
  });
};

const deployReport = (jobId, whichJob) => {
  logger(`${whichJob} Report`);
  console.log(runSfCommand(`npx sf project deploy report --job-id ${jobId}`));
};

// This code will find the json report for specific job
// Will find the test result and then the number of covered lines and not covered lines
// Then will print the apex code coverage
const codeCoverage = (jobIdFilePath, draftPR) => {
  const jobId = printContextFromFile(jobIdFilePath, "| Code Coverage");
  if (!jobId || jobId.includes("File not found")) return;

  logger("Apex Code Coverage");
  if (booleanMap(draftPR)) {
    console.log("Draft PR | No test");
    return;
  }

  const reportJson = JSON.parse(
    runSfCommand(`npx sf project deploy report --job-id ${jobId} --json`)
  );
  const runTestResult = reportJson["result"]["details"]["runTestResult"];
  const numTestsRun = runTestResult["numTestsRun"];
  if (!numTestsRun) {
    console.log("No test");
    return;
  }
  const codeCoverage = runTestResult["codeCoverage"];
  const coveredLines = codeCoverage.reduce((s, v) => s + +v.numLocations, 0);
  const notCoveredLines = codeCoverage.reduce(
    (s, v) => s + +v.numLocationsNotCovered,
    0
  );
  const percentage = (
    (1 - notCoveredLines / (coveredLines + notCoveredLines)) *
    100
  ).toFixed(2);

  console.log(`Apex test coverage: ${percentage}%`);
  return;
};

///////////////////////////////////////////

export {
  validateWithoutTest,
  validateWithSpecifiedTests,
  validateWithAllTests,
  prodValidationWithAllTests,
  prodDeploymentWithAllTests,
  deployWithoutTest,
  deployWithAllTests,
  cancel,
  validateProgress,
  deployProgress,
  deployReport,
  uploadJobId,
  codeCoverage,
  quickDeploy
};
