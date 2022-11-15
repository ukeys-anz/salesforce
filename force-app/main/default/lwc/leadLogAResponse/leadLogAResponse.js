import { LightningElement, api, wire, track } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import responseStatusDependentValues from "@salesforce/apex/CCRMLogAResponseController.responseStatusDependentValues";
import createResponseRecord from "@salesforce/apex/CCRMLogAResponseController.createResponseRecord";
import { updateRecord, getRecord } from "lightning/uiRecordApi";
import { getPicklistValues } from "lightning/uiObjectInfoApi";
import LEAD_LEAD_QUALITY from "@salesforce/schema/Lead.Lead_Quality__c";
import TASK_LEAD_QUALITY from "@salesforce/schema/Task.Lead_Quality__c";
// Util methods
import { handleErrors } from "c/utils";

export default class LeadLogAResponse extends LightningElement {
  @api recordId;
  @api recordTypeId;
  @track hasError = false;
  @track errorMessage;
  @track dependentPicklistWrapper;
  @track outcomeReasonDetailMap = [];
  @track responseStatusOptions;
  @track outcomeReasonOptions;
  @track selectedResponseTypeId;
  @track selectedFollowUpDateValue;
  @track selectedDueDateValue;
  @track followUpDateDisable = true;
  @track followUpDateState;
  @track commentValue;
  selectedResponseStatusValue;
  selectedOutcomeResponseValue;
  selectedLeadQualityValue;
  leadRecord;
  resetValidationError = false;
  isLoading = false;
  minFollowUpDate = new Date().toISOString();
  displayDueDate = false;
  autoCreateActivities = false;

  @wire(getRecord, { recordId: "$recordId", fields: [LEAD_LEAD_QUALITY] })
  getLeadRecord({ data, error }) {
    if (data) {
      this.leadRecord = data;
      this.selectedLeadQualityValue = data.fields.Lead_Quality__c.value;
    }
    if (error) {
      this.handleError(error);
    }
  }
  @wire(getPicklistValues, {
    recordTypeId: "012000000000000AAA",
    fieldApiName: TASK_LEAD_QUALITY
  })
  leadQualityWireResponse;

  @wire(responseStatusDependentValues, { leadRecordId: "$recordId" })
  responseData({ error, data }) {
    var key;
    let options = [];
    if (data) {
      if (!this.isEmptyObject(data)) {
        for (key in JSON.parse(data)) {
          if (key) {
            options.push({ label: key, value: key });
          }
        }
        this.dependentPicklistWrapper = JSON.parse(data);
        this.responseStatusOptions = options;
        this.outcomeReasonOptions = undefined;
      } else {
        error =
          "Response cannot be logged for this Lead as Campaign detail or Response Type is not available.";
        this.handleError(error);
      }
    } else if (error) {
      this.handleError(error);
    }
  }

  get leadQualityOptions() {
    return this.leadQualityWireResponse.data
      ? this.leadQualityWireResponse.data.values
      : [];
  }

  get isDisable() {
    return !(
      this.selectedResponseStatusValue &&
      this.selectedOutcomeResponseValue &&
      (!this.isLeadQualityRequired || this.selectedLeadQualityValue) &&
      (!this.isFollowUpDateRequired ||
        (this.selectedFollowUpDateValue &&
          new Date(this.selectedFollowUpDateValue) > new Date()))
    );
  }

  get isLeadQualityRequired() {
    return [
      "Accepted",
      "Customer Declined",
      "Customer Not Contacted",
      "Referral Made"
    ].includes(this.selectedResponseStatusValue);
  }

  get isLeadQualityDisabled() {
    return !this.isLeadQualityRequired;
  }

  get isFollowUpDateRequired() {
    return !this.followUpDateDisable && this.followUpDateState === "M";
  }

  handleLeadQualityChange(e) {
    this.selectedLeadQualityValue = e.detail.value;
  }

  handleResponseStatusChange(event) {
    var key;
    var subkey;

    try {
      let options = [];
      this.resetValidation();
      this.resetLeadQuality();
      this.selectedOutcomeResponseValue = undefined;
      this.selectedFollowUpDateValue = undefined;
      this.selectedDueDateValue = undefined;
      this.followUpDateDisable = true;
      this.outcomeReasonOptions = undefined;
      this.selectedResponseStatusValue = event.detail.value;
      if (this.dependentPicklistWrapper) {
        for (key in this.dependentPicklistWrapper) {
          if (this.selectedResponseStatusValue === key) {
            for (subkey in this.dependentPicklistWrapper[key]) {
              if (
                this.dependentPicklistWrapper[key][subkey].Outcome_Reason__c
              ) {
                options.push({
                  label: this.dependentPicklistWrapper[key][subkey]
                    .Outcome_Reason__c,
                  value: this.dependentPicklistWrapper[key][subkey]
                    .Outcome_Reason__c
                });
                this.outcomeReasonDetailMap.push({
                  OutcomeReasonKey: this.dependentPicklistWrapper[key][subkey]
                    .Outcome_Reason__c,
                  FollowUpState: this.dependentPicklistWrapper[key][subkey]
                    .Follow_Up_State__c,
                  ResponseTypeId: this.dependentPicklistWrapper[key][subkey].Id,
                  CreateActivities: this.dependentPicklistWrapper[key][subkey]
                    .Create_To_Do_Activities__c
                });
              }
            }
            break;
          }
        }
        this.outcomeReasonOptions = options;
      }
    } catch (error) {
      this.handleError(error);
    }
  }

