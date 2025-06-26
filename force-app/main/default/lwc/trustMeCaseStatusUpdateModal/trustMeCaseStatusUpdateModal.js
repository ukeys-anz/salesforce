import { track, api } from "lwc";
import { handleErrors } from "c/utils";
import { notifyRecordUpdateAvailable } from "lightning/uiRecordApi";
import LightningModal from "lightning/modal";
import updateStatus from "@salesforce/apex/TrustMeCaseStatusPathController.updateStatus";
import updateStatusAndOwner from "@salesforce/apex/TrustMeCaseStatusPathController.updateStatusAndOwnerOfCase";
import isFraudXAgent from "@salesforce/customPermission/ReKYCStatusUpdateForFraudAgents";
import { SimpleToast } from "c/utils";
import { refreshApex } from "@salesforce/apex";

const APEX_ERRORS = {
  InsufficientAccessException:
    "You don't have the required permission to perform this action",
  ServerErrorException:
    "The server encountered an unexpected error. Please retry after some time.",
  DmlException: "Error occurred while updating case status.",
  Exception: "Error occurred while updating case status."
};
const fraudStatuses = ["Fraud Confirmed", "Closed - No Fraud"];
const reKYCOpenStatuses = ["Rectify Defect", "Refer to Fraud"];

export default class TrustMeCaseStatusUpdateModal extends LightningModal {
  @api options;
  showSpinner = false;
  comments;
  isModalButtonDisable = false;
  primaryReasonOptions;
  secondaryReasonOptions;
  @track trustMeCase;
  checksList;
  toast = new SimpleToast(this);

  connectedCallback() {
    this.trustMeCase = JSON.parse(JSON.stringify(this.options.caseData));
    this.currentStatus = this.options.caseData.Status;
    this.statusOptions = this.options.statusOptions;
    this.primaryFailedReasonFieldInfo =
      this.options.primaryFailedReasonFieldInfo;
    this.secondaryFailedReasonFieldInfo =
      this.options.secondaryFailedReasonFieldInfo;
    this.checksList = [
      this.trustMeCase.Fraud_Customer_Details__c,
      this.trustMeCase.Fraud_MiddleNameCheck__c,
      this.trustMeCase.Fraud_Selfie_Comparison_Match__c,
      this.trustMeCase.Fraud_Address_Valid__c,
      this.trustMeCase.Fraud_ID_Legible__c,
      this.trustMeCase.Fraud_ID_Not_Picture__c,
      this.trustMeCase.Fraud_Customer_Photo_Modified__c,
      this.trustMeCase.Fraud_Security_Features__c
    ];
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
      this.toast.warning(
        "Case can't be updated with the same status. Please select a different status"
      );
      return;
    }
    if (this.trustMeCase.IsClosed) {
      this.toast.error(
        "You are not allowed to change the status of a closed case."
      );
      return;
    }
    if (fraudStatuses.includes(this.trustMeCase.Status) && !isFraudXAgent) {
      this.toast.error(
        "Only Fraud Agents can mark a ReKYC QA Case status to " +
          this.trustMeCase.Status
      );
      return;
    }
    if (
      !this.currentStatusIsClosed &&
      reKYCOpenStatuses.includes(this.trustMeCase.Status)
    ) {
      this.showSpinner = true;
      await updateStatusAndOwner({
        recordId: this.trustMeCase.Id,
        statusValue: this.trustMeCase.Status
      })
        .then(() => {
          this.toast.success("Successfully updated status.");
          notifyRecordUpdateAvailable([{ recordId: this.trustMeCase.Id }]);
          refreshApex(this.trustMeCase.Id);
        })
        .catch((error) => {
          this.toast.error(error.body.message);
        })
        .finally(() => {
          this.showSpinner = false;
          this.handleHideModal();
        });
      return;
    }

    if (
      this.trustMeCase.Status === "No Defect" &&
      this.checksList.includes("No")
    ) {
      this.toast.error(
        "You can only mark the case as 'No Defect' if all the checks are passed"
      );
      return;
    }

    if (
      (this.trustMeCase.Status === "Defect Identified" ||
        this.trustMeCase.Status === "Fraud Suspected") &&
      !this.checksList.includes("No")
    ) {
      this.toast.error(
        "Atleast one check should be marked as 'No' to update the status to 'Defect Identified/Fraud Suspected'"
      );
      return;
    }
    this.setAllNullChecksToYes();
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
      this.toast.error(msg);
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
    this.toast.success("Successfully updated status.");
    this.fireRefreshEvent();
  }

  setAllNullChecksToYes() {
    this.trustMeCase.Fraud_Customer_Details__c ??= "Yes";
    this.trustMeCase.Fraud_MiddleNameCheck__c ??= "Yes";
    this.trustMeCase.Fraud_Selfie_Comparison_Match__c ??= "Yes";
    this.trustMeCase.Fraud_Address_Valid__c ??= "Yes";
    this.trustMeCase.Fraud_ID_Legible__c ??= "Yes";
    this.trustMeCase.Fraud_ID_Not_Picture__c ??= "Yes";
    this.trustMeCase.Fraud_Customer_Photo_Modified__c ??= "Yes";
    this.trustMeCase.Fraud_Security_Features__c ??= "Yes";
  }
}
