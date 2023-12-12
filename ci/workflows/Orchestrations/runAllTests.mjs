// Run All Tests Orchestration

/// Import different function from different services.
import {
  authenticate,
  unauthenticate
} from "../Services/authentication-service.mjs";
import { uploadJobId, cancel } from "../Services/deploy-service.mjs";
import { findSecretName } from "../Services/find-secret-service.mjs";
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
  PR_NUMBER,
  ARTIFACTORY_SECRET_VALUE,
  WORKING_DIR,
  REPO_NAME
} = process.env;

const RUN_ALL_TEST_PACKAGE_PATH = "ci/workflows/RunAllTestsPackage";
const ARTIFACTORY_REPO_NAME = `anzx-${REPO_NAME}-releases-np`;
const TARGET_ORG = `run-all-tests-${BASE_REF}`;
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
  console.log(findSecretName(branchMapping[BASE_REF], REPO_NAME));
};

const runAllTests = () => {
  authenticate(TARGET_ORG, SFDX_URL);
  cancel(
    JOB_ID_FILE_NAME,
    ARTIFACTORY_SECRET_VALUE,
    ARTIFACTORY_REPO_NAME,
    TARGET_ORG,
    ANZX_CI_PACKAGE_XML
  );
  const runAllTestsReport = runAllLocalTests(
    TARGET_ORG,
    RUN_ALL_TEST_CLASS_PATH
  );
  uploadJobId(
    runAllTestsReport,
    JOB_ID_FILE_NAME,
    ARTIFACTORY_SECRET_VALUE,
    ARTIFACTORY_REPO_NAME
  );
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
