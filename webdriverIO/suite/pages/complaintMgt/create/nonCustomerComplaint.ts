import Base from "../../base";
import helpers from "../../../utilities/helpers";

import * as faker from "faker";
/*** COMMON VALUE IMPORTS ***/
import {
  state,
  age,
  gender
} from "../../../pages/complaintMgt/common/nonCustomerComplaint";

/**
 * Handles the Non Customer Complaint record type fields on Complaints Mgt during creation
 */
class NonCustomerComplaint extends Base {
  /****** TEXT INPUTS ******/
  get firstName() {
    return $(
      "//lightning-accordion-section[1]/section/div[2]/slot/div/div[2]/lightning-input-field/lightning-input/div[1]/input"
    );
  }
  get middleName() {
    return $(
      "//lightning-accordion-section[1]/section/div[2]/slot/div/div[3]/lightning-input-field/lightning-input/div/input"
    );
  }
  get lastName() {
    return $(
      "//lightning-accordion-section[1]/section/div[2]/slot/div/div[4]/lightning-input-field/lightning-input/div/input"
    );
  }
  get email() {
    return $(
      "//lightning-accordion-section[1]/section/div[2]/slot/div/div[7]/lightning-input-field/lightning-input/div/input"
    );
  }
  get mobile() {
    return $(
      "//lightning-accordion-section[1]/section/div[2]/slot/div/div[8]/div/lightning-input-field/lightning-input/div/input"
    );
  }
  get phone() {
    return $(
      "//lightning-accordion-section[1]/section/div[2]/slot/div/div[9]/lightning-input-field/lightning-input/div/input"
    );
  }
  get street() {
    return $(
      "//lightning-accordion-section[1]/section/div[2]/slot/div/div[10]/lightning-input-field/lightning-input/div/input"
    );
  }
  get suburb() {
    return $(
      "//lightning-accordion-section[1]/section/div[2]/slot/div/div[11]/lightning-input-field/lightning-input/div/input"
    );
  }
  get postcode() {
    return $(
      "//lightning-accordion-section[1]/section/div[2]/slot/div/div[12]/lightning-input-field/lightning-input/div/input"
    );
  }
  get description() {
    return $(
      "//lightning-accordion-section[2]/section[1]/div[2]/slot[1]/div[1]/div[6]/lightning-textarea[1]/div[1]/textarea[1]"
    );
  }
  get desiredOutcome() {
    return $(
      "//lightning-accordion-section[2]/section[1]/div[2]/slot[1]/div[1]/div[7]/lightning-input-field[1]/lightning-textarea[1]/div[1]/textarea[1]"
    );
  }

