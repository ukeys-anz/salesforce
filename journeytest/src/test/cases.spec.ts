import LwcCustomerDetails from "../pageObjects/lwcCustomerDetails";
import SfNavigation from "modules/navigation";
import data from "../../testdata.json";
import SfLogin from "../modules/login";
import SfCases from "modules/cases";

describe("Case Creation - General Enquiry", () => {
  it("Login as a Coach User", async () => {
    browser.maximizeWindow();

    let sfLogin = new SfLogin();
    await sfLogin.salesForceLogin(data.envToTest, "coach");
  });

  it("Search for an ANZx Customer", async () => {
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
    await sfCases.createCase();
  });
});
