import { LightningElement, wire, api } from "lwc";
import { CloseActionScreenEvent } from "lightning/actions";
import { getPicklistValues } from "lightning/uiObjectInfoApi";
import { getRecord, getFieldValue } from "lightning/uiRecordApi";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { getFocusedTabInfo, refreshTab } from "lightning/platformWorkspaceApi";
import ConfirmationMessage from "@salesforce/label/c.RLA_Cancellation_Confirmation_Message";
import cancelResidentialLoanApplication from "@salesforce/apex/ResidentialLoanApplicationActions.cancelResidentialLoanApplication";

import CANCELLATION_REASON from "@salesforce/schema/ResidentialLoanApplication.Cancellation_Reason__c";
import OCV_ID from "@salesforce/schema/ResidentialLoanApplication.Account.OCV_ID__c";
import RESIDENTIAL_LOAN_APPLICATION_NUMBER from "@salesforce/schema/ResidentialLoanApplication.ApplicationExtIdentifier";

export default class CancelResidentialLoanApplication extends LightningElement {
  @api recordId;
  value;
  otherReasonVisible = false;
  rlaRecordTypeId;
  options;
  mainWindow = true;
  rlaObject = {};
  loanApplicationNumber;
  ocvId;
  spinnerDisabled = true;

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
    let title;
    let message;
    let variant;
    this.spinnerDisabled = false;
    cancelResidentialLoanApplication({ rlaObject: this.rlaObject })
      .then((result) => {
        if (result === "success") {
          title = "Success";
          message = "The application was successfully withdrawn.";
          variant = "success";
          this.showNotificationAndRefreshTab(title, message, variant);
        } else {
          title = "Error";
          message =
            "The application could not be withdrawn. Please review and try again.";
          variant = "error";
          this.showNotificationAndRefreshTab(title, message, variant);
        }
      })
      .catch((error) => {
        title = "Error";
        message = error.body.message;
        variant = "error";
        this.showNotificationAndRefreshTab(title, message, variant);
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

  async showNotificationAndRefreshTab(title, message, variant) {
    const evt = new ShowToastEvent({
      title: title,
      message: message,
      variant: variant
    });
    this.dispatchEvent(evt);
    await this.refreshTab();
    this.handleCloseModel();
  }

  async refreshTab() {
    const { tabId } = await getFocusedTabInfo();
    await refreshTab(tabId, {
      includeAllSubtabs: false
    });
  }
}
