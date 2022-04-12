import Auth from "common/Auth";
import Transactions from "common/Transactions";
import { UserRole, App, AppTab } from "constants/enums";
import { navigateToConsoleAppAndTab } from "utils/consoleUtils";
import { searchRecordInGlobalSearchAndRedirect } from "utils/commonUtils";
import accountData from "data/accountData";

describe("Transactions - Coach Views and Verifies Details", () => {
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

  describe("Transaction History Date Filter", async (): Promise<void> => {
    const transaction = new Transactions();

    it("Go to Coaches Workbench and Account tab", async (): Promise<void> => {
      await navigateToConsoleAppAndTab(App.Coaches_Workbench, AppTab.Accounts);
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
  });

  describe("Transaction History and Load More", async (): Promise<void> => {
    const transaction = new Transactions();

    it("Go to Coaches Workbench and Account tab", async (): Promise<void> => {
      await navigateToConsoleAppAndTab(App.Coaches_Workbench, AppTab.Accounts);
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
  });

  describe("Transaction History and Detailed View", async (): Promise<void> => {
    const transaction = new Transactions();

    it("Go to Coaches Workbench and Account tab", async (): Promise<void> => {
      await navigateToConsoleAppAndTab(App.Coaches_Workbench, AppTab.Accounts);
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
  });

  after(async (): Promise<void> => {
    // log out test user
    await Auth.logoutSalesforce();
  });
});
