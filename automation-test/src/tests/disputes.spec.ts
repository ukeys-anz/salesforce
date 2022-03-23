import Auth from "common/Auth";
import { navigateToConsoleAppAndTab } from "utils/consoleUtils";
import { searchRecordInGlobalSearchAndRedirect } from "utils/commonUtils";
import { UserRole, App, AppTab, TransactionType } from "constants/enums";
import Case from "common/cases/Case";
import ATM from "common/cases/ATM";
import Card from "common/cases/Card";
import DirectEntry from "common/cases/DirectEntry";
import Disputes from "common/Disputes";
import caseData from "data/caseData";

describe("Disputes - Coach Creates Disputes from Transaction", () => {
  // pre test steps
  before(
    async (): Promise<void> => {
      // max viewport
      await browser.maximizeWindow();

      // login as test user
      await Auth.loginSalesforceAsRole(UserRole.COACH);

      // redirect test user to Coaches Workbench and Account home page
      await navigateToConsoleAppAndTab(App.COACHES_WORKBENCH, AppTab.ACCOUNTS);
    }
  );

  beforeEach(async () => {
    await browser.pause(1000);
  });

  describe("Deposit/Withdrawal Dispute", async (): Promise<void> => {
    const depositDispute = new Disputes(
      UserRole.COACH,
      TransactionType.DEPOSIT_WITHDRAWAL
    );

    // Deposit Withdrawal Dispute will raise ATM case
    let atmCase = new ATM(UserRole.COACH);

    it("Go to Transaction History", async (): Promise<void> => {
      // search financial account in global search and redirect
      await searchRecordInGlobalSearchAndRedirect(
        caseData.financialAccountNumber
      );
    });

    it("Raise Dispute", async (): Promise<void> => {
      await depositDispute.raiseDispute();
    });

    it("Create ATM Case", async (): Promise<void> => {
      await atmCase.createRecord();
    });

    it("Close ATM Case", async (): Promise<void> => {
      await atmCase.closeRecord();
    });
  });

  describe("BSB-ACC Dispute Dispute", async (): Promise<void> => {
    let bsbAccDispute = new Disputes(UserRole.COACH, TransactionType.BSB_ACC);

    // BSB-ACC Dispute will raise Direct Entry case
    const directEntryCase = new DirectEntry(UserRole.COACH);

    it("Go to Transaction History", async (): Promise<void> => {
      // search financial account in global search and redirect
      await searchRecordInGlobalSearchAndRedirect(
        caseData.financialAccountNumber
      );
    });

    it("Raise Dispute", async (): Promise<void> => {
      await bsbAccDispute.raiseDispute();
    });

    it("Create Direct Entry Case", async (): Promise<void> => {
      await directEntryCase.createRecord();
    });

    it("Close Direct Entry Case", async (): Promise<void> => {
      await directEntryCase.closeRecord();
    });
  });

  describe("Card Dispute Dispute", async (): Promise<void> => {
    let cardDispute = new Disputes(UserRole.COACH, TransactionType.CARD);

    // Card Dispute will raise Card case
    const cardCase = new Card(UserRole.COACH);

    it("Go to Transaction History", async (): Promise<void> => {
      // search financial account in global search and redirect
      await searchRecordInGlobalSearchAndRedirect(
        caseData.financialAccountNumber
      );
    });

    it("Raise Dispute", async (): Promise<void> => {
      await cardDispute.raiseDispute();
    });

    it("Create Card Case", async (): Promise<void> => {
      await cardCase.createRecord();
    });

    it("Close Card Case", async (): Promise<void> => {
      await cardCase.closeRecord();
    });
  });

  after(
    async (): Promise<void> => {
      // log out test user
      await Auth.logoutSalesforce();
    }
  );
});
