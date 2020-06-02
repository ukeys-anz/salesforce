import Base from "../../base";
/**
 * Handles the Customer Complaint record type fields on Complaints Mgt during creation
 */
class CustomerComplaint extends Base {
  /****** TEXT INPUTS ******/
  get customerNumber() {
    return $(
      "/html/body/div[4]/div[1]/div[2]/div[2]/div/div/div/section/div/div[2]/div/div/div/div/c-create-complaint-l-w-c/div/lightning-record-edit-form/form/slot/lightning-accordion/slot/lightning-accordion-section[1]/section/div[2]/slot/div/div[1]/lightning-input-field/lightning-input/div[1]/input"
    );
  }

  get accountCardPolicyNumber() {
    return $(
      "/html/body/div[4]/div[1]/div[2]/div[2]/div/div/div/section/div/div[2]/div/div/div/div/c-create-complaint-l-w-c/div/lightning-record-edit-form/form/slot/lightning-accordion/slot/lightning-accordion-section[2]/section/div[2]/slot/div/div[7]/lightning-input-field/lightning-input/div[1]/input"
    );
  }

  get description() {
    return $(
      "/html/body/div[4]/div[1]/div[2]/div[2]/div/div/div/section/div/div[2]/div/div/div/div/c-create-complaint-l-w-c/div/lightning-record-edit-form/form/slot/lightning-accordion/slot/lightning-accordion-section[2]/section/div[2]/slot/div/div[8]/lightning-input-field/lightning-textarea/div/textarea"
    );
  }

  get complainantDesiredOutcome() {
    return $(
      "/html/body/div[4]/div[1]/div[2]/div[2]/div/div/div/section/div/div[2]/div/div/div/div/c-create-complaint-l-w-c/div/lightning-record-edit-form/form/slot/lightning-accordion/slot/lightning-accordion-section[2]/section/div[2]/slot/div/div[9]/lightning-input-field/lightning-textarea/div/textarea"
    );
  }

  /****** DROPDOWNS ******/
  get complainantType() {
    return $(
      "/html/body/div[4]/div[1]/div[2]/div[2]/div/div/div/section/div/div[2]/div/div/div/div/c-create-complaint-l-w-c/div/lightning-record-edit-form/form/slot/lightning-accordion/slot/lightning-accordion-section[1]/section/div[2]/slot/div/div[3]/lightning-input-field/lightning-picklist/lightning-combobox/div[1]/lightning-base-combobox/div/div[1]/input"
    );
  }

  get descent() {
    return $(
      "/html/body/div[4]/div[1]/div[2]/div[2]/div/div/div/section/div/div[2]/div/div/div/div/c-create-complaint-l-w-c/div/lightning-record-edit-form/form/slot/lightning-accordion/slot/lightning-accordion-section[1]/section/div[2]/slot/div/div[4]/lightning-input-field/lightning-picklist/lightning-combobox/div/lightning-base-combobox/div/div[1]/input"
    );
  }

  get priority() {
    return $(
      "/html/body/div[4]/div[1]/div[2]/div[2]/div/div/div/section/div/div[2]/div/div/div/div/c-create-complaint-l-w-c/div/lightning-record-edit-form/form/slot/lightning-accordion/slot/lightning-accordion-section[2]/section/div[2]/slot/div/div[1]/lightning-input-field/lightning-picklist/lightning-combobox/div/lightning-base-combobox/div/div[1]/input"
    );
  }

  get caseType() {
    return $(
      "/html/body/div[4]/div[1]/div[2]/div[2]/div/div/div/section/div/div[2]/div/div/div/div/c-create-complaint-l-w-c/div/lightning-record-edit-form/form/slot/lightning-accordion/slot/lightning-accordion-section[2]/section/div[2]/slot/div/div[3]/lightning-input-field/lightning-picklist/lightning-combobox/div/lightning-base-combobox/div/div[1]/input"
    );
  }

  get productServiceLine() {
    return $(
      "/html/body/div[4]/div[1]/div[2]/div[2]/div/div/div/section/div/div[2]/div/div/div/div/c-create-complaint-l-w-c/div/lightning-record-edit-form/form/slot/lightning-accordion/slot/lightning-accordion-section[2]/section/div[2]/slot/div/div[4]/lightning-input-field/lightning-picklist/lightning-combobox/div/lightning-base-combobox/div/div[1]/input"
    );
  }

  get productServiceCategory() {
    return $(
      "/html/body/div[4]/div[1]/div[2]/div[2]/div/div/div/section/div/div[2]/div/div/div/div/c-create-complaint-l-w-c/div/lightning-record-edit-form/form/slot/lightning-accordion/slot/lightning-accordion-section[2]/section/div[2]/slot/div/div[5]/lightning-input-field/lightning-picklist/lightning-combobox/div/lightning-base-combobox/div/div[1]/input"
    );
  }

  get productServiceType() {
    return $(
      "/html/body/div[4]/div[1]/div[2]/div[2]/div/div/div/section/div/div[2]/div/div/div/div/c-create-complaint-l-w-c/div/lightning-record-edit-form/form/slot/lightning-accordion/slot/lightning-accordion-section[2]/section/div[2]/slot/div/div[6]/lightning-input-field/lightning-picklist/lightning-combobox/div/lightning-base-combobox/div/div[1]/input"
    );
  }

  /****** BUTTONS ******/
  get create() {
    return $(
      "/html/body/div[4]/div[1]/div[2]/div[2]/div/div/div/section/div/div[2]/div/div/div/div/c-create-complaint-l-w-c/div/lightning-record-edit-form/form/slot/div/div/lightning-button/button"
    );
  }

  /****** RADIO ******/
  //TODO Add yes and no radios
  get writtenResponseNo() {
    return $(
      "/html/body/div[4]/div[1]/div[2]/div[2]/div/div/div/section/div/div[2]/div/div/div/div/c-create-complaint-l-w-c/div/lightning-record-edit-form/form/slot/lightning-accordion/slot/lightning-accordion-section[3]/section/div[2]/slot/div[2]/div[1]/lightning-radio-group/fieldset/div/div/span[2]/label/span"
    );
  }
  get complaintRelatingNo() {
    return $(
      "/html/body/div[4]/div[1]/div[2]/div[2]/div/div/div/section/div/div[2]/div/div/div/div/c-create-complaint-l-w-c/div/lightning-record-edit-form/form/slot/lightning-accordion/slot/lightning-accordion-section[3]/section/div[2]/slot/div[2]/div[2]/lightning-radio-group/fieldset/div/div/span[2]/label/span"
    );
  }
}

export default new CustomerComplaint();
