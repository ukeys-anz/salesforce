import {
  runCommand,
  nonProdChangeValidation,
  retrieveComponent,
  changeForceIgnoreFile,
  findAllFiles,
  updateMetadataOnComponent,
  deployFiles
} from "./helper.mjs";

const runSandboxConfigSetupApex = (orgAlias) => {
  console.log("--- running runSandboxConfigSetupApex ---");
  nonProdChangeValidation(orgAlias);
  console.log("Deploy VlocityLogoDocumentUploads ... ");
  console.log("Update nonProd Aegis Custom Setting url ....");
  return runCommand(`
      sf apex run -f ./ci/apex-scripts/sandboxConfigSetup.apex -o "${orgAlias}"
    `);
};

const addPAMApproversIntoQueue = (orgAlias) => {
  console.log("--- addPAMApproversIntoQueue ---");
  nonProdChangeValidation(orgAlias);
  return runCommand(`
      sf apex run -f ./ci/apex-scripts/addPAMApproversIntoQueue.apex -o "${orgAlias}"
    `);
};

const updateOmniStudioRemoteSetting = (
  orgAlias,
  filepath = "ci/sandbox-service/Config/RemoteSiteSettingsPackage.xml"
) => {
  console.log("--- running updateOmniStudioRemoteSetting ---");
  nonProdChangeValidation(orgAlias);
  changeForceIgnoreFile("Change");
  retrieveComponent(filepath, orgAlias);
  let allRemoteSiteSettings = findAllFiles(
    "force-app/main/default/remoteSiteSettings"
  );
  allRemoteSiteSettings.filter((f) => f.toLowerCase().includes("omnistudio"));

  allRemoteSiteSettings.forEach((f) => {
    const flag = updateMetadataOnComponent(f, orgAlias);
    if (flag) {
      console.log(`change on: ${f}`);
    }
  });
  deployFiles(["force-app/main/default/remoteSiteSettings"], orgAlias);
  changeForceIgnoreFile("Revert");
  console.log("OmniStudio related Remote Site Settings are updated...");
};

// example: updateOmniStudioRemoteSetting('odaseva', 'ci/sandbox-service/Config/RemoteSiteSettingsPackage.xml')

const deployAllOmnistudioComponents = (orgAlias) => {
  console.log("--- running deployAllOmnistudioComponents ---");
  changeForceIgnoreFile("Change");
  nonProdChangeValidation(orgAlias);
  const filepathSet = [
    "force-app/main/default/omniDataTransforms",
    "force-app/main/default/omniIntegrationProcedures",
    "force-app/main/default/omniScripts",
    "force-app/main/default/omniUiCard"
  ];
  deployFiles(filepathSet, orgAlias);
  changeForceIgnoreFile("Revert");
  console.log("All OmniStudio components deployed...");
};

const deployContentAssets = (orgAlias) => {
  console.log("--- running deployContentAssets ---");
  changeForceIgnoreFile("Change");
  nonProdChangeValidation(orgAlias);
  const filepathSet = [
    "force-app/main/default/contentassets",
    "ci/sandbox-service/Config/VlocityLogoDocumentUploads.asset"
  ];
  deployFiles(filepathSet, orgAlias);
  changeForceIgnoreFile("Revert");
  console.log("Content Assets deployed...");
};

const createSystemCustomer = (orgAlias) => {
  console.log("--- running createSystemCustomer ---");
  nonProdChangeValidation(orgAlias);
  console.log("create system customer ...");
  return runCommand(`
    sf apex run -f ci/apex-scripts/createSystemCustomer.apex -o "${orgAlias}"
  `);
};

