import { runSfCommand } from "./helper.mjs";
import secretNames from "../Config/secretNames.json" assert { type: "json" };

// To find the related secret name for the target org
// This will be passed on one of the github action steps to find the secret.
// exp:
//   name: Find secret name
//   working-directory: salesforce
//   run: |
//     secretName=$(node ci/workflows/Services/authentication-service.mjs findSecretName "${{ github.base_ref }}")
//     echo SECRET_NAME="$secretName" >> $GITHUB_ENV
//   name: SFDXURL
//      id: secrets
//      uses: google-github-actions/get-secretmanager-secrets@main
//      with:
//      secrets: |-
//        sfdxurl:projects/36540621485/secrets/ghr-salesforce-prod-${{ env.SECRET_NAME }}/versions/latest
const findSecretName = (baseRef) => {
  const secretName = secretNames[baseRef];
  if (!secretName) {
    console.error(`No secret could be found for ${baseRef}`);
    process.exit(1);
  }
  return secretName;
};

// This will take the secretValue and branch name and will do the authentication.
// exp:
// name: Authenticate all orgs in SFDX CLI
//   run: |
//      node ci/workflows/Services/authentication-service.mjs authenticate "${{ github.head_ref }}" "${{ steps.secrets.outputs.sfdxurl }}"
const authenticate = (branchName, secretValue) => {
  return runSfCommand(
    `echo "${secretValue}" | npx sf org login sfdx-url -a "${branchName}" --sfdx-url-file=/dev/stdin`
  );
};

// For production, we use connectedApp with JWT to do the authentication
// Inputs:
//  username: tech.gcb@anzx.com
//  orgURL: https://anz.my.salesforce.com
const authenticateWithJWT = (consumerKey, cert, username, orgURL) => {
  return runSfCommand(
    `echo "${cert}" | sf org login jwt --client-id "${consumerKey}" --jwt-key-file=/dev/stdin --username "${username}" --instance-url "${orgURL}`
  );
};

// This will un-authenticate using the alias which is the branch name
// exp:
// name: logout
//  run: |
//     node ci/workflows/Services/authentication-service.mjs "${{ github.head_ref }}"
const unauthenticate = (branchName) => {
  return runSfCommand(`npx sf org logout -o ${branchName} --no-prompt`);
};

export { findSecretName, authenticate, unauthenticate, authenticateWithJWT };

// ** POINT: On orchestration, we should have a function which will check the input -
//           - and accoridng to the input, it will run a different function
// exp:
// const args = process.argv;
// if (args.includes("findSecretName")) {
//   console.log(findSecretName(args[3]));
// } else if (args.includes("authenticate")) {
//   console.log(authenticate(args[3], args[4]));
// } else {
//   console.log(unauthenticate(args[2]));
// }
