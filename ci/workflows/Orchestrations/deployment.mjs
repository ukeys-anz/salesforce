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
import { deleteFolder, findAllArgvs, renameItem } from "../Services/helper.mjs";
import { createTag } from "../Services/tag-service.mjs";
//////////

/// Find all the env, argv & other variables values

const {
  WHICH_JOB,
  BASE_REF,
  BASE_REF_LAST_TAG,
  RUN_ID,
  WORKING_DIR
} = process.env;

const PROPER_FOLDER_NAME = renameItem(BASE_REF);
const SOURCE_DIR = `artifact-${PROPER_FOLDER_NAME}-${RUN_ID}`;
const ARTIFACT_PACKAGE_XML =
  WORKING_DIR + "/" + SOURCE_DIR + "/package/package.xml";
const ARTIFACT_DESTRUCTIVE_XML =
  WORKING_DIR + "/" + SOURCE_DIR + "/destructiveChanges/destructiveChanges.xml";

const args = findAllArgvs();
const SFDX_URL = args[0];
//////////

/// functions

const deployment = () => {
  createDiffOnDeploy(SOURCE_DIR, BASE_REF, BASE_REF_LAST_TAG);
  authenticate(BASE_REF, SFDX_URL);
  const deployment = deployWithoutTest(BASE_REF, SOURCE_DIR);
  deployProgress(
    deployment,
    BASE_REF,
    ARTIFACT_PACKAGE_XML,
    ARTIFACT_DESTRUCTIVE_XML
  );
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
