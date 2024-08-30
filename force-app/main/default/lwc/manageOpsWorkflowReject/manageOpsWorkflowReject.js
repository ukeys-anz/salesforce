import { api, wire } from "lwc";
import { getObjectInfo, getPicklistValues } from "lightning/uiObjectInfoApi";
import CASE_OBJECT from "@salesforce/schema/Case";
import FAILED_REASON_FIELD from "@salesforce/schema/Case.OnboardingVerificationFailedReason__c";
import LightningModal from "lightning/modal";
import updateCaseStatusOnboarding from "@salesforce/apex/ManageOpsWorkflowActionController.updateCaseStatusOnboarding";
import updateCaseStatusPinAndSelfie from "@salesforce/apex/ManageOpsWorkflowActionController.updateCaseStatusPinAndSelfie";
import { ShowToastEvent } from "lightning/platformShowToastEvent";

export default class ManageOpsWorkflowReject extends LightningModal {
  statusValue;
  comments;
  recordTypeId;
  failedReasonValue;
  failedReasonValues;
  reasonOptions = [];

  optionVal = [];
  showSpinner = false;
  actionName;

  @api options;

  @api caseId;
  @wire(getObjectInfo, { objectApiName: CASE_OBJECT })
  getObjectInfo(result) {
    if (result.data) {
      const rtis = result.data.recordTypeInfos;
      this.recordTypeId = Object.keys(rtis).find(
        (rti) => rtis[rti].name === "ID Ops Assistance"
      );
    }
  }

  @wire(getPicklistValues, {
    recordTypeId: "$recordTypeId",
    fieldApiName: FAILED_REASON_FIELD
  })
  failedReasonFieldInfo({ data }) {
    if (data) {
      try {
        this.failedReasonValues = data;
        let tempValue = "Failed";
        let key = this.failedReasonValues.controllerValues[tempValue];
        this.reasonOptions = this.failedReasonValues.values.filter((opt) =>
          opt.validFor.includes(key)
        );
      } catch (e) {
        console.log(e);
      }
    }
  }

  get onboardingWorkflow() {
    return this.options?.parentComponent === "Onboarding";
  }

  connectedCallback() {
    if (this.onboardingWorkflow) {
      this.actionName = "OVERRIDE_GENERAL_REJECT";
      this.statusValue = "Failed";
      this.optionVal = [
        { label: "Failed", value: "Failed" },
        { label: "Potential Fraud", value: "Potential Fraud" }
      ];
    } else if (this.options?.isPinHistoryCheck && !this.onboardingWorkflow) {
      this.actionName = "OVERRIDE_GENERAL_REJECT";
      this.statusValue = "PIN History Check Failed";
      this.optionVal = [
        { label: "PIN History Check Failed", value: "PIN History Check Failed" }
      ];
    } else if (this.options?.isPinWorkFlow && !this.onboardingWorkflow) {
      this.actionName = "OVERRIDE_GENERAL_REJECT";
      this.statusValue = "Closed - Selfie Not Matched";
      this.optionVal = [
        {
          label: "Closed - Selfie Not Matched",
          value: "Closed - Selfie Not Matched"
        }
      ];
    } else {
      this.actionName = "OVERRIDE_SELFIE_REJECT";
      this.statusValue = "Closed - Selfie Not Matched";
      this.optionVal = [
        {
          label: "Closed - Selfie Not Matched",
          value: "Closed - Selfie Not Matched"
        }
      ];
    }
  }

  commentsChange(event) {
    this.comments = event.detail.value;
    if (!this.comments) {
      this.template
        .querySelector(".commentsCls")
        .setCustomValidity("Comment is required");
    } else {
      this.template.querySelector(".commentsCls").setCustomValidity("");
    }
  }

  statusChange(event) {
    this.statusValue = event.detail.value;
  }

  reasonChange(event) {
    this.failedReasonValue = event.detail.value;
    if (!this.failedReasonValue) {
      this.template
        .querySelector(".failedReasonCls")
        .setCustomValidity("Onboarding Verification Failed Reason is required");
    } else {
      this.template.querySelector(".failedReasonCls").setCustomValidity("");
    }
  }

  get statusFailed() {
    return this.statusValue === "Failed";
  }

  get rejectLabelName() {
    if (this.statusValue === "Potential Fraud" && this.onboardingWorkflow) {
      return "Update Case";
    }
    return "Reject";
  }

  rejectRecord() {
    if (!this.comments) {
      let commentCmp = this.template.querySelector(".commentsCls");
      commentCmp.setCustomValidity("Comment is required");
      commentCmp.reportValidity();
      return;
    }
    this.showSpinner = true;
    let requestedPaylodAPI = {
      case_id: this.options?.caseId,
      case_comments: this.comments,
      workflow_id: this.options?.workflowId,
      action: this.actionName
    };
    if (this.onboardingWorkflow) {
      this.updateCaseStatusOnboarding(requestedPaylodAPI);
    } else {
      this.updateCaseStatusPinAndSelfie(requestedPaylodAPI);
    }
  }

  fireRefreshEvent() {
    this.dispatchEvent(
      new CustomEvent("refresh", {
        detail: {
          message: "refresh"
        }
      })
    );
  }
  updateCaseStatusPinAndSelfie(requestedPaylodAPI) {
    updateCaseStatusPinAndSelfie({
      idValue: this.options?.IdValue,
      manageOpsRequest: requestedPaylodAPI,
      status: this.statusValue
    })
      .then((result) => {
        this.showToast(result.status, result.responseMessage, result.status);
        this.fireRefreshEvent();
      })
      .catch(() => {
        this.showToast(
          "Error",
          "Error occurred while updating status.",
          "error"
        );
      })
      .finally(() => {
        this.showSpinner = false;
        this.close();
      });
  }

  updateCaseStatusOnboarding(requestedPaylodAPI) {
    if (this.statusValue === "Failed" && !this.failedReasonValue) {
      let failedReasonCmp = this.template.querySelector(".failedReasonCls");
      failedReasonCmp.setCustomValidity(
        "Onboarding Verification Failed Reason is required"
      );
      failedReasonCmp.reportValidity();
      this.showSpinner = false;
      return;
    }
    let requestedData = {
      idValue: this.options?.IdValue,
      cobId: this.options?.cobId,
      status: this.statusValue,
      failedReason: this.failedReasonValue
    };
    updateCaseStatusOnboarding({
      manageOpsRequest: requestedPaylodAPI,
      updateStatusPayloads: requestedData
    })
      .then((result) => {
        this.showToast(result.status, result.responseMessage, result.status);
        this.fireRefreshEvent();
      })
      .catch(() => {
        this.showToast(
          "Error",
          "Error occurred while updating status.",
          "error"
        );
      })
      .finally(() => {
        this.showSpinner = false;
        this.close();
      });
  }

  showToast(title, message, variant) {
    const event = new ShowToastEvent({
      title: title,
      message: message,
      variant: variant,
      mode: "dismissable"
    });
    this.dispatchEvent(event);
  }
}
