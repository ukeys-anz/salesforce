import Auth from "../../common/Auth";
import { UserRole, Access } from "../../constants/enums";
import UAM from "../../common/UAM";
import { App } from "../../constants/appsDefinition";
import accountData from "../../data/accountData";
import { ReportAction, HasReportActionAccess } from "../../common/UAM";

describe("AR-13398: Salesforce UAM: AR-13405: Quality Analyst UAM", () => {
  const qualityAnalystUAM = new UAM(UserRole.Quality_Analyst);

  // pre test steps
  before(async (): Promise<void> => {
    // max viewport
    await browser.maximizeWindow();

    // login as test user
    await Auth.loginSalesforceAsRole(qualityAnalystUAM.userRole);
  });

  beforeEach(async (): Promise<void> => {
    await browser.takeScreenshot();
    await browser.pause(500);
  });

  afterEach(async (): Promise<void> => {
    await browser.takeScreenshot();
    await browser.pause(500);
  });

  it("Quality Analyst cannot access Content Workbench", async (): Promise<void> => {
    await qualityAnalystUAM.verifyAppAccess(false, App.Content_Workbench);
  });

  it("Quality Analyst cannot edit customer detail", async (): Promise<void> => {
    await qualityAnalystUAM.verifyAccountAccess(
      Access.Read_Only,
      accountData.ocvId
    );
  });

  it("Quality Analyst cannot edit financial account", async (): Promise<void> => {
    await qualityAnalystUAM.verifyFinancialAccountAccess(
      Access.Read_Only,
      accountData.checkAccountNumber
    );
  });

  it("Quality Analyst cannot create Knowledge article in Coaches Workbench", async (): Promise<void> => {
    await qualityAnalystUAM.verifyKnowledgeCreateAccess(false);
  });

  it("Quality Analyst cannot edit Knowledge article in Coaches Workbench", async (): Promise<void> => {
    await qualityAnalystUAM.verifyKnowledgeAccess(Access.Read_Only);
  });

  it("Quality Analyst cannot create report", async (): Promise<void> => {
    await qualityAnalystUAM.verifyReportAccess(Access.Read_Only);
  });

  it("Quality Analyst cannot export, edit, or delete report", async (): Promise<void> => {
    const actionsToCheck: Map<ReportAction, HasReportActionAccess> = new Map([
      ["Export", false],
      ["Edit", false],
      ["Delete", false]
    ]);
    await qualityAnalystUAM.verifyReportActionsAccess(actionsToCheck);
  });

  after(async (): Promise<void> => {
    // log out test user
    await Auth.logoutSalesforce();
  });
});
