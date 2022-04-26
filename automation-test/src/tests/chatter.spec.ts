import Auth from "common/Auth";
import Chatter from "common/Chatter";
import { navigateToConsoleAppAndTab } from "utils/consoleUtils";
import { UserRole, App, AppTab } from "constants/enums";
import { searchRecordInGlobalSearchAndRedirect } from "utils/commonUtils";
import accountData from "data/accountData";

describe("Chatter - Coach Updates Chatter", () => {
  // pre test steps
  before(async (): Promise<void> => {
    // max viewport
    await browser.maximizeWindow();

    // login as test user
    await Auth.loginSalesforceAsRole(UserRole.COACH);
  });

  beforeEach(async () => {
    await browser.pause(1000);
  });

  describe("Update and Delete Account Chatter Comment", async (): Promise<void> => {
    const chatter = new Chatter("Account");

    it("Go to Coaches Workbench and Account tab", async (): Promise<void> => {
      await navigateToConsoleAppAndTab(App.Coaches_Workbench, AppTab.Accounts);
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
