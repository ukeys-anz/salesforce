// Quality Check Orchestration

/// Import different functions from different services.
import { deleteFile, findAllArgvs } from "../Services/helper.mjs";
import {
  filterDiff,
  findDiffOnPR,
  createDiffFile,
  updateGithubOutput,
  uploadDiffFile,
  findAllChangedFiles,
  compareReports,
  printPreviousPRComment,
  uploadHTMLFile
} from "../Services/quality-check-service.mjs";

const { BASE_REF, HEAD_REF, PR_NUMBER, REPO_NAME, WHICH_JOB } = process.env;
const QUALITY_CHECK_FILE_NAME = `quality-check-${REPO_NAME}-${PR_NUMBER}`;
const NEW_REPORT = "summary.html";
const ARTIFACTORY_REPO_NAME = `anzx-${REPO_NAME}-releases-np`;

const args = findAllArgvs();
const ARTIFACTORY_SECRET_VALUE = args[0];

/// Functions

const detectChanges = () => {
  const changedFiles = findDiffOnPR(BASE_REF, HEAD_REF);
  const filteredFiles = filterDiff(changedFiles);
  const { allFiles, pmdJestSecurityFlag, syslFlag, prettierFlag, eslintFlag } =
    filteredFiles;
  const flagsObject = {
    security_pmd_jest_needed: pmdJestSecurityFlag,
    sysl_needed: syslFlag,
    prettier_needed: prettierFlag,
    eslint_lwc_needed: eslintFlag
  };
  createDiffFile(allFiles, QUALITY_CHECK_FILE_NAME);
  updateGithubOutput(flagsObject);
};

const uploadChangedFiles = () => {
  uploadDiffFile(
    QUALITY_CHECK_FILE_NAME + ".txt",
    ARTIFACTORY_SECRET_VALUE,
    ARTIFACTORY_REPO_NAME
  );
};

const downloadChangedFiles = () => {
  findAllChangedFiles(
    QUALITY_CHECK_FILE_NAME + ".txt",
    ARTIFACTORY_SECRET_VALUE,
    ARTIFACTORY_REPO_NAME
  );
};

const checkRaisePRComment = () => {
  const previousComment = printPreviousPRComment(
    QUALITY_CHECK_FILE_NAME + ".html",
    ARTIFACTORY_SECRET_VALUE,
    ARTIFACTORY_REPO_NAME
  );
  compareReports(previousComment, NEW_REPORT, QUALITY_CHECK_FILE_NAME);
};

const clean = () => {
  deleteFile(QUALITY_CHECK_FILE_NAME + ".txt");
};

const cleanPRCommentFiles = () => {
  uploadHTMLFile(
    QUALITY_CHECK_FILE_NAME + ".html",
    NEW_REPORT,
    ARTIFACTORY_SECRET_VALUE,
    ARTIFACTORY_REPO_NAME,
    "PR Comment HTML"
  );
  deleteFile(QUALITY_CHECK_FILE_NAME + ".html");
  deleteFile(QUALITY_CHECK_FILE_NAME + "-report");
};

/////////

/// Run Quality Check
const runQualityCheck = () => {
  const runFunctionMapping = {
    detect: detectChanges,
    upload: uploadChangedFiles,
    download: downloadChangedFiles,
    compare: checkRaisePRComment,
    cleanPRComment: cleanPRCommentFiles,
    clean: clean
  };

  return WHICH_JOB ? runFunctionMapping[WHICH_JOB]() : detectChanges();
};

runQualityCheck();
