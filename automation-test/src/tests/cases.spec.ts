import Auth from "common/Auth";
import AppLauncher from "pageObjects/appLauncher";
import ConsoleAppNavigation from "pageObjects/consoleAppNavigation";
import SfPageUtils from "utils/sfUtils";
import { UserRole } from "constants/enums";
import GeneralEnquiry from "common/cases/GeneralEnquiry";
import ANZXComplaint from "common/cases/ANZXComplaint";
import KYCQA from "common/cases/Fraud";
import RecipientMule from "common/cases/RecipientMule";
import Fraud from "common/cases/Fraud";

describe("Case - Coach Creates and Updates General Enquiry Case", async (): Promise<void> => {
  let generalEnquiryCase = new GeneralEnquiry(UserRole.COACH);

  it("Login as Coach", async (): Promise<void> => {
    await browser.maximizeWindow();
    await Auth.loginSalesforceAsRole(UserRole.COACH);
    await SfPageUtils.closeAllTabsMain();
  });

  it("Go to Coaches Workbench and Case tab", async (): Promise<void> => {
    // redirect user to Coaches Workbench
    const appLauncherRoot = await utam.load(AppLauncher);
    await appLauncherRoot.redirectToApp("Coaches Workbench");

    await browser.pause(2000);

    // redirect user to Case tab
    const consoleAppNavigationRoot = await utam.load(ConsoleAppNavigation);
    await consoleAppNavigationRoot.redirectToTab("Cases");
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

  it("Logout Coach", async (): Promise<void> => {
    await Auth.logoutSalesforce();
  });
});

describe("Case - Coach Creates and Updates ANZx Complaint Case", async (): Promise<void> => {
  let anzxComplaintCase = new ANZXComplaint(UserRole.COACH);

  it("Login as Coach", async (): Promise<void> => {
    await browser.maximizeWindow();
    await Auth.loginSalesforceAsRole(UserRole.COACH);
    await SfPageUtils.closeAllTabsMain();
  });

  it("Go to Coaches Workbench and Case tab", async (): Promise<void> => {
    // redirect user to Coaches Workbench
    const appLauncherRoot = await utam.load(AppLauncher);
    await appLauncherRoot.redirectToApp("Coaches Workbench");

    await browser.pause(2000);

    // redirect user to Case tab
    const consoleAppNavigationRoot = await utam.load(ConsoleAppNavigation);
    await consoleAppNavigationRoot.redirectToTab("Cases");
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

  it("Logout Coach", async (): Promise<void> => {
    await Auth.logoutSalesforce();
  });
});

describe("Case - FraudX Agent Creates and Updates KYC QA Case", async (): Promise<void> => {
  let kycQaCase = new KYCQA(UserRole.FRAUDX_AGENT);

  it("Login as FraudX Agent", async (): Promise<void> => {
    await browser.maximizeWindow();
    await Auth.loginSalesforceAsRole(UserRole.FRAUDX_AGENT);
    await SfPageUtils.closeAllTabsMain();
  });

  it("Go to Coaches Workbench and Case tab", async (): Promise<void> => {
    // redirect user to Coaches Workbench
    const appLauncherRoot = await utam.load(AppLauncher);
    await appLauncherRoot.redirectToApp("Coaches Workbench");

    await browser.pause(2000);

    // redirect user to Case tab
    const consoleAppNavigationRoot = await utam.load(ConsoleAppNavigation);
    await consoleAppNavigationRoot.redirectToTab("Cases");
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

  it("Logout FraudX Agent", async (): Promise<void> => {
    await Auth.logoutSalesforce();
  });
});

describe("Case - FraudX Agent Creates and Updates Recipient/Mule Case", async (): Promise<void> => {
  let recipientMuleCase = new RecipientMule(UserRole.FRAUDX_AGENT);

  it("Login as FraudX Agent", async (): Promise<void> => {
    await browser.maximizeWindow();
    await Auth.loginSalesforceAsRole(UserRole.FRAUDX_AGENT);
    await SfPageUtils.closeAllTabsMain();
  });

  it("Go to Coaches Workbench and Case tab", async (): Promise<void> => {
    // redirect user to Coaches Workbench
    const appLauncherRoot = await utam.load(AppLauncher);
    await appLauncherRoot.redirectToApp("Coaches Workbench");

    await browser.pause(2000);

    // redirect user to Case tab
    const consoleAppNavigationRoot = await utam.load(ConsoleAppNavigation);
    await consoleAppNavigationRoot.redirectToTab("Cases");
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

  it("Logout", async (): Promise<void> => {
    await Auth.logoutSalesforce();
  });
});

describe("Case - FraudX Agent Creates and Updates Fraud Case", async (): Promise<void> => {
  let fraudCase = new Fraud(UserRole.FRAUDX_AGENT);

  it("Login as FraudX Agent", async (): Promise<void> => {
    await browser.maximizeWindow();
    await Auth.loginSalesforceAsRole(UserRole.FRAUDX_AGENT);
    await SfPageUtils.closeAllTabsMain();
  });

  it("Go to Coaches Workbench and Case tab", async (): Promise<void> => {
    // redirect user to Coaches Workbench
    const appLauncherRoot = await utam.load(AppLauncher);
    await appLauncherRoot.redirectToApp("Coaches Workbench");

    await browser.pause(1000);

    // redirect user to Case tab
    const consoleAppNavigationRoot = await utam.load(ConsoleAppNavigation);
    await consoleAppNavigationRoot.redirectToTab("Cases");
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

  it("Logout", async (): Promise<void> => {
    await Auth.logoutSalesforce();
  });
});
