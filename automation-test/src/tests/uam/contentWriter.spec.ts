import Auth from "../../common/Auth";
import { UserRole } from "../../constants/enums";
import { AppTab } from "../../constants/appsDefinition";
import UAM from "../../common/UAM";
import { App } from "../../constants/appsDefinition";

describe("AR-13398: Salesforce UAM: AR-13406: Content Writer UAM (Automated)", () => {
  const contentWriterUAM = new UAM(UserRole.Content_Writer);

  // pre test steps
  before(async (): Promise<void> => {
    // max viewport
    await browser.maximizeWindow();

    // login as test user
    await Auth.loginSalesforceAsRole(contentWriterUAM.userRole);
  });

  beforeEach(async (): Promise<void> => {
    await browser.takeScreenshot();
    await browser.pause(500);
  });

  afterEach(async (): Promise<void> => {
    await browser.takeScreenshot();
    await browser.pause(500);
  });

  it("Content Writer cannot access Coaches Workbench", async (): Promise<void> => {
    await contentWriterUAM.verifyAppAccess(false, App.Coaches_Workbench);
  });

  it("Content Writer cannot access Cases", async (): Promise<void> => {
    await contentWriterUAM.verifyItemAccess(false, AppTab.Cases);
  });

  it("Content Writer cannot access Accounts", async (): Promise<void> => {
    await contentWriterUAM.verifyItemAccess(false, AppTab.Accounts);
  });

  it("Content Writer cannot access Financial Accounts", async (): Promise<void> => {
    await contentWriterUAM.verifyItemAccess(false, AppTab.Financial_Accounts);
  });

  after(async (): Promise<void> => {
    // log out test user
    await Auth.logoutSalesforce();
  });
});
