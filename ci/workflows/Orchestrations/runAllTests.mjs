// Run All Tests Orchestration

/// Import different function from different services.
import {
  authenticate,
  unauthenticate
} from "../Services/authentication-service.mjs";
import { uploadJobId, cancel } from "../Services/deploy-service.mjs";
import { deleteFile, renameItem } from "../Services/helper.mjs";
import {
  runAllLocalTestsProgress,
  runAllLocalTests
} from "../Services/run-all-test-service.mjs";

//////////

/// Find all the env variables & other variables values

const {
  WHICH_JOB,
  BASE_REF,
  SFDX_URL,
  TARGET_BASE_REF,
  PR_NUMBER,
  ARTIFACTORY_SECRET_VALUE,
  WORKING_DIR
} = process.env;

const RUN_ALL_TEST_PACKAGE_PATH = "ci/workflows/RunAllTestsPackage";
const RUN_ALL_TEST_CLASS_PATH =
  "ci/workflows/RunAllTestsPackage/RunAllTestsClass.cls";
const JOB_ID_FILE_NAME = renameItem(`${BASE_REF}-run-all-tests-${PR_NUMBER}`);
const ANZX_CI_PACKAGE_XML =
  WORKING_DIR + "/ci/workflows/Config/ANZxCIPackage.xml";
const ARTIFACT_PACKAGE_XML =
  WORKING_DIR + "/ci/workflows/RunAllTestsPackage/package.xml";

//////////

/// functions

const findProperSecret = () => {
  const branchMapping = {
    master: "develop"
  };
  console.log(branchMapping[BASE_REF]);
};

const runAllTests = () => {
  const TARGET_ORG = `run-all-tests-${TARGET_BASE_REF}`;
  authenticate(TARGET_ORG, SFDX_URL);
  cancel(
    JOB_ID_FILE_NAME,
    ARTIFACTORY_SECRET_VALUE,
    TARGET_ORG,
    ANZX_CI_PACKAGE_XML
  );
  const runAllTestsReport = runAllLocalTests(
    TARGET_ORG,
    RUN_ALL_TEST_CLASS_PATH
  );
  uploadJobId(runAllTestsReport, JOB_ID_FILE_NAME, ARTIFACTORY_SECRET_VALUE);
  runAllLocalTestsProgress(runAllTestsReport, TARGET_ORG, ARTIFACT_PACKAGE_XML);
};

const clean = () => {
  unauthenticate(TARGET_ORG);
  deleteFile(JOB_ID_FILE_NAME);
};
//////////

/// Run Tests

const runTests = () => {
  const runFunctionMapping = {
    findProperSecret: findProperSecret,
    runAllTests: runAllTests,
    clean: clean
  };

  return WHICH_JOB ? runFunctionMapping[WHICH_JOB]() : findProperSecret();
};

runTests();
