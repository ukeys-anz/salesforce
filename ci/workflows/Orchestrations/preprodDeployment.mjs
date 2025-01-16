// Preprod Deployment Orchestration

/// Import different function from different services.
import {
  createDiffOnDeploy,
  uploadToArtifactory,
  uploadDestructiveToArtifactory
} from "../Services/artifact-service.mjs";
import {
  authenticate,
  unauthenticate
} from "../Services/authentication-service.mjs";
import {
  deployWithoutTest,
  deployProgress,
  deployWithoutTestSkipDestructive,
  retrieveDestructiveFiles,
  destructiveDeployment
} from "../Services/deploy-service.mjs";
import { deleteFolder, booleanMap, findAllArgvs } from "../Services/helper.mjs";

//////////

/// Find all the env variables & other variables values

const {
  WHICH_JOB,
  PIPELINE_NAME,
  BASE_REF_LAST_TAG,
  CLEANING_JOB,
  WORKING_DIR,
  REPO_NAME,
  SKIP_DESTRUCTIVE_CHANGES
} = process.env;

const BASE_REF = "master";
const DEPLOY_USER_USERNAME = "preprod";
const ARTIFACTORY_REPO_NAME = `anzx-${REPO_NAME}-releases`;
const SOURCE_DIR = `artifact-preprod-${PIPELINE_NAME}`;
const DESTRUCTIVE_ARTIFACT = `destructive-preprod-${PIPELINE_NAME}`;
const MOVED_DESTRUCTIVE_ARTIFACT = "force-app/" + DESTRUCTIVE_ARTIFACT;
const DESTRUCTIVE_DIR = WORKING_DIR + "/" + DESTRUCTIVE_ARTIFACT;

const PREPROD_DEPLOY_FLAG = WHICH_JOB === "artifact";

const ARTIFACT_PACKAGE_XML =
  WORKING_DIR + "/" + SOURCE_DIR + "/package/package.xml";
const ARTIFACT_DESTRUCTIVE_XML =
  WORKING_DIR + "/" + SOURCE_DIR + "/destructiveChanges/destructiveChanges.xml";
const DESTRUCTIVE_PACKAGE_XML =
  WORKING_DIR +
  "/" +
  MOVED_DESTRUCTIVE_ARTIFACT +
  "/unpackaged/unpackaged/package.xml";

const args = findAllArgvs();
const SFDX_URL = args[0];
const ARTIFACTORY_SECRET_VALUE = args[1];
//////////

/// functions

const deployFunc = () =>
  booleanMap(SKIP_DESTRUCTIVE_CHANGES)
    ? deployWithoutTestSkipDestructive
    : deployWithoutTest;

const preprodDeployment = () => {
  createDiffOnDeploy(SOURCE_DIR, BASE_REF, BASE_REF_LAST_TAG);
  uploadToArtifactory(
    ARTIFACTORY_SECRET_VALUE,
    SOURCE_DIR,
    ARTIFACTORY_REPO_NAME
  );
  authenticate(DEPLOY_USER_USERNAME, SFDX_URL);
  const deploymentFunc = deployFunc();
  const deployment = deploymentFunc(DEPLOY_USER_USERNAME, SOURCE_DIR);
  deployProgress(
    deployment,
    DEPLOY_USER_USERNAME,
    ARTIFACT_PACKAGE_XML,
    ARTIFACT_DESTRUCTIVE_XML
  );
};

const deployDestructiveToPreprod = () => {
  authenticate(DEPLOY_USER_USERNAME, SFDX_URL);
  const destructiveDeploy = destructiveDeployment(
    DESTRUCTIVE_ARTIFACT,
    ARTIFACTORY_SECRET_VALUE,
    ARTIFACTORY_REPO_NAME,
    DEPLOY_USER_USERNAME
  );
  deployProgress(
    destructiveDeploy,
    DEPLOY_USER_USERNAME,
    DESTRUCTIVE_PACKAGE_XML,
    DESTRUCTIVE_PACKAGE_XML
  );
};

const preprodDeploymentCleaning = () => {
  retrieveDestructiveFiles(
    DEPLOY_USER_USERNAME,
    SOURCE_DIR,
    ARTIFACT_DESTRUCTIVE_XML,
    DESTRUCTIVE_DIR
  );
  uploadDestructiveToArtifactory(
    ARTIFACTORY_SECRET_VALUE,
    DESTRUCTIVE_ARTIFACT,
    ARTIFACTORY_REPO_NAME
  );
  unauthenticate(DEPLOY_USER_USERNAME);
  deleteFolder(SOURCE_DIR);
};

const destructiveCleaning = () => {
  unauthenticate(DEPLOY_USER_USERNAME);
  deleteFolder(MOVED_DESTRUCTIVE_ARTIFACT);
};

const pipelineFunction = () => {
  const cleaning = booleanMap(CLEANING_JOB);
  const jobMapping = {
    PreprodDeploy: PREPROD_DEPLOY_FLAG && !cleaning,
    PreprodClean: PREPROD_DEPLOY_FLAG && cleaning,
    DestructiveDeploy: !PREPROD_DEPLOY_FLAG && !cleaning,
    DestructiveClean: !PREPROD_DEPLOY_FLAG && cleaning
  };
  const releaseFunctionMapping = {
    PreprodDeploy: preprodDeployment,
    PreprodClean: preprodDeploymentCleaning,
    DestructiveDeploy: deployDestructiveToPreprod,
    DestructiveClean: destructiveCleaning
  };
  const chosenJob = Object.keys(jobMapping).find((k) => jobMapping[k]);
  return releaseFunctionMapping[chosenJob];
};

/////////

/// Run Preprod Deployment Pipeline
const runPipeline = () => {
  const pipelineJob = pipelineFunction();
  return pipelineJob ? pipelineJob() : "Approval Step";
};

runPipeline();
