import {
  salesforceSecretNames,
  brokerSecretNames
} from "../Config/secretNames.mjs";

// To find the related secret name for the target org
// This will be passed on one of the github action steps to find the secret.
// exp:
// - name: Find Secret Names
//   run: |
//     sfdxURL=$( node ci/workflows/Orchestrations/findSecret.mjs )
//     echo SECRET_NAME="$sfdxURL" >> $GITHUB_ENV

// - name: Retrieve GSM Credentials
//   id: secrets
//   uses: google-github-actions/get-secretmanager-secrets@main
//   with:
//     secrets: |-
//       sfdxurl:projects/448406129405/secrets/${{ env.SECRET_NAME }}/versions/latest

const findSecretName = (baseRef, repoName) => {
  const secretRepoMap = {
    salesforce: salesforceSecretNames,
    "salesforce-broker": brokerSecretNames
  };
  const secretNames = secretRepoMap[repoName];
  const secretName = secretNames[baseRef];
  if (!secretName) {
    console.error(`No secret could be found for ${baseRef}`);
    process.exit(1);
  }
  return secretName;
};

export { findSecretName };
