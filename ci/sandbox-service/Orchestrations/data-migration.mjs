/// How to run this : node ci/sandbox-service/Orchestrations/data-migration.mjs <orgAlias | org username>

import { deployIndustryCodeCCRM } from "../Services/data-service.mjs";

/// Hardcoded username input
let argvs = process.argv;
argvs = argvs.slice(2);
const USER_NAME = argvs[0];
////////

const dataMigration = (orgAlias) => {
  deployIndustryCodeCCRM(orgAlias);
};

// Run
dataMigration(USER_NAME);
