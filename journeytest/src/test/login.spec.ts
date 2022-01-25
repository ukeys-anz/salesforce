import LwcCustomerDetails from "../pageObjects/lwcCustomerDetails";
import LwcCaseCreation from "../pageObjects/lwcCaseCreation";
import SfNavigation from "modules/navigation";
import data from "../../testdata.json";
import console from "console";
import SfLogin from "../modules/login";
import LwcLogin from "../pageObjects/lwcLogin";
import allureReporter from "@wdio/allure-reporter";

describe("Case Creation - General Enquiry", () => {
  it("Login as a Coach User", async () => {
    browser.maximizeWindow();

    let sfLogin = new SfLogin();
    await sfLogin.salesForceLogin(data.envToTest, "coach");
  });

  // await browser.waitUntil(function(){
  //     return browser.getTitle().includes('Lightning Experience')
  //   }, {
  //     timeout: 120000, timeoutMsg: 'Page failed to load - 1'
  //   });
  // await expect(browser).toHaveTitle("Lightning Experience");

  // await browser.waitUntil(function(){
  //   return browser.getTitle().includes('| Salesforce')
  // }, {
  //   timeout: 12000, timeoutMsg: 'Page failed to load - 2'
  // });

  // await expect(browser).toHaveTitleContaining("| Salesforce");
  // console.log(await browser.getTitle())

  //await browser.waitUntil(() => browser.getWindowHandles().length > 1);
  // await browser.pause(3000);
  // const parentWindow = await browser.getWindowHandle();

  // const ID = await browser.getWindowHandles()

  // for(var i = 0; i< ID.length; i++){
  //     if( ID[i]!= parentWindow){
  //         await browser.switchToWindow(ID[i])
  //         await browser.maximizeWindow()
  //         console.log(await browser.getTitle())
  //         break;
  //     }
  // }
  // await browser.pause(3000)
  // await twilioLogin();
  // await browser.switchToWindow(parentWindow);
  // await browser.pause(3000)

  // });

  it("Search for an ANZx Customer", async () => {
    //Load the Customer Details Page
    const customerPageRoot = await utam.load(LwcCustomerDetails);
    // const appLauncherElement = await customerPageRoot.getAppLauncher();
    // const closePopup = await customerPageRoot.getConnectClose();
    // const closeCustomer = await customerPageRoot.getCloseCustomer(data.accounts[0].case_creation.name);

    //Switch to coaches workbench
    // appLauncherElement.click();

    // const buttonPresent = await closeCustomer.isEnabled();
    // console.log(buttonPresent);
    // if(buttonPresent){
    //   console.log('in');
    //   await closeCustomer.click();
    // }

    //Search for a customer
    // if(closePopup.isPresent()){
    //   console.log('Close popup');
    //   await closePopup.click();
    //   await browser.pause(10000);
    // }

    //Elements
    // const searchBoxBtn = await customerPageRoot.getSearchBoxBtn();
    // // const searchBoxElement = await customerPageRoot.getSearchBox();
    // const homeSearchBoxElement = await customerPageRoot.getHomeSearchBox();
    // // const searchMoreBoxElement = await customerPageRoot.getSearchMoreBox();
    // const customerLinkItem = await customerPageRoot.getSearchItem(data.accounts[1].case_creation.name)

    const navigationShowElement = await customerPageRoot.getNavigationShow();
    // const menuSelectElement = await customerPageRoot.getMenuSelect('Cases');

    let sfNavigation = new SfNavigation();

    await navigationShowElement.click();
    await sfNavigation.selectNavigation("Cases");
    await browser.pause(2000);
    // await navigationShowElement.click();
    // await selectNavigation('Accounts');

    // //Search for a customer
    // if(searchBoxBtn.isPresent()){
    //   console.log('searchbutton');
    //   await searchBoxBtn.click();
    // }

    // if(homeSearchBoxElement.isPresent()) {
    //   console.log('searchbox')
    //   await homeSearchBoxElement.click();
    //   await browser.pause(3000);
    //   await homeSearchBoxElement.setText(data.accounts[1].case_creation.ocv);
    //   // await searchMoreBoxElement.setText(data.accounts[1].case_creation.ocv);
    // }

    // await customerLinkItem.click();

    // //Elements
    // const caseLinkElement = await customerPageRoot.getCases();

    // //Create a new case
    // await caseLinkElement.click();
  });

  it("Create a New Case", async () => {
    const casePageRoot = await utam.load(LwcCaseCreation);
    const caseNewCaseElement = await casePageRoot.getNewCase();
    const caseGenEnqChk = await casePageRoot.getGeneralEnquiryChk();
    const caseNextButton = await casePageRoot.getNextButton();
    // const caseTabItem = await casePageRoot.getTabItem(1);
    const caseInputElement = await casePageRoot.getCustomerInput();
    const caseDropDown = await casePageRoot.getCustomerDropDown(
      data.accounts[1].case_creation.name
    );
    await caseNewCaseElement.click();

    //caseTabItem.click();

    //Select case Type - at the moment it is general enquiry
    await caseGenEnqChk.click();

    //Click next button
    await caseNextButton.click();

    //Enter case creation fields
    await caseInputElement.setText(data.accounts[1].case_creation.name);
    await caseDropDown.click();

    const selectElement = await casePageRoot.getSelectElements();

    await selectElement[0].click();
    await browser.pause(1000);

    const dropdownElement = await casePageRoot.getValueDropDown("Chat");
    await dropdownElement.click();
    await browser.pause(3000);
    await selectElement[1].click();
    await browser.pause(1000);

    const IssuedropdownElement = await casePageRoot.getValueDropDown(
      "Deceased Estate"
    );
    await IssuedropdownElement.click();
    await browser.pause(3000);
    //await browser.debug();

    // const dualListElement = await casePageRoot.getDualListLeft('Using card');
    // await dualListElement.click();
    // await browser.pause(2000);

    // const dualListElement = await casePageRoot.getDualListLeftItems();
    // await console.log(dualListElement[1].getText());
    // await dualListElement[1].click();
    // await browser.pause(2000);

    // const moveChosenElement = await casePageRoot.getMoveChosen();
    // await moveChosenElement.click();
    // await browser.pause(3000);

    const saveCaseElement = await casePageRoot.getSaveCase();
    await saveCaseElement.click();
    await browser.pause(3000);
  });
});
