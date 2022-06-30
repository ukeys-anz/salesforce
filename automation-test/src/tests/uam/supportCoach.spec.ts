import Auth from "../../common/Auth";
import { UserRole, Access } from "../../constants/enums";
import UAM from "../../common/UAM";
import { App } from "../../constants/appsDefinition";
import accountData from "../../data/accountData";

describe("AR-13398: Salesforce UAM: AR-13403: Support Coach UAM", () => {
  const supportCoachUAM = new UAM(UserRole.Support_Coach);

  // pre test steps
  before(async (): Promise<void> => {
    // max viewport
    await browser.maximizeWindow();

    // login as test user
    await Auth.loginSalesforceAsRole(supportCoachUAM.userRole);
  });

  beforeEach(async (): Promise<void> => {
    await browser.takeScreenshot();
    await browser.pause(500);
  });

  afterEach(async (): Promise<void> => {
    await browser.takeScreenshot();
    await browser.pause(500);
  });

  it("Support Coach cannot access Content Workbench", async (): Promise<void> => {
    await supportCoachUAM.verifyAppAccess(false, App.Content_Workbench);
  });

  it("Support Coach cannot edit customer detail", async (): Promise<void> => {
    await supportCoachUAM.verifyAccountAccess(
      Access.Read_Only,
      accountData.ocvId
    );
  });

  it("Support Coach cannot edit financial account", async (): Promise<void> => {
    await supportCoachUAM.verifyFinancialAccountAccess(
      Access.Read_Only,
      accountData.checkAccountNumber
    );
  });

  it("Support Coach cannot create Knowledge article", async (): Promise<void> => {
    await supportCoachUAM.verifyKnowledgeCreateAccess(false);
  });

  it("Support Coach cannot edit Knowledge article", async (): Promise<void> => {
    await supportCoachUAM.verifyKnowledgeAccess(Access.Read_Only);
  });

  after(async (): Promise<void> => {
    // log out test user
    await Auth.logoutSalesforce();
  });
});
