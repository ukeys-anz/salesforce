import { LightningElement, api, wire, track } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import responseStatusDependentValues from "@salesforce/apex/CCRMLogAResponseController.responseStatusDependentValues";
import createResponseRecord from "@salesforce/apex/CCRMLogAResponseController.createResponseRecord";
import getLeadResponseGuidanceMapping from "@salesforce/apex/CCRMLogAResponseController.getLeadResponseGuidanceMapping";
import {
  updateRecord,
  getRecord,
  getRecordNotifyChange
} from "lightning/uiRecordApi";
import { getPicklistValues } from "lightning/uiObjectInfoApi";
import LEAD_LEAD_QUALITY from "@salesforce/schema/Lead.Lead_Quality__c";
import STATUS from "@salesforce/schema/Lead.Status";
import RECORDTYPE_DEVELOPERNAME from "@salesforce/schema/Lead.RecordType.DeveloperName";
import TASK_LEAD_QUALITY from "@salesforce/schema/Task.Lead_Quality__c";
// Util methods
import { handleErrors } from "c/utils";
// import labels
import CCRM_SelectResponsePrompt from "@salesforce/label/c.CCRM_SelectResponsePrompt";
import CCRM_ConversationGuideHeading from "@salesforce/label/c.CCRM_ConversationGuideHeading";
import CCRM_WhatHappensNextHeading from "@salesforce/label/c.CCRM_WhatHappensNextHeading";
import CCRM_ConversationGuideBody from "@salesforce/label/c.CCRM_ConversationGuideBody";
import ML_ConversationGuideBody from "@salesforce/label/c.ML_ConversationGuideBody";
import ML_MaxExpiryDateErrorMessage from "@salesforce/label/c.ML_MaxExpiryDateErrorMessage";
import ML_LeadQualityRequiredValues from "@salesforce/label/c.ML_LeadQualityRequiredValues";
import ML_LeadResponsesToShowFollowUpDate from "@salesforce/label/c.ML_LeadResponseToShowFollowUpDate";
import CCRM_LeadQualityRequiredValues from "@salesforce/label/c.CCRM_LeadQualityRequiredValues";

const MOBILE_LENDING_RECORDTYPE = "MLCRM_Lead";
const CCRM_RECORDTYPE = "CCRM_Lead";

export default class LeadLogAResponse extends LightningElement {
  @api recordId;
  @api recordTypeId;
  @track hasError = false;
  @track hasNoError = true;
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
  recordTypeName;
  showLeadQuality = true;
  ML_LeadResponseToShowFollowUpDate = ML_LeadResponsesToShowFollowUpDate; //["Contact Attempted", "Call Back"];
  isMLRecordType = false;
  selectedResponseStatusValue;
  selectedOutcomeResponseValue;
  selectedLeadQualityValue;
  leadStatus;
  leadRecord;
  resetValidationError = false;
  isLoading = false;
  minFollowUpDate = new Date().toISOString();
  displayDueDate = false;
  autoCreateActivities = false;
  leadResponseGuidanceMapping;
  conversationGuidanceURL = "";
  label = {
    CCRM_SelectResponsePrompt,
    CCRM_ConversationGuideHeading,
    CCRM_WhatHappensNextHeading,
    CCRM_ConversationGuideBody,
    ML_ConversationGuideBody,
    ML_MaxExpiryDateErrorMessage,
    ML_LeadQualityRequiredValues,
    CCRM_LeadQualityRequiredValues
  };

