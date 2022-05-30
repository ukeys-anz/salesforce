import Auth from "common/Auth";
import { navigateToAppAndTab } from "utils/navigationUtils";
import { searchRecordInGlobalSearchAndRedirect } from "utils/commonUtils";
import { UserRole, TransactionType } from "constants/enums";
import { App, AppTab } from "constants/appsDefinition";
import ATM from "common/cases/ATM";
import Card from "common/cases/Card";
import DirectEntry from "common/cases/DirectEntry";
import Dispute from "common/Dispute";
import caseData from "data/caseData";

describe("AR-10290: Salesforce Dispute", async (): Promise<void> => {
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

  describe("AR-10291: Coach disputes ATM transaction", async (): Promise<void> => {
    const depositDispute = new Dispute(
      UserRole.COACH,
      TransactionType.DEPOSIT_WITHDRAWAL
    );

    // Deposit Withdrawal Dispute will raise ATM case
    const atmCase = new ATM(UserRole.COACH);

    it("Login as Coach", async (): Promise<void> => {
      // login as test user
      await Auth.loginSalesforceAsRole(UserRole.COACH);
    });

    it("Go to Coaches Workbench and Account tab", async (): Promise<void> => {
      // redirect test user to Coaches Workbench and Account home page
      await navigateToAppAndTab(App.Coaches_Workbench, AppTab.Accounts);
    });

    it("Go to Transaction History", async (): Promise<void> => {
      // search financial account in global search and redirect
      await searchRecordInGlobalSearchAndRedirect(caseData.checkAccountNumber);
    });

    it("Raise Dispute", async (): Promise<void> => {
      await depositDispute.raiseDispute();
    });

    it("Create ATM Case", async (): Promise<void> => {
      await atmCase.create();
    });

    it("Close ATM Case", async (): Promise<void> => {
      await atmCase.close();
    });

    it("Logout", async (): Promise<void> => {
      // log out test user
      await Auth.logoutSalesforce();
    });
  });

  describe("AR-10292: Coach disputes Direct Entry transaction", async (): Promise<void> => {
    const bsbAccDispute = new Dispute(UserRole.COACH, TransactionType.BSB_ACC);

    // BSB-ACC Dispute will raise Direct Entry case
    const directEntryCase = new DirectEntry(UserRole.COACH);

    it("Login as Coach", async (): Promise<void> => {
      // login as test user
      await Auth.loginSalesforceAsRole(UserRole.COACH);
    });

    it("Go to Coaches Workbench and Account tab", async (): Promise<void> => {
      // redirect test user to Coaches Workbench and Account home page
      await navigateToAppAndTab(App.Coaches_Workbench, AppTab.Accounts);
    });

    it("Go to Transaction History", async (): Promise<void> => {
      // search financial account in global search and redirect
      await searchRecordInGlobalSearchAndRedirect(caseData.checkAccountNumber);
    });

    it("Raise Dispute", async (): Promise<void> => {
      await bsbAccDispute.raiseDispute();
    });

    it("Create Direct Entry Case", async (): Promise<void> => {
      await directEntryCase.create(caseData);
    });

    it("Close Direct Entry Case", async (): Promise<void> => {
      await directEntryCase.close();
    });

    it("Logout", async (): Promise<void> => {
      // log out test user
      await Auth.logoutSalesforce();
    });
  });

  describe("AR-10294: Coach disputes Card transaction", async (): Promise<void> => {
    const cardDispute = new Dispute(UserRole.COACH, TransactionType.CARD);

    // Card Dispute will raise Card case
    const cardCase = new Card(UserRole.COACH);

    it("Login as Coach", async (): Promise<void> => {
      // login as test user
      await Auth.loginSalesforceAsRole(UserRole.COACH);
    });

    it("Go to Coaches Workbench and Account tab", async (): Promise<void> => {
      // redirect test user to Coaches Workbench and Account home page
      await navigateToAppAndTab(App.Coaches_Workbench, AppTab.Accounts);
    });

    it("Go to Transaction History", async (): Promise<void> => {
      // search financial account in global search and redirect
      await searchRecordInGlobalSearchAndRedirect(caseData.checkAccountNumber);
    });

    it("Raise Dispute", async (): Promise<void> => {
      await cardDispute.raiseDispute();
    });

    it("Create Card Case", async (): Promise<void> => {
      await cardCase.create();
    });

    it("Close Card Case", async (): Promise<void> => {
      await cardCase.close();
    });

    it("Logout", async (): Promise<void> => {
      // log out test user
      await Auth.logoutSalesforce();
    });
  });
});
