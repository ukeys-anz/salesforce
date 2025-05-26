// Submodule Duplication Check

/// Import different function from different services.

import { findDuplications } from "../Services/submodule-duplicate-checker.mjs";

///////////

/// Find all the env, argv & other variables values

const {
  BASE_REF_LAST_TAG,
  SUBMODULE_PATH,
  SUBMODULE_BRANCH,
  COMPARE_ALL,
  COMMENT_TAG
} = process.env;
//////////

/// Run CI
const runDuplicateChecker = () => {
  const submoduleVersionMap = SUBMODULE_BRANCH ? SUBMODULE_BRANCH : "current";
  const compareAllOrNewChangesTag =
    COMPARE_ALL === "true" ? "" : BASE_REF_LAST_TAG;
  const compareAllOrNewChangesComment =
    COMPARE_ALL === "true" ? "all" : "new changes";
  const duplicationReport = findDuplications(
    compareAllOrNewChangesTag,
    SUBMODULE_PATH
  );
  return duplicationReport
    ? `<h2>🔁 Duplication check on ${submoduleVersionMap} version of ${SUBMODULE_PATH} | Compare ${compareAllOrNewChangesComment}</h2>${duplicationReport}
      <!-- ${COMMENT_TAG} -->
    `
    : "";
};

console.log(runDuplicateChecker());
