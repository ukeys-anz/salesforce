import LwcAccounsView from "../pageObjects/lwcAccounsView";
import SfCustomer from "../scenarios/customer";

export default class SfAccounts {
  selectAccountFilter = async (filterName: string) => {
    const accountsPageRoot = await utam.load(LwcAccounsView);

    await (await accountsPageRoot.getSelectAccountFiler()).click();
    await browser.pause(1000);

    const selectElementList = await accountsPageRoot.getSelectElements();
    // await console.log(selectElementList.length);
    await selectElementList[1].click();
    await browser.pause(3000);
  };

  searchAccount = async (scenarioId: string) => {
    const accountsPageRoot = await utam.load(LwcAccounsView);
    // const searchBox = await accountsPageRoot.getInputAccountName();
    const searchBox = await $("//input[@name='Account-search-input']");
    await searchBox.click();

    let sfCustomerDetails = new SfCustomer();
    let customerName = await sfCustomerDetails.getCustomerName(scenarioId);

    // await searchBox.setText(customerName.name);
    await searchBox.setValue(customerName.name);
    const refreshButton = await $("//button[@name='refreshButton']");
    await refreshButton.click();
    await browser.pause(4000);
    const accountNameLink = await accountsPageRoot.getAccountItem(
      customerName.name
    );
    await accountNameLink.click();
    await browser.pause(4000);
  };
}
