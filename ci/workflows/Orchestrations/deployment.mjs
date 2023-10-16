// Deployment Orchestration

/// Import different function from different services.
import { createDiff } from "../Services/artifact-service.mjs";
import {
  authenticate,
  unauthenticate
} from "../Services/authentication-service.mjs";
import {
  deployWithoutTest,
  deployProgress,
  deployReport
} from "../Services/deploy-service.mjs";
import { deleteFolder, logger } from "../Services/helper.mjs";
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

const SOURCE_DIR = `artifact-${BASE_REF}-${RUN_ID}`;

//////////

/// functions

const deployment = () => {
  createDiff(SOURCE_DIR, BASE_REF_LAST_TAG, BASE_REF);
  authenticate(BASE_REF, SFDX_URL);
  const deployment = deployWithoutTest(BASE_REF, SOURCE_DIR);
  deployProgress(deployment);
};

const clean = () => {
  createTag(BASE_REF, RUN_ID);
  unauthenticate(BASE_REF);
  logger(deleteFolder(SOURCE_DIR));
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
