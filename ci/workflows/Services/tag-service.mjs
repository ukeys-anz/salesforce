import { exec, execSync } from "child_process";
import { currentDate, logger } from "./helper.mjs";
// The fundtion to create a tag for us.
// We should checkout the salesforce repo at first:

// - uses: actions/checkout@v2
//   with:
//      ref: ${{ github.ref }}
//      fetch-depth: 0

// Inputs:
// baseRef = ${GITHUB_REF#refs/heads/}
// runId = ${GITHUB_RUN_ID}
const createTag = (baseRef, runId, tagCreationFlag) => {
  if (tagCreationFlag) return;
  const tag = `${baseRef}-${runId}`;
  logger(`New created tag: ${tag}`);

  execSync(`
    git tag "${tag}"
    git push origin "${tag}"
  `);
};

const createTagPipeline = (tagPrefix, releaseName) => {
  const date = currentDate();
  const tag = `${tagPrefix}-${releaseName}-${date}`;
  logger(`New created tag: ${tag}`);

  execSync(`
    git tag ${tag}
    git push origin ${tag}
  `);
};

////////////////////

export { createTag, createTagPipeline };
