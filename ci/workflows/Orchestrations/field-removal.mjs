// Field Removal Check Orchestration

/// Import different functions from different services.
import { deleteFile, findAllArgvs } from "../Services/helper.mjs";
import {
  compareReports,
  printPreviousPRComment,
  uploadHTMLFile
} from "../Services/field-removal-service.mjs";

const { PR_NUMBER, REPO_NAME, WHICH_JOB } = process.env;
const REMOVAL_FIELD_CHECK_FILE_NAME = `removal-field-check-${REPO_NAME}-${PR_NUMBER}`;
const NEW_REPORT = "deleted_fields_comment.html";
const ARTIFACTORY_REPO_NAME = `anzx-${REPO_NAME}-releases-np`;

const args = findAllArgvs();
const ARTIFACTORY_SECRET_VALUE = args[0];

/// Functions
const checkRaisePRComment = () => {
  const previousComment = printPreviousPRComment(
    REMOVAL_FIELD_CHECK_FILE_NAME + ".html",
    ARTIFACTORY_SECRET_VALUE,
    ARTIFACTORY_REPO_NAME
  );
  compareReports(previousComment, NEW_REPORT, REMOVAL_FIELD_CHECK_FILE_NAME);
};

const cleanPRCommentFiles = () => {
  uploadHTMLFile(
    REMOVAL_FIELD_CHECK_FILE_NAME + ".html",
    NEW_REPORT,
    ARTIFACTORY_SECRET_VALUE,
    ARTIFACTORY_REPO_NAME,
    "PR Comment HTML"
  );
  deleteFile(REMOVAL_FIELD_CHECK_FILE_NAME + ".html");
  deleteFile(REMOVAL_FIELD_CHECK_FILE_NAME + "-report");
};

/////////

/// Run Field Removal Check
const runFieldRemovalCheck = () => {
  const runFunctionMapping = {
    compare: checkRaisePRComment,
    cleanPRComment: cleanPRCommentFiles
  };

  return WHICH_JOB ? runFunctionMapping[WHICH_JOB]() : checkRaisePRComment();
};

runFieldRemovalCheck();
