import { LightningElement, api, wire } from "lwc";
import finalise from "@salesforce/apex/CreditAssessmentActionsController.finalise";
import { handleErrorShowToast } from "c/utils";
import { CloseActionScreenEvent } from "lightning/actions";
import {
  getRecord,
  getFieldValue,
  notifyRecordUpdateAvailable
} from "lightning/uiRecordApi";
import ASSESSMENT_OUTCOME_FIELD from "@salesforce/schema/Case.Assessment_Outcome__c";
import CREDIT_REASSESS_FIELD from "@salesforce/schema/Case.Loan_Application__r.Credit_Reassess_Required__c";

const FIELDS = [ASSESSMENT_OUTCOME_FIELD, CREDIT_REASSESS_FIELD];

export default class CreditFinalise extends LightningElement {
  @api recordId;
  @api objectApiName;
  isAssessed = false;
  unapprovedState;
  creditReassess;
  assessmentOutcome;
  showSubmitBtn;
  isCaseLoaded = false;

  @wire(getRecord, {
    recordId: "$recordId",
    fields: FIELDS
  })
  wiredProject({ data }) {
    if (data) {
      //The assessment outcome values are also css class names to handle text colour
      //If values change, css class names need to change to match.
      this.assessmentOutcome = getFieldValue(data, ASSESSMENT_OUTCOME_FIELD);
      this.creditReassess = getFieldValue(data, CREDIT_REASSESS_FIELD);
      if (
        this.assessmentOutcome !== "Approved" &&
        this.assessmentOutcome !== "Declined"
      ) {
        this.unapprovedState = true;
      } else {
        this.unapprovedState = false;
      }

      this.showSubmitBtn = !(
        this.unapprovedState ||
        this.creditReassess ||
        this.isAssessed
      );
      this.isCaseLoaded = true;
    }
  }

  get isLoading() {
    return !this.isCaseLoaded || this.isExecuting;
  }

  get showSuccessIcon() {
    return this.isAssessed ? true : false;
  }
  get showErrorIcon() {
    return this.unapprovedState || this.creditReassess ? true : false;
  }

  get closeBtnLabel() {
    return this.isAssessed || this.unapprovedState || this.creditReassess
      ? "Close"
      : "Cancel";
  }

  handleCancel() {
    this.dispatchEvent(new CloseActionScreenEvent());
  }

  isExecuting = false; //use to prevent multiple executions

  async handleSubmit() {
    //if currently being executed, return
    if (this.isExecuting) {
      return;
    }

    this.isExecuting = true;
    try {
      let resp = await finalise({ recordId: this.recordId });
      if (resp) {
        this.isAssessed = true;
        this.showSubmitBtn = false;
        notifyRecordUpdateAvailable([{ recordId: this.recordId }]);
      }
    } catch (error) {
      handleErrorShowToast(
        this,
        "Credit Finalisation Failed",
        error,
        "Credit Finalisation Failed. Please refresh and try again. Raise a fault through TechAssist if the problem persists"
      );
    } finally {
      this.isExecuting = false;
    }
  }
}
