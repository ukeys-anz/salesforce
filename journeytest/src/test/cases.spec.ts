import LwcCustomerDetails from "pageObjects/lwcCustomerDetails";
import SfNavigation from "modules/navigation";
import data from "../../testdata.json";
import SfLogin from "../modules/login";
import SfCases from "modules/cases";
import SfPageUtils from "utilities/sfUtils";

describe("Case Creation - General Enquiry", () => {
  let caseNumber: string;

  it("Login as a Coach User", async () => {
    browser.maximizeWindow();

    let sfLogin = new SfLogin();
    await sfLogin.salesForceLogin(data.envToTest, "coach");
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
    let sfCases = new SfCases();
    caseNumber = await sfCases.createGenEnqCase("scenario_001");
  });

  it("Change Owner to Support Coach", async () => {
    let sfCases = new SfCases();
    await sfCases.changeOwner("scenario_001");
  });

  it("Edit Case Type", async () => {
    let sfCases = new SfCases();
    await sfCases.editIssueType("scenario_001");
  });

  it("Change Owner to Another Coach", async () => {
    let sfCases = new SfCases();
    await sfCases.changeOwner("scenario_002_1");
  });

  it("Close the ANZx Complaint case", async () => {
    await SfPageUtils.closeAllTabsMain();

    let sfCases = new SfCases();
    await sfCases.closeCase(caseNumber);
  });
});

describe("Case Creation - ANZx Complaints", async () => {
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
    let sfCases = new SfCases();
    caseNumber = await sfCases.createAnzxComplaintCase("scenario_002");
  });

  it("Change Owner to Support Coach", async () => {
    let sfCases = new SfCases();
    await sfCases.changeOwner("scenario_002");
  });

  it("Edit Case Type", async () => {
    let sfCases = new SfCases();
    await sfCases.editIssueType("scenario_002");
  });

  it("Change Owner to Another Coach", async () => {
    let sfCases = new SfCases();
    await sfCases.changeOwner("scenario_002_1");
  });

  it("Close the ANZx Complaint case", async () => {
    await SfPageUtils.closeAllTabsMain();

    let sfCases = new SfCases();
    await sfCases.closeCase(caseNumber);
  });
});
