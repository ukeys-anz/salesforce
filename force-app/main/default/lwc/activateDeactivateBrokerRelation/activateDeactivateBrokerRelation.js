import { LightningElement, api, wire } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { getRecord, updateRecord } from "lightning/uiRecordApi";
import deactivationSuccessMsgBS from "@salesforce/label/c.Broker_Set_Deactivation_Success_Message";
import activationSuccessMsgBS from "@salesforce/label/c.Broker_Set_activation_Success_Message";
import deactivationSuccessMsgOG from "@salesforce/label/c.Office_Group_Deactivation_Success_Message";
import activationSuccessMsgOG from "@salesforce/label/c.Office_Group_Activation_Success_Message";
const FIELDS = [
  "Broker_Relation__c.Name",
  "Broker_Relation__c.IsActive__c",
  "Broker_Relation__c.RecordType.DeveloperName"
];
const ERROR_VARIANT = "Error";
const ERROR_TITLE = "Error Occurred";
const SUCCESS_VARIANT = "Success";
const SUCCESS_TITLE = "Success";

export default class activateDeactivateBrokerRelation extends LightningElement {
  @api recordId;
  newIsActiveValue;
  recordType;
  showSpinner = false;

  @wire(getRecord, { recordId: "$recordId", fields: FIELDS })
  wiredBrokerRelation({ data }) {
    if (data) {
      this.newIsActiveValue = data.fields.IsActive__c.value ? false : true;
      this.recordType = data.fields.RecordType.value.fields.DeveloperName.value;
    }
  }

  @api invoke() {
    this.updateBrokerRelation();
  }

  updateBrokerRelation() {
    this.showSpinner = true;
    const fields = {
      Id: this.recordId,
      IsActive__c: this.newIsActiveValue
    };
    const recordInput = { fields };
    updateRecord(recordInput)
      .then(() => {
        this.showToast(
          SUCCESS_TITLE,
          this.getSuccessMessage(),
          SUCCESS_VARIANT
        );
      })
      .catch((error) => {
        this.showToast(
          ERROR_TITLE,
          error.body.output.errors[0].message,
          ERROR_VARIANT
        );
      })
      .finally(() => {
        this.showSpinner = false;
      });
  }

  getSuccessMessage() {
    let successMessage = "";
    if (this.recordType === "Office_Group") {
      successMessage = this.newIsActiveValue
        ? activationSuccessMsgOG
        : deactivationSuccessMsgOG;
    } else {
      successMessage = this.newIsActiveValue
        ? activationSuccessMsgBS
        : deactivationSuccessMsgBS;
    }
    return successMessage;
  }

  showToast(title, message, variant) {
    const event = new ShowToastEvent({
      title,
      message,
      variant
    });
    this.dispatchEvent(event);
  }
}
