import Auth from "../common/Auth";
import Chatter from "../common/Chatter";
import { navigateToAppAndTab } from "../utils/navigationUtils";
import { UserRole } from "../constants/enums";
import { App, AppTab } from "../constants/appsDefinition";
import { searchRecordInGlobalSearchAndRedirect } from "../utils/commonUtils";
import accountData from "../data/accountData";

describe("AR-10341: Salesforce Chatter", async (): Promise<void> => {
  // pre test steps
  before(async (): Promise<void> => {
    // max viewport
    await browser.maximizeWindow();

    // login as test user
    await Auth.loginSalesforceAsRole(UserRole.Coach);
  });

  beforeEach(async (): Promise<void> => {
    await browser.takeScreenshot();
    await browser.pause(500);
  });

  afterEach(async (): Promise<void> => {
    await browser.takeScreenshot();
    await browser.pause(500);
  });

  describe("AR-10342: Coach comments on Person Account page", async (): Promise<void> => {
    const chatter = new Chatter("Account");

    it("Go to Coaches Workbench and Account tab", async (): Promise<void> => {
      await navigateToAppAndTab(App.Coaches_Workbench, AppTab.Accounts);
    });

    it("Go to Account", async (): Promise<void> => {
      // search account in global search and redirect
      await searchRecordInGlobalSearchAndRedirect(accountData.ocvId);
    });

    it("Create Credit Card Comment", async (): Promise<void> => {
      await chatter.postChatterComment("CreditCard");
    });

    it("Credit Card Number has been Masked", async (): Promise<void> => {
      await chatter.verifyChatterComment("CreditCard");
    });

    it("User Cannot Delete Comment", async (): Promise<void> => {
      await chatter.deleteChatterComment();
    });
  });

  after(async (): Promise<void> => {
    // log out test user
    await Auth.logoutSalesforce();
  });
});
