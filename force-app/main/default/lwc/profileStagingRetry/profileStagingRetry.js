import { LightningElement, api } from "lwc";
import { showToast } from "c/utils";
import { notifyRecordUpdateAvailable } from "lightning/uiRecordApi";
import profileStagingRetry from "@salesforce/apex/ProfileStagingController.profileStagingRetry";

const TOAST_SUCCESS_MESSAGE = "Request has been re-triggered successfully.";
const TOAST_ERROR_MESSAGE = "Error occurred while re-triggering the request.";

export default class ProfileStagingRetry extends LightningElement {
  isLoading = false;
  @api recordId;
  @api async invoke() {
    try {
      this.isLoading = true;
      await profileStagingRetry({ recordId: this.recordId });
      notifyRecordUpdateAvailable([{ recordId: this.recordId }]);
      showToast(this, "Success!", TOAST_SUCCESS_MESSAGE, "", "success", "");
    } catch (error) {
      showToast(this, "Error!", TOAST_ERROR_MESSAGE, "", "error", "");
    } finally {
      this.isLoading = false;
    }
  }
}
