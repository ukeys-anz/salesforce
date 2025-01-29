import { nonProdChangeValidation, runCommand } from "./helper.mjs";

const continueCheck = (output, msg, msgError = msg) => {
  console.log(output);
  if (!output.includes(msg)) return;
  console.error(`ERROR: ${msgError}`);
  process.exit(1);
};

const assignRequiredPsets = (orgAlias) => {
  console.log("--- running assignRequiredPsets ---");
  nonProdChangeValidation(orgAlias);
  let output = runCommand(`
      sf apex run -f ci/apex-scripts/assignPset.apex -o "${orgAlias}"
    `);
  console.log(output);
};

const upsertCCRMIndustries = (orgAlias) => {
  console.log("--- running upsertCCRMIndustries ---");
  nonProdChangeValidation(orgAlias);
  let output = runCommand(`
    sf data upsert bulk --sobject Industry__c --file data/CCRM-Industry__c.csv --external-id Code__c -o "${orgAlias}"
  `);
  console.log(output);
};

const deployIndustryCodeCCRM = (orgAlias) => {
  console.log("--- running deployIndustryCodeCCRM ---");
  nonProdChangeValidation(orgAlias);

  let output = runCommand(`
        sf apex run -f ci/apex-scripts/createReciprocalAccountRoles.apex -o "${orgAlias}"
    `);
  continueCheck(
    output,
    "failed",
    "Failed on running createReciprocalAccountRoles.apex"
  );

  output = runCommand(`
        sf apex run -f ci/apex-scripts/createReciprocalContactRoles.apex -o "${orgAlias}"
    `);
  continueCheck(
    output,
    "failed",
    "Failed on running createReciprocalContactRoles.apex"
  );
};

const createCMOSKnownIssues = (orgAlias) => {
  console.log("--- running createKnownIssues ---");
  nonProdChangeValidation(orgAlias);
  let output = runCommand(`
    sf data import tree -p data/IDR-Known-Issues-plan.json --json -o "${orgAlias}"
  `);
  console.log(output);
};

export {
  assignRequiredPsets,
  upsertCCRMIndustries,
  deployIndustryCodeCCRM,
  createCMOSKnownIssues
};
