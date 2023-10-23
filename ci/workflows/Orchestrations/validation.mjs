// Validation Orchestration

/// Import different function from different services.

import { createAndUploadArtifact } from "../Services/artifact-service.mjs";
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
import { booleanMap, deleteFolder, deleteFile } from "../Services/helper.mjs";

//////////

/// Find all the env variables & other variables values

const {
  WHICH_JOB,
  BASE_REF,
  BRANCH_NAME,
  SFDX_URL,
  DRAFT_PR,
  SPECIFIED_TEST_PR,
  ARTIFACTORY_SECRET_VALUE,
  PR_NUMBER,
  WORKING_DIR
} = process.env;

const SOURCE_DIR = `artifact-${BRANCH_NAME}`;
const CLASS_FOLDER_PATH = `${SOURCE_DIR}/force-app/main/default/classes`;
const JOB_ID_FILE_NAME = `${BASE_REF}-${PR_NUMBER}`;
const ANZX_CI_PACKAGE_XML =
  WORKING_DIR + "/ci/workflows/Config/ANZxCIPackage.xml";
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
  createAndUploadArtifact(
    SOURCE_DIR,
    BASE_REF,
    BRANCH_NAME,
    ARTIFACTORY_SECRET_VALUE,
    JOB_ID_FILE_NAME
  );
  authenticate(BRANCH_NAME, SFDX_URL);
  cancel(
    JOB_ID_FILE_NAME,
    ARTIFACTORY_SECRET_VALUE,
    BRANCH_NAME,
    ANZX_CI_PACKAGE_XML
  );
  const validationFunc = validationFunction();
  const validation = validationFunc(BRANCH_NAME, SOURCE_DIR, CLASS_FOLDER_PATH);
  uploadJobId(validation, JOB_ID_FILE_NAME, ARTIFACTORY_SECRET_VALUE);
  validateProgress(validation);
};

const clean = () => {
  codeCoverage(JOB_ID_FILE_NAME);
  unauthenticate(BRANCH_NAME);
  deleteFolder(SOURCE_DIR);
  deleteFile(JOB_ID_FILE_NAME);
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
