import Auth from "../common/Auth";
import LwcCustomerDetails from "../pageObjects/lwcCustomerDetails";
import SfNavigation from "../common/navigation";
import SfAccounts from "../common/accounts";
import SfCustomer from "../common/customer";
import SfPageUtils from "../utils/sfUtils";

describe("Cards verification", () => {
  it("Login and search for a customer with a valid card", async () => {
    await browser.maximizeWindow();

    await Auth.loginSalesforce("Coach");

    //Close all tabs
    await browser.pause(5000);
    await SfPageUtils.closeAllTabsMain();

    //Search for a customer
    const customerPageRoot = await utam.load(LwcCustomerDetails);
    const navigationShowElement = await customerPageRoot.getNavigationShow();
    await navigationShowElement.click();

    let sfNavigation = new SfNavigation();
    await sfNavigation.selectNavigation("Accounts");

    let sfAccountView = new SfAccounts();

    await sfAccountView.selectAccountFilter("All Accounts");
    await sfAccountView.searchAccount("scenarioCardVerification");
  });

  it("Verify the accounts of a customer", async () => {
    //Get card details
    let sfCustomer = new SfCustomer();
    await sfCustomer.getAccounts();
  });
});
