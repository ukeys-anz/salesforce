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
  validateProgress,
  deployReport,
  uploadJobId,
  codeCoverage
} from "../Services/deploy-service.mjs";
import { booleanMap, deleteFolder, logger } from "../Services/helper.mjs";

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
const SOURCE_DIR = `artifact-${BRANCH_NAME}`;
const CLASS_FOLDER_PATH = `${SOURCE_DIR}/force-app/main/default/classes`;
// This should be change to the project name later
const PROJECT_NAME = "xxxx";

//////////

/// functions

const validationFunction = () => {
  const draftPr = booleanMap(DRAFT_PR);
  const specifiedTestsPR = booleanMap(SPECIFIED_TEST_PR);
  const testMapping = {
    NoTest: draftPr,
    SpecifiedTests: specifiedTestsPR,
    AllTests: !(draftPr || specifiedTestsPR)
  };

  const validationFunctionMapping = {
    NoTest: validateWithoutTest,
    SpecifiedTests: validateWithSpecifiedTests,
    AllTests: validateWithAllTests
  };

  const chosenTest = Object.keys(testMapping).filter((k) => testMapping[k])[0];
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
  const validation = validationFunc(BRANCH_NAME, SOURCE_DIR, CLASS_FOLDER_PATH);
  uploadJobId(validation, BRANCH_NAME);
  validateProgress(validation);
};

const clean = () => {
  codeCoverage(JOB_ID_PATH);
  unauthenticate(BRANCH_NAME);
  logger(deleteFolder(SOURCE_DIR));
};

/////////

/// Run CI

const runCI = () => {
  const runFunctionMapping = {
    validation: validate,
    clean: clean
  };

  return WHICH_JOB ? runFunctionMapping[WHICH_JOB]() : validate();
};

runCI();
