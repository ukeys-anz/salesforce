import Auth from "../../common/Auth";
import { navigateToAppAndTab } from "../../utils/navigationUtils";
import { UserRole, Queue, OwnerType } from "../../constants/enums";
import { App, AppTab } from "../../constants/appsDefinition";
import GeneralEnquiry from "../../common/cases/GeneralEnquiry";
import ANZXComplaint from "../../common/cases/ANZXComplaint";
import caseData from "../../data/caseData";

describe("AR-4499: Get Help Salesforce Case Management", () => {
  // pre test steps
  before(async (): Promise<void> => {
    // max viewport
    await browser.maximizeWindow();

    // login as test user
    await Auth.loginSalesforceAsRole(UserRole.Support_Coach);
  });

  beforeEach(async (): Promise<void> => {
    await browser.takeScreenshot();
    await browser.pause(500);
  });

  afterEach(async (): Promise<void> => {
    await browser.takeScreenshot();
    await browser.pause(500);
  });

  describe("AR-13407: Support Coach - General Enquiry Case", async (): Promise<void> => {
    const generalEnquiryCase = new GeneralEnquiry(UserRole.Support_Coach);

    it("Go to Coaches Workbench and Case tab", async (): Promise<void> => {
      await navigateToAppAndTab(App.Coaches_Workbench, AppTab.Cases);
    });

    it("Create a General Enquiry Case", async (): Promise<void> => {
      await generalEnquiryCase.create(caseData);
    });

    it("Assign General Enquiry Case to Support Coach Queue", async (): Promise<void> => {
      await generalEnquiryCase.assignNewOwner(
        OwnerType.Queues,
        Queue.Support_Coach_Queue
      );
    });

    it("Update General Enquiry Case", async (): Promise<void> => {
      await generalEnquiryCase.update();
    });

    it("Add Call Details", async (): Promise<void> => {
      await generalEnquiryCase.updateCallDetails();
    });

    it("Create Case Comment", async (): Promise<void> => {
      await generalEnquiryCase.postChatterComment();
    });

    it("Case Comment does not appear in Activity History", async (): Promise<void> => {
      await generalEnquiryCase.verifyChatterComment();
    });

    it("Assign General Enquiry Case to Another Coach", async (): Promise<void> => {
      await generalEnquiryCase.assignNewOwner(
        OwnerType.Users,
        caseData.newCoachOwnerName
      );
    });

    it("Close General Enquiry Case", async (): Promise<void> => {
      await generalEnquiryCase.close();
    });
  });

  describe("AR-13409: Support Coach - ANZ Plus Complaint Case", async (): Promise<void> => {
    const anzxComplaintCase = new ANZXComplaint(UserRole.Support_Coach);

    it("Go to Coaches Workbench and Case tab", async (): Promise<void> => {
      await navigateToAppAndTab(App.Coaches_Workbench, AppTab.Cases);
    });

    it("Create a ANZ Plus Complaint Case", async (): Promise<void> => {
      await anzxComplaintCase.create(caseData);
    });

    it("Assign ANZ Plus Complaint Case to Coach Queue", async (): Promise<void> => {
      await anzxComplaintCase.assignNewOwner(
        OwnerType.Queues,
        Queue.Coach_Queue
      );
    });

    it("Update ANZ Plus Complaint Case", async (): Promise<void> => {
      await anzxComplaintCase.update();
    });

    it("Assign General Enquiry Case to Another Coach", async (): Promise<void> => {
      await anzxComplaintCase.assignNewOwner(
        OwnerType.Users,
        caseData.newCoachOwnerName
      );
    });

    it("Close ANZ Plus Complaint Case", async (): Promise<void> => {
      await anzxComplaintCase.close();
    });
  });

  after(async (): Promise<void> => {
    // log out test user
    await Auth.logoutSalesforce();
  });
});
