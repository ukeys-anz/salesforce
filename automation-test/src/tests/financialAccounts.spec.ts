import Auth from "../common/Auth";
import Financial_Account from "../common/FinancialAccount";
import { navigateToAppAndTab } from "../utils/navigationUtils";
import { UserRole } from "../constants/enums";
import { App, AppTab } from "../constants/appsDefinition";
import { searchRecordInGlobalSearchAndRedirect } from "../utils/commonUtils";
import accountData from "../data/accountData";

describe("AR-10350: Salesforce Financial Details", async (): Promise<void> => {
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

  describe("AR-10351: Coach view financial details on Person Account", async (): Promise<void> => {
    const everydayAccount = new Financial_Account("Everyday");
    const savingsAccount = new Financial_Account("Savings");

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

    it("Load Everyday Account (Checking Account)", async (): Promise<void> => {
      await everydayAccount.load();
    });

    it("Verify Everyday Account (Checking Account)", async (): Promise<void> => {
      await everydayAccount.verifyDetails();
    });

    it("Load Savings Account", async (): Promise<void> => {
      await savingsAccount.load();
    });

    it("Verify Savings Account", async (): Promise<void> => {
      await savingsAccount.verifyDetails();
    });

    it("Logout", async (): Promise<void> => {
      // log out test user
      await Auth.logoutSalesforce();
    });
  });

  describe("AR-10352: Quality Analyst view financial details on Person Account", async (): Promise<void> => {
    const everydayAccount = new Financial_Account("Everyday");
    const savingsAccount = new Financial_Account("Savings");

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

    it("Load Everyday Account (Checking Account)", async (): Promise<void> => {
      await everydayAccount.load();
    });

    it("Verify Everyday Account (Checking Account)", async (): Promise<void> => {
      await everydayAccount.verifyDetails();
    });

    it("Load Savings Account", async (): Promise<void> => {
      await savingsAccount.load();
    });

    it("Verify Savings Account", async (): Promise<void> => {
      await savingsAccount.verifyDetails();
    });

    it("Logout", async (): Promise<void> => {
      // log out test user
      await Auth.logoutSalesforce();
    });
  });
});
