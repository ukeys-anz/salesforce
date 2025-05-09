import { LightningElement, api } from "lwc";
import updateStatus from "@salesforce/apex/LendingCaseController.updateCaseStatusApproveReject";
import { handleErrorShowToast, showToast } from "c/utils";
import { notifyRecordUpdateAvailable } from "lightning/uiRecordApi";

export default class LendingCaseStatusUpdate extends LightningElement {
  @api recordId;
  @api status;

  componentSpinner = false;
  additionalInfo =
    "<b>Note: </b>Non-Credit Critical Cases can only be initiated during business days. doing so on non-business day will result in a failure";
  warningMessage =
    "Please ensure that you have completed the required checks before proceeding. This case will close once the request has processed successfully.";

  partialSuccessMessage =
    "The request was processed successfully and the account has been updated.";
  caseUpdateWarningMessage =
    "An error has occurred, when closing the case. Please raise a fault through TechAssist to close the case.";
  errorMessage =
    "An error has occurred. Please refresh and try again. Raise a fault through TechAssist if the problem persists.";

  get statusApprove() {
    return this.status === "STATE_APPROVED";
  }

  get headerMessage() {
    return this.statusApprove
      ? "Approve Non-Credit Critical Change"
      : "Reject Non-Credit Critical Change";
  }

  get successMessage() {
    return this.statusApprove
      ? "The request was processed successfully, the account has been updated and the case has been closed."
      : "The request was processed successfully and the case has been closed.";
  }

  handleClose() {
    let closeEvent = new CustomEvent("close");
    this.dispatchEvent(closeEvent);
  }

  async handleSubmit() {
    await this.handleStatusUpdate(this.recordId);
  }

  async handleStatusUpdate(caseRecordId) {
    this.componentSpinner = true;
    try {
      let response = await updateStatus({
        approvalState: this.status,
        recordId: caseRecordId
      });
      this.componentSpinner = false;
      if (response.approveRejectSuccess && response.caseUpdateSuccess) {
        showToast(this, "", this.successMessage, "", "Success", "");
        this.handleClose();
      } else if (response.approveRejectSuccess && !response.caseUpdateSuccess) {
        showToast(this, "", this.caseUpdateWarningMessage, "", "Warning", "");
        showToast(this, "", this.partialSuccessMessage, "", "Success", "");
        this.handleClose();
      } else {
        handleErrorShowToast(
          this,
          "Non-Credit Critical Change Failed",
          "Error",
          this.errorMessage,
          "pester"
        );
      }
      notifyRecordUpdateAvailable([{ caseRecordId: caseRecordId }]);
    } catch (error) {
      handleErrorShowToast(
        this,
        "Non-Credit Critical Change Failed",
        "Error",
        this.errorMessage,
        "pester"
      );
    } finally {
      this.componentSpinner = false;
    }
  }
}
