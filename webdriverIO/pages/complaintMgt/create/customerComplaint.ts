import Base from "../../base";
/**
 * Handles the Customer Complaint record type fields on Complaints Mgt during creation
 */
class CustomerComplaint extends Base {
  /****** TEXT INPUTS ******/
  get customerNumber() {
    return $(
      "//lightning-accordion-section[1]/section/div[2]/slot/div/div[1]/lightning-input-field/lightning-input/div[1]/input"
    );
  }

  get accountCardPolicyNumber() {
    return $(
      "//lightning-accordion-section[2]/section/div[2]/slot/div/div[5]/lightning-input-field/lightning-input/div[1]/input"
    );
  }

  get description() {
    return $(
      "//lightning-accordion-section[2]/section/div[2]/slot/div/div[6]/lightning-input-field/lightning-textarea/div[1]/textarea"
    );
  }

  get complainantDesiredOutcome() {
    return $(
      "//lightning-accordion-section[2]/section/div[2]/slot/div/div[7]/lightning-input-field/lightning-textarea/div[1]/textarea"
    );
  }

  /****** DROPDOWNS ******/
  get complainantType() {
    return $(
      "//lightning-accordion-section[1]/section/div[2]/slot/div/div[3]/lightning-input-field/lightning-picklist/lightning-combobox/div[1]/lightning-base-combobox/div/div[1]/input"
    );
  }

  get descent() {
    return $(
      "//lightning-accordion-section[1]/section/div[2]/slot/div/div[4]/lightning-input-field/lightning-picklist/lightning-combobox/div/lightning-base-combobox/div/div[1]/input"
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
      "//lightning-accordion-section[2]/section/div[2]/slot/div/div[4]/lightning-input-field/lightning-lookup/lightning-lookup-desktop/lightning-grouped-combobox/div[1]/div/lightning-base-combobox/div/div[1]/input"
    );
  }
}

export default new CustomerComplaint();
