import Auth from "common/Auth";
import { navigateToConsoleAppAndTab } from "utils/consoleUtils";
import { UserRole, App, AppTab } from "constants/enums";
import GeneralEnquiry from "common/cases/GeneralEnquiry";
import ANZXComplaint from "common/cases/ANZXComplaint";

describe("Case - Coach Creates and Updates Cases", () => {
  // pre test steps
  before(
    async (): Promise<void> => {
      // max viewport
      await browser.maximizeWindow();

      // login as test user
      await Auth.loginSalesforceAsRole(UserRole.COACH);
    }
  );

  beforeEach(async () => {
    await browser.pause(1000);
  });

  describe("General Enquiry Case", async (): Promise<void> => {
    let generalEnquiryCase = new GeneralEnquiry(UserRole.COACH);

    it("Go to Coaches Workbench and Case tab", async (): Promise<void> => {
      await navigateToConsoleAppAndTab(App.COACHES_WORKBENCH, AppTab.CASES);
    });

    it("Create a General Enquiry Case", async (): Promise<void> => {
      await generalEnquiryCase.createRecord();
    });

    it("Assign General Enquiry Case to Support Coach Queue", async (): Promise<void> => {
      await generalEnquiryCase.assignNewOwner("Queues");
    });

    it("Update General Enquiry Case", async (): Promise<void> => {
      await generalEnquiryCase.updateRecord();
    });

    it("Assign General Enquiry Case to Another Coach", async (): Promise<void> => {
      await generalEnquiryCase.assignNewOwner("Users");
    });

    it("Close General Enquiry Case", async (): Promise<void> => {
      await generalEnquiryCase.closeRecord();
    });
  });

  describe("ANZx Complaint Case", async (): Promise<void> => {
    let anzxComplaintCase = new ANZXComplaint(UserRole.COACH);

    it("Go to Coaches Workbench and Case tab", async (): Promise<void> => {
      await navigateToConsoleAppAndTab(App.COACHES_WORKBENCH, AppTab.CASES);
    });

    it("Create a ANZx Complaint Case", async (): Promise<void> => {
      await anzxComplaintCase.createRecord();
    });

    it("Assign ANZx Complaint Case to Support Coach Queue", async (): Promise<void> => {
      await anzxComplaintCase.assignNewOwner("Queues");
    });

    it("Update ANZx Complaint Case", async (): Promise<void> => {
      await anzxComplaintCase.updateRecord();
    });

    it("Assign General Enquiry Case to Another Coach", async (): Promise<void> => {
      await anzxComplaintCase.assignNewOwner("Users");
    });

    it("Close ANZx Complaint Case", async (): Promise<void> => {
      await anzxComplaintCase.closeRecord();
    });
  });

  after(
    async (): Promise<void> => {
      // log out test user
      await Auth.logoutSalesforce();
    }
  );
});
