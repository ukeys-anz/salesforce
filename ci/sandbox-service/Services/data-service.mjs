import { nonProdChangeValidation, runCommand } from "./helper.mjs";

const continueCheck = (output, msg, msgError = msg) => {
  if (!output.includes(msg)) return;
  console.error(`ERROR: ${msgError}`);
  process.exit(1);
};

const deployIndustryCodeCCRM = (orgAlias) => {
  console.log("--- running deployIndustryCodeCCRM ---");
  nonProdChangeValidation(orgAlias);

  let output = runCommand(`
      sf apex run -f ci/apex-scripts/pamApproversSetting.apex -o "${orgAlias}"
    `);
  continueCheck(output, "Error assigning Permission Set");

  output = runCommand(`
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

export { deployIndustryCodeCCRM };
