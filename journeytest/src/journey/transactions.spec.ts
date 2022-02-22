import SfLogin from "../scenarios/login";
import data from "../../testdata.json";
import SfPageUtils from "../common/sfUtils";
import LwcCustomerDetails from "../pageObjects/lwcCustomerDetails";
import SfNavigation from "../scenarios/navigation";
import SfAccounts from "../scenarios/accounts";
import SfCustomer from "../scenarios/customer";
import SfTransactions from "../scenarios/transactions";

describe("Transactions verification", () => {
  it("Login and search for a customer with a valid transactions", async () => {
    //Login
    browser.maximizeWindow();
    let sfLogin = new SfLogin();
    await sfLogin.salesForceLogin(data.envToTest, "coach");

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
    await sfAccountView.searchAccount("scenarioTransaction001");
  });

  it("Verify the details of a Card transaction", async () => {
    //Open Transactions
    let sfCustomerView = new SfCustomer();

    await sfCustomerView.openEverydayAccount("scenarioTransaction001");

    let SfTransactionsView = new SfTransactions();
    await SfTransactionsView.verifyTransactions("Card");
  });
});
