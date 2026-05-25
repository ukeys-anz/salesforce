import { LightningElement, api, wire } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import { handleErrorShowToast, navigate } from "c/utils";
import { CloseActionScreenEvent } from "lightning/actions";
import { getRecord } from "lightning/uiRecordApi";
import CaseNumber from "@salesforce/schema/Case.CaseNumber";
import { EnclosingTabId, closeTab } from "lightning/platformWorkspaceApi";
import fetchQualityAssessments from "@salesforce/apex/IDRFetchQualityAssessmentsController.fetchQualityAssessments";
import checkCaseExists from "@salesforce/apex/IDRFetchQualityAssessmentsController.checkCaseExists";
import hasAIQAPermission from "@salesforce/customPermission/AzureTokenCache";

const fields = [CaseNumber];

export default class GenerateQAEvaluation extends NavigationMixin(
  LightningElement
) {
  @api recordId;
  caseNumber;
  isGenerating = false;
  caseNumberReadOnly = false;

  connectedCallback() {
    if (!hasAIQAPermission) {
      handleErrorShowToast(
        this,
        "Error",
        undefined,
        "You don't have permission to retrieve an A.I. evaluation."
      );
      closeTab(this.tabId);
      this.handleNavigateTolistView();
    }
  }

  @wire(EnclosingTabId) tabId;
  @wire(getRecord, {
    recordId: "$recordId",
    fields: fields
  })
  wiredCaseRecord({ data, error }) {
    if (data) {
      this.caseNumber = data.fields.CaseNumber.value;
      this.caseNumberReadOnly = true;
    } else if (error) {
      handleErrorShowToast(
        this,
        "Error",
        undefined,
        "Unable to retrieve Case details. Please contact your System Administrator.",
        "error"
      );
    }
  }

  handleCaseNumberChange(event) {
    let validPattern = /[0-9]*/;
    if (!event.target.value.match(validPattern)) {
      handleErrorShowToast(
        this,
        "Error",
        undefined,
        "Enter a valid Case Number"
      );
      return;
    }
    this.caseNumber = event.target.value;
  }

  handleCancel() {
    if (this.tabId) {
      closeTab(this.tabId);
    } else {
      this.dispatchEvent(new CloseActionScreenEvent());
    }
    this.handleNavigateTolistView();
  }

  async handleGenerate() {
    if (!this.caseNumber) {
      handleErrorShowToast(
        this,
        "Error",
        undefined,
        "Please enter a Case Number."
      );
      return;
    }
    if (
      !this.caseNumber.match(/^[0-9]{1,8}$/) ||
      this.caseNumber.length !== 8
    ) {
      handleErrorShowToast(
        this,
        "Error",
        undefined,
        "Please enter a valid Case Number."
      );
      return;
    }
    let exists = await checkCaseExists({ caseNumber: this.caseNumber });
    if (!exists) {
      handleErrorShowToast(
        this,
        "Error",
        undefined,
        "Complaint ID not found. Please enter a valid Complaint ID to continue."
      );
      this.isGenerating = false;
      return;
    }
    this.isGenerating = true;
    fetchQualityAssessments({
      complaintId: this.caseNumber
    })
      .then((result) => {
        if (
          result.status === "ERROR" &&
          ![200, 201].includes(result.httpsStatusCode)
        ) {
          handleErrorShowToast(
            this,
            "A.I. Evaluation not generated.",
            null,
            "An Evaluation of this type already exists for this Complaint.",
            "sticky"
          );
        }
        if (
          !Object.hasOwn(result, "qualityAssessmentId") &&
          result.httpsStatusCode === 200
        ) {
          handleErrorShowToast(
            this,
            "No A.I. evaluation available",
            null,
            "Enter a different Complaint ID to continue.",
            "sticky"
          );
        }
        let attributes = {
          recordId: result.qualityAssessmentId,
          objectApiName: "Quality_Assessment__c",
          actionName: "view"
        };
        if (
          Object.hasOwn(result, "qualityAssessmentId") &&
          result.httpsStatusCode === 201
        ) {
          navigate(this, "standard__recordPage", attributes);
          this.dispatchEvent(new CustomEvent("close"));
        }
      })
      .catch((error) => {
        handleErrorShowToast(
          this,
          "Retrieve AI Draft error",
          "Error",
          error.body?.message || error.message,
          "sticky"
        );
      })
      .finally(() => {
        this.isGenerating = false;
      });
  }
  handleNavigateTolistView() {
    navigate(this, "standard__objectPage", {
      objectApiName: "Quality_Assessment__c",
      actionName: "list"
    });
    this.dispatchEvent(new CustomEvent("close"));
  }
}
