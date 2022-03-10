import Auth from "common/Auth";
import { navigateToConsoleAppAndObjectHome } from "utils/consoleUtils";
import { UserRole } from "constants/enums";
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

  describe("General Enquiry Case", async (): Promise<void> => {
    let generalEnquiryCase = new GeneralEnquiry(UserRole.COACH);

    it("Go to Coaches Workbench and Case tab", async (): Promise<void> => {
      await navigateToConsoleAppAndObjectHome("Coaches Workbench", "Cases");
    });

    it("Create a General Enquiry Case", async (): Promise<void> => {
      await generalEnquiryCase.createRecord();
    });

    it("Assign General Enquiry Case to Support Coach Queue", async (): Promise<void> => {
      await generalEnquiryCase.assignNewOwner();
    });

    it("Update General Enquiry Case", async (): Promise<void> => {
      await generalEnquiryCase.updateRecord();
    });

    it("Close General Enquiry Case", async (): Promise<void> => {
      await generalEnquiryCase.closeRecord();
    });
  });

  describe("ANZx Complaint Case", async (): Promise<void> => {
    let anzxComplaintCase = new ANZXComplaint(UserRole.COACH);

    it("Go to Coaches Workbench and Case tab", async (): Promise<void> => {
      await navigateToConsoleAppAndObjectHome("Coaches Workbench", "Cases");
    });

    it("Create a ANZx Complaint Case", async (): Promise<void> => {
      await anzxComplaintCase.createRecord();
    });

    it("Assign ANZx Complaint Case to Support Coach Queue", async (): Promise<void> => {
      await anzxComplaintCase.assignNewOwner();
    });

    it("Update ANZx Complaint Case", async (): Promise<void> => {
      await anzxComplaintCase.updateRecord();
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
