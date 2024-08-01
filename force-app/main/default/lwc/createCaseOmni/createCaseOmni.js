import { OmniscriptBaseMixin } from "omnistudio/omniscriptBaseMixin";
import { LightningElement, track } from "lwc";
import { validate } from "./formValidator/caseFormValidator";
import { handleErrorShowToast } from "c/utils";
export default class CreateCaseOmni extends OmniscriptBaseMixin(
  LightningElement
) {
  loading = false;
  showError = false;
  @track missingFields = [];
  @track modalMsg;
  @track showModal = false;
  @track modalHeader = "Error";

  closeModal() {
    this.showModal = false;
  }
  async callCreateCaseIP() {
    this.missingFields = [];
    this.modalMsg = "";
    this.missingFields = await validate(this.omniJsonData);

    if (this.missingFields.length > 0) {
      this.modalMsg =
        "Please complete all required fields: " + this.missingFields.join(", ");
      if (
        this.omniJsonData.Case.isThisCustomerComplaint === "Yes" &&
        !this.omniJsonData.Case.CustomerDetails.Customer &&
        this.omniJsonData.Case.CustomerDetails.CustomerIdentifier !== "CACHE ID"
      )
        this.modalMsg +=
          "<br><br>Customer number must be numbers and atleast 10 digits long.";
      if (
        this.omniJsonData.Case.isThisCustomerComplaint === "Yes" &&
        this.omniJsonData.Response === false
      )
        this.modalMsg +=
          "<br><br>Customer number is not valid or has not been validated, check the number and try again.";
      this.showModal = true;
    } else if (!this.validateCustomerNumber()) {
      this.modalMsg =
        "Customer number must be numbers and at least 10 digits long";
      this.showModal = true;
    } else if (
      !this.missingFields.length &&
      this.omniJsonData.Case.isThisCustomerComplaint === "Yes" &&
      this.omniScriptHeaderDef.hasInvalidElements
    ) {
      this.modalMsg = "Please complete all required fields";
      this.showModal = true;
    } else if (
      !this.missingFields.length &&
      this.omniJsonData.Case.isThisCustomerComplaint === "Yes" &&
      (this.omniJsonData.Response === false ||
        !Object.prototype.hasOwnProperty.call(this.omniJsonData, "Response"))
    ) {
      this.modalMsg +=
        "Please complete all required fields: Customer number is not valid or has not been validated, check the number and try again.";
      this.showModal = true;
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
      this.showModal = true;
    } else if (!this.checkIsvalidCustomer()) {
      this.modalMsg = "Customer number is not valid or has not been validated";
      this.showModal = true;
    } else if (
      this.omniJsonData.validatedEventNumber !==
        this.omniJsonData.Case.ResolutionInformation.realFormMAXId &&
      this.omniJsonData.Case.ResolutionInformation.realFormRequired === "Yes"
    ) {
      handleErrorShowToast(
        this,
        "Real Form ID Validation",
        undefined,
        "Revalidate Risk Event ID"
      );
      this.loading = false;
    } else {
      this.showModal = false;
      this.loading = true;

      const inputs = {
        Case: this.omniJsonData.Case,
        Response:
          this.omniJsonData.Response != null
            ? { profile: this.omniJsonData.Response.profile }
            : this.omniJsonData.Response
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
        let result = res.result.IPResult;
        this.loading = false;
        if (result.CaseId) {
          let url = window.location.origin + "/" + result.CaseId;
          window.open(url, "_self");
        }
      });
    }
  }

  validateRealFormID() {
    if (
      this.omniJsonData.Case.ResolutionInformation.ComplaintStatus ===
        "Closed" &&
      this.omniJsonData.Case.ResolutionInformation.realFormRequired === "Yes" &&
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
    var compare = /^[0-9]{10}$/;
    if (
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
    var details = JSON.parse(JSON.stringify(this.omniJsonData.Case));
    var customerNumber = JSON.stringify(this.omniJsonData.CustomerNumber);
    if (
      (details.isThisCustomerComplaint === "Yes" &&
        details.CustomerDetails.Customer &&
        details.CustomerDetails.Customer !== customerNumber) ||
      (details.CustomerDetails.Customer1 &&
        details.CustomerDetails.Customer1 !== customerNumber)
    ) {
      return false;
    }
    return true;
  }
}
