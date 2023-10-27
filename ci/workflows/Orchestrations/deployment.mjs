// Deployment Orchestration

/// Import different function from different services.
import { createDiffOnDeploy } from "../Services/artifact-service.mjs";
import {
  authenticate,
  unauthenticate
} from "../Services/authentication-service.mjs";
import {
  deployWithoutTest,
  deployProgress,
  deployReport
} from "../Services/deploy-service.mjs";
import { deleteFolder, renameItem } from "../Services/helper.mjs";
import { createTag } from "../Services/tag-service.mjs";
//////////

/// Find all the env variables & other variables values

const {
  WHICH_JOB,
  BASE_REF,
  BASE_REF_LAST_TAG,
  SFDX_URL,
  RUN_ID
} = process.env;

const PROPER_FOLDER_NAME = renameItem(BASE_REF);
const SOURCE_DIR = `artifact-${PROPER_FOLDER_NAME}-${RUN_ID}`;

//////////

/// functions

const deployment = () => {
  createDiffOnDeploy(SOURCE_DIR, BASE_REF, BASE_REF_LAST_TAG);
  authenticate(BASE_REF, SFDX_URL);
  const deployment = deployWithoutTest(BASE_REF, SOURCE_DIR);
  deployProgress(deployment);
};

const clean = () => {
  unauthenticate(BASE_REF);
  deleteFolder(SOURCE_DIR);
  createTag(BASE_REF, RUN_ID);
};

/////////

/// Run CD

const runCD = () => {
  const runFunctionMapping = {
    deployment: deployment,
    clean: clean
  };

  return WHICH_JOB ? runFunctionMapping[WHICH_JOB]() : deployment();
};

runCD();
