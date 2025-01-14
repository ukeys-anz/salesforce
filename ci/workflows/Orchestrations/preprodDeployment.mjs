// Preprod Deployment Orchestration

/// Import different function from different services.
import {
  createDiffOnDeploy,
  uploadToArtifactory
} from "../Services/artifact-service.mjs";
import {
  authenticate,
  unauthenticate
} from "../Services/authentication-service.mjs";
import {
  deployWithoutTest,
  deployProgress
} from "../Services/deploy-service.mjs";
import { deleteFolder, booleanMap, findAllArgvs } from "../Services/helper.mjs";

//////////

/// Find all the env variables & other variables values

const {
  PIPELINE_NAME,
  STAGE_NAME,
  BASE_REF_LAST_TAG,
  CLEANING_JOB,
  WORKING_DIR,
  REPO_NAME
} = process.env;

const BASE_REF = "master";
const ARTIFACTORY_REPO_NAME = `anzx-${REPO_NAME}-releases`;
const SOURCE_DIR = `artifact-preprod-${PIPELINE_NAME}`;

const DEPLOY_USER_USERNAME = "preprod";
const ARTIFACT_PACKAGE_XML =
  WORKING_DIR + "/" + SOURCE_DIR + "/package/package.xml";
const ARTIFACT_DESTRUCTIVE_XML =
  WORKING_DIR + "/" + SOURCE_DIR + "/destructiveChanges/destructiveChanges.xml";

const args = findAllArgvs();
const SFDX_URL = args[0];
const ARTIFACTORY_SECRET_VALUE = args[1];
//////////

/// functions

const preprodDeployment = () => {
  createDiffOnDeploy(SOURCE_DIR, BASE_REF, BASE_REF_LAST_TAG);
  uploadToArtifactory(
    ARTIFACTORY_SECRET_VALUE,
    SOURCE_DIR,
    ARTIFACTORY_REPO_NAME
  );
  authenticate(DEPLOY_USER_USERNAME, SFDX_URL);
  const deployment = deployWithoutTest(DEPLOY_USER_USERNAME, SOURCE_DIR);
  deployProgress(
    deployment,
    DEPLOY_USER_USERNAME,
    ARTIFACT_PACKAGE_XML,
    ARTIFACT_DESTRUCTIVE_XML
  );
};

const deploymentCleaning = () => {
  unauthenticate(DEPLOY_USER_USERNAME);
  deleteFolder(SOURCE_DIR);
};

const pipelineFunction = () => {
  const cleaning = booleanMap(CLEANING_JOB);
  const jobMapping = {
    PreprodDeploy: STAGE_NAME === "prod-release-start" && !cleaning,
    PreprodClean: STAGE_NAME === "prod-release-start" && cleaning
  };
  const releaseFunctionMapping = {
    PreprodDeploy: preprodDeployment,
    PreprodClean: deploymentCleaning
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
