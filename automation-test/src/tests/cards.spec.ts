import Auth from "../common/Auth";
import Card from "../common/Card";
import { navigateToAppAndTab } from "../utils/navigationUtils";
import { UserRole } from "../constants/enums";
import { App, AppTab } from "../constants/appsDefinition";
import { searchRecordInGlobalSearchAndRedirect } from "../utils/commonUtils";
import accountData from "../data/accountData";

describe("AR-10296: Salesforce Cards", async (): Promise<void> => {
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

  describe("AR-10297: Coach views card details on Person Account page", async (): Promise<void> => {
    const card = new Card();

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

    it("Show Card Details", async (): Promise<void> => {
      await card.showDetails();
    });

    it("Verify Card Details", async (): Promise<void> => {
      await card.verifyDetails();
    });

    it("Load More Cards", async (): Promise<void> => {
      await card.loadMore();
    });

    it("Verify First Displayed Card Status is Active/Issued", async (): Promise<void> => {
      await card.verifyFirstCardActive();
    });

    it("Logout", async (): Promise<void> => {
      // log out test user
      await Auth.logoutSalesforce();
    });
  });

  describe("AR-10298: Quality Analyst views card details on Person Account page", async (): Promise<void> => {
    const card = new Card();

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

    it("Show Card Details", async (): Promise<void> => {
      await card.showDetails();
    });

    it("Verify Card Details", async (): Promise<void> => {
      await card.verifyDetails();
    });

    it("Load More Cards", async (): Promise<void> => {
      await card.loadMore();
    });

    it("Verify First Displayed Card Status is Active/Issued", async (): Promise<void> => {
      await card.verifyFirstCardActive();
    });

    it("Logout", async (): Promise<void> => {
      // log out test user
      await Auth.logoutSalesforce();
    });
  });
});
