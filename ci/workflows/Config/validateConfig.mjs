const salesforceMetadataToSkipTest = [
  "ActionLauncherItemDef",
  "ActionPlanTemplate",
  "AnimationRule",
  "AssessmentQuestion",
  "AuraDefinitionBundle",
  "AuthProvider",
  "CallCenter",
  "Certificate",
  "CompactLayout",
  "ConnectedApp",
  "ContentAsset",
  "CustomApplication",
  "CustomIndex",
  "CustomObjectTranslation",
  "CustomTab",
  "Dashboard",
  "DataCategoryGroup",
  "EclairGeoData",
  "EmailTemplate",
  "FlexiPage",
  "Index",
  "Layout",
  "LightningComponentBundle",
  "LightningMessageChannel",
  "ListView",
  "OmniDataTransform",
  "OmniIntegrationProcedure",
  "OmniScript",
  "OmniUiCard",
  "PathAssistant",
  "QuickAction",
  "RecordActionDeployment",
  "Report",
  "ReportType",
  "TimelineObjectDefinition",
  "WaveApplication",
  "WaveDashboard",
  "WaveDataflow",
  "WaveDataset",
  "WaveLens",
  "WaveTemplateBundle",
  "WaveXmd",
  "WebLink"
];

const selectiveMetadataToSkipTest = {
  PermissionSet: ["SF_Data_Sync_Integration"]
};

const checkIfTestWhiteListed = (type, items) => {
  if (salesforceMetadataToSkipTest.includes(type)) {
    return true;
  }

  if (Object.keys(selectiveMetadataToSkipTest).includes(type)) {
    return items.every((x) => selectiveMetadataToSkipTest[type].includes(x));
  }

  return false;
};
export { checkIfTestWhiteListed };
