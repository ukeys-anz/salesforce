import Auth from "../common/Auth";
import VirtualGoal from "../common/VirtualGoal";
import { navigateToAppAndTab } from "../utils/navigationUtils";
import { UserRole } from "../constants/enums";
import { App, AppTab } from "../constants/appsDefinition";
import { searchRecordInGlobalSearchAndRedirect } from "../utils/commonUtils";
import accountData from "../data/accountData";

describe("AR-10286: Salesforce Virual Goals", async (): Promise<void> => {
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

  describe("AR-10285: Coach views VG on Person Account page", async (): Promise<void> => {
    it("Login as Coach", async (): Promise<void> => {
      // login as test user
      await Auth.loginSalesforceAsRole(UserRole.Coach);
    });

    it("Go to Coaches Workbench and Account tab", async (): Promise<void> => {
      await navigateToAppAndTab(App.Coaches_Workbench, AppTab.Accounts);
    });

    it("Go to Account", async (): Promise<void> => {
      // search account in global search and redirect
      await searchRecordInGlobalSearchAndRedirect(accountData.ocvId);
    });

    it("View Goal Component", async (): Promise<void> => {
      await new VirtualGoal().viewAccountGoals();
    });

    it("Logout", async (): Promise<void> => {
      // log out test user
      await Auth.logoutSalesforce();
    });
  });

  describe("AR-10287: Coach views VG on Financial Account page", async (): Promise<void> => {
    it("Login as Coach", async (): Promise<void> => {
      // login as test user
      await Auth.loginSalesforceAsRole(UserRole.Coach);
    });

    it("Go to Coaches Workbench and Account tab", async (): Promise<void> => {
      await navigateToAppAndTab(App.Coaches_Workbench, AppTab.Accounts);
    });

    it("Go to Financial Account", async (): Promise<void> => {
      // search financial account in global search and redirect
      await searchRecordInGlobalSearchAndRedirect(
        accountData.savingsAccountNumber
      );
    });

    it("View Goal Component", async (): Promise<void> => {
      await new VirtualGoal().viewFinancialAccountGoals();
    });

    it("Logout", async (): Promise<void> => {
      // log out test user
      await Auth.logoutSalesforce();
    });
  });

  describe("AR-10288: Quality Analyst views VG on Person Account page", async (): Promise<void> => {
    it("Login as Quality Analyst", async (): Promise<void> => {
      // login as test user
      await Auth.loginSalesforceAsRole(UserRole.Quality_Analyst);
    });

    it("Go to Quality Workbench and Account tab", async (): Promise<void> => {
      await navigateToAppAndTab(App.Quality_Workbench, AppTab.Accounts);
    });

    it("Go to Account", async (): Promise<void> => {
      // search account in global search and redirect
      await searchRecordInGlobalSearchAndRedirect(accountData.ocvId);
    });

    it("View Goal Component", async (): Promise<void> => {
      await new VirtualGoal().viewAccountGoals();
    });

    it("Logout", async (): Promise<void> => {
      // log out test user
      await Auth.logoutSalesforce();
    });
  });

  describe("AR-10289: Quality Analyst views VG on Financial Account page", async (): Promise<void> => {
    it("Login as Quality Analyst", async (): Promise<void> => {
      // login as test user
      await Auth.loginSalesforceAsRole(UserRole.Quality_Analyst);
    });

    it("Go to Quality Workbench and Account tab", async (): Promise<void> => {
      await navigateToAppAndTab(App.Quality_Workbench, AppTab.Accounts);
    });

    it("Go to Financial Account", async (): Promise<void> => {
      // search financial account in global search and redirect
      await searchRecordInGlobalSearchAndRedirect(
        accountData.savingsAccountNumber
      );
    });

    it("View Goal Component", async (): Promise<void> => {
      await new VirtualGoal().viewFinancialAccountGoals();
    });

    it("Logout", async (): Promise<void> => {
      // log out test user
      await Auth.logoutSalesforce();
    });
  });
});
