/// How to run this : node ci/sandbox-service/Orchestrations/setup-config-setting.mjs <orgAlias | org username>

import { createCMOSEntitlement } from "../../createCmosEntitlment.mjs";
import {
  createSystemCustomer,
  deployAllOmnistudioComponents,
  deployContentAssets,
  deployRequiredFiles,
  runLoggingRecordsPurgeScheduler,
  runSandboxConfigSetupApex,
  addPAMApproversIntoQueue,
  updateOmniStudioRemoteSetting,
  updatePamApproversCustomSetting,
  updateUserFedId,
  assignDeployUserViewAllFields,
  unfreezeUsers,
  assignDisableMFA,
  addDisableMFAToEngineerPSG
} from "../Services/config-setting.mjs";
import { removeSensitiveProdInformation } from "../Services/remove-secrets.mjs";

/// Hardcoded username input
let argvs = process.argv;
argvs = argvs.slice(2);
const USER_NAME = argvs[0];
////////

const runSetupConfigAndSettings = (orgAlias) => {
  removeSensitiveProdInformation(orgAlias);
  createSystemCustomer(orgAlias);
  createCMOSEntitlement(orgAlias);
  deployContentAssets(orgAlias);
  updateOmniStudioRemoteSetting(orgAlias);
  runSandboxConfigSetupApex(orgAlias);
  addPAMApproversIntoQueue(orgAlias);
  updatePamApproversCustomSetting(orgAlias);
  deployRequiredFiles(orgAlias);
  updateUserFedId(orgAlias);
  unfreezeUsers(orgAlias);
  addDisableMFAToEngineerPSG(orgAlias);
  assignDisableMFA(orgAlias);
  runLoggingRecordsPurgeScheduler(orgAlias);
  deployAllOmnistudioComponents(orgAlias);
  assignDeployUserViewAllFields(orgAlias); //Only Required for Test Sandbox (BigQuery Integrated Sandbox)
};

/// Run
runSetupConfigAndSettings(USER_NAME);
