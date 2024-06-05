// Manual Steps Orchestration

/// Import different functions from different services.
import {
  authenticate,
  unauthenticate
} from "../Services/authentication-service.mjs";
import { deleteFile, findAllArgvs, renameItem } from "../Services/helper.mjs";

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
  FROM_WHICH_EPIC,
  TO_WHICH_EPIC
} = process.env;

const args = findAllArgvs();
const SFDX_URL = args[0];

const TARGET_ORG = renameItem(`run-manual-steps-${BASE_REF}`);
const SOURCE_DIR = `manual-steps/${RELEASE_FOLDER_NAME}`;

///////

/// functions

const runValidManualDeploySteps = () => {
  authenticate(TARGET_ORG, SFDX_URL);
  runAllValidManualSteps(
    SOURCE_DIR,
    WHICH_MANUAl_STEP,
    EXCLUDE_EPIC_FOLDERS,
    TARGET_ORG
  );
};

const clean = () => {
  deleteFile(WORKING_DIR + "/stderr");
  unauthenticate(TARGET_ORG);
};

///////

/// Run ManualSteps

const runManualSteps = () => {
  const runFunctionMapping = {
    manualSteps: runValidManualDeploySteps,
    clean: clean
  };
  return WHICH_JOB
    ? runFunctionMapping[WHICH_JOB]()
    : runValidManualDeploySteps();
};

runManualSteps();
