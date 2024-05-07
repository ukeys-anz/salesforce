import { LightningElement, api } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { notifyRecordUpdateAvailable } from "lightning/uiRecordApi";
import assignCaseToOriginalQueue from "@salesforce/apex/DisputeExternalCaseStatusController.assignCaseToOriginalQueue";
import { handleErrors } from "c/utils";

export default class DisputeCaseToQueueAction extends LightningElement {
  @api recordId;
  isExecuting = false;

  @api async invoke() {
    if (this.isExecuting) {
      return;
    }
    this.isExecuting = true;

    try {
      await assignCaseToOriginalQueue({ caseId: this.recordId });
      this.dispatchEvent(
        new ShowToastEvent({
          title: "Success",
          message: "Case assigned to original queue",
          variant: "success"
        })
      );
      notifyRecordUpdateAvailable([{ recordId: this.recordId }]);
    } catch (error) {
      this.dispatchEvent(
        new ShowToastEvent({
          title: "Error",
          message: handleErrors(error),
          variant: "error"
        })
      );
    } finally {
      this.isExecuting = false;
    }
  }
}