  setConversationGuidanceUrl() {
    getLeadResponseGuidanceMapping({
      leadId: this.recordId
    })
      .then((result) => {
        this.leadResponseGuidanceMapping = JSON.parse(result);
        if (this.recordTypeName === MOBILE_LENDING_RECORDTYPE) {
          this.conversationGuidanceURL =
            this.label.ML_ConversationGuideBody.replace(
              "Max",
              "<a href=" +
                this.leadResponseGuidanceMapping.customerConversationGuideLink +
                ' target="_blank">Max</a>'
            );
        } else if (this.recordTypeName === CCRM_RECORDTYPE) {
          this.conversationGuidanceURL = this.label.CCRM_ConversationGuideBody;
          if (
            this.leadResponseGuidanceMapping.campaignLeadsLink !== undefined &&
            this.leadResponseGuidanceMapping.campaignLeadsLink !== ""
          ) {
            this.conversationGuidanceURL =
              this.label.CCRM_ConversationGuideBody.replace(
                "Campaign Leads",
                "<a href=" +
                  this.leadResponseGuidanceMapping.campaignLeadsLink +
                  ' target="_blank">Campaign Leads</a>'
              ).replace(
                "Customer Conversation Guides.",
                "<a href=" +
                  this.leadResponseGuidanceMapping
                    .customerConversationGuideLink +
                  ' target="_blank">Customer Conversation Guides.</a>'
              );
          }
        }
      })
      .catch((error) => {
        this.isLoading = false;
        this.handleError(error);
        this.resetFields();
      });
  }
  @wire(getRecord, {
    recordId: "$recordId",
    fields: [LEAD_LEAD_QUALITY, STATUS, RECORDTYPE_DEVELOPERNAME]
  })
  getLeadRecord({ data, error }) {
    if (data) {
      this.recordTypeName =
        data.fields.RecordType.value.fields.DeveloperName.value;
      if (this.recordTypeName === MOBILE_LENDING_RECORDTYPE) {
        this.isMLRecordType = true;
        this.showLeadQuality = false; // if Lead RT is ML then do not show Lead Quality by default
      }
      this.leadRecord = data;
      this.selectedLeadQualityValue = data.fields.Lead_Quality__c.value;
      this.leadStatus = data.fields.Status.value;
      this.setConversationGuidanceUrl();
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
    let isRequired;
    if (this.recordTypeName === MOBILE_LENDING_RECORDTYPE) {
      isRequired = this.label.ML_LeadQualityRequiredValues.includes(
        this.selectedResponseStatusValue
      );
    } else if (this.recordTypeName === CCRM_RECORDTYPE) {
      isRequired = this.label.CCRM_LeadQualityRequiredValues.includes(
        this.selectedResponseStatusValue
      );
    }
    return isRequired;
  }

  get isFollowUpDateRequired() {
    return (
      !this.followUpDateDisable &&
      ((this.followUpDateState === "M" && !this.displayDueDate) ||
        this.isMLRecordType) // CC-7618 If FollowUpDate is disabled and RT is ML then make return false
    );
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
      this.displayDueDate = false;
      this.outcomeReasonOptions = undefined;
      this.whatHappensNextInfo = "";
      this.showWhatHappensNext = false;
      this.selectedResponseStatusValue = event.detail.value;
      // CC-7618 update values to show/hide Lead Quality and FollowUp date
      this.showHideQualityAndFolloupDateForML(this.selectedResponseStatusValue);
      if (this.dependentPicklistWrapper) {
        for (key in this.dependentPicklistWrapper) {
          if (this.selectedResponseStatusValue === key) {
            for (subkey in this.dependentPicklistWrapper[key]) {
              if (
                this.dependentPicklistWrapper[key][subkey].Outcome_Reason__c
              ) {
                options.push({
                  label:
                    this.dependentPicklistWrapper[key][subkey]
                      .Outcome_Reason__c,
                  value:
                    this.dependentPicklistWrapper[key][subkey].Outcome_Reason__c
                });
                this.outcomeReasonDetailMap.push({
                  OutcomeReasonKey:
                    this.dependentPicklistWrapper[key][subkey]
                      .Outcome_Reason__c,
                  FollowUpState:
                    this.dependentPicklistWrapper[key][subkey]
                      .Follow_Up_State__c,
                  ResponseTypeId: this.dependentPicklistWrapper[key][subkey].Id,
                  CreateActivities:
                    this.dependentPicklistWrapper[key][subkey]
                      .Create_To_Do_Activities__c,
                  CreateOpportunity:
                    this.dependentPicklistWrapper[key][subkey]
                      .Create_Opportunity__c
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
    var whatsNextKey;
    var createOpportunity;
    var currentFollowupDate = this.selectedFollowUpDateValue;
    try {
      this.selectedOutcomeResponseValue = undefined;
      this.selectedOutcomeResponseValue = event.detail.value;
      if (this.outcomeReasonDetailMap) {
        for (key in this.outcomeReasonDetailMap) {
          if (
            this.outcomeReasonDetailMap[key].OutcomeReasonKey ===
            this.selectedOutcomeResponseValue
          ) {
            createOpportunity =
              this.outcomeReasonDetailMap[key].CreateOpportunity !==
                undefined &&
              this.outcomeReasonDetailMap[key].CreateOpportunity !== null
                ? this.outcomeReasonDetailMap[key].CreateOpportunity
                : "";
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
            this.followUpDateState =
              this.outcomeReasonDetailMap[key].FollowUpState;
            this.selectedResponseTypeId =
              this.outcomeReasonDetailMap[key].ResponseTypeId;
            whatsNextKey =
              this.selectedResponseStatusValue +
              (this.recordTypeName === MOBILE_LENDING_RECORDTYPE
                ? ""
                : createOpportunity);
            if (
              this.leadResponseGuidanceMapping
                .mapOfLeadStatusReasonAndNextDetail[whatsNextKey] !==
                undefined &&
              this.leadResponseGuidanceMapping
                .mapOfLeadStatusReasonAndNextDetail[whatsNextKey]
            ) {
              this.whatHappensNextInfo =
                this.leadResponseGuidanceMapping.mapOfLeadStatusReasonAndNextDetail[
                  whatsNextKey
                ];
              if (this.whatHappensNextInfo === "") {
                this.showWhatHappensNext = false;
                return;
              }
              if (this.whatHappensNextInfo.includes(this.leadStatus + ":")) {
                this.whatHappensNextInfo = this.whatHappensNextInfo.split(
                  this.leadStatus + ":"
                )[1];
                this.whatHappensNextInfo = this.whatHappensNextInfo.includes(
                  ";"
                )
                  ? this.whatHappensNextInfo.split(";")[0]
                  : this.whatHappensNextInfo;
              }
              this.showWhatHappensNext = true;
            }
          }
        }
      }
      if (this.isMLRecordType) {
        // IF ML RT -> Update followUpDateDisable based on value of Response Status, irrespective of value of Outcome Reason
        this.followUpDateDisable =
          !this.ML_LeadResponseToShowFollowUpDate.includes(
            this.selectedResponseStatusValue
          );
        // if followUpDate is enabled then restore selected Follow up date
        if (!this.followUpDateDisable) {
          this.selectedFollowUpDateValue = currentFollowupDate;
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
      // validate leadQuality only when it is displayed
      this.showLeadQuality
      ? this.template.querySelector(".leadQuality").reportValidity()
      : true &&
          this.template.querySelector(".outcomeReason").reportValidity() &&
          this.template.querySelector(".comment").reportValidity() &&
          this.autoCreateActivities &&
          this.selectedResponseStatusValue === "Accepted"
        ? this.template.querySelector(".dueDate").reportValidity()
        : this.template.querySelector(".followUpDate") != null
          ? this.template.querySelector(".followUpDate").reportValidity()
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
          // CC-1057 to set the default value of expiry date for Manually created ML Lead
          let strResponse = JSON.parse(result);
          if (strResponse.responseData.includes("Warning Message:")) {
            this.sendToastMessage("warning", result, "dismissable");
          } else if (strResponse.responseData.includes("Error Message:")) {
            this.handleError(result);
          } else {
            if (strResponse.isCampaignEndDateMax) {
              this.sendToastMessage(
                "info",
                this.label.ML_MaxExpiryDateErrorMessage,
                "sticky"
              );
            }
            this.sendToastMessage(
              "success",
              "Response Logged Successfully.",
              "dismissable"
            );
            updateRecord({ fields: { Id: this.recordId } });
          }
          getRecordNotifyChange([{ recordId: this.recordId }]);
          this.dispatchEvent(new CustomEvent("handleSaveRecord"));
          this.closeQuickAction();
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

  handleError(error) {
    var handledError = handleErrors(error);
    this.sendToastMessage("error", handledError, "dismissable");
    this.resetFields();
  }

  sendToastMessage(varriant, message, mode) {
    let ERRORTYPE = {
      error: "ERROR!",
      warning: "WARNING!",
      success: "SUCCESS!",
      info: "Info"
    };
    const toastEvent = new ShowToastEvent({
      title: ERRORTYPE[varriant],
      message: message,
      variant: varriant,
      mode: mode
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

  closeQuickAction() {
    this.dispatchEvent(new CustomEvent("closemodal"));
  }

  renderedCallback() {
    if (this.resetValidationError) {
      this.resetValidationError = false;
    }
  }
  get enableComboBox() {
    // If this.resetValidationError is false, return a value of true
    return !this.resetValidationError;
  }
  get enableFollowUpDateComboBox() {
    // If this.followUpDateDisable is false, return a value of true
    return !this.followUpDateDisable;
  }

  // Set values to show/hide LeadQuality and Followup date
  showHideQualityAndFolloupDateForML(selectedResponseStatusValue) {
    // If record type is not ML then do nothing
    if (!this.isMLRecordType) {
      return;
    }
    // If select Response Status is in ML_LeadQualityRequiredValues then show leadQuality
    if (
      this.label.ML_LeadQualityRequiredValues.includes(
        selectedResponseStatusValue
      )
    ) {
      this.showLeadQuality = true;
    } else {
      this.showLeadQuality = false;
    }
    // If select Response Status is in ML_LeadResponseToShowFollowUpDate then show FollowUp date
    if (
      this.ML_LeadResponseToShowFollowUpDate.includes(
        selectedResponseStatusValue
      )
    ) {
      this.followUpDateDisable = false;
    } else {
      this.followUpDateDisable = true;
    }
  }
}
