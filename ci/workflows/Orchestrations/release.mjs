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
  prodQuickDeployment,
  deployWithoutTest,
  quickDeployProgress,
  deployProgress,
  deployReport,
  validateProgress,
  uploadJobId
} from "../Services/deploy-service.mjs";
import {
  deleteFolder,
  renameItem,
  booleanMap,
  findAllArgvs,
  deleteFile
} from "../Services/helper.mjs";
import { createTagPipeline } from "../Services/tag-service.mjs";
//////////

/// Find all the env variables & other variables values

const {
  RELEASE_NAME,
  STAGE_NAME,
  BASE_REF_LAST_TAG,
  CLEANING_JOB,
  WORKING_DIR,
  REPO_NAME,
  PROD_DEPLOY_USERNAME,
  PROD_URL
} = process.env;

// STAGE_NAME should be changed from preprod deployment to prod validation/deployment
const BASE_REF = STAGE_NAME === "preprod-deployment" ? "master" : "prodrel";
const ARTIFACTORY_REPO_NAME = `anzx-${REPO_NAME}-releases`;
const SOURCE_DIR = `artifact-master-${RELEASE_NAME}`;
const JOB_ID_FILE_NAME = renameItem(`release-${RELEASE_NAME}`);

const DEPLOY_USER_USERNAME =
  BASE_REF === "master" ? "master" : PROD_DEPLOY_USERNAME;
const ARTIFACT_PACKAGE_XML =
  WORKING_DIR + "/" + SOURCE_DIR + "/package/package.xml";
const ARTIFACT_DESTRUCTIVE_XML =
  WORKING_DIR + "/" + SOURCE_DIR + "/destructiveChanges/destructiveChanges.xml";

const args = findAllArgvs();
const SFDX_URL = args[0];
const CONSUMER_KEY_SECRET_VALUE = args[1];
const CERT_SECRET_VALUE = args[2];
const ARTIFACTORY_SECRET_VALUE = args[3];
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

const prodValidation = () => {
  authenticateWithJWT(
    CONSUMER_KEY_SECRET_VALUE,
    CERT_SECRET_VALUE,
    DEPLOY_USER_USERNAME,
    PROD_URL
  );
  const validation = prodValidationWithAllTests(
    SOURCE_DIR,
    ARTIFACTORY_SECRET_VALUE,
    ARTIFACTORY_REPO_NAME,
    DEPLOY_USER_USERNAME
  );
  validateProgress(
    validation,
    DEPLOY_USER_USERNAME,
    ARTIFACT_PACKAGE_XML,
    ARTIFACT_DESTRUCTIVE_XML
  );
  uploadJobId(
    validation,
    JOB_ID_FILE_NAME,
    ARTIFACTORY_SECRET_VALUE,
    ARTIFACTORY_REPO_NAME
  );
};

const prodDeployment = () => {
  authenticateWithJWT(
    CONSUMER_KEY_SECRET_VALUE,
    CERT_SECRET_VALUE,
    DEPLOY_USER_USERNAME,
    PROD_URL
  );
  const deployment = prodQuickDeployment(
    JOB_ID_FILE_NAME,
    SOURCE_DIR,
    ARTIFACTORY_SECRET_VALUE,
    ARTIFACTORY_REPO_NAME,
    DEPLOY_USER_USERNAME
  );
  quickDeployProgress(
    deployment,
    DEPLOY_USER_USERNAME,
    ARTIFACT_PACKAGE_XML,
    ARTIFACT_DESTRUCTIVE_XML
  );
};

const validationCleaning = () => {
  unauthenticate(DEPLOY_USER_USERNAME);
  deleteFolder(SOURCE_DIR);
};

const deploymentCleaning = () => {
  unauthenticate(DEPLOY_USER_USERNAME);
  deleteFolder(SOURCE_DIR);
  deleteFile(JOB_ID_FILE_NAME);
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
