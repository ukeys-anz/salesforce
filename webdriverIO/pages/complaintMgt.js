const baseNonCustomer = `/html/body/div[4]/div[1]/div[2]/div[2]/div/div/div/section/div/div[2]/div/div/div/div/c-create-complaint-l-w-c/div/lightning-record-edit-form/form/slot/lightning-accordion/slot/lightning-accordion-section[1]/section/div[2]/slot/div`;
export const nonCustomer = {
  dropdown: {
    complainantType: {
      selector: `${baseNonCustomer}/div[1]/lightning-input-field/lightning-picklist/lightning-combobox/div[1]/lightning-base-combobox/div/div[1]/input`,
      individualValue: `${baseNonCustomer}/div[1]/lightning-input-field/lightning-picklist/lightning-combobox/div[1]/lightning-base-combobox/div/div[2]/lightning-base-combobox-item[2]/span[2]/span`,
      smallBusinessValue: `${baseNonCustomer}/div[1]/lightning-input-field/lightning-picklist/lightning-combobox/div[1]/lightning-base-combobox/div/div[2]/lightning-base-combobox-item[3]/span[2]/span`,
      notStatedValue: `${baseNonCustomer}/div[1]/lightning-input-field/lightning-picklist/lightning-combobox/div[1]/lightning-base-combobox/div/div[2]/lightning-base-combobox-item[4]/span[2]/span`
    },
    age: {
      selector: `${baseNonCustomer}/div[5]/lightning-input-field/lightning-picklist/lightning-combobox/div[1]/lightning-base-combobox/div/div[1]/input`,
      less18Value: `${baseNonCustomer}/div[5]/lightning-input-field/lightning-picklist/lightning-combobox/div[1]/lightning-base-combobox/div/div[2]/lightning-base-combobox-item[2]`
    },
    gender: {
      selector: `${baseNonCustomer}/div[6]/lightning-input-field/lightning-picklist/lightning-combobox/div/lightning-base-combobox/div/div[1]/input`,
      maleValue: `${baseNonCustomer}/div[6]/lightning-input-field/lightning-picklist/lightning-combobox/div[1]/lightning-base-combobox/div/div[2]/lightning-base-combobox-item[2]`
    },
    descent: {
      selector: `${baseNonCustomer}/div[7]/lightning-input-field/lightning-picklist/lightning-combobox/div/lightning-base-combobox/div/div[1]/input`,
      noValue: `${baseNonCustomer}/div[7]/lightning-input-field/lightning-picklist/lightning-combobox/div[1]/lightning-base-combobox/div/div[2]/lightning-base-combobox-item[2]`
    },
    country: {
      selector: `${baseNonCustomer}/div[14]/lightning-input-field/lightning-picklist/lightning-combobox/div/lightning-base-combobox/div/div[1]/input`,
      australiaValue: `${baseNonCustomer}/div[14]/lightning-input-field/lightning-picklist/lightning-combobox/div/lightning-base-combobox/div/div[1]/input`
    },
    state: {
      selector: `${baseNonCustomer}/div[15]/lightning-input-field/lightning-picklist/lightning-combobox/div/lightning-base-combobox/div/div[1]/input`,
      vicValue: `${baseNonCustomer}/div[15]/lightning-input-field/lightning-picklist/lightning-combobox/div[1]/lightning-base-combobox/div/div[2]/lightning-base-combobox-item[3]`
    },
    priority: {
      selector:
        "/html/body/div[4]/div[1]/div[2]/div[2]/div/div/div/section/div/div[2]/div/div/div/div/c-create-complaint-l-w-c/div/lightning-record-edit-form/form/slot/lightning-accordion/slot/lightning-accordion-section[2]/section/div[2]/slot/div/div[1]/lightning-input-field/lightning-picklist/lightning-combobox/div/lightning-base-combobox/div/div[1]/input",
      noneValue:
        "/html/body/div[4]/div[1]/div[2]/div[2]/div/div/div/section/div/div[2]/div/div/div/div/c-create-complaint-l-w-c/div/lightning-record-edit-form/form/slot/lightning-accordion/slot/lightning-accordion-section[2]/section/div[2]/slot/div/div[1]/lightning-input-field/lightning-picklist/lightning-combobox/div/lightning-base-combobox/div/div[2]/lightning-base-combobox-item[2]"
    },
    caseType: {
      selector:
        "/html/body/div[4]/div[1]/div[2]/div[2]/div/div/div/section/div/div[2]/div/div/div/div/c-create-complaint-l-w-c/div/lightning-record-edit-form/form/slot/lightning-accordion/slot/lightning-accordion-section[2]/section/div[2]/slot/div/div[3]/lightning-input-field/lightning-picklist/lightning-combobox/div/lightning-base-combobox/div/div[1]/input",
      processValue:
        "/html/body/div[4]/div[1]/div[2]/div[2]/div/div/div/section/div/div[2]/div/div/div/div/c-create-complaint-l-w-c/div/lightning-record-edit-form/form/slot/lightning-accordion/slot/lightning-accordion-section[2]/section/div[2]/slot/div/div[3]/lightning-input-field/lightning-picklist/lightning-combobox/div[1]/lightning-base-combobox/div/div[2]/lightning-base-combobox-item[6]"
    },
    productServiceLine: {
      selector:
        "/html/body/div[4]/div[1]/div[2]/div[2]/div/div/div/section/div/div[2]/div/div/div/div/c-create-complaint-l-w-c/div/lightning-record-edit-form/form/slot/lightning-accordion/slot/lightning-accordion-section[2]/section/div[2]/slot/div/div[4]/lightning-input-field/lightning-picklist/lightning-combobox/div/lightning-base-combobox/div/div[1]/input",
      creditValue:
        "/html/body/div[4]/div[1]/div[2]/div[2]/div/div/div/section/div/div[2]/div/div/div/div/c-create-complaint-l-w-c/div/lightning-record-edit-form/form/slot/lightning-accordion/slot/lightning-accordion-section[2]/section/div[2]/slot/div/div[4]/lightning-input-field/lightning-picklist/lightning-combobox/div[1]/lightning-base-combobox/div/div[2]/lightning-base-combobox-item[2]"
    },
    productServiceCategory: {
      selector:
        "/html/body/div[4]/div[1]/div[2]/div[2]/div/div/div/section/div/div[2]/div/div/div/div/c-create-complaint-l-w-c/div/lightning-record-edit-form/form/slot/lightning-accordion/slot/lightning-accordion-section[2]/section/div[2]/slot/div/div[5]/lightning-input-field/lightning-picklist/lightning-combobox/div[1]/lightning-base-combobox/div/div[1]/input",
      guaranteeValue:
        "/html/body/div[4]/div[1]/div[2]/div[2]/div/div/div/section/div/div[2]/div/div/div/div/c-create-complaint-l-w-c/div/lightning-record-edit-form/form/slot/lightning-accordion/slot/lightning-accordion-section[2]/section/div[2]/slot/div/div[5]/lightning-input-field/lightning-picklist/lightning-combobox/div[1]/lightning-base-combobox/div/div[2]/lightning-base-combobox-item[4]"
    }
  },
  text: {
    firstName: `${baseNonCustomer}/div[2]/lightning-input-field/lightning-input/div[1]/input`,
    middleName: `${baseNonCustomer}/div[3]/lightning-input-field/lightning-input/div/input`,
    lastName: `${baseNonCustomer}/div[4]/lightning-input-field/lightning-input/div/input`,
    email: `${baseNonCustomer}/div[8]/lightning-input-field/lightning-input/div/input`,
    mobile: `${baseNonCustomer}/div[9]/div/lightning-input-field/lightning-input/div[1]/input`,
    phone: `${baseNonCustomer}/div[10]/lightning-input-field/lightning-input/div/input`,
    street: `${baseNonCustomer}/div[11]/lightning-input-field/lightning-input/div/input`,
    suburb: `${baseNonCustomer}/div[12]/lightning-input-field/lightning-input/div/input`,
    postcode: `${baseNonCustomer}/div[13]/lightning-input-field/lightning-input/div/input`,
    description:
      "/html/body/div[4]/div[1]/div[2]/div[2]/div/div/div/section/div/div[2]/div/div/div/div/c-create-complaint-l-w-c/div/lightning-record-edit-form/form/slot/lightning-accordion/slot/lightning-accordion-section[2]/section/div[2]/slot/div/div[7]/lightning-input-field/lightning-textarea/div[1]/textarea",
    desiredOutcome:
      "/html/body/div[4]/div[1]/div[2]/div[2]/div/div/div/section/div/div[2]/div/div/div/div/c-create-complaint-l-w-c/div/lightning-record-edit-form/form/slot/lightning-accordion/slot/lightning-accordion-section[2]/section/div[2]/slot/div/div[8]/lightning-input-field/lightning-textarea/div/textarea"
  },
  radio: {
    writtenResponse: {
      no:
        "/html/body/div[4]/div[1]/div[2]/div[2]/div/div/div/section/div/div[2]/div/div/div/div/c-create-complaint-l-w-c/div/lightning-record-edit-form/form/slot/lightning-accordion/slot/lightning-accordion-section[3]/section/div[2]/slot/div[2]/div[1]/lightning-radio-group/fieldset/div/div/span[2]/label/span"
    },
    complaintRelating: {
      no:
        "/html/body/div[4]/div[1]/div[2]/div[2]/div/div/div/section/div/div[2]/div/div/div/div/c-create-complaint-l-w-c/div/lightning-record-edit-form/form/slot/lightning-accordion/slot/lightning-accordion-section[3]/section/div[2]/slot/div[2]/div[2]/lightning-radio-group/fieldset/div/div/span[2]/label/span"
    }
  },
  button: {
    create:
      "/html/body/div[4]/div[1]/div[2]/div[2]/div/div/div/section/div/div[2]/div/div/div/div/c-create-complaint-l-w-c/div/lightning-record-edit-form/form/slot/div/div/lightning-button/button"
  }
};
