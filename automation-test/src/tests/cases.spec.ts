import Auth from "common/Auth";
import AppLauncher from "pageObjects/appLauncher";
import ConsoleAppNavigation from "pageObjects/consoleAppNavigation";
import LwcCustomerDetails from "pageObjects/lwcCustomerDetails";
import SfNavigation from "common/navigation";
import CaseHandler from "common/cases/CaseHandler";
import SfPageUtils from "utils/sfUtils";

describe.skip("Case Creation - General Enquiry", () => {
  let caseNumber: string;

  it("Login as a Coach User", async () => {
    browser.maximizeWindow();

    await Auth.loginSalesforceAsRole("Coach");

    await browser.pause(2000);

    await SfPageUtils.closeAllTabsMain();
  });

  it("Go to Cases -> New Case", async () => {
    //Load the Customer Details Page
    const customerPageRoot = await utam.load(LwcCustomerDetails);
    const navigationShowElement = await customerPageRoot.getNavigationShow();

    let sfNavigation = new SfNavigation();

    await navigationShowElement.click();
    await sfNavigation.selectNavigation("Cases");
    await browser.pause(2000);
  });

  it("Create a New Case", async () => {
    let cases = new CaseHandler();
    caseNumber = await cases.createGenEnqCase("scenario_001");
  });

  it("Change Owner to Support Coach", async () => {
    let cases = new CaseHandler();
    await cases.changeOwner("scenario_001");
  });

  it("Edit Case Type", async () => {
    let cases = new CaseHandler();
    await cases.editIssueType("scenario_001");
  });

  it("Change Owner to Another Coach", async () => {
    let cases = new CaseHandler();
    await cases.changeOwner("scenario_002_1");
  });

  it("Close the ANZx Complaint case", async () => {
    await SfPageUtils.closeAllTabsMain();

    let cases = new CaseHandler();
    await cases.closeCase(caseNumber);
  });
});

describe.skip("Case Creation - ANZx Complaints", async () => {
  let caseNumber: string;

  it("Go to Cases -> New Case", async () => {
    //Load the Customer Details Page
    await SfPageUtils.closeAllTabsMain();
    const customerPageRoot = await utam.load(LwcCustomerDetails);
    const navigationShowElement = await customerPageRoot.getNavigationShow();

    let sfNavigation = new SfNavigation();

    await navigationShowElement.click();
    await sfNavigation.selectNavigation("Cases");
    await browser.pause(2000);
  });

  it("Create an ANZx Complaint Case", async () => {
    let cases = new CaseHandler();
    caseNumber = await cases.createAnzxComplaintCase("scenario_002");
  });

  it("Change Owner to Support Coach", async () => {
    let cases = new CaseHandler();
    await cases.changeOwner("scenario_002");
  });

  it("Edit Case Type", async () => {
    let cases = new CaseHandler();
    await cases.editIssueType("scenario_002");
  });

  it("Change Owner to Another Coach", async () => {
    let cases = new CaseHandler();
    await cases.changeOwner("scenario_002_1");
  });

  it("Close the ANZx Complaint case", async () => {
    await SfPageUtils.closeAllTabsMain();

    let cases = new CaseHandler();
    await cases.closeCase(caseNumber);
  });
});

describe("Case Creation - KYC QA", async (): Promise<void> => {
  let kycQaCase: CaseHandler = new CaseHandler("KYC QA");

  it("Login as FraudX Agent", async (): Promise<void> => {
    browser.maximizeWindow();
    await Auth.loginSalesforceAsRole("FraudX Agent");
    await SfPageUtils.closeAllTabsMain();
  });

  it("Go to Coaches Workbench and Case tab", async (): Promise<void> => {
    // redirect user to Coaches Workbench
    const appLauncherRoot = await utam.load(AppLauncher);
    await appLauncherRoot.redirectToApp("Coaches Workbench");

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

describe("Case Creation - Recipient/Mule", async (): Promise<void> => {
  let recipientMuleCase: CaseHandler = new CaseHandler("Recipient/Mule");

  it("Login as FraudX Agent", async (): Promise<void> => {
    browser.maximizeWindow();
    await Auth.loginSalesforceAsRole("FraudX Agent");
    await SfPageUtils.closeAllTabsMain();
  });

  it("Go to Coaches Workbench and Case tab", async (): Promise<void> => {
    // redirect user to Coaches Workbench
    const appLauncherRoot = await utam.load(AppLauncher);
    await appLauncherRoot.redirectToApp("Coaches Workbench");

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
