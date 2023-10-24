// Quick Deployment Orchestration

/// Import different function from different services.

import {
  authenticate,
  unauthenticate
} from "../Services/authentication-service.mjs";
import {
  deployProgress,
  deployReport,
  quickDeploy
} from "../Services/deploy-service.mjs";
import { deleteFolder, renameItem } from "../Services/helper.mjs";
import { createTag } from "../Services/tag-service.mjs";

//////////

/// Find all the env variables & other variables values

const {
  WHICH_JOB,
  BASE_REF,
  SFDX_URL,
  RUN_ID,
  ARTIFACTORY_SECRET_VALUE,
  BRANCH_NAME
} = process.env;

const ARTIFACT_NAME = renameItem(`artifact-${BRANCH_NAME}`);

//////////

/// functions

const quickDeployment = () => {
  authenticate(BRANCH_NAME, SFDX_URL);
  const deployment = quickDeploy(
    ARTIFACT_NAME,
    ARTIFACTORY_SECRET_VALUE,
    BRANCH_NAME
  );
  deployProgress(deployment);
};

const quickClean = () => {
  unauthenticate(BASE_REF);
  deleteFolder(ARTIFACT_NAME);
  createTag(BASE_REF, RUN_ID);
};

/////////

/// Run CD

const runCD = () => {
  const runFunctionMapping = {
    quickDeployment: quickDeployment,
    quickClean: quickClean
  };

  return WHICH_JOB ? runFunctionMapping[WHICH_JOB]() : quickDeployment();
};

runCD();
