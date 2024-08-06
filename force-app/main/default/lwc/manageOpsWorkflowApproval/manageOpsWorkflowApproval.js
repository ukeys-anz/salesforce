import { api } from "lwc";
import LightningModal from "lightning/modal";
import updateCaseStatusOnboarding from "@salesforce/apex/ManageOpsWorkflowActionController.updateCaseStatusOnboarding";
import updateCaseStatusPinAndSelfie from "@salesforce/apex/ManageOpsWorkflowActionController.updateCaseStatusPinAndSelfie";
import { ShowToastEvent } from "lightning/platformShowToastEvent";

export default class ManageOpsWorkflowApproval extends LightningModal {
  statusValue;
  comments;
  @api options;
  title;
  message;
  variant;
  showSpinner = false;
  optionVal = [];
  showApproveEnrolledLabel = false;
  actionName;

  get onboardingWorkflow() {
    return this.options.parentComponent === "Onboarding";
  }

  connectedCallback() {
    if (this.onboardingWorkflow) {
      this.statusValue = "ID Ops: Daon OK";
      this.optionVal = [{ label: "ID Ops: Daon OK", value: "ID Ops: Daon OK" }];
      this.actionName = "OVERRIDE_GENERAL_APPROVE";
    } else if (this.options?.isPinWorkFlow && !this.onboardingWorkflow) {
      this.statusValue = "Closed - Approved";
      this.actionName = "OVERRIDE_GENERAL_APPROVE";
      this.optionVal = [
        { label: "Closed - Approved", value: "Closed - Approved" }
      ];
    } else {
      this.statusValue = "Closed - Approved & Re-enrolled";
      this.optionVal = [
        { label: "Closed - Approved", value: "Closed - Approved" },
        {
          label: "Closed - Approved & Re-enrolled",
          value: "Closed - Approved & Re-enrolled"
        }
      ];
    }
  }

  get approveLabelName() {
    if (this.statusValue === "Closed - Approved & Re-enrolled") {
      this.actionName = "OVERRIDE_SELFIE_APPROVE_ENROL_SELFIE";
      return "Approve & Re-enrol Selfie";
    } else if (!this.options?.isPinWorkFlow && !this.onboardingWorkflow) {
      this.actionName = "OVERRIDE_SELFIE_APPROVE";
    }
    return "Approve";
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
    if (this.statusValue === "Closed - Approved & Re-enrolled") {
      this.showApproveEnrolledLabel = true;
    } else {
      this.showApproveEnrolledLabel = false;
    }
  }
  approveRecord() {
    if (!this.comments) {
      let commentCmp = this.template.querySelector(".commentsCls");
      commentCmp.setCustomValidity("Comment is required");
      commentCmp.reportValidity();
      return;
    }
    this.showSpinner = true;
    let data = {
      case_id: this.options.caseId,
      case_comments: this.comments != null ? this.comments : "",
      workflow_id: this.options.workflowId,
      action: this.actionName
    };
    if (this.onboardingWorkflow) {
      this.updateCaseStatusOnboarding(data);
    } else {
      this.updateCaseStatusPinAndSelfie(data);
    }
  }

  updateCaseStatusPinAndSelfie(data) {
    updateCaseStatusPinAndSelfie({
      idValue: this.options.IdValue,
      manageOpsRequest: data,
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

  updateCaseStatusOnboarding(data) {
    updateCaseStatusOnboarding({
      idValue: this.options.IdValue,
      manageOpsRequest: data,
      cobId: this.options.cobId,
      status: this.statusValue,
      failedReason: ""
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

  fireRefreshEvent() {
    this.dispatchEvent(
      new CustomEvent("refresh", {
        detail: {
          message: "refresh"
        }
      })
    );
  }
}
