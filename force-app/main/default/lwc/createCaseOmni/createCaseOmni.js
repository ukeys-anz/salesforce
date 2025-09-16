import { OmniscriptBaseMixin } from "omnistudio/omniscriptBaseMixin";
import { LightningElement, track, wire } from "lwc";
import {
  validate,
  getCustomerNumberValidationMsg
} from "./formValidator/caseFormValidator";
import { handleErrorShowToast } from "c/utils";
import {
  EnclosingTabId,
  openTab,
  closeTab
} from "lightning/platformWorkspaceApi";
import logCaseCreation from "@salesforce/apex/IDRCaseActionsHelper.logCaseCreation";
import logCaseError from "@salesforce/apex/IDRCaseActionsHelper.logCaseError";
export default class CreateCaseOmni extends OmniscriptBaseMixin(
  LightningElement
) {
  loading = false;
  showError = false;
  @track missingFields = [];
  @track modalMsg;
  @track modalHeader = "Error";

  @wire(EnclosingTabId) tabId;

  closeModal() {
    this.modalMsg = null;
  }
  async callCreateCaseIP() {
    this.missingFields = [];
    this.modalMsg = "";
    this.missingFields = await validate(this.omniJsonData);
    if (this.missingFields.length > 0) {
      this.modalMsg = await getCustomerNumberValidationMsg(
        this.omniJsonData,
        this.missingFields
      );
    } else if (!this.validateCustomerNumber()) {
      this.modalMsg =
        "Customer number must be numbers and at least 10 digits long";
    } else if (
      !this.missingFields.length &&
      this.omniJsonData.Case.isThisCustomerComplaint === "Yes" &&
      this.omniScriptHeaderDef.hasInvalidElements &&
      !this.omniJsonData.isEligibleAppForLookUp
    ) {
      this.modalMsg = "Please complete all required fields";
    } else if (
      !this.missingFields.length &&
      this.omniJsonData.Case.isThisCustomerComplaint === "Yes" &&
      (this.omniJsonData.Response === false ||
        !Object.prototype.hasOwnProperty.call(this.omniJsonData, "Response")) &&
      !this.omniJsonData.isEligibleAppForLookUp &&
      !this.omniJsonData.enableAccountLookUp
    ) {
      this.modalMsg +=
        "Please complete all required fields: Customer number is not valid or has not been validated, check the number and try again.";
    } else if (this.checkOCVDown()) {
      this.modalMsg +=
        "Customer details cannot be retrieved as One Customer View (OCV) is currently unavailable.";
    } else if (this.validateRealFormID()) {
      handleErrorShowToast(
        this,
        "Real Form ID Validation",
        undefined,
        "Please Validate Real Form ID."
      );
    } else if (this.validateComplianceChecks()) {
      this.modalMsg =
        "The Status must be set to 'Escalated' if either Compliance Checks are selected as 'YES'";
    } else if (!this.checkIsvalidCustomer()) {
      this.modalMsg = "Customer number is not valid or has not been validated";
    } else if (
      this.omniJsonData.validatedEventNumber !==
        this.omniJsonData.Case.ResolutionInformation.realFormMAXId &&
      this.omniJsonData.Case.ResolutionInformation.realFormRequired === "Y_EXI"
    ) {
      handleErrorShowToast(
        this,
        "Real Form ID Validation",
        undefined,
        "Revalidate Risk Event ID"
      );
      this.loading = false;
    } else {
      this.loading = true;
      const inputs = {
        Case: this.omniJsonData.Case,
        Response:
          this.omniJsonData.Response != null
            ? { profile: this.omniJsonData.Response.profile }
            : this.omniJsonData.Response,
        data: this.omniJsonData.data
      };

      const options = {
        chainable: true
      };

      // Invoking Integration procedure(IP) to create a case
      const params = {
        input: JSON.stringify(inputs),
        sClassName: "omnistudio.IntegrationProcedureService",
        sMethodName: "Case_CreateCase",
        options: JSON.stringify(options)
      };

      // Navigate to the case record that is closed
      this.omniRemoteCall(params, true).then((res) => {
        let result = res?.result?.IPResult;
        if (result?.error || result?.result?.errors) {
          logCaseError({
            message: result.error ?? JSON.stringify(result.result.errors)
          });
          handleErrorShowToast(
            this,
            "Case Creation failed : ",
            undefined,
            "Please contact CMOS Support",
            "sticky"
          );
          this.loading = false;
        }

        if (result?.CaseId) {
          logCaseCreation({ caseId: result.CaseId });
          openTab({
            recordId: result.CaseId,
            focus: true
          })
            .then(() => {
              this.loading = false;
              closeTab(this.tabId);
            })
            .catch(() => {
              this.loading = false;
            });
        }
      });
    }
  }

  validateRealFormID() {
    if (
      this.omniJsonData.Case.ResolutionInformation.ComplaintStatus ===
        "Closed" &&
      this.omniJsonData.Case.ResolutionInformation.realFormRequired ===
        "Y_EXI" &&
      (this.omniJsonData.Case.ResolutionInformation.realFormMAXId !==
        undefined ||
        this.omniJsonData.Case.ResolutionInformation.realFormMAXId !== null) &&
      !(
        this.omniJsonData.apiRun &&
        this.omniJsonData.apiSuccess &&
        this.omniJsonData.RiskFormIDValid
      )
    ) {
      return true;
    }
    return false;
  }

  validateCustomerNumber() {
    let compare = /^[0-9]{10}$/;
    if (
      !this.omniJsonData.enableAccountLookUp &&
      this.omniJsonData.Case.isThisCustomerComplaint === "Yes" &&
      this.omniJsonData.Case.CustomerDetails.Customer &&
      (this.omniJsonData.Case.CustomerDetails.Customer !==
        this.omniJsonData.Case.CustomerDetails.Customer.trim() ||
        !this.omniJsonData.Case.CustomerDetails.Customer.match(compare))
    ) {
      return false;
    }
    return true;
  }

  validateComplianceChecks() {
    let issueTypeCheck = [
      this.omniJsonData.Case.ComplaintDetails.IssueType,
      this.omniJsonData.Case.ComplaintDetails.IssueType2,
      this.omniJsonData.Case.ComplaintDetails.IssueType3
    ];
    let complianceChecks = [
      this.omniJsonData.Case.ResolutionInformation.custWrittenResponse,
      this.omniJsonData.Case.ResolutionInformation.complaintRelatedHardship
    ];
    if (
      !issueTypeCheck.includes("4") &&
      complianceChecks.includes("Yes") &&
      this.omniJsonData.Case.ResolutionInformation.complaintStatus1 !==
        "Escalated"
    ) {
      return true;
    }
    return false;
  }
  checkIsvalidCustomer() {
    let details = JSON.parse(JSON.stringify(this.omniJsonData.Case));
    let customerNumber = JSON.stringify(this.omniJsonData.CustomerNumber);
    if (
      (!this.omniJsonData.enableAccountLookUp &&
        details.isThisCustomerComplaint === "Yes" &&
        details.CustomerDetails.Customer &&
        details.CustomerDetails.Customer !== customerNumber) ||
      (details.CustomerDetails.Customer1 &&
        details.CustomerDetails.Customer1 !== customerNumber)
    ) {
      return false;
    }
    return true;
  }
  checkOCVDown() {
    if (
      this.omniJsonData.IsOCVDown === true &&
      this.omniJsonData.Case.isThisCustomerComplaint === "Yes" &&
      !this.omniJsonData.isEligibleAppForLookUp
    ) {
      return true;
    }
    return false;
  }
}
