import Auth from "../common/Auth";
import { navigateToAppAndTab } from "../utils/navigationUtils";
import { UserRole } from "../constants/enums";
import { App, AppTab } from "../constants/appsDefinition";
import ANZXLead from "../common/leads/ANZXLead";
import { cleanupTestData } from "../utils/wdioUtils";
import * as commonUtils from "../utils/commonUtils";

describe("AR-11357: Salesforce Leads", async (): Promise<void> => {
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

  after(async (): Promise<void> => {
    await cleanupTestData(UserRole.Qualtrics_Automation_User, ["Lead"]);
  });

  async function createAndNurtureLeadByRole(role: UserRole): Promise<void> {
    const anzxLead = new ANZXLead(role);

    it(`Login as ${role}`, async (): Promise<void> => {
      await Auth.loginSalesforceAsRole(role);
    });

    it("Go to Coaches Workbench and Leads Tab", async (): Promise<void> => {
      await navigateToAppAndTab(App.Coaches_Workbench, AppTab.Leads);
    });

    it("Create an ANZX Lead", async (): Promise<void> => {
      await anzxLead.create();
    });

    it("Post chatter on Lead", async (): Promise<void> => {
      await anzxLead.postChatterComment();
    });

    it("Chatter post appears on Lead", async (): Promise<void> => {
      await anzxLead.verifyChatterComment();
    });

    it("Lead cannot be manually converted", async (): Promise<void> => {
      await anzxLead.verifyCannotManuallyConvert();
    });

    it("Logout", async (): Promise<void> => {
      await Auth.logoutSalesforce();
    });
  }

  describe("Lead creation and nurturing by role", async (): Promise<void> => {
    describe("AR-11387: Coach creates and nurtures ANZX Lead", async (): Promise<void> => {
      await createAndNurtureLeadByRole(UserRole.Coach);
    });

    describe("AR-11390: Coach Lead creates and nurtures ANZX Lead", async (): Promise<void> => {
      await createAndNurtureLeadByRole(UserRole.Coach_Lead);
    });

    describe("AR-11391: Support Coach creates and nurtures ANZX Lead", async (): Promise<void> => {
      await createAndNurtureLeadByRole(UserRole.Support_Coach);
    });

    describe("AR-11388: Business Admin creates and nurtures ANZX Lead", async (): Promise<void> => {
      await createAndNurtureLeadByRole(UserRole.Business_Admin);
    });
  });

  describe("AR-11385: Coach creates duplicate ANZX Leads", async (): Promise<void> => {
    const anzxLead = new ANZXLead(UserRole.Coach);

    it("Login as Coach", async (): Promise<void> => {
      // login as test user
      await Auth.loginSalesforceAsRole(UserRole.Coach);
    });

    it("Go to Coaches Workbench and Leads Tab", async (): Promise<void> => {
      await navigateToAppAndTab(App.Coaches_Workbench, AppTab.Leads);
    });

    it("Create an ANZX Lead", async (): Promise<void> => {
      await anzxLead.create();
    });

    it("Verify first ANZX Lead has no duplicate", async (): Promise<void> => {
      await anzxLead.verifyDuplicate(false);
    });

    it("Go to Coaches Workbench and Leads Tab", async (): Promise<void> => {
      await navigateToAppAndTab(App.Coaches_Workbench, AppTab.Leads);
    });

    it("Create a duplicate ANZX Lead", async (): Promise<void> => {
      await anzxLead.create();
    });

    it("Verify second ANZX Lead is a duplicate", async (): Promise<void> => {
      await anzxLead.verifyDuplicate(true);
    });

    it("Logout", async (): Promise<void> => {
      await Auth.logoutSalesforce();
    });
  });

  describe("AR-11384: Lead creation by Qualtrics Integration", async (): Promise<void> => {
    let apiResult: string | void;

    const anzxLead = new ANZXLead(UserRole.Coach);

    it("Create Lead Record via Qualtrics Integration", async (): Promise<void> => {
      apiResult = await anzxLead.receiveLeadViaQualtricsIntegration()!;
    });

    it("Go to Lead record", async (): Promise<void> => {
      // Login in as a Coach
      await Auth.loginSalesforceAsRole(UserRole.Coach);

      // Open Lead record by navigating to record page using Id
      // As Lead search results contains Einstein results recommendations
      // Which is not predictable when searching via contact details
      await anzxLead.openById(apiResult!);
    });

    it("Verify Lead Fields", async (): Promise<void> => {
      // Verify Lead fields
      await anzxLead.verifyQualtricsLead();
    });

    it("Logout", async (): Promise<void> => {
      await Auth.logoutSalesforce();
    });
  });

  describe("AR-11386: Lead conversion upon account creation", async (): Promise<void> => {
    const anzxLead = new ANZXLead(UserRole.Coach);

    it("Login as Coach", async (): Promise<void> => {
      await Auth.loginSalesforceAsRole(UserRole.Coach);
    });

    it("Go to Coaches Workbench and Leads Tab", async (): Promise<void> => {
      await navigateToAppAndTab(App.Coaches_Workbench, AppTab.Leads);
    });

    it("Create an ANZX Lead", async (): Promise<void> => {
      await anzxLead.create();
    });

    it("Post chatter on Lead", async (): Promise<void> => {
      await anzxLead.postChatterComment();
    });

    it("Verify Lead in List View", async (): Promise<void> => {
      await anzxLead.verifyVisibleInListView(`Today's Leads`, true);
    });

    // for now just create Account Through UI
    it("Create Account through API", async (): Promise<void> => {
      await anzxLead.createAccountFromOCVIntegration();
    });

    it("Cannot find previously created Lead in List View", async (): Promise<void> => {
      await anzxLead.verifyVisibleInListView(`Today's Leads`, false);
    });

    it("Open Account", async (): Promise<void> => {
      await anzxLead.openAccount();
    });

    it("Verify Chatter Post migrated to Account", async (): Promise<void> => {
      await anzxLead.verifyChatterOnAccount();
    });

    it("Logout", async (): Promise<void> => {
      await Auth.logoutSalesforce();
    });
  });

  describe("AR-11392: Quality Analyst views ANZX Leads", async (): Promise<void> => {
    const anzxLead = new ANZXLead(UserRole.Quality_Analyst);

    it("Login as Quality Analyst", async (): Promise<void> => {
      await Auth.loginSalesforceAsRole(UserRole.Quality_Analyst);
    });

    it("Go to Quality Workbench and Leads Tab", async (): Promise<void> => {
      await navigateToAppAndTab(App.Quality_Workbench, AppTab.Leads);
    });

    it("Select a Lead record from All New List View", async (): Promise<void> => {
      await commonUtils.openListViewByIndex(0);
      await commonUtils.openFirstRecordInListView();
    });

    it("Lead fields are read only for Quality Analyst", async (): Promise<void> => {
      await anzxLead.verifyLeadFieldsAreReadOnly();
    });

    it("Quality Analyst adds Chatter Post onto Lead", async (): Promise<void> => {
      await anzxLead.postChatterComment();
      await anzxLead.verifyChatterComment();
    });

    it("Logout", async (): Promise<void> => {
      await Auth.logoutSalesforce();
    });
  });
});
