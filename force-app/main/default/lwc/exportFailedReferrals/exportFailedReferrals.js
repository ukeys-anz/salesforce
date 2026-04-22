import { LightningElement, api } from "lwc";
import retryReferralExport from "@salesforce/apex/ExportFailedReferralsController.retryReferralExport";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { notifyRecordUpdateAvailable } from "lightning/uiRecordApi";

export default class ExportFailedReferrals extends LightningElement {
  @api recordId;
  isLoading = false;

  @api async invoke() {
    if (this.isLoading) {
      return;
    }
    this.isLoading = true;
    try {
      await retryReferralExport({ leadId: this.recordId });
      this.showToast("Success", "Event has been published.", "success");
      await notifyRecordUpdateAvailable([{ recordId: this.recordId }]);
    } catch (error) {
      const message = error.body
        ? error.body.message
        : "Your Referral has failed to be sent, please check the details and try again.";
      this.showToast("Error", message, "error");
    } finally {
      this.isLoading = false;
    }
  }

  showToast(title, message, variant) {
    this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
  }
}
