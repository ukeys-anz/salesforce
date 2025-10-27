import {
  findBranchSlackInfo,
  updateGithubOutput
} from "../Services/back-merge-service.mjs";

const { GITHUB_EVENT, BRANCH_FROM, BRANCH_TO } = process.env;

/**
 * Prepares Slack notification mapping information for GitHub Actions.
 *
 * This function:
 * 1. Retrieves environment variables related to the GitHub event and branches.
 * 2. Calls `findBranchSlackInfo` to generate relevant Slack group info.
 * 3. Passes the resulting info to `updateGithubOutput` to expose it as GitHub Actions output.
 *
 * Expected environment variables:
 * - `GITHUB_EVENT`: GitHub event name (e.g., "workflow_dispatch")
 * - `BRANCH_FROM`: The source branch name (e.g., "develop")
 * - `BRANCH_TO`: The target branch name (e.g., "epic/feature-x")
 */
const prepareInfo = () => {
  const outputs = findBranchSlackInfo(GITHUB_EVENT, BRANCH_FROM, BRANCH_TO);
  const outputObject = {
    info: outputs
  };
  updateGithubOutput(outputObject);
};

prepareInfo();
