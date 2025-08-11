import { runSfCommand, logger, loggerInStep } from "./helper.mjs";

// Required allowedDomains based on sfdx's AuthURL
const ALLOWED_DOMAINS = [
  "@anz--",
  "@anzbankbroker--",
  "@australiaandnewzealandbanking--"
];

// This function checks if the provided secret value contains any allowed ANZx Salesforce domains.
const checkAllowedDomains = (secretValue) => {
  return ALLOWED_DOMAINS.some((domain) => secretValue.includes(domain));
};

// This will take the secretValue and branch name and will do the authentication.
const authenticate = (branchName, secretValue) => {
  logger("Authenticate to targetOrg");
  if (!checkAllowedDomains(secretValue)) {
    loggerInStep("❌ Invalid ANZx Salesforce domain. Authentication aborted.");
    process.exit(1);
  }
  const authLog = runSfCommand(
    `echo "${secretValue}" | npx sf org login sfdx-url -a "${branchName}" --sfdx-url-file=/dev/stdin`
  );
  console.log(authLog);
};

// For production, we use connectedApp with JWT to do the authentication
// Inputs:
//  username: tech.gcb@anzx.com
//  orgURL: https://anz.my.salesforce.com
const authenticateWithJWT = (consumerKey, cert, username, orgURL) => {
  logger("Authenticate to Production");
  const authLog = runSfCommand(
    `echo "${cert}" | sf org login jwt --client-id "${consumerKey}" --jwt-key-file=/dev/stdin --username "${username}" --instance-url "${orgURL}"`
  );
  console.log(authLog);
};

// This will un-authenticate using the alias which is the branch name
const unauthenticate = (branchName) => {
  logger("Un-authenticate from targetOrg");
  const unauthLog = runSfCommand(
    `npx sf org logout -o ${branchName} --no-prompt`
  );
  console.log(unauthLog);
};

///////////////////////////////////////////

export { authenticate, unauthenticate, authenticateWithJWT };
