import Auth from "common/Auth";
import VirtualGoals from "common/VirtualGoals";
import { navigateToConsoleAppAndTab } from "utils/consoleUtils";
import { UserRole, App, AppTab } from "constants/enums";
import { searchRecordInGlobalSearchAndRedirect } from "utils/commonUtils";
import accountData from "data/accountData";

describe("Virual Goal - Coach Views Goal Details", () => {
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

  describe("View Account Goal Details", async (): Promise<void> => {
    it("Go to Coaches Workbench and Account tab", async (): Promise<void> => {
      await navigateToConsoleAppAndTab(App.Coaches_Workbench, AppTab.Accounts);
    });

    it("Go to Account", async (): Promise<void> => {
      // search account in global search and redirect
      await searchRecordInGlobalSearchAndRedirect(accountData.ocvId);
    });

    it("View Goal Component", async (): Promise<void> => {
      await new VirtualGoals().viewAccountGoals();
    });
  });

  describe("View Financial Goal Details", async (): Promise<void> => {
    it("Go to Coaches Workbench and Account tab", async (): Promise<void> => {
      await navigateToConsoleAppAndTab(App.Coaches_Workbench, AppTab.Accounts);
    });

    it("Go to Financial Account", async (): Promise<void> => {
      // search financial account in global search and redirect
      await searchRecordInGlobalSearchAndRedirect(
        accountData.savingsAccountNumber
      );
    });

    it("View Goal Component", async (): Promise<void> => {
      await new VirtualGoals().viewFinancialAccountGoals();
    });
  });

  after(async (): Promise<void> => {
    // log out test user
    await Auth.logoutSalesforce();
  });
});
