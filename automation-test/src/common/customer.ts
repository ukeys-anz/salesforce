import LwcCustomerDetails from "../pageObjects/lwcCustomerDetails";
import ScenarioUtil from "../utils/scenarioUtils";

export default class SfCustomer {
  verifyCustomerAccount = async () => {
    const accountsPageRoot = await utam.load(LwcCustomerDetails);

    const accountName = await accountsPageRoot.getAccountDetails();

    // const accountName = await $$("//article[@class='everydayAccount slds-card']//p");

    await console.log(await accountName.length);
    await browser.pause(3000);
  };

  getCustomerName = async (scenarioId: string) => {
    let customerDetails: any = {};
    customerDetails = await ScenarioUtil.getCustomerDetails(scenarioId);
    return customerDetails;
  };

  getCustomerOcv = async (scenarioId: string) => {
    let customerDetails: any = {};
    customerDetails = await ScenarioUtil.getCustomerDetails(scenarioId);
    return customerDetails.ocv;
  };

  getAccounts = async () => {
    // const assert = require('assert');
    await browser.pause(4000);
    const customerPageRoot = await utam.load(LwcCustomerDetails);
    // const accountSection = await utam.load(LwcAccountsSection);
    // await assert.ok(customerPageRoot instanceof LwcCustomerDetails);
    const accountsections = await customerPageRoot.getTabHeader();
    await console.log(await accountsections.length);
    // await console.log(await accountSection.getButtonsByText("Get Card Details"));
  };

  openEverydayAccount = async (scenarioId: string) => {
    let customerDetails: any = {};
    customerDetails = await this.getCustomerName(scenarioId);
    const valueToSelect = customerDetails.accountName;

    const everydayAccLink = await $(
      `(//article[@class='everydayAccount slds-card']//a[@title='${valueToSelect}'])[1]`
    );
    await everydayAccLink.click();
    await browser.pause(4000);
  };
}
