import { LightningElement, api } from "lwc";
import reassess from "@salesforce/apex/CreditAssessmentActionsController.reassess";
import { handleErrorShowToast, showToast } from "c/utils";
import { notifyRecordUpdateAvailable } from "lightning/uiRecordApi";

export default class CreditReassessment extends LightningElement {
  _recordId;
  @api set recordId(recordId) {
    if (recordId !== this._recordId) {
      this._recordId = recordId;
    }
  }
  get recordId() {
    return this._recordId;
  }

  isExecuting = false; //use to prevent multiple executions

  @api async invoke() {
    //if currently being executed, return
    if (this.isExecuting) {
      return;
    }

    this.isExecuting = true;
    try {
      let resp = await reassess({ recordId: this.recordId });
      if (resp) {
        showToast(
          this,
          "Credit Reassessment",
          "The assessment for this loan application has been successfully submitted for reassessment.",
          "",
          "Success",
          ""
        );
        notifyRecordUpdateAvailable([{ recordId: this.recordId }]);
      }
    } catch (error) {
      handleErrorShowToast(
        this,
        "Credit Reassessment Failed",
        error,
        "Credit Reassessment Failed. Please refresh and try again. Raise a fault through TechAssist if the problem persists"
      );
    } finally {
      this.isExecuting = false;
    }
  }
}
