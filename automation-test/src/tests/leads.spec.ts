import Auth from "common/Auth";
import { navigateToAppAndTab } from "utils/navigationUtils";
import { UserRole } from "constants/enums";
import { App, AppTab } from "constants/appsDefinition";
import ANZXLead from "common/Lead/ANZXLead";
import * as faker from "faker";
import * as commonUtils from "utils/commonUtils";

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
      await createAndNurtureLeadByRole(UserRole.COACH);
    });

    describe("AR-11390: Coach Lead creates and nurtures ANZX Lead", async (): Promise<void> => {
      await createAndNurtureLeadByRole(UserRole.COACH_LEAD);
    });

    describe("AR-11391: Support Coach creates and nurtures ANZX Lead", async (): Promise<void> => {
      await createAndNurtureLeadByRole(UserRole.SUPPORT_COACH);
    });

    describe("AR-11388: Business Admin creates and nurtures ANZX Lead", async (): Promise<void> => {
      await createAndNurtureLeadByRole(UserRole.BUSINESS_ADMIN);
    });
  });

  describe("AR-11385: Coach creates duplicate ANZX Leads", async (): Promise<void> => {
    const anzxLead = new ANZXLead(UserRole.COACH);
    const firstName = faker.name.firstName();
    const lastName = faker.name.lastName();
    const mobile = faker.phone.phoneNumber("04########");
    const email = faker.internet.exampleEmail(firstName, lastName);

    const anzxLeadData = {
      firstName,
      lastName,
      mobile,
      email
    };

    it("Login as Coach", async (): Promise<void> => {
      // login as test user
      await Auth.loginSalesforceAsRole(UserRole.COACH);
    });

    it("Go to Coaches Workbench and Leads Tab", async (): Promise<void> => {
      await navigateToAppAndTab(App.Coaches_Workbench, AppTab.Leads);
    });

    it("Create an ANZX Lead", async (): Promise<void> => {
      await anzxLead.create(anzxLeadData);
    });

    it("Verify first ANZX Lead has no duplicate", async (): Promise<void> => {
      await anzxLead.verifyDuplicate(false);
    });

    it("Go to Coaches Workbench and Leads Tab", async (): Promise<void> => {
      await navigateToAppAndTab(App.Coaches_Workbench, AppTab.Leads);
    });

    it("Create a duplicate ANZX Lead", async (): Promise<void> => {
      await anzxLead.create(anzxLeadData);
    });

    it("Verify second ANZX Lead is a duplicate", async (): Promise<void> => {
      await anzxLead.verifyDuplicate(true);
    });

    it("Logout", async (): Promise<void> => {
      await Auth.logoutSalesforce();
    });
  });

  describe("AR-11392: Quality Analyst views ANZX Leads", async (): Promise<void> => {
    const anzxLead = new ANZXLead(UserRole.QUALITY_ANALYST);

    it("Login as Quality Analyst", async (): Promise<void> => {
      await Auth.loginSalesforceAsRole(UserRole.QUALITY_ANALYST);
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
