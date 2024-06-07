// Manual Steps Orchestration

/// Import different functions from different services.
import {
  authenticateWithJWT,
  unauthenticate
} from "../Services/authentication-service.mjs";
import { deleteFile, findAllArgvs } from "../Services/helper.mjs";

import {
  findAllManualDeploySteps,
  runAllValidManualSteps
} from "../Services/manual-steps-service.mjs";

///////

/// Find all the env, argv & other variables values
const {
  WHICH_JOB,
  BASE_REF,
  REPO_NAME,
  WORKING_DIR,
  WHICH_MANUAl_STEP,
  RELEASE_FOLDER_NAME,
  EXCLUDE_EPIC_FOLDERS,
  PROD_URL,
  PROD_DEPLOY_USERNAME,
  FROM_WHICH_EPIC,
  TO_WHICH_EPIC
} = process.env;

const args = findAllArgvs();
const CONSUMER_KEY_SECRET_VALUE = args[1];
const CERT_SECRET_VALUE = args[2];

const SOURCE_DIR = `manual-steps/${RELEASE_FOLDER_NAME}`;

///////

/// functions

const runValidManualDeploySteps = () => {
  authenticateWithJWT(
    CONSUMER_KEY_SECRET_VALUE,
    CERT_SECRET_VALUE,
    PROD_DEPLOY_USERNAME,
    PROD_URL
  );
  runAllValidManualSteps(
    SOURCE_DIR,
    WHICH_MANUAl_STEP,
    EXCLUDE_EPIC_FOLDERS,
    PROD_DEPLOY_USERNAME
  );
};

const clean = () => {
  deleteFile(WORKING_DIR + "/stderr");
  unauthenticate(PROD_DEPLOY_USERNAME);
};

///////

/// Run ManualSteps

const runProdManualSteps = () => {
  const runFunctionMapping = {
    manualSteps: runValidManualDeploySteps,
    clean: clean
  };
  return WHICH_JOB
    ? runFunctionMapping[WHICH_JOB]()
    : runValidManualDeploySteps();
};

runProdManualSteps();
