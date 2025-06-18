import { LightningElement, track, api, wire } from "lwc";
import { CloseActionScreenEvent } from "lightning/actions";
import { showToast, handleErrorShowToast } from "c/utils"; // Importing the methods from Utils.js
import { updateRecord } from "lightning/uiRecordApi";
import { getRecord } from "lightning/uiRecordApi";
import LEAD_AUTONUMBER_FIELD from "@salesforce/schema/Lead.Lead_Auto_Number__c";
import ID_FIELD from "@salesforce/schema/Lead.Id";
import RECORDTYPEID_FIELD from "@salesforce/schema/Lead.RecordTypeId";
import LEADID_FIELD from "@salesforce/schema/Lead.Lead_Id__c";
import { getObjectInfo } from "lightning/uiObjectInfoApi";

export default class AcceptReferral extends LightningElement {
  @track selectedValue;
  @api recordId;
  CONSTANT = {
    HEADER_TEXT: "Select a record type for this lead.",
    CANCEL: "Cancel",
    SAVE: "Save"
  };
  isLoading;

  @wire(getObjectInfo, { objectApiName: "Lead" })
  leadObjectInfo;

  get recordTypeValues() {
    if (!this.leadObjectInfo.data) return [];
    return Object.values(this.leadObjectInfo.data.recordTypeInfos)
      .filter((rt) => rt.available && !rt.master && rt.name !== "Referral")
      .map((rt) => ({ label: rt.name, value: rt.recordTypeId }));
  }

  @wire(getRecord, {
    recordId: "$recordId",
    fields: [LEAD_AUTONUMBER_FIELD]
  })
  lead;

  handleChange(event) {
    this.selectedValue = event.detail.value;
  }

  handleCancel() {
    this.dispatchEvent(new CloseActionScreenEvent());
  }

  handleSave() {
    if (!this.selectedValue) {
      handleErrorShowToast(
        this,
        "Error",
        "",
        "Please select atleast one record type.",
        "dismissable"
      );
      return;
    }
    this.isLoading = true;
    const fields = {};
    fields[ID_FIELD.fieldApiName] = this.recordId;
    fields[RECORDTYPEID_FIELD.fieldApiName] = this.selectedValue;
    fields[LEADID_FIELD.fieldApiName] =
      this.lead.data.fields.Lead_Auto_Number__c.value;
    const recordInput = { fields };
    updateRecord(recordInput)
      .then(() => {
        showToast(
          this,
          "Success",
          "Record type changed successfully",
          "",
          "success",
          "dismissable"
        );
      })
      .catch((error) => {
        handleErrorShowToast(
          this,
          "Error",
          error,
          "Some error occurred while changing record type.",
          "dismissable"
        );
      })
      .finally(() => {
        this.isLoading = false;
        this.dispatchEvent(new CloseActionScreenEvent());
      });
  }
}
