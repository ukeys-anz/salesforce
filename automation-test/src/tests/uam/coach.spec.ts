import Auth from "../../common/Auth";
import { UserRole, Access } from "../../constants/enums";
import UAM from "../../common/UAM";
import { App } from "../../constants/appsDefinition";
import accountData from "../../data/accountData";
import { ReportAction, HasReportActionAccess } from "../../common/UAM";

describe("AR-13398: Salesforce UAM: AR-13402: Coach UAM", () => {
  const coachUAM = new UAM(UserRole.Coach);

  // pre test steps
  before(async (): Promise<void> => {
    // max viewport
    await browser.maximizeWindow();

    // login as test user
    await Auth.loginSalesforceAsRole(coachUAM.userRole);
  });

  beforeEach(async (): Promise<void> => {
    await browser.takeScreenshot();
    await browser.pause(500);
  });

  afterEach(async (): Promise<void> => {
    await browser.takeScreenshot();
    await browser.pause(500);
  });

  it("Coach cannot access Content Workbench", async (): Promise<void> => {
    await coachUAM.verifyAppAccess(false, App.Content_Workbench);
  });

  it("Coach cannot edit customer detail", async (): Promise<void> => {
    await coachUAM.verifyAccountAccess(Access.Read_Only, accountData.ocvId);
  });

  it("Coach cannot edit financial account", async (): Promise<void> => {
    await coachUAM.verifyFinancialAccountAccess(
      Access.Read_Only,
      accountData.checkAccountNumber
    );
  });

  it("Coach cannot create Knowledge article in Coaches Workbench", async (): Promise<void> => {
    await coachUAM.verifyKnowledgeCreateAccess(false);
  });

  it("Coach cannot edit Knowledge article in Coaches Workbench", async (): Promise<void> => {
    await coachUAM.verifyKnowledgeAccess(Access.Read_Only);
  });

  it("Coach can access Release Notes from Content Workbench", async (): Promise<void> => {
    await coachUAM.verifyCanOpenReleaseNotes();
  });

  it("Coach cannot create report", async (): Promise<void> => {
    await coachUAM.verifyReportAccess(Access.Read_Only);
  });

  it("Coach cannot export, edit, or delete report", async (): Promise<void> => {
    const actionsToCheck: Map<ReportAction, HasReportActionAccess> = new Map([
      ["Export", false],
      ["Edit", false],
      ["Delete", false]
    ]);
    await coachUAM.verifyReportActionsAccess(actionsToCheck);
  });

  it("Coach can open and view Apps and Reports in Analytics Studio", async (): Promise<void> => {
    const appsToCheck = ["Dashboards for Coaches"];
    const reportsToCheck = ["My Dashboard"];

    await coachUAM.verifyAnalyticsAppsAndReportsAccess(
      appsToCheck,
      reportsToCheck
    );
  });

  after(async (): Promise<void> => {
    // log out test user
    await Auth.logoutSalesforce();
  });
});
