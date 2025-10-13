import { LightningElement, api } from "lwc";
import { SimpleToast } from "c/utils";
import { notifyRecordUpdateAvailable } from "lightning/uiRecordApi";
import completeChecksAsYes from "@salesforce/apex/TrustMeCaseActions.completeChecksAsYes";

const SUCCESS_MESSAGE = "Checks have been set to 'Yes' successfully.";

export default class SetDocumentChecks extends LightningElement {
  showSpinner = false;
  toast = new SimpleToast(this);

  @api recordId;

  @api async invoke() {
    this.showSpinner = true;
    await completeChecksAsYes({ recordId: this.recordId })
      .then(() => {
        notifyRecordUpdateAvailable([{ recordId: this.recordId }]);
        this.toast.success(SUCCESS_MESSAGE);
      })
      .catch((error) => {
        this.toast.error(error.body.message);
      })
      .finally(() => {
        this.showSpinner = false;
      });
  }
}
