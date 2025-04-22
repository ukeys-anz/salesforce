import { track, api } from "lwc";
import { handleErrors, showToast } from "c/utils";
import LightningModal from "lightning/modal";
import updateStatus from "@salesforce/apex/TrustMeCaseStatusPathController.updateStatus";

const APEX_ERRORS = {
  InsufficientAccessException:
    "You don't have the required permission to perform this action",
  ServerErrorException:
    "The server encountered an unexpected error. Please retry after some time.",
  DmlException: "Error occurred while updating case status.",
  Exception: "Error occurred while updating case status."
};

export default class TrustMeCaseStatusUpdateModal extends LightningModal {
  @api options;
  showSpinner = false;
  comments;
  isModalButtonDisable = false;
  primaryReasonOptions;
  secondaryReasonOptions;
  @track trustMeCase;

  connectedCallback() {
    this.trustMeCase = JSON.parse(JSON.stringify(this.options.caseData));
    this.currentStatus = this.options.caseData.Status;
    this.statusOptions = this.options.statusOptions;
    this.primaryFailedReasonFieldInfo =
      this.options.primaryFailedReasonFieldInfo;
    this.secondaryFailedReasonFieldInfo =
      this.options.secondaryFailedReasonFieldInfo;
  }

  get statusFailed() {
    this.calculatePrimaryAndSecondaryFailedReasonOptions(this.currentStatus);
    return this.trustMeCase.Status === "Failed";
  }

  get currentStatusIsClosed() {
    const selectedPicklistItem = this.options.statusOptions.find(
      (item) => item.value === this.trustMeCase.Status
    );
    return selectedPicklistItem && selectedPicklistItem.attributes.closed;
  }

  handleStatusChange(event) {
    this.calculatePrimaryAndSecondaryFailedReasonOptions(event.detail.value);
    this.trustMeCase.Status = event.detail.value;
  }

  calculatePrimaryAndSecondaryFailedReasonOptions(controllerValue) {
    if (controllerValue !== "Failed") {
      return;
    }
    const primaryKey =
      this.primaryFailedReasonFieldInfo?.controllerValues[controllerValue];
    this.primaryReasonOptions =
      this.primaryFailedReasonFieldInfo?.values.filter((opt) =>
        opt.validFor.includes(primaryKey)
      );

    const secondaryKey =
      this.secondaryFailedReasonFieldInfo?.controllerValues[controllerValue];
    this.secondaryReasonOptions =
      this.secondaryFailedReasonFieldInfo?.values.filter((opt) =>
        opt.validFor.includes(secondaryKey)
      );
  }

  isSelectionValid() {
    if (!this.currentStatusIsClosed) {
      return this.template.querySelector(".status").reportValidity();
    }
    return (
      this.template.querySelector(".status").reportValidity() &&
      this.template.querySelector(".commentsCls").reportValidity()
    );
  }

  primaryReasonChange(event) {
    this.trustMeCase.OnboardingVerificationFailedReason__c = event.detail.value;
    event.target.reportValidity();
    event.target.blur();
  }

  secondaryReasonChange(event) {
    this.trustMeCase.SecondaryVerificationFailedReason__c = event.detail.value;
  }

  commentsChange(event) {
    this.comments = event.detail.value;
    event.target.reportValidity();
  }

  handleHideModal() {
    this.close("canceled");
  }

  checkSelectionForFailed() {
    if (this.trustMeCase.Status !== "Failed") {
      return true;
    }
    let isValid = false;
    if (this.template.querySelector(".primaryFailedReasonCls")) {
      isValid = this.template
        .querySelector(".primaryFailedReasonCls")
        .reportValidity();
    }
    return isValid;
  }
  async handleUpdateStatus() {
    const isValid = this.isSelectionValid();
    const isValidForFailed = this.checkSelectionForFailed();
    if (!isValid) {
      return;
    }
    if (!isValidForFailed) {
      return;
    }

    if (this.currentStatus === this.trustMeCase.Status) {
      showToast(
        this,
        "Warning",
        "Case can't be updated with the same status. Please select a different status",
        "",
        "warning",
        ""
      );
      return;
    }
    if (this.trustMeCase.IsClosed) {
      showToast(
        this,
        "Error",
        "You are not allowed to change the status of a closed case.",
        "",
        "error",
        ""
      );
      return;
    }

    if (!this.currentStatusIsClosed) {
      showToast(
        this,
        "Error",
        "You're not allowed to change the status to - " +
          this.trustMeCase.Status,
        "",
        "error",
        ""
      );
      return;
    }
    this.isModalButtonDisable = true;
    this.showSpinner = true;

    try {
      await updateStatus({
        trustMeCase: this.trustMeCase,
        comments: this.comments
      });

      this.successScenario();
    } catch (error) {
      this.handleHideModal();
      let msg = APEX_ERRORS[error.body.message] ?? handleErrors(error);
      showToast(this, "Error", msg, "", "error", "");
    } finally {
      this.isModalButtonDisable = false;
      this.showSpinner = false;
    }
  }

  fireRefreshEvent() {
    this.dispatchEvent(
      new CustomEvent("refresh", {
        detail: {
          message: "refresh",
          status: this.trustMeCase.Status
        }
      })
    );
  }

  successScenario() {
    this.handleHideModal();
    showToast(
      this,
      "Success!",
      "Successfully updated status.",
      "",
      "success",
      ""
    );
    this.fireRefreshEvent();
  }
}
