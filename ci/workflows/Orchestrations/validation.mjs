// Validation Orchestration

/// Import different function from different services.

import { uploadArtifact } from "../Services/artifact-service.mjs";
import {
  authenticate,
  unauthenticate
} from "../Services/authentication-service.mjs";
import {
  validateWithoutTest,
  validateWithSpecifiedTests,
  validateWithAllTests,
  cancel,
  deployProgress,
  deployReport,
  findAndUploadJobId,
  codeCoverage
} from "../Services/deploy-service.mjs";

//////////

/// Find all the env variables & other variables values

const {
  WHICH_JOB,
  BASE_REF,
  BRANCH_NAME,
  SFDX_URL,
  DRAFT_PR,
  SPECIFIED_TEST_PR,
  ARTIFACTORY_SECRET_VALUE
} = process.env;

const JOB_ID_PATH = `${BRANCH_NAME}.txt`;
const SOURCE_DIR = "artifact";
const CLASS_FOLDER_PATH = `${SOURCE_DIR}/force-app/main/default/classes`;
// This should be change to the project name later
const PROJECT_NAME = "xxxx";

//////////

/// functions

const validationFunction = () => {
  const testMapping = {
    NoTest: DRAFT_PR,
    SpecifiedTests: SPECIFIED_TEST_PR,
    AllTests: !(DRAFT_PR || SPECIFIED_TEST_PR)
  };

  const validationFunctionMapping = {
    NoTest: validateWithoutTest,
    SpecifiedTests: validateWithSpecifiedTests,
    AllTests: validateWithAllTests
  };

  const chosenTest = Object.keys(testMapping).filter((k) => testMapping[k]);
  return validationFunctionMapping[chosenTest];
};

const validate = () => {
  uploadArtifact(
    SOURCE_DIR,
    BASE_REF,
    BRANCH_NAME,
    ARTIFACTORY_SECRET_VALUE,
    PROJECT_NAME
  );
  authenticate(BRANCH_NAME, SFDX_URL);
  cancel(JOB_ID_PATH);
  const validationFunc = validationFunction();
  const validation = validationFunc(BRANCH_NAME, CLASS_FOLDER_PATH);
  findAndUploadJobId(validation, BRANCH_NAME);
  deployProgress(JOB_ID_PATH);
};

const clean = () => {
  codeCoverage(JOB_ID_PATH);
  unauthenticate(BRANCH_NAME);
};

/////////

/// Run CI

const runCI = () => {
  const runFunctionMapping = {
    validation: validate,
    clean: clean
  };

  return runFunctionMapping[WHICH_JOB]();
};

runCI();
