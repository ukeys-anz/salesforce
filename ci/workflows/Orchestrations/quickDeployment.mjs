// Quick Deployment Orchestration

/// Import different function from different services.

import {
  authenticate,
  unauthenticate
} from "../Services/authentication-service.mjs";
import {
  deployProgress,
  deployReport,
  quickDeploy,
  quickDeployProgress
} from "../Services/deploy-service.mjs";
import {
  deleteFolder,
  renameItem,
  findAllArgvs,
  deleteFile
} from "../Services/helper.mjs";
import { createTag } from "../Services/tag-service.mjs";

//////////

/// Find all the env, argv & other variables values

const {
  WHICH_JOB,
  BASE_REF,
  RUN_ID,
  BRANCH_NAME,
  WORKING_DIR,
  REPO_NAME,
  JOB_NAME,
  PR_NUMBER
} = process.env;

const IS_MASTER_BRANCH = BASE_REF === "master";
const CREATE_TAG_FLAG = JOB_NAME ? true : false;
const POSTFIX_ALIAS = JOB_NAME
  ? `${JOB_NAME.replace("sf-platform-np", "")}`
  : "";
const BRANCH_NAME_ALIAS = BRANCH_NAME + POSTFIX_ALIAS;

const JOB_ID_FILE_NAME = renameItem(`${BASE_REF}-${PR_NUMBER}`) + POSTFIX_ALIAS;

const ARTIFACT_NAME = renameItem(`artifact-${BRANCH_NAME_ALIAS}`);
const ARTIFACTORY_REPO_NAME = `anzx-${REPO_NAME}-releases-np`;
const ARTIFACT_PACKAGE_XML =
  WORKING_DIR + "/" + ARTIFACT_NAME + "/package/package.xml";
const ARTIFACT_DESTRUCTIVE_XML =
  WORKING_DIR +
  "/" +
  ARTIFACT_NAME +
  "/destructiveChanges/destructiveChanges.xml";

const args = findAllArgvs();
const SFDX_URL = args[0];
const ARTIFACTORY_SECRET_VALUE = args[1];
//////////

/// functions

const quickDeployment = () => {
  authenticate(BRANCH_NAME_ALIAS, SFDX_URL);
  const quickDeployment = quickDeploy(
    JOB_ID_FILE_NAME,
    ARTIFACT_NAME,
    ARTIFACTORY_SECRET_VALUE,
    ARTIFACTORY_REPO_NAME,
    BRANCH_NAME_ALIAS
  );
  quickDeployProgress(
    quickDeployment,
    BRANCH_NAME_ALIAS,
    ARTIFACT_PACKAGE_XML,
    ARTIFACT_DESTRUCTIVE_XML
  );
};

const quickClean = () => {
  unauthenticate(BRANCH_NAME_ALIAS);
  deleteFolder(ARTIFACT_NAME);
  deleteFile(JOB_ID_FILE_NAME);
  createTag(BASE_REF, RUN_ID, CREATE_TAG_FLAG);
};

/////////

/// Run CD

const runCD = () => {
  const runFunctionMapping = {
    quickDeployment: quickDeployment,
    quickClean: quickClean
  };
  if (IS_MASTER_BRANCH && !CREATE_TAG_FLAG) return;
  return WHICH_JOB ? runFunctionMapping[WHICH_JOB]() : quickDeployment();
};

runCD();
