import { exec } from "child_process";
import { readFileSync } from "fs";
import {
  runSfCommand,
  findJobIdFromCommand,
  logger,
  createDeployCacheFile,
  printContextFromFile,
  createReportFile
} from "./helper.mjs";
import { deployReport, runAllTestsProgress } from "./deploy-service.mjs";

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

const runAllLocalTestsProgress = async (
  runAllTestsReport,
  targetOrg,
  runAllTestPackage
) =>
  await runAllTestsProgress(
    runAllTestsReport,
    targetOrg,
    runAllTestPackage,
    runAllTestPackage
  );

const createReportJSONFile = (jobId, targetOrg, anzxCIPackage) => {
  console.log("Previous jobId: " + jobId);
  createDeployCacheFile(jobId, targetOrg, anzxCIPackage, anzxCIPackage);
  try {
    const command = `npx sf project deploy report --job-id ${jobId} -o ${targetOrg} --json`;
    console.log(command);
    const output = runSfCommand(command);
    createReportFile(output, "testReport.json", "Test Report");
  } catch (error) {
    console.log(`Job (${jobId}) has some issues...`);
    return;
  }
};

// This will prepare the json file to be used on other methods to prepare the report
const reportDetail = (jsonFilePath) => {
  const fileContext = readFileSync(jsonFilePath).toString();
  const res = JSON.parse(fileContext);
  return res;
};

// This will prepare the result out of json file
const reportResult = (jsonReport, key = "method") => {
  const res = { method: {}, time: {} };
  jsonReport.forEach((o) => {
    res["time"][o.time] = o.name + "." + o.methodName;
    res["method"][o.name + "." + o.methodName] = o.time;
  });
  return res[key];
};

// This will gives us the result
const testReport = (jsonFilePath = "testReport.json", key = "method") => {
  const report = reportDetail(jsonFilePath);
  let result = {};
  const succeedTests = report.result.details.runTestResult.successes;
  const failedTests = report.result.details.runTestResult.failures;
  result = {
    ...result,
    ...reportResult(succeedTests, key),
    ...reportResult(failedTests, key)
  };
  return result;
};

const parseTestName = (key) => {
  const parts = key.split(".");
  return parts.slice(0, -1).join(".");
};

const getCategory = (value) => {
  return Math.floor(value / 500) + 1;
};

const calculateMedian = (values) => {
  const sorted = [...values].sort((a, b) => a - b);
  const mid = Math.floor(sorted.length / 2);
  return sorted.length % 2 === 0
    ? (sorted[mid - 1] + sorted[mid]) / 2
    : sorted[mid];
};

const prepareReportInfo = () => {
  const rawData = testReport();
  const entries = Object.entries(rawData);
  const totalMethods = entries.length;
  const values = entries.map(([, value]) => value);
  const average = values.reduce((a, b) => a + b, 0) / values.length;
  const median = calculateMedian(values);
  // Output
  console.log("\n--- Overall Stats ---");
  console.log(`Total Methods: ${totalMethods}`);
  console.log(`Average Time: ${average.toFixed(2)}`);
  console.log(`Median Time: ${median}`);
  return { entries, totalMethods };
};

const categorization = (entries, totalMethods) => {
  const categories = {};
  for (const [key, value] of entries) {
    const category = getCategory(value);
    if (!categories[category]) categories[category] = [];
    categories[category].push({ method: key, value });
  }

  console.log("\n--- Categories ---");
  let catIndex = 1;
  for (const [catStr, methods] of Object.entries(categories)) {
    const cat = Number(catStr);
    const lower = (cat - 1) * 500;
    const upper = cat * 500 - 1;
    const count = methods.length;
    const percent = ((count / totalMethods) * 100).toFixed(2);

    const times = methods.map((m) => m.value);
    const max = Math.max(...times);
    const min = Math.min(...times);

    console.log(`\nCategory ${catIndex} (${lower} - ${upper}):`);
    console.log(`  Number of Methods: ${count}`);
    console.log(`  Percentage of Total: ${percent}%`);
    console.log(`  Max Time: ${max}`);
    console.log(`  Min Time: ${min}`);
    console.log(`  Methods:`);
    methods.forEach(({ method, value }) => {
      console.log(`    ${method}: ${value}`);
    });
    catIndex++;
  }
};

const testReportSummary = (entries) => {
  const testSummary = {};
  for (const [key, value] of entries) {
    const testName = parseTestName(key);
    testSummary[testName] = (testSummary[testName] || 0) + value;
  }
  console.log("\n--- Test Summary | Test: time to finish all test methods ---");
  for (const [test, total] of Object.entries(testSummary)) {
    console.log(`  ${test}: ${total}`);
  }
};

const detailedReport = (
  jobIdInput,
  jobIdFileName,
  targetOrg,
  anzxCIPackage
) => {
  logger("Prepare Unit Tests Report");
  let jobId = jobIdInput;
  if (!jobId) {
    console.log("jobIdFileName: " + jobIdFileName);
    jobId = printContextFromFile(jobIdFileName, "| Detailed Unit Test Report.");
  }

  if (
    !jobId ||
    jobId.includes("File not found") ||
    jobId.includes("Invalid deploy ID")
  ) {
    console.log("Job Id not found...");
    return;
  }

  createReportJSONFile(jobId, targetOrg, anzxCIPackage);
  const { entries, totalMethods } = prepareReportInfo();
  categorization(entries, totalMethods);
  testReportSummary(entries);
};

/////

export { runAllLocalTestsProgress, runAllLocalTests, detailedReport };
