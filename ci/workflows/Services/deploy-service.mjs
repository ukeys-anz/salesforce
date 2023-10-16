import { exec } from "child_process";
import { createWriteStream } from "fs";
import {
  runSfCommand,
  findJobId,
  salesforceDiffExist,
  findAllSpecifiedTests,
  findJobIdFromCommand,
  logger
} from "./helper.mjs";

const validateWithoutTest = (targetOrg) => {
  if (!salesforceDiffExist()) return;
  const command = `npx sf project deploy start -o ${targetOrg} -d artifact --dry-run --ignore-conflicts --async --verbose --json`;
  logger(command);
  return runSfCommand(command);
};

const validateWithAllTests = (targetOrg) => {
  if (!salesforceDiffExist()) return;
  const command = `npx sf project deploy start -o ${targetOrg} -d artifact --dry-run --ignore-conflicts --async --verbose --test-level RunLocalTests --json`;
  logger(command);
  return runSfCommand(command);
};

const validateWithSpecifiedTests = (targetOrg, classFolderPath) => {
  if (!salesforceDiffExist()) return;
  let command = `npx sf project deploy start -o ${targetOrg} -d artifact --dry-run --ignore-conflicts --async --verbose --test-level RunSpecifiedTests`;

  const specifiedTestsArray = findAllSpecifiedTests(classFolderPath);
  if (!specifiedTestsArray.length) {
    console.error("ERROR: No Specifed tests found.");
    process.exit(1);
  }

  const allSpecifiedTests = " -t " + specifiedTestsArray.join(" -t ");
  command += allSpecifiedTests + " --json";

  logger(command);
  return runSfCommand(command);
};

const deployWithoutTest = (targetOrg) => {
  if (!salesforceDiffExist()) return;
  const command = `npx sf project deploy start -o ${targetOrg} -d artifact --ignore-conflicts --async --verbose --json`;
  logger(command);
  return runSfCommand(command);
};

const deployWithAllTests = (targetOrg) => {
  if (!salesforceDiffExist()) return;
  const command = `npx sf project deploy start -o ${targetOrg} -d artifact --ignore-conflicts --async --verbose --test-level RunLocalTests --json`;
  logger(command);
  return runSfCommand(command);
};

// This will create a file and will put the job Id into it.
// The file should be uploaded from artifactory as if we raise a new commit, it will find it and -
// will cancel the previous job.
// Another scenario to use this is to find the job id and run the resume command to check the deployment progress.
const findAndUploadJobId = (validationReport, branchName) => {
  const jobId = findJobIdFromCommand(validationReport);
  if (!jobId) process.exit();
  logger(`Job Id : ${jobId}`);

  const createFile = createWriteStream(`${branchName}.txt`);
  createFile.write(jobId);
  createFile.end();
  // we should upload this txt file to artifactory
  // this txt file will have the jobId and we can -
  // - use it for cancel jobId, if another commit is raised
};

const cancel = (jobIdFilePath) => {
  // At first we should download the file which contain the jobId from artifactory.
  // This will give us the current running jobId
  // Then we can cancel that and run a new job, when we raise a new commit
  const jobId = findJobId(jobIdFilePath);
  if (!jobId) return;
  const command = `npx sf project deploy cancel --job-id ${jobId}`;
  logger(command);
  return runSfCommand(command);
};

const validateProgress = (jobIdFilePath) => {
  const jobId = findJobId(jobIdFilePath);
  if (!jobId) process.exit();

  const command = `npx sf project deploy resume --job-id ${jobId}`;
  logger(command);

  const validateProcess = exec(command);
  validateProcess.stdout.on("data", (data) => {
    try {
      const output = JSON.parse(data);
      if (output.status === 0) {
        console.log("Validation completed successfully");
      } else if (output.progress) {
        console.log(`Progress: ${output.progress}`);
      } else {
        console.log(data);
      }
    } catch (err) {
      console.log(data);
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
    }
  });
};

const deployProgress = (deploymentCommand) => {
  const jobId = findJobIdFromCommand(deploymentCommand);
  if (!jobId) process.exit();

  const command = `npx sf project deploy resume --job-id ${jobId}`;
  logger(command);

  const deployProcess = exec(command);
  deployProcess.stdout.on("data", (data) => {
    try {
      const output = JSON.parse(data);
      if (output.status === 0) {
        console.log("Deployment completed successfully");
      } else if (output.progress) {
        console.log(`Progress: ${output.progress}`);
      } else {
        console.log(data);
      }
    } catch (err) {
      console.log(data);
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
    }
  });
};

const deployReport = (jobIdFilePath) => {
  const jobId = findJobId(jobIdFilePath);
  if (!jobId) process.exit();
  return runSfCommand(`npx sf project deploy report --job-id ${jobId}`);
};

// This code will find the json report for specific job
// Will find the test result and then the number of covered lines and not covered lines
// Then will print the apex code coverage
const codeCoverage = (jobIdFilePath) => {
  const jobId = findJobId(jobIdFilePath);
  if (!jobId) return;

  const reportJson = JSON.parse(
    runSfCommand(`npx sf project deploy report --job-id ${jobId} --json`)
  );
  const runTestResult = reportJson["result"]["details"]["runTestResult"];
  const numTestsRun = runTestResult["numTestsRun"];
  if (!numTestsRun) {
    console.log("Draft PR | No test");
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

  logger(`Apex test coverage: ${percentage}%`);
  return;
};

///////////////////////////////////////////

export {
  validateWithoutTest,
  validateWithSpecifiedTests,
  validateWithAllTests,
  deployWithoutTest,
  deployWithAllTests,
  cancel,
  validateProgress,
  deployProgress,
  deployReport,
  findAndUploadJobId,
  codeCoverage
};
