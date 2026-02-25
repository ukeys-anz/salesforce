// Configuration for Agentforce exclusions in cloned sandboxes

// List of baseRef values for cloned sandboxes
export const clonedSandboxes = ["epic/blm"];

// Agentforce folder paths to exclude from deployment
export const agentforcePaths = [
  "force-app/main/default/genAiFunctions",
  "force-app/main/default/genAiPlannerBundles",
  "force-app/main/default/genAiPlugins",
  "force-app/main/default/genAiPromptTemplates",
  "force-app/main/default/classes/Agentforce"
];
