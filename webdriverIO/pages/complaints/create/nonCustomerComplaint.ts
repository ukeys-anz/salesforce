import Base from "../../base";
/**
 * Handles the Non Customer Complaint record type fields on Complaints Mgt during creation
 */
class NonCustomerComplaint extends Base {
  /****** TEXT INPUTS ******/
  get firstName() {
    return $(
      "/html/body/div[4]/div[1]/div[2]/div[2]/div/div/div/section/div/div[2]/div/div/div/div/c-create-complaint-l-w-c/div/lightning-record-edit-form/form/slot/lightning-accordion/slot/lightning-accordion-section[1]/section/div[2]/slot/div/div[2]/lightning-input-field/lightning-input/div[1]/input"
    );
  }
  get middleName() {
    return $(
      "/html/body/div[4]/div[1]/div[2]/div[2]/div/div/div/section/div/div[2]/div/div/div/div/c-create-complaint-l-w-c/div/lightning-record-edit-form/form/slot/lightning-accordion/slot/lightning-accordion-section[1]/section/div[2]/slot/div/div[3]/lightning-input-field/lightning-input/div/input"
    );
  }
  get lastName() {
    return $(
      "/html/body/div[4]/div[1]/div[2]/div[2]/div/div/div/section/div/div[2]/div/div/div/div/c-create-complaint-l-w-c/div/lightning-record-edit-form/form/slot/lightning-accordion/slot/lightning-accordion-section[1]/section/div[2]/slot/div/div[4]/lightning-input-field/lightning-input/div/input"
    );
  }
  get email() {
    return $(
      "/html/body/div[4]/div[1]/div[2]/div[2]/div/div/div/section/div/div[2]/div/div/div/div/c-create-complaint-l-w-c/div/lightning-record-edit-form/form/slot/lightning-accordion/slot/lightning-accordion-section[1]/section/div[2]/slot/div/div[8]/lightning-input-field/lightning-input/div/input"
    );
  }
  get mobile() {
    return $(
      "/html/body/div[4]/div[1]/div[2]/div[2]/div/div/div/section/div/div[2]/div/div/div/div/c-create-complaint-l-w-c/div/lightning-record-edit-form/form/slot/lightning-accordion/slot/lightning-accordion-section[1]/section/div[2]/slot/div/div[9]/div/lightning-input-field/lightning-input/div[1]/input"
    );
  }
  get phone() {
    return $(
      "/html/body/div[4]/div[1]/div[2]/div[2]/div/div/div/section/div/div[2]/div/div/div/div/c-create-complaint-l-w-c/div/lightning-record-edit-form/form/slot/lightning-accordion/slot/lightning-accordion-section[1]/section/div[2]/slot/div/div[10]/lightning-input-field/lightning-input/div/input"
    );
  }
  get street() {
    return $(
      "/html/body/div[4]/div[1]/div[2]/div[2]/div/div/div/section/div/div[2]/div/div/div/div/c-create-complaint-l-w-c/div/lightning-record-edit-form/form/slot/lightning-accordion/slot/lightning-accordion-section[1]/section/div[2]/slot/div/div[11]/lightning-input-field/lightning-input/div/input"
    );
  }
  get suburb() {
    return $(
      "/html/body/div[4]/div[1]/div[2]/div[2]/div/div/div/section/div/div[2]/div/div/div/div/c-create-complaint-l-w-c/div/lightning-record-edit-form/form/slot/lightning-accordion/slot/lightning-accordion-section[1]/section/div[2]/slot/div/div[12]/lightning-input-field/lightning-input/div/input"
    );
  }
  get postcode() {
    return $(
      "/html/body/div[4]/div[1]/div[2]/div[2]/div/div/div/section/div/div[2]/div/div/div/div/c-create-complaint-l-w-c/div/lightning-record-edit-form/form/slot/lightning-accordion/slot/lightning-accordion-section[1]/section/div[2]/slot/div/div[13]/lightning-input-field/lightning-input/div/input"
    );
  }
  get description() {
    return $(
      "/html/body/div[4]/div[1]/div[2]/div[2]/div/div/div/section/div/div[2]/div/div/div/div/c-create-complaint-l-w-c/div/lightning-record-edit-form/form/slot/lightning-accordion/slot/lightning-accordion-section[2]/section/div[2]/slot/div/div[7]/lightning-input-field/lightning-textarea/div[1]/textarea"
    );
  }
  get desiredOutcome() {
    return $(
      "/html/body/div[4]/div[1]/div[2]/div[2]/div/div/div/section/div/div[2]/div/div/div/div/c-create-complaint-l-w-c/div/lightning-record-edit-form/form/slot/lightning-accordion/slot/lightning-accordion-section[2]/section/div[2]/slot/div/div[8]/lightning-input-field/lightning-textarea/div/textarea"
    );
  }

