// Run All Tests Orchestration

/// Import different function from different services.
import {
  authenticate,
  unauthenticate
} from "../Services/authentication-service.mjs";
import {
  runAllLocalTestsProgress,
  runAllTestsProgress
} from "../Services/run-all-test-service.mjs";

//////////

/// Find all the env variables & other variables values

const { WHICH_JOB, BASE_REF, SFDX_URL } = process.env;

const RUN_ALL_TEST_PACKAGE_PATH = "ci/workflows/RunAllTestsPackage";
const RUN_ALL_TEST_CLASS_PATH =
  "ci/workflows/RunAllTestsPackage/RunAllTestsClass.cls";
const BRANCH_NAME = findProperSecret(BASE_REF);

//////////

/// functions

const findProperSecret = () => {
  const branchMapping = {
    master: "develop"
  };
  return branchMapping[BASE_REF];
};

const runAllTests = () => {
  authenticate(BRANCH_NAME, SFDX_URL);
  runAllTestsProgress(BRANCH_NAME, RUN_ALL_TEST_CLASS_PATH);
};

const clean = () => {
  unauthenticate(BRANCH_NAME);
};

/////////

/// Run Tests

const runTests = () => {
  const runFunctionMapping = {
    runAllTests: runAllTests,
    clean: clean
  };

  return WHICH_JOB ? runFunctionMapping[WHICH_JOB]() : runAllTests();
};

runTests();
