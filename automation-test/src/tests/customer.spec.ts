import LwcCustomerDetails from "../pageObjects/lwcCustomerDetails";
import SfNavigation from "../common/navigation";
import Auth from "../common/Auth";
import SfAccounts from "../common/accounts";
import SfCustomer from "../common/customer";
import customerData from "../data/customerData.json";

describe("Customer Verification", () => {
  it("Customer Information", async () => {
    browser.maximizeWindow();
    await Auth.loginSalesforceAsRole("Coach");

    const customerPageRoot = await utam.load(LwcCustomerDetails);
    const navigationShowElement = await customerPageRoot.getNavigationShow();
    await navigationShowElement.click();

    const sfNavigation = new SfNavigation();
    await sfNavigation.selectNavigation("Accounts");

    const sfAccountView = new SfAccounts();
    await sfAccountView.selectAccountFilter();
    await sfAccountView.searchAccount(customerData.customers[0].name);

    const sfCustomerDetails = new SfCustomer();
    await sfCustomerDetails.verifyCustomerAccount();
  });
});