const updateUserFedId = (orgAlias) => {
  console.log("--- running updateUserFedId ---");
  nonProdChangeValidation(orgAlias);
  let continueFlag = true;
  while (continueFlag) {
    console.log("----------------------------");
    console.log("Run updateUserFedId apex....");
    const output = runCommand(`
      sf apex run -f ci/apex-scripts/updateUserFedId.apex -o "${orgAlias}"
    `);

    console.log(output);

    if (output.includes("Stop job Flag: true")) {
      continueFlag = false;
    } else if (output.includes("Error while updating UserLogins")) {
      console.log("Encountered error while updating UserLogins...");
      process.exit(1);
    }
  }
  console.log("User Federation Identifiers are updated...");
};

const unfreezeUsers = (orgAlias) => {
  console.log("--- running unfreezeUsers ---");
  nonProdChangeValidation(orgAlias);
  let continueFlag = true;
  while (continueFlag) {
    console.log("----------------------------");
    console.log("Run updateFrozenUser apex....");
    const output = runCommand(`
      sf apex run -f ci/apex-scripts/updateFrozenUser.apex -o "${orgAlias}"
    `);

    console.log(output);

    if (output.includes("Stop job Flag: false")) {
      continueFlag = true;
    } else {
      console.log("All users are unfrozen...");
      continueFlag = false;
    }
  }
  console.log("All frozen users are unfrozen...");
};

const deployRequiredFiles = (orgAlias) => {
  console.log("--- running deployRequiredFiles ---");
  nonProdChangeValidation(orgAlias);
  deployFiles(
    [
      "ci/sandbox-service/Config/TEST_ONLY_Refresh_Token.permissionset-meta.xml",
      "force-app/main/default/permissionsets/View_All_Fields.permissionset-meta.xml",
      "force-app/main/default/labels/CustomLabels.labels-meta.xml",
      "force-app/main/default/AssessmentQuestions"
    ],
    orgAlias
  );
  console.log("Required files deployed...");
};

const assignDeployUserViewAllFields = (orgAlias) => {
  console.log("--- running assignDeployUserViewAllFields ---");
  nonProdChangeValidation(orgAlias);

  // Validate sandbox name, as this script is only required for test sandboxes
  if (!orgAlias.startsWith("sitl")) {
    console.log("No action needed for other sandbox, besides Test Sandbox");
    return;
  }

  //Querying Deploy User's username
  const deployUsernameCommand = `
    sf data query --query "SELECT Username FROM User WHERE Name = 'Deploy User' AND IsActive = true LIMIT 1" --target-org ${orgAlias} --result-format csv | tail -n +2
  `;

  const deployUsername = runCommand(deployUsernameCommand).trim();

  // Assigning View_All_Fields permset to Deploy User
  if (deployUsername) {
    const assignPermsetCommand = `
      sf org assign permset --name View_All_Fields --on-behalf-of "${deployUsername}" --target-org ${orgAlias}
    `;
    const result = runCommand(assignPermsetCommand);
    console.log(`Assigned permset to ${deployUsername}:`, result);
    return result;
  } else {
    console.log("No active Deploy User found.");
  }
};

const runLoggingRecordsPurgeScheduler = (orgAlias) => {
  console.log("--- running runLoggingRecordsPurgeScheduler ---");
  nonProdChangeValidation(orgAlias);
  console.log("Schedule LoggingRecordsPurgeScheduler ...");
  return runCommand(`
    sf apex run -f ci/apex-scripts/runLoggingRecordsPurgeScheduler.apex -o "${orgAlias}"
  `);
};

const updatePamApproversCustomSetting = (orgAlias) => {
  console.log("--- running updatePamApproversCustomSetting ---");
  nonProdChangeValidation(orgAlias);
  return runCommand(`
    sf apex run -f ci/apex-scripts/pamApproversSetting.apex -o "${orgAlias}"
  `);
};

export {
  runSandboxConfigSetupApex,
  addPAMApproversIntoQueue,
  updateOmniStudioRemoteSetting,
  deployAllOmnistudioComponents,
  deployContentAssets,
  createSystemCustomer,
  updateUserFedId,
  deployRequiredFiles,
  runLoggingRecordsPurgeScheduler,
  updatePamApproversCustomSetting,
  assignDeployUserViewAllFields,
  unfreezeUsers
};
