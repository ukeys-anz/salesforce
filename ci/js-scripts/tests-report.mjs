import { findJobIdFromCommand } from "../workflows/Services/helper.mjs";
import { runAllLocalTests } from "../workflows/Services/run-all-test-service.mjs";
import { execSync } from "child_process";
import {readFileSync, writeFileSync} from "fs"

const RUN_ALL_TEST_CLASS_PATH =
  "ci/workflows/RunAllTestsPackage/RunAllTestsClass.cls";

// TARGET_ORG : should be the org that you run the tests against it and already authenticated
// WHICH_JOB : should be: 
//             - createJson : to create the json file out of report
//             - reportResult: to give us a json file whith method-time key-value object
const TARGET_ORG = 'test24';
const WHICH_JOB = 'createJson'

if (!TARGET_ORG || !WHICH_JOB) {
    console.error(`No ${!TARGET_ORG ? 'target org' : 'job'} has been selected!!`)
    process.exit()
}

/// methods

// This will update the cacheFile for sf job to run and wait for 120 mins
const updateDeployCasheFile = (jobId) => {
    const homeDir = execSync(`echo $HOME`)
    const deployCacheFile = `${homeDir}/.sf/deploy-cache.json`.replace("\n", "");
    let jsonFile = {};
    const data = readFileSync(deployCacheFile);
    jsonFile = JSON.parse(data);
    jsonFile[jobId]['wait'] = 120
    writeFileSync(deployCacheFile, JSON.stringify(jsonFile));
}

// This will create a json file out of report
const creatingReportJsonFile = (targetOrg, runAllTestPackage) => {
    const runAllTestsReport = runAllLocalTests(
        targetOrg,
        runAllTestPackage
    );
    const jobId = findJobIdFromCommand(runAllTestsReport);
    if (!jobId) process.exit();

    updateDeployCasheFile(jobId)

    const command = `npx sf project deploy resume --job-id ${jobId} --json > testReport.json`;
    console.log(command);
    execSync(command);
}

// This will prepare the json file to be used on other methods to prepare the report
const reportDetail = (jsonFilePath) => {
    const fileContext = readFileSync(jsonFilePath).toString();
    const res = JSON.parse(fileContext)
    return res
}

// This will prepare the result out of json file
const reportResult = (jsonReport,key = 'method') => {
    const res = {'method': {} , 'time' : {}}
    jsonReport.forEach(o => {
        res['time'][o.time] = o.name + '.' + o.methodName;
        res['method'][o.name + '.' + o.methodName] = o.time;
    })
    return res[key]
}

// This will gives us the result
const testReport = (jsonFilePath, key='method') => {
    const report = reportDetail(jsonFilePath)
    let result = {}
    const succeedTests = report.result.details.runTestResult.successes;
    const failedTests = report.result.details.runTestResult.failures;
    result = {...result, ...reportResult(succeedTests, key), ...reportResult(failedTests, key)}
    return result;
}

// According to the WHICH_JOB, this will either create the json file, or the report
const runTestReport = (whichJob) => whichJob === 'createJson' ? creatingReportJsonFile(TARGET_ORG, RUN_ALL_TEST_CLASS_PATH) : testReport('testReport.json')

console.log(runTestReport(WHICH_JOB))

// You should run this command to have the result: node ci/js-scripts/tests-report.mjs > reportTest.json
// this will echo the result to reportTest.json file