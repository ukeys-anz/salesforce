export const enum App {
  Coaches_Workbench = "Coaches Workbench",
  Content_Workbench = "Content Workbench",
  Quality_Workbench = "Quality Workbench"
}

export const enum AppTab {
  Home = "Home",
  Cases = "Cases",
  Accounts = "Accounts",
  Knowledge = "Knowledge",
  Survey_Responses = "Survey Responses",
  Leads = "Leads"
}

export default new Map<string, { name: string; type: "Console" | "Standard" }>([
  [
    App.Coaches_Workbench,
    {
      name: App.Coaches_Workbench,
      type: "Console"
    }
  ],
  [
    App.Quality_Workbench,
    {
      name: App.Quality_Workbench,
      type: "Console"
    }
  ],
  [
    App.Content_Workbench,
    {
      name: App.Content_Workbench,
      type: "Standard"
    }
  ]
]);
