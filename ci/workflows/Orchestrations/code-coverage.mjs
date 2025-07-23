// Code Coverage Orchestration

/// Import different functions from different services.

import {
  authenticate,
  unauthenticate
} from "../Services/authentication-service.mjs";

import {
  codeCoverage,
  compareReports,
  printPreviousPRComment,
  uploadHTMLFile
} from "../Services/code-coverage-service.mjs";
import {
  deleteFile,
  downloadFile,
  findAllArgvs,
  renameItem,
  uploadFile
} from "../Services/helper.mjs";

const {
  WHICH_JOB,
  BASE_REF,
  PR_NUMBER,
  BRANCH_NAME,
  REPO,
  REPO_NAME,
  WORKING_DIR
} = process.env;

const BRANCH_NAME_ALIAS = BRANCH_NAME;
const JOB_ID_FILE_NAME = renameItem(`${BASE_REF}-${PR_NUMBER}`);
const SOURCE_DIR = renameItem(`artifact-${BRANCH_NAME_ALIAS}`);
const ARTIFACTORY_REPO_NAME = `anzx-${REPO_NAME}-releases-np`;
const CODE_COVERAGE_FILE_NAME = `code-coverage-report-${REPO_NAME}-${PR_NUMBER}`;
const ANZX_CI_PACKAGE_XML =
  WORKING_DIR + "/ci/workflows/Config/ANZxCIPackage.xml";
const ARTIFACT_PACKAGE_XML =
  WORKING_DIR + "/" + SOURCE_DIR + "/package/package.xml";

const args = findAllArgvs();
const SFDX_URL = args[0];
const ARTIFACTORY_SECRET_VALUE = args[1];

const codeCoverageRun = () => {
  authenticate(BRANCH_NAME_ALIAS, SFDX_URL);
  const previousComment = printPreviousPRComment(
    CODE_COVERAGE_FILE_NAME + ".html",
    ARTIFACTORY_SECRET_VALUE,
    ARTIFACTORY_REPO_NAME
  );
  codeCoverage(
    JOB_ID_FILE_NAME,
    ARTIFACT_PACKAGE_XML,
    BRANCH_NAME_ALIAS,
    ANZX_CI_PACKAGE_XML,
    CODE_COVERAGE_FILE_NAME
  );
  compareReports(previousComment, CODE_COVERAGE_FILE_NAME);
};

const clean = () => {
  uploadHTMLFile(
    CODE_COVERAGE_FILE_NAME + ".html",
    ARTIFACTORY_SECRET_VALUE,
    ARTIFACTORY_REPO_NAME,
    "PR Comment HTML"
  );
  unauthenticate(BRANCH_NAME_ALIAS);
  deleteFile(JOB_ID_FILE_NAME);
  deleteFile(CODE_COVERAGE_FILE_NAME + ".html");
};

/////////

/// Run Code Coverage

const runCodeCoverage = () => {
  const runFunctionMapping = {
    coverage: codeCoverageRun,
    clean: clean
  };

  return WHICH_JOB ? runFunctionMapping[WHICH_JOB]() : codeCoverageRun();
};

runCodeCoverage();