  /****** DROPDOWNS ******/
  get complainantType() {
    return $(
      "//lightning-accordion-section[1]/section/div[2]/slot/div/div[1]/lightning-input-field/lightning-picklist/lightning-combobox/div[1]/lightning-base-combobox/div/div[1]/input"
    );
  }
  get age() {
    return $(
      "//lightning-accordion-section[1]/section/div[2]/slot/div/div[5]/lightning-input-field/lightning-picklist/lightning-combobox/div[1]/lightning-base-combobox/div/div[1]/input"
    );
  }
  get gender() {
    return $(
      "//lightning-accordion-section[1]/section/div[2]/slot/div/div[6]/lightning-input-field/lightning-picklist/lightning-combobox/div/lightning-base-combobox/div/div[1]/input"
    );
  }
  get country() {
    return $(
      "//lightning-accordion-section[1]/section/div[2]/slot/div/div[13]/lightning-input-field/lightning-picklist/lightning-combobox/div/lightning-base-combobox/div/div[1]/input"
    );
  }
  get state() {
    return $(
      "//lightning-accordion-section[1]/section/div[2]/slot/div/div[14]/lightning-input-field/lightning-picklist/lightning-combobox/div/lightning-base-combobox/div/div[1]/input"
    );
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

  /****** BUTTONS ******/
  get create() {
    return $(
      "//lightning-record-edit-form/form/slot/div/div/lightning-button/button"
    );
  }

  get newBtn() {
    return $("=New");
  }

  get nextBtn() {
    return $("button=Next");
  }

  get agreeBtn() {
    return $("span=Agrees");
  }

  get disAgreeBtn() {
    return $("span=Disagrees");
  }

  /****** RADIO ******/
  get writtenResponseNo() {
    return $(
      "//lightning-accordion-section[3]/section/div[2]/slot/div[2]/div[1]/lightning-radio-group/fieldset/div/div/span[2]/label/span"
    );
  }
  get complaintRelatingNo() {
    return $(
      "//lightning-accordion-section[3]/section/div[2]/slot/div[2]/div[2]/lightning-radio-group/fieldset/div/div/span[2]/label/span"
    );
  }

  get systemicIssueNo() {
    return $(
      "//lightning-accordion-section[3]/section/div[2]/slot/div[2]/div[3]/lightning-radio-group/fieldset/div/div/span[2]/label/span"
    );
  }

  get AnonymousSystemicIssueNo() {
    return $(
      "//lightning-accordion-section[3]/section/div[2]/slot/div/div[1]/lightning-radio-group/fieldset/div/div/span[2]/label/span"
    );
  }

  get nonComplaint() {
    return $("span=Non-Customer Complaint");
  }

  /****** LOOKUPS ******/
  get productServiceName() {
    return $(
      "//lightning-accordion-section[2]/section[1]/div[2]/slot[1]/div[1]/div[5]/lightning-input-field[1]/lightning-lookup[1]/lightning-lookup-desktop[1]/lightning-grouped-combobox[1]/div[1]/div[1]/lightning-base-combobox[1]/div[1]/div[1]/input[1]"
    );
  }

  /****PAGE ACTIONS *****/

  clickNewBtn() {
    helpers.doJSClick(this.newBtn);
  }

  gotoCreateNonComplaintPage() {
    helpers.doClick(this.nonComplaint);
    helpers.doClick(this.nextBtn);
    helpers.doClick(this.agreeBtn);
  }

  gotoCreateAnonymousNonComplaintPage() {
    helpers.doClick(this.nonComplaint);
    helpers.doClick(this.nextBtn);
    helpers.doClick(this.disAgreeBtn);
  }

  selectComplaintType() {
    helpers.doClick(this.complainantType);
    const pageElement = $("span.slds-truncate=Individual");
    helpers.doJSClick(pageElement);
  }

  selectAge() {
    helpers.doClick(this.age);
    helpers.doClick($(`span.slds-truncate=${faker.random.arrayElement(age)}`));
  }

  selectGender() {
    helpers.doClick(this.gender);
    helpers.doClick(
      $(`span.slds-truncate=${faker.random.arrayElement(gender)}`)
    );
  }

  selectCountry() {
    helpers.doClick(this.country);
    const pageElement = $("span.slds-truncate=Australia");
    helpers.doJSClick(pageElement);
  }

  selectState() {
    helpers.doClick(this.state);
    const pageElement = $(
      `span.slds-truncate=${faker.random.arrayElement(state)}`
    );
    helpers.doJSClick(pageElement);
  }

  selectPriority() {
    helpers.doClick(this.priority);

    const pageElement = $(
      "//lightning-accordion-section[2]/section/div[2]/slot/div/div[1]/lightning-input-field/lightning-picklist/lightning-combobox/div/lightning-base-combobox/div/div[2]/lightning-base-combobox-item[3]"
    );
    helpers.doJSClick(pageElement);
  }

  selectIssueType() {
    helpers.doClick(this.caseType);

    const pageElement = $(
      "//lightning-accordion-section[2]/section/div[2]/slot/div/div[3]/lightning-input-field/lightning-picklist/lightning-combobox/div[1]/lightning-base-combobox/div/div[2]/lightning-base-combobox-item[2]/span[2]/span"
    );
    helpers.doJSClick(pageElement);
  }

  selectSubIssueType() {
    helpers.doClick(this.subIssueType);
    const pageElement = $(
      "//lightning-accordion-section[2]/section/div[2]/slot/div/div[4]/lightning-input-field/lightning-picklist/lightning-combobox/div[1]/lightning-base-combobox/div/div[2]/lightning-base-combobox-item[2]/span[2]/span"
    );
    helpers.doJSClick(pageElement);
  }

  selectProdType() {
    helpers.enterText(this.productServiceName, "Netwealth");
    const pageElement = $("strong=Netwealth");
    helpers.doJSClick(pageElement);
  }

  fillCreateNonCustomerComplaintDetails() {
    this.selectComplaintType();
    helpers.enterText(this.firstName, faker.name.firstName());
    helpers.enterText(this.middleName, faker.name.firstName());
    helpers.enterText(this.lastName, faker.name.lastName());
    this.selectAge();
    this.selectGender();
    helpers.enterText(this.email, faker.internet.email());
    helpers.enterText(this.mobile, faker.phone.phoneNumber("04########"));
    helpers.enterText(this.phone, faker.phone.phoneNumber("97######"));
    helpers.enterText(this.street, faker.address.streetName());
    helpers.enterText(this.suburb, faker.address.city());
    helpers.enterText(this.postcode, faker.address.zipCode("####"));
    this.selectState();
    this.selectPriority();
    this.selectIssueType();
    this.selectSubIssueType();
    this.selectProdType();
    helpers.enterText(this.description, faker.lorem.text());
    helpers.enterText(this.desiredOutcome, faker.lorem.text());
    helpers.doClick(this.writtenResponseNo);
    helpers.doClick(this.complaintRelatingNo);
    helpers.doClick(this.systemicIssueNo);
  }

  fillCreateAnonymousNonCustomerComplaintDetails() {
    this.selectComplaintType();
    helpers.enterText(this.firstName, faker.name.firstName());
    helpers.enterText(this.middleName, faker.name.firstName());
    helpers.enterText(this.lastName, faker.name.lastName());
    this.selectAge();
    this.selectGender();
    helpers.enterText(this.email, faker.internet.email());
    helpers.enterText(this.mobile, faker.phone.phoneNumber("04########"));
    helpers.enterText(this.phone, faker.phone.phoneNumber("97######"));
    helpers.enterText(this.street, faker.address.streetName());
    helpers.enterText(this.suburb, faker.address.city());
    helpers.enterText(this.postcode, faker.address.zipCode("####"));
    this.selectState();
    this.selectPriority();
    this.selectIssueType();
    this.selectSubIssueType();
    this.selectProdType();
    helpers.enterText(this.description, faker.lorem.text());
    helpers.enterText(this.desiredOutcome, faker.lorem.text());
    //helpers.doClick(this.writtenResponseNo);
    // helpers.doClick(this.complaintRelatingNo);
    helpers.doClick(this.AnonymousSystemicIssueNo);
  }
}

export default new NonCustomerComplaint();
