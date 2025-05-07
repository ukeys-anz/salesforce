import { LightningElement, api, wire } from "lwc";
import reassess from "@salesforce/apex/CreditAssessmentActionsController.reassess";
import { handleErrorShowToast, showToast } from "c/utils";
import { notifyRecordUpdateAvailable } from "lightning/uiRecordApi";
import { getRecord, getFieldValue } from "lightning/uiRecordApi";
import REASSESS_TIME from "@salesforce/schema/Case.Credit_Reassessment_Time__c";
import ASSESSMENT_OUTCOME from "@salesforce/schema/Case.Assessment_Outcome__c";

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

  @wire(getRecord, {
    recordId: "$recordId",
    fields: [REASSESS_TIME, ASSESSMENT_OUTCOME]
  })
  case;

  get reassessTime() {
    return getFieldValue(this.case.data, REASSESS_TIME);
  }

  get assessmentOutcome() {
    return getFieldValue(this.case.data, ASSESSMENT_OUTCOME);
  }

  isExecuting = false; //use to prevent multiple executions

  @api async invoke() {
    //if currently being executed, return
    if (this.isExecuting) {
      return;
    }

    const reassessTime = new Date(this.reassessTime);
    // Get the current time
    const now = new Date();

    // Calculate the difference in milliseconds
    const timeDifference = now - reassessTime;
    //Prevent reassess on Processing unless 10 minutes have elapsed since previous reassess
    if (
      this.assessmentOutcome === "Processing" &&
      timeDifference < 10 * 60 * 1000
    ) {
      const remainingTime = 10 * 60 * 1000 - timeDifference;
      const remainingMinutes = Math.floor(remainingTime / (60 * 1000));
      const remainingSeconds = Math.floor((remainingTime % (60 * 1000)) / 1000);
      showToast(
        this,
        "Credit Reassessment In Progress",
        `This loan application has already been submitted for assessment and is being processed. Please wait ${remainingMinutes} minutes ${remainingSeconds} seconds before trying again.`,
        "",
        "Error",
        ""
      );
      this.isExecuting = false;
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
