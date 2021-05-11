import Base from "../../base";
import helpers from "../../../utilities/helpers";
import * as faker from "faker";
/*** COMMON VALUE IMPORTS ***/
import { status, channelReceived } from "../common/generalEnquiry";

/**
 * Handles the General Inquiry record type fields on Coaches Workbench during edit
 */
class GeneralInquiry extends Base {
  /****** TEXT INPUTS ******/
  get subject() {
    return $("//div/div[1]/div/div/div[1]/div/div/div/div/input");
  }
  get description() {
    return $("//div/div[1]/div/div/div[2]/div/div/div/div/textarea");
  }

  get searchTxt() {
    return $("//input[@placeholder='Search this list...']");
  }

  /****** LOOKUPS ******/
  get accountName() {
    return $(
      "//div/div[2]/div/div/div[2]/div[1]/div/div/div/div/div/div[1]/div/input"
    );
  }
  get parentCase() {
    return $(
      "//div/div[2]/div/div/div[5]/div[1]/div/div/div/div/div/div[1]/div/input"
    );
  }
  get financialAccount() {
    return $(
      "//div/div[2]/div/div/div[8]/div[1]/div/div/div/div/div/div[1]/div/input"
    );
  }

  /****** DROPDOWNS ******/
  get status() {
    return $(
      "//article/div[3]/div/div[2]/div/div/div[3]/div[2]/div/div/div/div/div/div/div/a"
    );
  }
  get type() {
    return $(
      "//article[1]/div[3]/div[1]/div[2]/div[1]/div[1]/div[3]/div[1]/div[1]/div[1]/div[1]/div[1]/div[1]/div[1]/div[1]/a[1]"
    );
  }
  get channelReceivedLink() {
    return $(
      "//article/div[3]/div/div[2]/div/div/div[5]/div[2]/div/div/div/div/div[1]/div/div/a"
    );
  }
  get caseReason() {
    return $("//div/div[2]/div/div/div[5]/div[2]/div/div/div/div");
  }
  get priority() {
    return $("//div/div[2]/div/div/div[6]/div[1]/div/div/div/div");
  }

  /****** BUTTONS ******/
  get subTypeAdd() {
    return $(
      "//div[2]/div/div/lightning-picklist/lightning-dual-listbox/div/div[2]/div/div[4]/lightning-button-icon[1]/button"
    );
  }
  get additionalTypeAdd() {
    return $(
      "//div[1]/div/div/lightning-picklist/lightning-dual-listbox/div/div[2]/div/div[4]/lightning-button-icon[1]/button"
    );
  }
  get save() {
    return $(
      "//section/div/div[2]/div/div/div/div[2]/div/div/div[3]/button[3]/span"
    );
  }

  get editBtn() {
    return $("//button[@name='Edit']");
  }

  get appSupport() {
    return $("=App Support");
  }

  get bugReport() {
    return $("span=Bug Report & Feature");
  }

  get refreshBtn() {
    return $("//button[@name='refreshButton']");
  }

  /****** LINKS ******/

  get caseLink() {
    return $("//tr[1]//th[1]//span[1]//a[1]");
  }

  get searchCase() {
    return $(
      "//*[@id='brandBand_1']/div/div/div/div/div[2]/div/div[1]/div[2]/div[2]/div[1]/div/div/table/tbody/tr/th/span/a"
    );
  }

  get menuList() {
    return $("a[title='Select List View']");
  }

  get openCaseLink() {
    return $("span=My Open Cases");
  }

  /*******Page Actions *****/

  enterCaseInSearch(value: string) {
    helpers.enterText(this.searchTxt, value);
  }

  clickEdit() {
    helpers.doJSClick(this.editBtn);
  }

  clickBugReport() {
    this.bugReport.scrollIntoView();
    this.bugReport.click();
  }

  waitForCaseToDisplay(valueToClick: string) {
    helpers.waitAndRetry(this.refreshBtn, this.caseLink, valueToClick);
  }

  clickAccountName(accName: string) {
    helpers.doClick($(`div=${accName}`));
  }

  clickFinancialAccountName(finaccName: string) {
    helpers.doClick($(`div=${finaccName}`));
  }

  selectStatus() {
    helpers.doClick(this.status);
    const PageElement = $(
      `a[role="menuitemradio"]=${faker.random.arrayElement(status)}`
    );
    PageElement.click();
  }

  selectCloseStatus() {
    helpers.doClick(this.status);
    const PageElement = $('a[role="menuitemradio"]=Closed');
    PageElement.click();
  }

  selectChannelReceived() {
    helpers.doClick(this.channelReceivedLink);
    const PageElement = $(`=${faker.random.arrayElement(channelReceived)}`);
    PageElement.click();
  }

  fillEditGeneralInquiryDetails(accName: string, finaccName: string) {
    helpers.enterText(this.description, faker.lorem.text());
    helpers.enterText(this.accountName, accName.toString());
    this.clickAccountName(accName);
    this.selectStatus();
    helpers.doClick(this.type);
    helpers.doClick(this.appSupport);
    this.clickBugReport();
    helpers.doClick(this.additionalTypeAdd);
    this.selectChannelReceived();
    helpers.enterText(this.financialAccount, finaccName.toString());
    this.clickFinancialAccountName(finaccName);
  }
}

export default new GeneralInquiry();
