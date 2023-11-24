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
  BRANCH_NAME,
  WORKING_DIR,
  REPO_NAME
} = process.env;

const ARTIFACT_NAME = renameItem(`artifact-${BRANCH_NAME}`);
const ARTIFACTORY_REPO_NAME = `anzx-${REPO_NAME}-releases-np`;
const ARTIFACT_PACKAGE_XML =
  WORKING_DIR + "/" + ARTIFACT_NAME + "/package/package.xml";
const ARTIFACT_DESTRUCTIVE_XML =
  WORKING_DIR +
  "/" +
  ARTIFACT_NAME +
  "/destructiveChanges/destructiveChanges.xml";
//////////

/// functions

const quickDeployment = () => {
  authenticate(BRANCH_NAME, SFDX_URL);
  const deployment = quickDeploy(
    ARTIFACT_NAME,
    ARTIFACTORY_SECRET_VALUE,
    ARTIFACTORY_REPO_NAME,
    BRANCH_NAME
  );
  deployProgress(
    deployment,
    BRANCH_NAME,
    ARTIFACT_PACKAGE_XML,
    ARTIFACT_DESTRUCTIVE_XML
  );
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
