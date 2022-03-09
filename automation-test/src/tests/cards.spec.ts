import SfCards from "../common/cards";
import Auth from "../common/Auth";
import LwcCustomerDetails from "../pageObjects/lwcCustomerDetails";
import SfNavigation from "../common/navigation";
import SfAccounts from "../common/accounts";
import SfPageUtils from "../utils/sfUtils";

describe("Cards verification", () => {
  it("Login as a Coach User", async () => {
    //Login
    browser.maximizeWindow();
    await Auth.loginSalesforceAsRole("Coach");

    //Close all tabs
    await browser.pause(5000);
    await SfPageUtils.closeAllTabsMain();
  });

  it("Search for a customer with a valid card", async () => {
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

  it("Verify the details of a valid card", async () => {
    //Get card details
    let sfCards = new SfCards();
    await sfCards.getCardDetails();

    //Verify card details
    await sfCards.verifyCardDetails("scenarioCardVerification");
  });
});
