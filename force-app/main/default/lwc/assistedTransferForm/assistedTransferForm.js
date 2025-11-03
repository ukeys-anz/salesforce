import { LightningElement, api, wire } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { getPicklistValues } from "lightning/uiObjectInfoApi";
import TRANSFER_REASON from "@salesforce/schema/Case.Transfer_Reason__c";
import { getRecord } from "lightning/uiRecordApi";

const fields = ["Case.RecordTypeId"];
export default class AssistedTransferForm extends LightningElement {
  @api recordId;
  selectedRow;
  selectedAccount = "";
  amountToFields = {
    toAccount: "",
    toAccountNumber: "",
    toAccountBsb: "",
    toAccountAmount: "",
    transferReason: ""
  };
  isValid = true;
  recordTypeId;
  transferReasonOptions;

  @api
  set selectedRows(newValue) {
    this.selectedRow = newValue;
    this.selectedAccount =
      this.selectedRow?.Product_Name__c +
      " Account(" +
      this.selectedRow?.FinServ__FinancialAccountNumber__c +
      ")";
  }

  get selectedRows() {
    return this.selectedRow;
  }

  @wire(getRecord, {
    recordId: "$recordId",
    fields
  })
  caseRecord({ data }) {
    if (data) {
      this.recordTypeId = data.recordTypeId;
    }
  }

  @wire(getPicklistValues, {
    recordTypeId: "$recordTypeId",
    fieldApiName: TRANSFER_REASON
  })
  wiredPicklistTransferReason({ data }) {
    if (data) {
      const picklistValues = data.values.map((object) => {
        return { label: object.label, value: object.value };
      });
      this.transferReasonOptions = picklistValues;
    }
  }

  @api
  updateData() {
    this.isValid = this.validateForm();
    if (this.isValid) {
      let toAmount = this.template.querySelector(
        '[data-prop-name="amountToBeTransferred"]'
      ).value;
      let fromAmount = this.template.querySelector(
        '[data-id="amountFrom"]'
      ).value;

      if (parseFloat(fromAmount) !== parseFloat(toAmount)) {
        this.showToast("Amount From and Amount To must be equal!");
      } else {
        const inputFields = this.template.querySelectorAll(
          '[data-id="amountTo"]'
        );
        inputFields.forEach((field) => {
          this.amountToFields[field.name] = field.value;
        });
        this.dispatchEvent(
          new CustomEvent("updatefinancialaccount", {
            detail: {
              amountTo: this.amountToFields
            }
          })
        );
      }
    }
  }

  validateForm() {
    this.isValid = true;
    let inputFields = [];
    inputFields.push(
      ...this.template.querySelectorAll('[data-id="amountTo"]'),
      this.template.querySelector('[data-id="amountFrom"]')
    );
    inputFields.forEach((input) => {
      if (!input.value) {
        input.reportValidity();
        this.isValid = false;
      }
    });
    return this.isValid;
  }

  showToast(message) {
    this.dispatchEvent(
      new ShowToastEvent({
        title: "Validation Error",
        message: message,
        variant: "error"
      })
    );
  }
}
