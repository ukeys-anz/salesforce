import Auth from "common/Auth";
import { OwnerType } from "constants/enums";
import { navigateToAppAndTab } from "utils/navigationUtils";
import { UserRole } from "constants/enums";
import { App, AppTab } from "constants/appsDefinition";
import ANZXComplaint from "common/cases/ANZXComplaint";
import KYCQA from "common/cases/KYCQA";
import RecipientMule from "common/cases/RecipientMule";
import Fraud from "common/cases/Fraud";
import GeneralEnquiry from "common/cases/GeneralEnquiry";
import Identity from "common/cases/Identity";
import Scam from "common/cases/Scam";
import caseData from "data/caseData";

describe("AR-4499: Get Help Salesforce Case Management", () => {
  // pre test steps
  before(async (): Promise<void> => {
    // max viewport
    await browser.maximizeWindow();

    // login as test user
    await Auth.loginSalesforceAsRole(UserRole.FRAUDX_AGENT);
  });

  beforeEach(async (): Promise<void> => {
    await browser.takeScreenshot();
    await browser.pause(500);
  });

  afterEach(async (): Promise<void> => {
    await browser.takeScreenshot();
    await browser.pause(500);
  });

  describe("AR-10338: FraudX Agent - KYC QA Case", async (): Promise<void> => {
    const kycQaCase = new KYCQA(UserRole.FRAUDX_AGENT);

    it("Go to Coaches Workbench and Case tab", async (): Promise<void> => {
      await navigateToAppAndTab(App.Coaches_Workbench, AppTab.Cases);
    });

    it("Create a KYC QA Case", async (): Promise<void> => {
      await kycQaCase.create(caseData);
    });

    it("Assign KYC QA Case to Another FraudX Agent", async (): Promise<void> => {
      await kycQaCase.assignNewOwner(
        OwnerType.Users,
        caseData.newFraudXAgentOwnerName
      );
    });

    it("Update KYC QA Case", async (): Promise<void> => {
      await kycQaCase.update();
    });

    it("Close KYC QA Case", async (): Promise<void> => {
      await kycQaCase.close();
    });
  });

  describe("AR-10337: FraudX Agent - Recipient/Mule Case", async (): Promise<void> => {
    const recipientMuleCase = new RecipientMule(UserRole.FRAUDX_AGENT);

    it("Go to Coaches Workbench and Case tab", async (): Promise<void> => {
      await navigateToAppAndTab(App.Coaches_Workbench, AppTab.Cases);
    });

    it("Create a Recipient/Mule Case", async (): Promise<void> => {
      await recipientMuleCase.create(caseData);
    });

    it("Assign Recipient/Mule Case to Another FraudX Agent", async (): Promise<void> => {
      await recipientMuleCase.assignNewOwner(
        OwnerType.Users,
        caseData.newFraudXAgentOwnerName
      );
    });

    it("Update Recipient/Mule Case", async (): Promise<void> => {
      await recipientMuleCase.update();
    });

    it("Close Recipient/Mule Case", async (): Promise<void> => {
      await recipientMuleCase.close();
    });
  });

  describe("AR-10335: FraudX Agent - Fraud Case", async (): Promise<void> => {
    const fraudCase = new Fraud(UserRole.FRAUDX_AGENT);

    it("Go to Coaches Workbench and Case tab", async (): Promise<void> => {
      await navigateToAppAndTab(App.Coaches_Workbench, AppTab.Cases);
    });

    it("Create a Fraud Case", async (): Promise<void> => {
      await fraudCase.create(caseData);
    });

    it("Assign Fraud Case to Another FraudX Agent", async (): Promise<void> => {
      await fraudCase.assignNewOwner(
        OwnerType.Users,
        caseData.newFraudXAgentOwnerName
      );
    });

    it("Update Fraud Case", async (): Promise<void> => {
      await fraudCase.update();
    });

    it("Close Fraud Case", async (): Promise<void> => {
      await fraudCase.close();
    });
  });

  describe("AR-10325: FraudX Agent - ANZ Plus Complaint Case", async (): Promise<void> => {
    const anzxComplaintCase = new ANZXComplaint(UserRole.FRAUDX_AGENT);

    it("Go to Coaches Workbench and Case tab", async (): Promise<void> => {
      await navigateToAppAndTab(App.Coaches_Workbench, AppTab.Cases);
    });

    it("Create a ANZ Plus Complaint Case", async (): Promise<void> => {
      await anzxComplaintCase.create(caseData);
    });

    it("Assign ANZ Plus Complaint Case to Another FraudX Agent", async (): Promise<void> => {
      await anzxComplaintCase.assignNewOwner(
        OwnerType.Users,
        caseData.newFraudXAgentOwnerName
      );
    });

    it("Update ANZ Plus Complaint Case", async (): Promise<void> => {
      await anzxComplaintCase.update();
    });

    it("Close ANZ Plus Complaint Case", async (): Promise<void> => {
      await anzxComplaintCase.close();
    });
  });

  describe("AR-10312: FraudX Agent - General Enquiry Case", async (): Promise<void> => {
    const generalEnquiryCase = new GeneralEnquiry(UserRole.FRAUDX_AGENT);

    it("Go to Coaches Workbench and Case tab", async (): Promise<void> => {
      await navigateToAppAndTab(App.Coaches_Workbench, AppTab.Cases);
    });

    it("Create a General Enquiry Case", async (): Promise<void> => {
      await generalEnquiryCase.create(caseData);
    });

    it("Assign General Enquiry Case to Another FraudX Agent", async (): Promise<void> => {
      await generalEnquiryCase.assignNewOwner(
        OwnerType.Users,
        caseData.newFraudXAgentOwnerName
      );
    });

    it("Update General Enquiry Case", async (): Promise<void> => {
      await generalEnquiryCase.update();
    });

    it("Close General Enquiry Case", async (): Promise<void> => {
      await generalEnquiryCase.close();
    });
  });

  describe("AR-10333: FraudX Agent - Identity Case", async (): Promise<void> => {
    const identityCase = new Identity(UserRole.FRAUDX_AGENT);

    it("Go to Coaches Workbench and Case tab", async (): Promise<void> => {
      await navigateToAppAndTab(App.Coaches_Workbench, AppTab.Cases);
    });

    it("Open Case Creation Form and Select Identity Case", async (): Promise<void> => {
      await identityCase.selectIdentityCase();
    });

    it("Issue Type - Open Banking is Selectable", async (): Promise<void> => {
      await identityCase.verifyIssueType("Open Banking");
    });

    it("Issue Type - Verified by Visa is Selectable", async (): Promise<void> => {
      await identityCase.verifyIssueType("Verified by Visa");
    });

    it("Issue Type - Assisted PIN Recovery is Selectable", async (): Promise<void> => {
      await identityCase.verifyIssueType("Assisted PIN Recovery");
    });

    it("Issue Type - Digital Wallet Provisioning is Selectable", async (): Promise<void> => {
      await identityCase.verifyIssueType("Digital Wallet Provisioning");
    });

    it("Create an Identity Case", async (): Promise<void> => {
      await identityCase.create(caseData);
    });

    it("Assign Identity Case to Another FraudX Agent", async (): Promise<void> => {
      await identityCase.assignNewOwner(
        OwnerType.Users,
        caseData.newFraudXAgentOwnerName
      );
    });

    it("Update Identity Case", async (): Promise<void> => {
      await identityCase.update();
    });

    it("Close Identity Case", async (): Promise<void> => {
      await identityCase.close();
    });
  });

  describe("AR-10328: FraudX Agent - Scam Case", async (): Promise<void> => {
    const scamCase = new Scam(UserRole.FRAUDX_AGENT);

    it("Go to Coaches Workbench and Case tab", async (): Promise<void> => {
      await navigateToAppAndTab(App.Coaches_Workbench, AppTab.Cases);
    });

    it("Create a Scam Case", async (): Promise<void> => {
      await scamCase.create(caseData);
    });

    it("Assign Scam Case to Another FraudX Agent", async (): Promise<void> => {
      await scamCase.assignNewOwner(
        OwnerType.Users,
        caseData.newFraudXAgentOwnerName
      );
    });

    it("Update Scam Case", async (): Promise<void> => {
      await scamCase.update();
    });

    it("Close Scam Case", async (): Promise<void> => {
      await scamCase.close();
    });
  });

  after(async (): Promise<void> => {
    // log out test user
    await Auth.logoutSalesforce();
  });
});
