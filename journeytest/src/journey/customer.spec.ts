import LwcCustomerDetails from "../pageObjects/lwcCustomerDetails";
import SfNavigation from "../scenarios/navigation";
import SfLogin from "../scenarios/login";
import SfAccounts from "../scenarios/accounts";
import data from "../../testdata.json";
import SfCustomer from "../scenarios/customer";

describe("Customer Verification", () => {
  it("Customer Information", async () => {
    browser.maximizeWindow();
    let sfLogin = new SfLogin();
    await sfLogin.salesForceLogin(data.envToTest, "coach");

    const customerPageRoot = await utam.load(LwcCustomerDetails);
    const navigationShowElement = await customerPageRoot.getNavigationShow();
    await navigationShowElement.click();

    let sfNavigation = new SfNavigation();
    await sfNavigation.selectNavigation("Accounts");

    let sfAccountView = new SfAccounts();
    await sfAccountView.selectAccountFilter("All Accounts");
    await sfAccountView.searchAccount(data.accounts[0].case_creation.name);

    let sfCustomerDetails = new SfCustomer();
    await sfCustomerDetails.verifyCustomerAccount();
  });
});
