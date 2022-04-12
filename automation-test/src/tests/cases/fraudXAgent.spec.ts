import Auth from "common/Auth";
import { navigateToConsoleAppAndTab } from "utils/consoleUtils";
import { UserRole, App, AppTab } from "constants/enums";
import ANZXComplaint from "common/cases/ANZXComplaint";
import KYCQA from "common/cases/KYCQA";
import RecipientMule from "common/cases/RecipientMule";
import Fraud from "common/cases/Fraud";
import GeneralEnquiry from "common/cases/GeneralEnquiry";
import Identity from "common/cases/Identity";
import Scam from "common/cases/Scam";

describe("Case - FraudX Agent Creates and Updates Cases", () => {
  // pre test steps
  before(
    async (): Promise<void> => {
      // max viewport
      await browser.maximizeWindow();

      // login as test user
      await Auth.loginSalesforceAsRole(UserRole.FRAUDX_AGENT);
    }
  );

  beforeEach(async () => {
    await browser.pause(1000);
  });

  describe("KYC QA Case", async (): Promise<void> => {
    const kycQaCase = new KYCQA(UserRole.FRAUDX_AGENT);

    it("Go to Coaches Workbench and Case tab", async (): Promise<void> => {
      await navigateToConsoleAppAndTab(App.COACHES_WORKBENCH, AppTab.CASES);
    });

    it("Create a KYC QA Case", async (): Promise<void> => {
      await kycQaCase.createRecord();
    });

    it("Assign KYC QA Case to Another FraudX Agent", async (): Promise<void> => {
      await kycQaCase.assignNewOwner();
    });

    it("Update KYC QA Case", async (): Promise<void> => {
      await kycQaCase.updateRecord();
    });

    it("Close KYC QA Case", async (): Promise<void> => {
      await kycQaCase.closeRecord();
    });
  });

  describe("Recipient/Mule Case", async (): Promise<void> => {
    const recipientMuleCase = new RecipientMule(UserRole.FRAUDX_AGENT);

    it("Go to Coaches Workbench and Case tab", async (): Promise<void> => {
      await navigateToConsoleAppAndTab(App.COACHES_WORKBENCH, AppTab.CASES);
    });

    it("Create a Recipient/Mule Case", async (): Promise<void> => {
      await recipientMuleCase.createRecord();
    });

    it("Assign Recipient/Mule Case to Another FraudX Agent", async (): Promise<void> => {
      await recipientMuleCase.assignNewOwner();
    });

    it("Update Recipient/Mule Case", async (): Promise<void> => {
      await recipientMuleCase.updateRecord();
    });

    it("Close Recipient/Mule Case", async (): Promise<void> => {
      await recipientMuleCase.closeRecord();
    });
  });

  describe("Fraud Case", async (): Promise<void> => {
    const fraudCase = new Fraud(UserRole.FRAUDX_AGENT);

    it("Go to Coaches Workbench and Case tab", async (): Promise<void> => {
      await navigateToConsoleAppAndTab(App.COACHES_WORKBENCH, AppTab.CASES);
    });

    it("Create a Fraud Case", async (): Promise<void> => {
      await fraudCase.createRecord();
    });

    it("Assign Fraud Case to Another FraudX Agent", async (): Promise<void> => {
      await fraudCase.assignNewOwner();
    });

    it("Update Fraud Case", async (): Promise<void> => {
      await fraudCase.updateRecord();
    });

    it("Close Fraud Case", async (): Promise<void> => {
      await fraudCase.closeRecord();
    });
  });

  describe("ANZx Complaint Case", async (): Promise<void> => {
    const anzxComplaintCase = new ANZXComplaint(UserRole.FRAUDX_AGENT);

    it("Go to Coaches Workbench and Case tab", async (): Promise<void> => {
      await navigateToConsoleAppAndTab(App.COACHES_WORKBENCH, AppTab.CASES);
    });

    it("Create a ANZx Complaint Case", async (): Promise<void> => {
      await anzxComplaintCase.createRecord();
    });

    it("Assign ANZx Complaint Case to Another FraudX Agent", async (): Promise<void> => {
      await anzxComplaintCase.assignNewOwner();
    });

    it("Update ANZx Complaint Case", async (): Promise<void> => {
      await anzxComplaintCase.updateRecord();
    });

    it("Close ANZx Complaint Case", async (): Promise<void> => {
      await anzxComplaintCase.closeRecord();
    });
  });

  describe("General Enquiry Case", async (): Promise<void> => {
    const generalEnquiryCase = new GeneralEnquiry(UserRole.FRAUDX_AGENT);

    it("Go to Coaches Workbench and Case tab", async (): Promise<void> => {
      await navigateToConsoleAppAndTab(App.COACHES_WORKBENCH, AppTab.CASES);
    });

    it("Create a General Enquiry Case", async (): Promise<void> => {
      await generalEnquiryCase.createRecord();
    });

    it("Assign General Enquiry Case to Another FraudX Agent", async (): Promise<void> => {
      await generalEnquiryCase.assignNewOwner();
    });

    it("Update General Enquiry Case", async (): Promise<void> => {
      await generalEnquiryCase.updateRecord();
    });

    it("Close General Enquiry Case", async (): Promise<void> => {
      await generalEnquiryCase.closeRecord();
    });
  });

  describe("Identity Case", async (): Promise<void> => {
    const identityCase = new Identity(UserRole.FRAUDX_AGENT);

    it("Go to Coaches Workbench and Case tab", async (): Promise<void> => {
      await navigateToConsoleAppAndTab(App.COACHES_WORKBENCH, AppTab.CASES);
    });

    it("Create an Identity Case", async (): Promise<void> => {
      await identityCase.createRecord();
    });

    it("Assign Identity Case to Another FraudX Agent", async (): Promise<void> => {
      await identityCase.assignNewOwner();
    });

    it("Update Identity Case", async (): Promise<void> => {
      await identityCase.updateRecord();
    });

    it("Close Identity Case", async (): Promise<void> => {
      await identityCase.closeRecord();
    });
  });

  describe("Scam Case", async (): Promise<void> => {
    const scamCase = new Scam(UserRole.FRAUDX_AGENT);

    it("Go to Coaches Workbench and Case tab", async (): Promise<void> => {
      await navigateToConsoleAppAndTab(App.COACHES_WORKBENCH, AppTab.CASES);
    });

    it("Create a Scam Case", async (): Promise<void> => {
      await scamCase.createRecord();
    });

    it("Assign Scam Case to Another FraudX Agent", async (): Promise<void> => {
      await scamCase.assignNewOwner();
    });

    it("Update Scam Case", async (): Promise<void> => {
      await scamCase.updateRecord();
    });

    it("Close Scam Case", async (): Promise<void> => {
      await scamCase.closeRecord();
    });
  });

  after(
    async (): Promise<void> => {
      // log out test user
      await Auth.logoutSalesforce();
    }
  );
});
