import { appendFileSync } from "fs";
import { slackGroupMapping } from "../Config/slackGroup.mjs";

const WORKFLOW_DISPATCH_EVENT = "workflow_dispatch";

/**
 * Generates Slack group mapping info based on GitHub event and branches.
 *
 * @param {string} githubEvent - The type of GitHub event (e.g. "workflow_dispatch").
 * @param {string} branchFrom - The source branch name (e.g. "develop").
 * @param {string} branchTo - The target branch name (e.g. "epic/feature-x").
 * @returns {string[]} An array of strings in the format "target|source|slackGroup"
 *                     where slackGroup is derived from the slackGroupMapping config.
 *                     If no mapping exists, "none" is used.
 */
const findBranchSlackInfo = (githubEvent, branchFrom, branchTo) => {
  if (githubEvent === WORKFLOW_DISPATCH_EVENT) {
    return [
      branchTo +
        "|" +
        branchFrom +
        "|" +
        (slackGroupMapping[branchTo] ?? "none")
    ];
  }

  const output = [];
  for (let epic in slackGroupMapping) {
    output.push(epic + "|develop|" + (slackGroupMapping[epic] ?? "none"));
  }
  return output;
};

/**
 * Writes key-value pairs to GitHub Actions output environment file.
 *
 * This method is used in GitHub Actions to set output variables using the special
 * `GITHUB_OUTPUT` environment variable. If the environment variable is not defined,
 * the process exits with an error.
 *
 * @param {Object} flagsObject - An object where each key-value pair will be written
 *                               to the GitHub Actions output file. Arrays are
 *                               stringified as JSON.
 */
const updateGithubOutput = (flagsObject) => {
  if (!process.env.GITHUB_OUTPUT) {
    console.log("Could not set GITHUB_OUTPUT...");
    process.exit(1);
  }

  for (const [key, value] of Object.entries(flagsObject)) {
    console.log(`${key}=${value}`);
    const outputValue = Array.isArray(value) ? JSON.stringify(value) : value;
    appendFileSync(process.env.GITHUB_OUTPUT, `${key}=${outputValue}\n`);
  }
  console.log("Debug logs on Github Outputs...");
  console.log(process.env.GITHUB_OUTPUT);
};

export { findBranchSlackInfo, updateGithubOutput };
