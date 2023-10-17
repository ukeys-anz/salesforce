import { runSfCommand, logger } from "./helper.mjs";

// This will take the secretValue and branch name and will do the authentication.
// exp:
// name: Authenticate all orgs in SFDX CLI
//   run: |
//      node ci/workflows/Services/authentication-service.mjs authenticate "${{ github.head_ref }}" "${{ steps.secrets.outputs.sfdxurl }}"
const authenticate = (branchName, secretValue) => {
  const authLog = runSfCommand(
    `echo "${secretValue}" | npx sf org login sfdx-url -a "${branchName}" --sfdx-url-file=/dev/stdin`
  );
  logger(authLog);
};

// For production, we use connectedApp with JWT to do the authentication
// Inputs:
//  username: tech.gcb@anzx.com
//  orgURL: https://anz.my.salesforce.com
const authenticateWithJWT = (consumerKey, cert, username, orgURL) => {
  const authLog = runSfCommand(
    `echo "${cert}" | sf org login jwt --client-id "${consumerKey}" --jwt-key-file=/dev/stdin --username "${username}" --instance-url "${orgURL}`
  );
  logger(authLog);
};

// This will un-authenticate using the alias which is the branch name
// exp:
// name: logout
//  run: |
//     node ci/workflows/Services/authentication-service.mjs "${{ github.head_ref }}"
const unauthenticate = (branchName) => {
  const unauthLog = runSfCommand(
    `npx sf org logout -o ${branchName} --no-prompt`
  );
  logger(unauthLog);
};

export { authenticate, unauthenticate, authenticateWithJWT };

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
