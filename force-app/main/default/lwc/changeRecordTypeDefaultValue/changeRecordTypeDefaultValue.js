import { LightningElement, api, track } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { fieldFactory } from "./helper/helper-field-list-handler";

export default class ChangeRecordTypeDefaultValue extends LightningElement {
  @api recordId;
  @api updatedRT;
  @api updatedRTName;
  @api defaultValues;
  @track allOtherFields = [];
  @track lookupFields = [];
  @track updatedDefaultValues = {};
  @track loadingData = true;
  @track submittingFlag = false;
  changedFields = [];

  connectedCallback() {
    let defaultValues = JSON.parse(this.defaultValues);
    const fields = {
      ...fieldFactory(this.updatedRTName, { ...defaultValues })
    };
    this.lookupFields = fields.lookupFields;
    this.allOtherFields = fields.allOtherFields;
    this.updatedDefaultValues = { ...fields.defaultValueFieldsNotOnForm };
    this.loadingData = false;
  }

  handleCancelButton() {
    const cancelDefaultValue = new CustomEvent("canceldefaultvalue", {
      detail: { close: true }
    });
    // Fire the custom event
    this.dispatchEvent(cancelDefaultValue);
  }

  handleError(e) {
    this.handleToast(e.detail.message, e.detail.detail, "error");
    this.submittingFlag = false;
  }

  handleSuccess(e) {
    const caseNumber =
      e.detail.fields.CaseNumber__c?.value || e.detail.fields.CaseNumber?.value;

    this.handleToast(
      caseNumber ? `Case "${caseNumber}" was updated.` : "Case was updated.",
      "",
      "success"
    );
  }

  handleSendValues(event) {
    this.submittingFlag = true;

    // stop the form from submitting
    event.preventDefault();
    //Get the fields
    let fields = event.detail.fields;

    fields = this.addChangedFieldsHandler(fields);
    fields = this.addDefaultValuesNotOnForm(fields);

    const requireFieldIndex = Object.keys(fields).findIndex(
      (el) => !fields[el] && fields[el] !== false
    );

    if (requireFieldIndex !== -1) {
      const toastTitle =
        "An error occurred while trying to update the record. Please try again.";
      const toastMessage = "All fields are required and must completed.";
      const toastVariant = "error";

      this.handleToast(toastTitle, toastMessage, toastVariant);
      this.submittingFlag = false;
    } else {
      this.handleSubmit(event, fields);
    }
  }

  addChangedFieldsHandler(fields) {
    for (let i = 0; i < this.changedFields.length; i++) {
      let changedField = this.changedFields[i];
      fields[changedField.name] = changedField.value;
    }
    return fields;
  }

  addDefaultValuesNotOnForm(fields) {
    for (let fieldName in this.updatedDefaultValues) {
      if (!fields[fieldName]) {
        fields[fieldName] = this.updatedDefaultValues[fieldName];
      }
    }
    return fields;
  }

  handleSubmit(event, fields) {
    // stop the form from submitting
    event.preventDefault();
    //Submit the form
    this.template.querySelector(".submitRecordEditForm").submit(fields);
  }

  handleChosenValue(e) {
    let name = e.target.fieldName;
    let value = e.target.value;

    const exisitingFieldIndex = this.changedFields.findIndex(
      (el) => el.name === name
    );
    if (exisitingFieldIndex !== -1) {
      this.changedFields[exisitingFieldIndex].value = value;
    } else {
      this.changedFields.push({ name, value });
    }
  }

  handleToast(title, message, variant) {
    this.dispatchEvent(
      new ShowToastEvent({
        title: title,
        message: message,
        variant: variant
      })
    );
  }
}
