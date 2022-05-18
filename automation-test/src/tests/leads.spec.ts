import Auth from "common/Auth";
import { navigateToAppAndTab } from "utils/navigationUtils";
import { UserRole } from "constants/enums";
import { App, AppTab } from "constants/appsDefinition";
import ANZXLead from "common/Lead/ANZXLead";

describe("AR-11357: ANZX Leads", async (): Promise<void> => {
  // pre test steps
  before(async (): Promise<void> => {
    // max viewport
    await browser.maximizeWindow();
  });

  beforeEach(async (): Promise<void> => {
    await browser.takeScreenshot();
    await browser.pause(500);
  });

  afterEach(async (): Promise<void> => {
    await browser.takeScreenshot();
    await browser.pause(500);
  });

  describe("AR-11387: Coach creates and nurtures ANZX Lead", async (): Promise<void> => {
    const anzxLead = new ANZXLead(UserRole.COACH);

    it("Login as Coach", async (): Promise<void> => {
      // login as test user
      await Auth.loginSalesforceAsRole(UserRole.COACH);
    });

    it("Go to Coaches Workbench and Leads Tab", async (): Promise<void> => {
      await navigateToAppAndTab(App.Coaches_Workbench, AppTab.Leads);
    });

    it("Create an ANZX Lead", async (): Promise<void> => {
      await anzxLead.create();
    });

    it("Post chatter on Lead", async (): Promise<void> => {
      await anzxLead.postChatterComment();
    });

    it("Chatter post appears on Lead", async (): Promise<void> => {
      await anzxLead.verifyChatterComment();
    });

    it("Lead cannot be manually converted", async (): Promise<void> => {
      await anzxLead.verifyCannotManuallyConvert();
    });

    after(async (): Promise<void> => {
      // log out test user
      await Auth.logoutSalesforce();
    });
  });
});
