import Auth from "../common/Auth";
import TransactionHistory from "../common/TransactionHistory";
import { UserRole } from "../constants/enums";
import { App, AppTab } from "../constants/appsDefinition";
import { navigateToAppAndTab } from "../utils/navigationUtils";
import { searchRecordInGlobalSearchAndRedirect } from "../utils/commonUtils";
import accountData from "../data/accountData";

describe("AR-10299: Salesforce Transaction History", async (): Promise<void> => {
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

  describe("AR-10306: Coach views Transaction History with Date Filters", async (): Promise<void> => {
    const transaction = new TransactionHistory();

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

      await transaction.loadFinancialAccountTab();
    });

    it("Records Displays in Chronological Order", async (): Promise<void> => {
      await transaction.verifyRecordsDisplayOrder();
    });

    it("Search Seciton End Date Defaults to Today's Date", async (): Promise<void> => {
      await transaction.verifySearchEndDate();
    });

    it("Transaction Time Displays in 12 Hour Format", async (): Promise<void> => {
      await transaction.verifyTransactionTime();
    });

    it("Logout", async (): Promise<void> => {
      // log out test user
      await Auth.logoutSalesforce();
    });
  });

  describe("AR-10305: Coach views Transaction History and loads more Transaction", async (): Promise<void> => {
    const transaction = new TransactionHistory();

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

      await transaction.loadFinancialAccountTab();
    });

    it("Load Next page of Transaction History", async (): Promise<void> => {
      await transaction.verifyLoadMore();
    });

    it("Logout", async (): Promise<void> => {
      // log out test user
      await Auth.logoutSalesforce();
    });
  });

  describe("AR-10300: Coach views Transaction History and Transaction Details", async (): Promise<void> => {
    const transaction = new TransactionHistory();

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

      await transaction.loadFinancialAccountTab();
    });

    it("Verify Transaction Details", async (): Promise<void> => {
      await transaction.verifyDetails();
    });

    it("Logout", async (): Promise<void> => {
      // log out test user
      await Auth.logoutSalesforce();
    });
  });

  describe("AR-10311: Quality Analyst views Transaction History and Transaction Details", async (): Promise<void> => {
    const transaction = new TransactionHistory();

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

      await transaction.loadFinancialAccountTab();
    });

    it("Verify Transaction Details", async (): Promise<void> => {
      await transaction.verifyDetails();
    });

    it("Logout", async (): Promise<void> => {
      // log out test user
      await Auth.logoutSalesforce();
    });
  });
});
