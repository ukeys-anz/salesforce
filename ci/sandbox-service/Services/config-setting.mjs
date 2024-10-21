import {
  runCommand,
  nonProdChangeValidation,
  retrieveComponent,
  changeForceIgnoreFile,
  findAllFiles,
  updateMetadataOnComponent,
  deployFiles
} from "./helper.mjs";

const insertOmniStudioDocument = (usernameOrAlias) => {
  nonProdChangeValidation(usernameOrAlias);
  return runCommand(`
        sf apex run -f ./ci/apex-scripts/sandbox.apex -o "${usernameOrAlias}"
    `);
};

const updateOmniStudioRemoteSetting = (orgAlias, filepath) => {
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
  changeForceIgnoreFile("Change");
  nonProdChangeValidation(orgAlias);
  const filepathSet = [
    "force-app/main/default/contentassets",
    "ci/sandbox-service/Config/VlocityLogoDocumentUploads.asset"
  ];
  deployFiles(filepathSet, orgAlias);
  changeForceIgnoreFile("Revert");
};

export {
  insertOmniStudioDocument,
  updateOmniStudioRemoteSetting,
  deployAllOmnistudioComponents,
  deployContentAssets
};
