import { exec, execSync } from "child_process";
import {
  createArtifactFolder,
  renameForceignore
} from "./artifact-service.mjs";
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
  booleanMap,
  salesforceForceAppChangesExist,
  salesforceDestructiveChanges,
  loggerInStep,
  destructivePackageChangesExist,
  moveDestructiveFolderToForceApp
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

const validateWithAllTestsSkipDestructive = (targetOrg, artifactPath) => {
  logger("Running Validation | Skip Destrictive Changes | All Local Tests");
  if (!salesforceForceAppChangesExist(artifactPath)) return;
  const command = `npx sf project deploy start -o ${targetOrg} --manifest "${artifactPath}/package/package.xml" --dry-run --ignore-conflicts --async --verbose --test-level RunLocalTests --json`;
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

const deployWithoutTestSkipDestructive = (targetOrg, artifactPath) => {
  if (!destructivePackageChangesExist(artifactPath)) return;
  logger("Running Deployment | Skip Destrictive Changes | No Test");
  const command = `npx sf project deploy start -o ${targetOrg} --manifest "${artifactPath}/unpackaged/unpackaged/package.xml" --ignore-conflicts --async --verbose --json`;
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

const destructiveDeployment = (
  destructiveFolderName,
  artifactorySecret,
  artifactoryRepoName,
  targetOrg
) => {
  downloadZipFile(
    destructiveFolderName,
    artifactorySecret,
    artifactoryRepoName,
    "Destructive"
  );
  unzipFile(destructiveFolderName);
  moveDestructiveFolderToForceApp(destructiveFolderName);
  renameForceignore();
  return deployWithoutTestSkipDestructive(
    targetOrg,
    "force-app/" + destructiveFolderName
  );
};

const quickDeployment = (targetOrg, jobId) => {
  logger("Running Quick Deployment");
  const command = `npx sf project deploy quick -o ${targetOrg} --job-id ${jobId} --async --verbose --json`;
  console.log(command);
  return runSfCommand(command);
};

const quickDeploy = (
  jobIdFileName,
  artifactFolderName,
  artifactorySecret,
  artifactoryRepoName,
  targetOrg
) => {
  logger("Download Job Id and Artifact Folder");
  downloadFile(jobIdFileName, artifactorySecret, artifactoryRepoName, "Job Id");

  const pastJobId = printContextFromFile(
    jobIdFileName,
    "| Quick deployment job."
  );
  if (
    !pastJobId ||
    pastJobId.includes("File not found") ||
    pastJobId.includes("Invalid deploy ID")
  ) {
    console.log("No Running Job Found.");
    return;
  }

  downloadZipFile(
    artifactFolderName,
    artifactorySecret,
    artifactoryRepoName,
    "Artifactory"
  );
  unzipFile(artifactFolderName);

  console.log("Validated jobId: " + pastJobId);
  return quickDeployment(targetOrg, pastJobId);
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
  renameForceignore();
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
  renameForceignore();
  return deployWithAllTests(targetOrg, artifactFolderName);
};

const prodQuickDeployment = (
  jobIdFileName,
  artifactFolderName,
  artifactorySecret,
  artifactoryRepoName,
  targetOrg
) => {
  logger("Download Job Id and Artifact Folder");
  downloadFile(jobIdFileName, artifactorySecret, artifactoryRepoName, "Job Id");

  const pastJobId = printContextFromFile(
    jobIdFileName,
    "| Production Quick deployment job."
  );
  if (
    !pastJobId ||
    pastJobId.includes("File not found") ||
    pastJobId.includes("Invalid deploy ID")
  ) {
    console.log("No Running Job Found.");
    process.exit(1);
  }

  downloadZipFile(
    artifactFolderName,
    artifactorySecret,
    artifactoryRepoName,
    "Artifactory"
  );
  unzipFile(artifactFolderName);
  renameForceignore();
  return quickDeployment(targetOrg, pastJobId);
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

const createProdValidationJobIdFile = (validationReport, fileName) => {
  const jobId = findJobIdFromCommand(validationReport);
  if (!jobId) return;
  console.log(`Create Prod Validation Job Id File: ${jobId}`);
  createFile(jobId, fileName, "Validation Job Id ");
};

const uploadProdValidationJobIdFile = (
  filename,
  artifactorySecret,
  artifactoryRepoName
) => {
  logger(`Upload Prod Validation Job Id File: ${filename}`);
  uploadFile(
    filename,
    artifactorySecret,
    artifactoryRepoName,
    "Prod Validation Job Id"
  );
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
  if (
    !pastJobId ||
    pastJobId.includes("File not found") ||
    pastJobId.includes("Invalid deploy ID")
  ) {
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

const commandProgress = (
  command,
  targetOrg,
  artifactPackage,
  artifactDestructivePackage,
  whichJob
) => {
  const jobId = findJobIdFromCommand(command);
  if (!jobId) {
    logger("No Job Id could be found.");
    process.exit();
  }

  logger(`${whichJob} Progress`);

  createDeployCacheFile(
    jobId,
    targetOrg,
    artifactPackage,
    artifactDestructivePackage
  );

  const resumeCommand = `npx sf project deploy resume --job-id ${jobId}`;
  console.log(resumeCommand);

  const runCommandProcess = exec(resumeCommand);
  runCommandProcess.stdout.on("data", (data) => {
    try {
      const output = JSON.parse(data);
      if (output.status === 0) {
        console.log(`${whichJob} completed successfully`);
        deployReport(jobId, targetOrg, whichJob);
      } else if (output.progress) {
        console.log(`Progress: ${output.progress}`);
      } else {
        console.log(data);
      }
    } catch (err) {
      console.log(data);
    }
  });

  runCommandProcess.stderr.on("data", (data) => {
    const dataReport = data.toString();
    if (dataReport.toLowerCase().includes("status")) {
      console.error(`Progress: ${data.toString()}`);
    }
  });

  runCommandProcess.on("close", (code) => {
    if (code !== 0) {
      const report = commandReport(jobId, targetOrg);
      const status = JSON.parse(report)["result"]["status"];
      if (status !== "InProgress" && status !== "Pending") {
        console.error(`${whichJob} failed with exit code: \n${code}`);
        deployReport(jobId, targetOrg, whichJob);
        process.exit(1);
      } else {
        return commandProgress(
          command,
          targetOrg,
          artifactPackage,
          artifactDestructivePackage,
          whichJob
        );
      }
    }
  });
};

const commandReport = (jobId, targetOrg) =>
  runSfCommand(
    `npx sf project deploy report --job-id ${jobId} -o ${targetOrg} --json`
  );

const validateProgress = (
  validationReport,
  targetOrg,
  artifactPackage,
  artifactDestructivePackage
) =>
  commandProgress(
    validationReport,
    targetOrg,
    artifactPackage,
    artifactDestructivePackage,
    "Validation"
  );

const quickDeployProgress = (
  quickDeploymentCommand,
  targetOrg,
  artifactPackage,
  artifactDestructivePackage
) =>
  commandProgress(
    quickDeploymentCommand,
    targetOrg,
    artifactPackage,
    artifactDestructivePackage,
    "Quick Deployment"
  );

const deployProgress = (
  deploymentCommand,
  targetOrg,
  artifactPackage,
  artifactDestructivePackage
) =>
  commandProgress(
    deploymentCommand,
    targetOrg,
    artifactPackage,
    artifactDestructivePackage,
    "Deployment"
  );

const deployReport = (jobId, targetOrg, whichJob) => {
  logger(`${whichJob} Report`);
  console.log(
    runSfCommand(
      `npx sf project deploy report --job-id ${jobId} -o ${targetOrg}`
    )
  );
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

const retrieveDestructiveFiles = (
  targetOrg,
  artifactPath,
  destructivePackageXMLPath,
  targetFolderPath
) => {
  logger("Running Retrieve | All Destructive Changes");
  if (!salesforceDestructiveChanges(artifactPath)) {
    loggerInStep("There is no Destructive changes to be retrieved.");
    return;
  }
  createArtifactFolder(targetFolderPath);
  const command = `npx sf project retrieve start -o "${targetOrg}" --manifest "${destructivePackageXMLPath}" --target-metadata-dir "${targetFolderPath}" --unzip --wait 20 --json`;
  console.log(command);
  return runSfCommand(command);
};

///////////////////////////////////////////

export {
  validateWithoutTest,
  validateWithSpecifiedTests,
  validateWithAllTests,
  validateWithAllTestsSkipDestructive,
  prodValidationWithAllTests,
  prodDeploymentWithAllTests,
  prodQuickDeployment,
  deployWithoutTest,
  deployWithoutTestSkipDestructive,
  deployWithAllTests,
  retrieveDestructiveFiles,
  destructiveDeployment,
  cancel,
  validateProgress,
  deployProgress,
  deployReport,
  quickDeployProgress,
  uploadJobId,
  createProdValidationJobIdFile,
  uploadProdValidationJobIdFile,
  codeCoverage,
  quickDeploy
};
