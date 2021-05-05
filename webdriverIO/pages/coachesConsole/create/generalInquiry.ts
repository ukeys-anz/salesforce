import Base from "../../base";
import helpers from "../../../utilities/helpers";
import * as faker from "faker";

/*** COMMON VALUE IMPORTS ***/
import {
  status,
  channelReceived
} from "../../../pages/coachesWorkbench/common/generalInquiry";

/**
 * Handles the General Inquiry record type fields on Coaches Workbench during create
 */
class GeneralInquiry extends Base {
  /****** TEXT INPUTS ******/
  get subject() {
    return $("//div/div[1]/div/div/div[1]/div/div/div/div/input");
  }
  get description() {
    return $("//div/div[1]/div/div/div[2]/div/div/div/div/textarea");
  }
  get originalCaseNumber() {
    return $("//div/div[2]/div/div/div[1]/div[1]/div/div/div/input");
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
      "//article/div[3]/div/div[2]/div/div/div[2]/div[2]/div/div/div/div"
    );
  }
  get type() {
    return $(
      "//article[1]/div[3]/div[1]/div[2]/div[1]/div[1]/div[3]/div[1]/div[1]/div[1]/div[1]/div[1]/div[1]/div[1]/div[1]/a[1]"
    );
  }
  get channelReceivedLink() {
    return $("//div/div[2]/div/div/div[4]/div[2]/div/div/div/div");
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
      "//div/div[3]/div[2]/div/div/lightning-picklist/lightning-dual-listbox/div/div[2]/div/div[4]/lightning-button-icon[1]/button"
    );
  }
  get additionalTypeAdd() {
    return $(
      "//div/div[4]/div[1]/div/div/lightning-picklist/lightning-dual-listbox/div/div[2]/div/div[4]/lightning-button-icon[1]/button"
    );
  }
  get save() {
    return $("//div/div[2]/button[3]");
  }

  get newBtn() {
    return $("=New");
  }

  get appSupport() {
    return $("=App Support");
  }

  get appGuide() {
    return $("span=App Guide");
  }

  get deviceSupport() {
    return $("span=Device Support");
  }

  get bugReport() {
    return $("span=Bug Report & Feature");
  }

  /*******Page Actions *****/

  clickNewBtn() {
    helpers.doJSClick(this.newBtn);
  }

  selectLowPriority() {
    helpers.doClick(this.priority);
    const PageElement = $("=Low");
    PageElement.click();
  }

  clickBugReport() {
    this.bugReport.scrollIntoView();
    this.bugReport.click();
  }

  selectChannelReceived() {
    helpers.doClick(this.channelReceivedLink);
    const PageElement = $(`=${faker.random.arrayElement(channelReceived)}`);
    PageElement.click();
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

  fillCreateInquiryDetails(accName: string, finaccName: string) {
    helpers.enterText(this.description, faker.lorem.text());
    helpers.enterText(this.accountName, accName.toString());
    this.clickAccountName(accName);
    this.selectStatus();
    helpers.doClick(this.type);
    helpers.doClick(this.appSupport);
    helpers.doClick(this.appGuide);
    helpers.doClick(this.subTypeAdd);
    helpers.doClick(this.deviceSupport);
    helpers.doClick(this.subTypeAdd);
    helpers.doClick(this.additionalTypeAdd);
    this.selectChannelReceived();
    this.selectLowPriority();
    helpers.enterText(this.financialAccount, finaccName.toString());
    this.clickFinancialAccountName(finaccName);
  }
}

export default new GeneralInquiry();
