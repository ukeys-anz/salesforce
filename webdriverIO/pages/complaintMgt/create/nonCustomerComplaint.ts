import Base from "../../base";
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
      "//lightning-accordion-section[1]/section/div[2]/slot/div/div[8]/lightning-input-field/lightning-input/div/input"
    );
  }
  get mobile() {
    return $(
      "//lightning-accordion-section[1]/section/div[2]/slot/div/div[9]/div/lightning-input-field/lightning-input/div[1]/input"
    );
  }
  get phone() {
    return $(
      "//lightning-accordion-section[1]/section/div[2]/slot/div/div[10]/lightning-input-field/lightning-input/div/input"
    );
  }
  get street() {
    return $(
      "//lightning-accordion-section[1]/section/div[2]/slot/div/div[11]/lightning-input-field/lightning-input/div/input"
    );
  }
  get suburb() {
    return $(
      "//lightning-accordion-section[1]/section/div[2]/slot/div/div[12]/lightning-input-field/lightning-input/div/input"
    );
  }
  get postcode() {
    return $(
      "//lightning-accordion-section[1]/section/div[2]/slot/div/div[13]/lightning-input-field/lightning-input/div/input"
    );
  }
  get description() {
    return $(
      "//lightning-accordion-section[2]/section/div[2]/slot/div/div[6]/lightning-input-field/lightning-textarea/div[1]/textarea"
    );
  }
  get desiredOutcome() {
    return $(
      "//lightning-accordion-section[2]/section/div[2]/slot/div/div[7]/lightning-input-field/lightning-textarea/div[1]/textarea"
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
  get descent() {
    return $(
      "//lightning-accordion-section[1]/section/div[2]/slot/div/div[7]/lightning-input-field/lightning-picklist/lightning-combobox/div/lightning-base-combobox/div/div[1]/input"
    );
  }
  get country() {
    return $(
      "//lightning-accordion-section[1]/section/div[2]/slot/div/div[14]/lightning-input-field/lightning-picklist/lightning-combobox/div/lightning-base-combobox/div/div[1]/input"
    );
  }
  get state() {
    return $(
      "//lightning-accordion-section[1]/section/div[2]/slot/div/div[15]/lightning-input-field/lightning-picklist/lightning-combobox/div/lightning-base-combobox/div/div[1]/input"
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

  /****** LOOKUPS ******/
  get productServiceName() {
    return $(
      "//lightning-accordion-section[2]/section/div[2]/slot/div/div[5]/lightning-input-field/lightning-lookup/lightning-lookup-desktop/lightning-grouped-combobox/div/div/lightning-base-combobox/div/div[1]/input"
    );
  }
}

export default new NonCustomerComplaint();