  /****** DROPDOWNS ******/
  get complainantType() {
    return $(
      "/html/body/div[4]/div[1]/div[2]/div[2]/div/div/div/section/div/div[2]/div/div/div/div/c-create-complaint-l-w-c/div/lightning-record-edit-form/form/slot/lightning-accordion/slot/lightning-accordion-section[1]/section/div[2]/slot/div/div[1]/lightning-input-field/lightning-picklist/lightning-combobox/div[1]/lightning-base-combobox/div/div[1]/input"
    );
  }
  get age() {
    return $(
      "/html/body/div[4]/div[1]/div[2]/div[2]/div/div/div/section/div/div[2]/div/div/div/div/c-create-complaint-l-w-c/div/lightning-record-edit-form/form/slot/lightning-accordion/slot/lightning-accordion-section[1]/section/div[2]/slot/div/div[5]/lightning-input-field/lightning-picklist/lightning-combobox/div[1]/lightning-base-combobox/div/div[1]/input"
    );
  }
  get gender() {
    return $(
      "/html/body/div[4]/div[1]/div[2]/div[2]/div/div/div/section/div/div[2]/div/div/div/div/c-create-complaint-l-w-c/div/lightning-record-edit-form/form/slot/lightning-accordion/slot/lightning-accordion-section[1]/section/div[2]/slot/div/div[6]/lightning-input-field/lightning-picklist/lightning-combobox/div/lightning-base-combobox/div/div[1]/input"
    );
  }
  get descent() {
    return $(
      "/html/body/div[4]/div[1]/div[2]/div[2]/div/div/div/section/div/div[2]/div/div/div/div/c-create-complaint-l-w-c/div/lightning-record-edit-form/form/slot/lightning-accordion/slot/lightning-accordion-section[1]/section/div[2]/slot/div/div[7]/lightning-input-field/lightning-picklist/lightning-combobox/div/lightning-base-combobox/div/div[1]/input"
    );
  }
  get country() {
    return $(
      "/html/body/div[4]/div[1]/div[2]/div[2]/div/div/div/section/div/div[2]/div/div/div/div/c-create-complaint-l-w-c/div/lightning-record-edit-form/form/slot/lightning-accordion/slot/lightning-accordion-section[1]/section/div[2]/slot/div/div[14]/lightning-input-field/lightning-picklist/lightning-combobox/div/lightning-base-combobox/div/div[1]/input"
    );
  }
  get state() {
    return $(
      "/html/body/div[4]/div[1]/div[2]/div[2]/div/div/div/section/div/div[2]/div/div/div/div/c-create-complaint-l-w-c/div/lightning-record-edit-form/form/slot/lightning-accordion/slot/lightning-accordion-section[1]/section/div[2]/slot/div/div[15]/lightning-input-field/lightning-picklist/lightning-combobox/div/lightning-base-combobox/div/div[1]/input"
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
      "/html/body/div[4]/div[1]/div[2]/div[2]/div/div/div/section/div/div[2]/div/div/div/div/c-create-complaint-l-w-c/div/lightning-record-edit-form/form/slot/lightning-accordion/slot/lightning-accordion-section[2]/section/div[2]/slot/div/div[5]/lightning-input-field/lightning-picklist/lightning-combobox/div[1]/lightning-base-combobox/div/div[1]/input"
    );
  }
  get productServiceType() {
    return $(
      "/html/body/div[4]/div[1]/div[2]/div[2]/div/div/div/section/div/div[2]/div/div/div/div/c-create-complaint-l-w-c/div/lightning-record-edit-form/form/slot/lightning-accordion/slot/lightning-accordion-section[2]/section/div[2]/slot/div/div[6]/lightning-input-field/lightning-picklist/lightning-combobox/div[1]/lightning-base-combobox/div/div[1]/input"
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

export default new NonCustomerComplaint();
