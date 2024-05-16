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
import {
  booleanMap,
  deleteFolder,
  deleteFile,
  renameItem,
  findAllArgvs
} from "../Services/helper.mjs";

//////////

/// Find all the env, argv & other variables values

const {
  WHICH_JOB,
  BASE_REF,
  BASE_REF_LAST_TAG,
  BRANCH_NAME,
  DRAFT_PR,
  SPECIFIED_TEST_PR,
  PR_NUMBER,
  WORKING_DIR,
  REPO_NAME,
  JOB_NAME
} = process.env;

const SOURCE_DIR = renameItem(`artifact-${BRANCH_NAME}`);
const ARTIFACTORY_REPO_NAME = `anzx-${REPO_NAME}-releases-np`;
const CLASS_FOLDER_PATH = `${SOURCE_DIR}/force-app/main/default/classes`;
const JOB_ID_FILE_NAME =
  renameItem(`${BASE_REF}-${PR_NUMBER}`) +
  (JOB_NAME ? `${JOB_NAME.replace("sf-platform-np", "")}` : "");
const ANZX_CI_PACKAGE_XML =
  WORKING_DIR + "/ci/workflows/Config/ANZxCIPackage.xml";
const ARTIFACT_PACKAGE_XML =
  WORKING_DIR + "/" + SOURCE_DIR + "/package/package.xml";
const ARTIFACT_DESTRUCTIVE_XML =
  WORKING_DIR + "/" + SOURCE_DIR + "/destructiveChanges/destructiveChanges.xml";
const args = findAllArgvs();
const SFDX_URL = args[0];
const ARTIFACTORY_SECRET_VALUE = args[1];
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
    BASE_REF_LAST_TAG,
    ARTIFACTORY_SECRET_VALUE,
    ARTIFACTORY_REPO_NAME
  );
  authenticate(BRANCH_NAME, SFDX_URL);
  cancel(
    JOB_ID_FILE_NAME,
    ARTIFACTORY_SECRET_VALUE,
    ARTIFACTORY_REPO_NAME,
    BRANCH_NAME,
    ANZX_CI_PACKAGE_XML
  );
  const validationFunc = validationFunction();
  const validation = validationFunc(BRANCH_NAME, SOURCE_DIR, CLASS_FOLDER_PATH);
  uploadJobId(
    validation,
    JOB_ID_FILE_NAME,
    ARTIFACTORY_SECRET_VALUE,
    ARTIFACTORY_REPO_NAME
  );
  validateProgress(
    validation,
    BRANCH_NAME,
    ARTIFACT_PACKAGE_XML,
    ARTIFACT_DESTRUCTIVE_XML
  );
};

const clean = () => {
  codeCoverage(JOB_ID_FILE_NAME, DRAFT_PR);
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
