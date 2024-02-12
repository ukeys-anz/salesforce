import { exec } from "child_process";
import {
  runSfCommand,
  findJobIdFromCommand,
  logger,
  createDeployCacheFile
} from "./helper.mjs";
import { deployReport } from "./deploy-service.mjs";

// We are using sfdx command here, as it seems there is no equivalent command on sf to run tests -
// - using sf project commands.
// POINT: not in use now
const runAllLocalTestsSFDX = (targetOrg, runAllTestPackagePath) => {
  return runSfCommand(
    `npx sfdx force:source:deploy -u ${targetOrg} -c -d ${runAllTestPackagePath} -l RunLocalTests --json`
  );
};

// POINT: not in use now
const runAllLocalTestsProgressSFDX = (targetOrg, runAllTestPackagePath) => {
  const command = runAllLocalTests(targetOrg, runAllTestPackagePath);
  const jobId = findJobIdFromCommand(command);
  if (!jobId) {
    console.error("Error Running all local tests.");
    process.exit(1);
  }
  const runAllTestsReportSFDX = exec(
    `npx sfdx force:mdapi:deploy:report -i ${jobId} -u ${targetOrg} -w 60 --verbose`
  );
  runAllTestsReport.stdout.on("data", (data) => {
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

  runAllTestsReport.stderr.on("data", (data) => {
    const dataReport = data.toString();
    if (dataReport.toLowerCase().includes("status")) {
      console.error(`Progress: ${data.toString()}`);
    }
  });

  runAllTestsReport.on("close", (code) => {
    if (code !== 0) {
      console.error(`Validation failed with exit code: \n${code}`);
    }
  });
};

// If we want to use sf project command, we should choose one class to run the fake validation -
// - with running all the tests.

const runAllLocalTests = (targetOrg, runAllTestClassPath) => {
  logger("Run All Tests");
  const command = `npx sf project deploy start -o ${targetOrg} -d ${runAllTestClassPath} --dry-run --ignore-conflicts --async --verbose --test-level RunLocalTests --json`;
  console.log(command);
  return runSfCommand(command);
};

const runAllLocalTestsProgress = (
  runAllTestsReport,
  targetOrg,
  runAllTestPackage
) => {
  const jobId = findJobIdFromCommand(runAllTestsReport);
  if (!jobId) process.exit();

  logger("Run All Tests Progress");

  createDeployCacheFile(jobId, targetOrg, runAllTestPackage, runAllTestPackage);

  const command = `npx sf project deploy resume --job-id ${jobId}`;
  console.log(command);

  const runAllTestsProcess = exec(command);
  runAllTestsProcess.stdout.on("data", (data) => {
    try {
      const output = JSON.parse(data);
      if (output.status === 0) {
        console.log("All Tests completed successfully");
      } else if (output.progress) {
        console.log(`Progress: ${output.progress}`);
      } else {
        console.log(data);
      }
    } catch (err) {
      console.log(data);
    }
  });

  runAllTestsProcess.stderr.on("data", (data) => {
    const dataReport = data.toString();
    if (dataReport.toLowerCase().includes("status")) {
      console.error(`Progress: ${data.toString()}`);
    }
  });

  runAllTestsProcess.on("close", (code) => {
    if (code !== 0) {
      console.error(`Tests failed with exit code: \n${code}`);
      deployReport(jobId, "Run All Tests");
      process.exit(1);
    }
  });
};

/////

export { runAllLocalTestsProgress, runAllLocalTests };
