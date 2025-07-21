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
  runCommand,
  salesforceForceAppChangesExist,
  salesforceDestructiveChanges,
  loggerInStep,
  destructivePackageChangesExist,
  moveDestructiveFolderToForceApp,
  runSpawnCommand
} from "./helper.mjs";

const POLL_INTERVAL = 15 * 1000; // 15 seconds
const TIMEOUT_MS = 2 * 60 * 60 * 1000; // 2 hour timeout

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
  try {
    const report = runCommand(
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
  } catch (error) {
    console.log(`Prevoius job (${pastJobId}) has already been completed...`);
    return;
  }
};

const logDeployProgress = (status, reportResult, whichJob) => {
  if (status === "Pending") {
    console.log(
      `⏳ ${whichJob} is pending — waiting for the org to start the job...`
    );
    return;
  }

  const {
    numberTestsCompleted,
    numberTestsTotal,
    numberTestErrors,
    numberComponentsTotal,
    numberComponentsDeployed,
    numberComponentErrors,
    stateDetail
  } = reportResult || {};

  const hasTests = numberTestsTotal > 0;

  const logParts = [`🔧 ${whichJob} Progress`];

  if (hasTests) {
    logParts.push(
      `🧪 Running Tests: ${numberTestsCompleted}/${numberTestsTotal}`
    );
    if (numberTestErrors) {
      logParts.push(`❌ Errors: ${numberTestErrors}`);
    }
  } else {
    logParts.push(
      `📦 Components: ${numberComponentsDeployed}/${numberComponentsTotal}`
    );
    if (numberComponentErrors) {
      logParts.push(`❌ Errors: ${numberComponentErrors}`);
    }
  }

  if (stateDetail) {
    logParts.push(`ℹ️ ${stateDetail}`);
  }

  console.log(logParts.join(" | "));
};

const commandProgress = async (
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

  logger(`🔄 ${whichJob} Progress`);

  createDeployCacheFile(
    jobId,
    targetOrg,
    artifactPackage,
    artifactDestructivePackage
  );

  const start = Date.now();

  const pollDeployStatus = async () => {
    if (Date.now() - start > TIMEOUT_MS) {
      console.error(`⏰ ${whichJob} timed out after 2 hour.`);
      process.exit(1);
    }

    let report;
    try {
      report = await runSpawnCommand(jobId);
    } catch (err) {
      console.error("❌ Failed on report output:", err);
      deployReport(jobId, targetOrg, whichJob);
    }

    const status = report?.result?.status;

    if (status === "Succeeded") {
      console.log(`✅ ${whichJob} completed successfully.`);
      deployReport(jobId, targetOrg, whichJob);
    } else if (status === "Failed" || status === "Canceled") {
      console.error(`❌ ${whichJob} failed with status: ${status}`);
      deployReport(jobId, targetOrg, whichJob);
      process.exit(1);
    } else if (status === "InProgress" || status === "Pending") {
      logDeployProgress(status, report?.result, whichJob);
      setTimeout(pollDeployStatus, POLL_INTERVAL);
    } else {
      console.warn(`⚠️ Unexpected status: ${status}`);
      setTimeout(pollDeployStatus, POLL_INTERVAL);
    }
  };

  await pollDeployStatus(); // start polling
};

const commandReport = (jobId, targetOrg) =>
  runSfCommand(
    `npx sf project deploy report --job-id ${jobId} -o ${targetOrg} --json`
  );

const validateProgress = async (
  validationReport,
  targetOrg,
  artifactPackage,
  artifactDestructivePackage
) => {
  await commandProgress(
    validationReport,
    targetOrg,
    artifactPackage,
    artifactDestructivePackage,
    "Validation"
  );
};

const quickDeployProgress = async (
  quickDeploymentCommand,
  targetOrg,
  artifactPackage,
  artifactDestructivePackage
) => {
  await commandProgress(
    quickDeploymentCommand,
    targetOrg,
    artifactPackage,
    artifactDestructivePackage,
    "Quick Deployment"
  );
};

const deployProgress = async (
  deploymentCommand,
  targetOrg,
  artifactPackage,
  artifactDestructivePackage
) => {
  await commandProgress(
    deploymentCommand,
    targetOrg,
    artifactPackage,
    artifactDestructivePackage,
    "Deployment"
  );
};

const deployReport = (jobId, targetOrg, whichJob) => {
  logger(`${whichJob} Report`);
  console.log(
    runSfCommand(
      `npx sf project deploy report --job-id ${jobId} -o ${targetOrg}`
    )
  );
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
  quickDeploy
};
