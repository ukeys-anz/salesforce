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
    }
  }
};

const deployRequiredFiles = (orgAlias) => {
  console.log("--- running deployRequiredFiles ---");
  nonProdChangeValidation(orgAlias);
  deployFiles(
    [
      "ci/sandbox-service/Config/TEST_ONLY_Refresh_Token.permissionset-meta.xml",
      "force-app/main/default/labels/CustomLabels.labels-meta.xml",
      "force-app/main/default/AssessmentQuestions"
    ],
    orgAlias
  );
};

const runLoggingRecordsPurgeScheduler = (orgAlias) => {
  console.log("--- running runLoggingRecordsPurgeScheduler ---");
  nonProdChangeValidation(orgAlias);
  console.log("Schedule LoggingRecordsPurgeScheduler ...");
  return runCommand(`
    sf apex run -f ci/apex-scripts/runLoggingRecordsPurgeScheduler.apex -o "${orgAlias}"
  `);
};

export {
  runSandboxConfigSetupApex,
  updateOmniStudioRemoteSetting,
  deployAllOmnistudioComponents,
  deployContentAssets,
  createSystemCustomer,
  updateUserFedId,
  deployRequiredFiles,
  runLoggingRecordsPurgeScheduler
};
