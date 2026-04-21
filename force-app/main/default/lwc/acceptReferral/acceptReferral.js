import { LightningElement, track, api, wire } from "lwc";
import { CloseActionScreenEvent } from "lightning/actions";
import { showToast, handleErrorShowToast } from "c/utils"; // Importing the methods from Utils.js
import { updateRecord } from "lightning/uiRecordApi";
import { getRecord } from "lightning/uiRecordApi";
import LEAD_AUTONUMBER_FIELD from "@salesforce/schema/Lead.Lead_Auto_Number__c";
import ID_FIELD from "@salesforce/schema/Lead.Id";
import RECORDTYPEID_FIELD from "@salesforce/schema/Lead.RecordTypeId";
import REFERRAL_ACK_DATE_FIELD from "@salesforce/schema/Lead.Referral_Acknowledged_Date__c";
import LEADID_FIELD from "@salesforce/schema/Lead.Lead_Id__c";
import { getObjectInfo } from "lightning/uiObjectInfoApi";
import checkCampaignMember from "@salesforce/apex/AcceptReferralController.checkCampaignMember";

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
    fields[REFERRAL_ACK_DATE_FIELD.fieldApiName] = new Date().toISOString();
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
        this.checkCampaignMember(this.recordId);
      })
      .catch((error) => {
        let errorMessage;
        if (error?.body?.output?.errors?.length > 0) {
          errorMessage = error.body.output.errors[0].message;
        }
        showToast(
          this,
          "Error",
          errorMessage || "Some error occurred while changing record type.",
          "",
          "error",
          "dismissable"
        );
      })
      .finally(() => {
        this.isLoading = false;
        this.dispatchEvent(new CloseActionScreenEvent());
      });
  }
  checkCampaignMember(leadId) {
    checkCampaignMember({ leadId: leadId })
      .then(() => {})
      .catch((error) => {
        if (error.body) {
          handleErrorShowToast(
            this,
            "Error",
            error,
            "Campaign Member Creation is not successful.",
            "dismissable"
          );
        }
      });
  }
}
