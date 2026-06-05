// Configuration for Agentforce exclusions in cloned sandboxes

// List of baseRef values for cloned sandboxes
export const clonedSandboxes = ["epic/blm"];

// Agentforce folder paths to exclude from deployment
export const agentforcePaths = [
  "force-app/main/default/genAiFunctions",
  "force-app/main/default/genAiPlannerBundles",
  "force-app/main/default/genAiPlugins",
  "force-app/main/default/genAiPromptTemplates",
  "force-app/main/default/classes/Agentforce",
  "force-app/main/default/dataKitObjectDependencies",
  "force-app/main/default/dataKitObjectTemplates",
  "force-app/main/default/dataPackageKitDefinitions",
  "force-app/main/default/DataPackageKitObjects",
  "force-app/main/default/dataSourceBundleDefinitions",
  "force-app/main/default/dataSourceObjects",
  "force-app/main/default/dataSrcDataModelFieldMaps",
  "force-app/main/default/dataStreamTemplates",
  "force-app/main/default/mktDataSources",
  "force-app/main/default/objects/BusinessBankerDesktop__dlm",
  "force-app/main/default/objects/Caz_Assessment__dlm",
  "force-app/main/default/objects/Customer_Insights__dlm",
  "force-app/main/default/objects/WholeOfCustomer__dlm"
];
