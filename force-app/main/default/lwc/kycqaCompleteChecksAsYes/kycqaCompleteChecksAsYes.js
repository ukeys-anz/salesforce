import { LightningElement, api } from "lwc";
import { showToast } from "c/utils";
import { notifyRecordUpdateAvailable } from "lightning/uiRecordApi";
import completeChecksAsYes from "@salesforce/apex/AutoKYCQACaseController.completeChecksAsYes";
import compleKYCQAChecksPermission from "@salesforce/customPermission/ANZx_Complete_KYC_QA_Checks";

const TOAST_SUCCESS_MESSAGE =
  "All the KYC QA checks are completed successfully.";
const TOAST_ERROR_ACCESS_MESSAGE =
  "You do not have enough permission to perform the KYC QA Check completion.";

export default class KycqaCompleteChecksAsYes extends LightningElement {
  isLoading = false;
  @api recordId;
  @api async invoke() {
    if (!compleKYCQAChecksPermission) {
      showToast(this, "Error!", TOAST_ERROR_ACCESS_MESSAGE, "", "error", "");
      return;
    }
    try {
      this.isLoading = true;
      await completeChecksAsYes({ recordId: this.recordId });
      notifyRecordUpdateAvailable([{ recordId: this.recordId }]);
      showToast(this, "Success!", TOAST_SUCCESS_MESSAGE, "", "success", "");
    } catch (error) {
      if (error.body.message.includes("already been completed")) {
        showToast(this, "Warning!", error.body.message, "", "warning", "");
      } else {
        showToast(this, "Error!", error.body.message, "", "error", "");
      }
    } finally {
      this.isLoading = false;
    }
  }
}
