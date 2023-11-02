// Release Orchestration

/// Import different function from different services.
import {
  createDiffOnDeploy,
  uploadToArtifactory
} from "../Services/artifact-service.mjs";
import {
  authenticate,
  authenticateWithJWT,
  unauthenticate
} from "../Services/authentication-service.mjs";
import {
  prodValidationWithAllTests,
  prodDeploymentWithAllTests,
  deployWithoutTest,
  deployProgress,
  deployReport,
  validateProgress
} from "../Services/deploy-service.mjs";
import { deleteFolder, renameItem, booleanMap } from "../Services/helper.mjs";
import { createTagPipeline } from "../Services/tag-service.mjs";
//////////

/// Find all the env variables & other variables values

const {
  RELEASE_NAME,
  ARTIFACTORY_SECRET_VALUE,
  STAGE_NAME,
  SFDX_URL,
  CONSUMER_KEY_SECRET_VALUE,
  CERT_SECRET_VALUE,
  BASE_REF_LAST_TAG,
  CLEANING_JOB
} = process.env;

// STAGE_NAME should be changed from preprod deployment to prod validation/deployment
const BASE_REF = STAGE_NAME === "preprod-deployment" ? "master" : "prodrel";
const SOURCE_DIR = `artifact-master-${RELEASE_NAME}`;
const DEPLOY_USER_USERNAME =
  BASE_REF === "master" ? "master" : "tech.gcb@anzx.com";
const PROD_URL = "https://anz.my.salesforce.com";
//////////

/// functions

const preprodDeployment = () => {
  createDiffOnDeploy(SOURCE_DIR, BASE_REF, BASE_REF_LAST_TAG);
  uploadToArtifactory(ARTIFACTORY_SECRET_VALUE, SOURCE_DIR);
  authenticate(DEPLOY_USER_USERNAME, SFDX_URL);
  const deployment = deployWithoutTest(DEPLOY_USER_USERNAME, SOURCE_DIR);
  deployProgress(deployment);
};

const prodValidation = () => {
  authenticateWithJWT(
    CONSUMER_KEY_SECRET_VALUE,
    CERT_SECRET_VALUE,
    PROD_DEPLOY_USERNAME,
    PROD_URL
  );
  const validation = prodValidationWithAllTests(
    SOURCE_DIR,
    ARTIFACTORY_SECRET_VALUE,
    PROD_DEPLOY_USERNAME
  );
  validateProgress(validation);
};

const prodDeployment = () => {
  authenticateWithJWT(
    CONSUMER_KEY_SECRET_VALUE,
    CERT_SECRET_VALUE,
    PROD_DEPLOY_USERNAME,
    PROD_URL
  );
  const deployment = prodDeploymentWithAllTests(
    SOURCE_DIR,
    ARTIFACTORY_SECRET_VALUE,
    PROD_DEPLOY_USERNAME
  );
  deployProgress(deployment);
};

const validationCleaning = () => {
  unauthenticate(DEPLOY_USER_USERNAME);
  deleteFolder(SOURCE_DIR);
};

const deploymentCleaning = () => {
  unauthenticate(DEPLOY_USER_USERNAME);
  deleteFolder(SOURCE_DIR);
  createTagPipeline(BASE_REF, RELEASE_NAME);
};

const releaseFunction = () => {
  const cleaning = booleanMap(CLEANING_JOB);
  const jobMapping = {
    PreprodDeploy: STAGE_NAME === "preprod-deployment" && !cleaning,
    PreprodClean: STAGE_NAME === "preprod-deployment" && cleaning,
    ProdValidate: STAGE_NAME === "production-validation" && !cleaning,
    ProdValidateClean: STAGE_NAME === "production-validation" && cleaning,
    ProdDeploy: STAGE_NAME === "production-deployment" && !cleaning,
    ProdDeployClean: STAGE_NAME === "production-deployment" && cleaning
  };
  const releaseFunctionMapping = {
    PreprodDeploy: preprodDeployment,
    PreprodClean: deploymentCleaning,
    ProdValidate: prodValidation,
    ProdValidateClean: validationCleaning,
    ProdDeploy: prodDeployment,
    ProdDeployClean: deploymentCleaning
  };
  const chosenJob = Object.keys(jobMapping).filter((k) => jobMapping[k])[0];
  return releaseFunctionMapping[chosenJob];
};

/////////

/// Run Release Pipeline

const runReleasePipeline = () => {
  const releaseJob = releaseFunction();
  return releaseJob ? releaseJob() : "Approval Step";
};

runReleasePipeline();