  handleOutcomeResponseChange(event) {
    var key;

    try {
      this.selectedOutcomeResponseValue = undefined;
      this.selectedOutcomeResponseValue = event.detail.value;
      if (this.outcomeReasonDetailMap) {
        for (key in this.outcomeReasonDetailMap) {
          if (
            this.outcomeReasonDetailMap[key].OutcomeReasonKey ===
            this.selectedOutcomeResponseValue
          ) {
            if (this.outcomeReasonDetailMap[key].FollowUpState === "R") {
              this.followUpDateDisable = true;
              this.selectedFollowUpDateValue = undefined;
            } else {
              this.followUpDateDisable = false;
              this.selectedFollowUpDateValue = undefined;
            }
            if (
              this.outcomeReasonDetailMap[key].CreateActivities &&
              this.selectedResponseStatusValue === "Accepted"
            ) {
              this.displayDueDate = true;
              this.followUpDateDisable = true;
              this.autoCreateActivities = true;
            } else {
              this.displayDueDate = false;
              this.autoCreateActivities = false;
            }
            this.followUpDateState = this.outcomeReasonDetailMap[
              key
            ].FollowUpState;
            this.selectedResponseTypeId = this.outcomeReasonDetailMap[
              key
            ].ResponseTypeId;
          }
        }
      }
    } catch (error) {
      this.handleError(error);
    }
  }

  handleFollowUpDateChange(event) {
    this.selectedFollowUpDateValue = event.detail.value;
    this.validateRecord();
  }

  handleDueDateChange(event) {
    this.selectedDueDateValue = event.detail.value;
    this.validateRecord();
  }

  handleCommentChange(event) {
    this.commentValue = event.detail.value;
  }

  validateRecord() {
    return this.template.querySelector(".responseStatus").reportValidity() &&
      this.template.querySelector(".leadQuality").reportValidity() &&
      this.template.querySelector(".outcomeReason").reportValidity() &&
      this.template.querySelector(".comment").reportValidity() &&
      this.template.querySelector(".followUpDate").reportValidity() &&
      this.autoCreateActivities
      ? this.template.querySelector(".dueDate").reportValidity()
      : true;
  }

  submitResponse() {
    if (this.validateRecord()) {
      const leadResponseWrapperValue = {
        responseStatus: this.selectedResponseStatusValue,
        leadQuality: this.selectedLeadQualityValue,
        outcomeReason: this.selectedOutcomeResponseValue,
        followUpDate: this.selectedFollowUpDateValue,
        dueDate: this.selectedDueDateValue,
        autoCreateActivities: this.autoCreateActivities,
        commentVal: this.commentValue,
        leadId: this.recordId,
        responseTypeValue: this.selectedResponseTypeId
      };
      this.isLoading = true;
      createResponseRecord({
        leadRespString: JSON.stringify(leadResponseWrapperValue)
      })
        .then((result) => {
          this.isLoading = false;
          if (result.includes("Warning Message:")) {
            this.sendToastMessage("warning", result);
          } else if (result.includes("Error Message:")) {
            this.handleError(result);
          } else {
            this.sendToastMessage("success", "Response Logged Successfully.");
            updateRecord({ fields: { Id: this.recordId } });
          }
          this.resetFields();
        })
        .catch((error) => {
          this.isLoading = false;
          this.handleError(error);
          this.resetFields();
        });
    }
  }

  resetFields() {
    this.selectedOutcomeResponseValue = undefined;
    this.selectedResponseStatusValue = undefined;
    this.selectedFollowUpDateValue = undefined;
    this.commentValue = undefined;
    this.followUpDateDisable = true;
    if (this.autoCreateActivities) {
      this.selectedDueDateValue = undefined;
    }
    this.resetLeadQuality();
  }

  handleCancel() {
    this.resetFields();
  }

  handleError(error) {
    var handledError = handleErrors(error);
    this.sendToastMessage("error", handledError);
    this.resetFields();
  }

  sendToastMessage(varriant, message) {
    let ERRORTYPE = {
      error: "ERROR!",
      warning: "WARNING!",
      success: "SUCCESS!"
    };
    const toastEvent = new ShowToastEvent({
      title: ERRORTYPE[varriant],
      message: message,
      variant: varriant
    });
    this.dispatchEvent(toastEvent);
  }

  isEmptyObject(data) {
    return JSON.stringify(data) === '"{}"';
  }

  resetValidation() {
    this.resetValidationError = true;
  }

  resetLeadQuality() {
    this.selectedLeadQualityValue = this.leadRecord
      ? this.leadRecord.fields.Lead_Quality__c.value
      : null;
  }

  renderedCallback() {
    if (this.resetValidationError) {
      this.resetValidationError = false;
    }
  }
}
