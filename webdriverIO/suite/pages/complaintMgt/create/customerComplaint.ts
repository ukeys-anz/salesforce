import Base from "../../base";
import helpers from "../../../utilities/helpers";

/*** UTILITIES IMPORTS ***/
import * as faker from "faker";

/**
 * Handles the Customer Complaint record type fields on Complaints Mgt during creation
 */
class CustomerComplaint extends Base {
  /****** TEXT INPUTS ******/
  get customerNumber() {
    return $(
      "//lightning-accordion-section[1]/section/div[2]/slot/div[1]/div[1]/lightning-input/div[1]/input"
    );
  }

  get accountCardPolicyNumber() {
    return $(
      "//lightning-accordion-section[2]/section/div[2]/slot/div/div[6]/lightning-input-field/lightning-input/div[1]/input"
    );
  }

  get issueDescription() {
    return $(
      "//lightning-accordion-section[2]/section/div[2]/slot/div/div[7]/lightning-textarea/div[1]/textarea"
    );
  }

  get custDesiredOutcome() {
    return $(
      "//lightning-accordion-section[2]/section/div[2]/slot/div/div[8]/lightning-input-field/lightning-textarea/div[1]/textarea"
    );
  }

  /****** DROPDOWNS ******/
  get complainantType() {
    return $(
      "//lightning-accordion-section[1]/section/div[2]/slot/div[2]/div[1]/lightning-input-field/lightning-picklist/lightning-combobox/div/lightning-base-combobox/div/div/input"
    );
  }

  get individualComplaintType() {
    return $("span.slds-truncate=Individual");
  }

  get priority() {
    return $(
      "//lightning-accordion-section[2]/section/div[2]/slot/div/div[1]/lightning-input-field/lightning-picklist/lightning-combobox/div/lightning-base-combobox/div/div[1]/input"
    );
  }

  get caseType() {
    return $(
      "//lightning-accordion-section[2]/section/div[2]/slot/div/div[3]/lightning-input-field/lightning-picklist/lightning-combobox/div/lightning-base-combobox/div/div[1]/input"
    );
  }

  get subIssueType() {
    return $(
      "//lightning-accordion-section[2]/section[1]/div[2]/slot[1]/div[1]/div[4]/lightning-input-field[1]/lightning-picklist[1]/lightning-combobox[1]/div[1]/lightning-base-combobox[1]/div[1]/div[1]/input[1]"
    );
  }

  get complaintSubIssue() {
    return $(
      "//lightning-accordion-section[2]/section/div[2]/slot/div/div[4]/lightning-input-field/lightning-picklist/lightning-combobox/div/lightning-base-combobox/div/div[1]/input"
    );
  }

  /****** BUTTONS ******/
  get create() {
    return $(
      "//lightning-record-edit-form/form/slot/div/div/lightning-button/button"
    );
  }

  get nextBtn() {
    return $("button=Next");
  }
  get newBtn() {
    return $("=New");
  }

  get searchBtn() {
    return $(
      "//lightning-accordion-section[1]/section/div[2]/slot/div[1]/div[2]/div/lightning-button/button"
    );
  }

  /****** RADIO ******/
  get writtenResponseNo() {
    return $(
      "//lightning-accordion-section[3]/section/div[2]/slot/div[2]/div[1]/lightning-radio-group/fieldset/div/div/span[2]/label/span"
    );
    //lightning-accordion-section[3]/section/div[2]/slot/div[2]/div[1]/lightning-radio-group/fieldset/div/div/span[2]/label/span
  }
  get complaintRelatingNo() {
    return $(
      "//lightning-accordion-section[3]/section/div[2]/slot/div[2]/div[2]/lightning-radio-group/fieldset/div/div/span[2]/label/span"
    );
    //lightning-accordion-section[3]/section/div[2]/slot/div[2]/div[2]/lightning-radio-group/fieldset/div/div/span[2]/label/span
  }

  get systemicIssueNo() {
    return $(
      "//lightning-accordion-section[3]/section/div[2]/slot/div[2]/div[3]/lightning-radio-group/fieldset/div/div/span[2]/label/span"
    );
    //lightning-accordion-section[3]/section/div[2]/slot/div[2]/div[1]/lightning-radio-group/fieldset/div/div/span[2]/label/span
  }

  get custComplaint() {
    return $("span=Customer Complaint");
  }

  /****** LOOKUPS ******/
  get productServiceName() {
    return $(
      "//lightning-accordion-section[2]/section/div[2]/slot/div/div[5]/lightning-input-field/lightning-lookup/lightning-lookup-desktop/lightning-grouped-combobox/div[1]/div/lightning-base-combobox/div/div[1]/input"
    );
  }

  /****PAGE ACTIONS *****/
  clickNewBtn() {
    helpers.doJSClick(this.newBtn);
  }

  gotoCreateComplaintPage() {
    helpers.doClick(this.custComplaint);
    helpers.doClick(this.nextBtn);
  }

  selectPriority() {
    const pageElement = $(
      "//lightning-accordion-section[2]/section/div[2]/slot/div/div[1]/lightning-input-field/lightning-picklist/lightning-combobox/div/lightning-base-combobox/div/div[2]/lightning-base-combobox-item[3]"
    );
    helpers.doJSClick(pageElement);
  }

  selectComplaintType() {
    helpers.doClick(this.complainantType);
    const pageElement = $("span.slds-truncate=Individual");
    helpers.doJSClick(pageElement);
  }

  selectIssueType() {
    const pageElement = $(
      "//lightning-accordion-section[2]/section/div[2]/slot/div/div[3]/lightning-input-field/lightning-picklist/lightning-combobox/div[1]/lightning-base-combobox/div/div[2]/lightning-base-combobox-item[2]/span[2]/span"
    );
    helpers.doJSClick(pageElement);
  }

  selectSubIssueType() {
    const pageElement = $(
      "//lightning-accordion-section[2]/section/div[2]/slot/div/div[4]/lightning-input-field/lightning-picklist/lightning-combobox/div[1]/lightning-base-combobox/div/div[2]/lightning-base-combobox-item[2]/span[2]/span"
    );
    helpers.doJSClick(pageElement);
  }

  selectProdType() {
    const pageElement = $("strong=Netwealth");
    helpers.doJSClick(pageElement);
  }

  fillCustomerComplaintDetails() {
    helpers.enterText(this.customerNumber, "1234567891");
    helpers.doClick(this.searchBtn);
    this.selectComplaintType();
    helpers.doClick(this.priority);
    this.selectPriority();
    helpers.doClick(this.caseType);
    this.selectIssueType();
    helpers.doClick(this.subIssueType);
    this.selectSubIssueType();
    helpers.enterText(this.productServiceName, "Netwealth");
    this.selectProdType();
    helpers.enterText(this.accountCardPolicyNumber, "12345");
    helpers.enterText(this.issueDescription, faker.lorem.text());
    helpers.enterText(this.custDesiredOutcome, faker.lorem.text());
    helpers.doClick(this.writtenResponseNo);
    helpers.doClick(this.complaintRelatingNo);
    helpers.doClick(this.systemicIssueNo);
  }
}

export default new CustomerComplaint();
