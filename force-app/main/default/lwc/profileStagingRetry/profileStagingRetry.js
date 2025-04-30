import { LightningElement, api } from "lwc";
import { showToast, getApexError } from "c/utils";
import { notifyRecordUpdateAvailable } from "lightning/uiRecordApi";
import profileStagingRetry from "@salesforce/apex/ProfileStagingController.profileStagingRetry";

const TOAST_SUCCESS_MESSAGE = "Request has been re-triggered successfully.";

export default class ProfileStagingRetry extends LightningElement {
  isLoading = false;
  @api recordId;
  @api async invoke() {
    try {
      this.isLoading = true;
      await profileStagingRetry({ recordId: this.recordId });
      notifyRecordUpdateAvailable([{ recordId: this.recordId }]);
      showToast(this, TOAST_SUCCESS_MESSAGE, "", "", "success", "");
    } catch (error) {
      showToast(this, getApexError(error), "", "", "error", "");
    } finally {
      this.isLoading = false;
    }
  }
}
