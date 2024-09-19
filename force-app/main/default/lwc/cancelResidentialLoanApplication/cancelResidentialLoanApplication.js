import { LightningElement, wire, api } from "lwc";
import { CloseActionScreenEvent } from "lightning/actions";
import { getPicklistValues } from "lightning/uiObjectInfoApi";
import { getRecord, getFieldValue } from "lightning/uiRecordApi";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import ConfirmationMessage from "@salesforce/label/c.RLA_Cancellation_Confirmation_Message";
import cancelResidentialLoanApplication from "@salesforce/apex/ResidentialLoanApplicationActions.cancelResidentialLoanApplication";

import CANCELLATION_REASON from "@salesforce/schema/ResidentialLoanApplication.Cancellation_Reason__c";
import OCV_ID from "@salesforce/schema/ResidentialLoanApplication.Account.OCV_ID__c";
import RESIDENTIAL_LOAN_APPLICATION_NUMBER from "@salesforce/schema/ResidentialLoanApplication.ApplicationExtIdentifier";

export default class CancelResidentialLoanApplication extends LightningElement {
  @api recordId;
  title;
  message;
  variant;
  value;
  otherReasonVisible = false;
  rlaRecordTypeId;
  options;
  mainWindow = true;
  rlaObject = {};
  loanApplicationNumber;
  ocvId;

  // fetches the Loan Application Number
  @wire(getRecord, {
    recordId: "$recordId",
    fields: [RESIDENTIAL_LOAN_APPLICATION_NUMBER, OCV_ID]
  })
  loanApplciation({ data }) {
    if (data) {
      this.rlaRecordTypeId = data.recordTypeId;
      this.loanApplicationNumber = getFieldValue(
        data,
        RESIDENTIAL_LOAN_APPLICATION_NUMBER
      );
      this.ocvId = getFieldValue(data, OCV_ID);
    }
  }

  // fetches the picklist values of the Cancellation Reason field
  @wire(getPicklistValues, {
    recordTypeId: "$rlaRecordTypeId",
    fieldApiName: CANCELLATION_REASON
  })
  picklistResults({ data }) {
    if (data) {
      this.options = data.values.map((val) => ({
        label: val.label,
        value: val.value
      }));
    }
  }

  handleCloseModel() {
    this.dispatchEvent(new CloseActionScreenEvent());
  }

  get confirmationMessage() {
    return ConfirmationMessage;
  }

  handleChange(event) {
    this.value = event.detail.value;
    this.otherReasonVisible = this.value === "Other";
  }

  handleSave() {
    if (this.checkFieldsValidity()) {
      const inputs = this.template.querySelectorAll(
        "lightning-input, lightning-combobox,lightning-textarea"
      );
      inputs.forEach((input) => {
        const fieldId = input.dataset.id;
        const value = input.value;
        this.rlaObject[fieldId] = value;
      });
      this.rlaObject.requestId = this.loanApplicationNumber;
      this.rlaObject.recordId = this.recordId;
      this.rlaObject.ocvId = this.ocvId;
      this.mainWindow = false;
    }
  }

  handleSubmit() {
    cancelResidentialLoanApplication({ rlaObject: this.rlaObject })
      .then((result) => {
        if (result === "success") {
          this.title = "success";
          this.message = "Your application has been cancelled";
          this.variant = "success";
          this.showNotification();
        } else {
          this.title = "Error";
          this.message = result;
          this.variant = "error";
          this.showNotification();
        }
      })
      .catch((error) => {
        this.title = "Error";
        this.message = error.body.message;
        this.variant = "error";
        this.showNotification();
      });
  }

  checkFieldsValidity() {
    const allValid = [
      ...this.template.querySelectorAll(
        "lightning-input, lightning-combobox,lightning-textarea"
      )
    ].reduce((validSoFar, inputCmp) => {
      inputCmp.reportValidity();
      return validSoFar && inputCmp.checkValidity();
    }, true);
    return allValid;
  }

  showNotification() {
    const evt = new ShowToastEvent({
      title: this.title,
      message: this.message,
      variant: this.variant
    });
    this.dispatchEvent(evt);
    this.handleCloseModel();
  }
}
