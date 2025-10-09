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
const ALLOWED_POSTCODES = ["not applicable", "overseas"];

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
  makePriorityFieldRequired(data) {
    if (data.isEcf || data?.Case?.ComplaintDetails?.Priority) {
      return;
    }
    this.missingFields.push("Priority");
  }
  async callCreateCaseIP() {
    this.missingFields = [];
    this.modalMsg = "";
    this.missingFields = await validate(this.omniJsonData);
    this.makePriorityFieldRequired(this.omniJsonData);
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
    } else if (this.checkForCustomerAddressSearch()) {
      this.modalMsg +=
        "Please fill the Address Details by Selecting address from search";
    } else if (this.checkValidCustmerPostCode()) {
      this.modalMsg += "Please Enter a Valid Postcode";
    } else if (this.checkForThirdPartyCode()) {
      this.modalMsg += "Please Enter a Valid Nominated 3rd Party Postcode";
    } else if (
      this.checkForThirdPartyAddressSearch() ||
      this.isValidEmailAddress()
    ) {
      this.modalMsg +=
        "Please fill the 3rd party address details by selecting an address from search";
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
        isEcf: this.omniJsonData.isEcf,
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
  checkForCustomerAddressSearch() {
    if (
      this.omniJsonData.Case.isThisCustomerComplaint === "No" &&
      this.omniJsonData.Case.CustomerDetails?.SearchAddressRadio ===
        "Search Address" &&
      !Object.prototype.hasOwnProperty.call(
        this.omniJsonData.Case,
        "disablAddress"
      )
    ) {
      return true;
    }

    return false;
  }
  checkForThirdPartyAddressSearch() {
    if (
      this.omniJsonData.Case.CustomerDetails.thirdPartyRepCheckbox === "Yes" &&
      this.omniJsonData.Case.CustomerDetails?.thirdPartyAddress ===
        "Search Address" &&
      !Object.prototype.hasOwnProperty.call(
        this.omniJsonData.Case,
        "disablThirdAddress"
      )
    ) {
      return true;
    }
    return false;
  }
  checkValidCustmerPostCode() {
    let compare = /^[0-9]{4}$/;
    let postCode =
      "" + this.omniJsonData.Case.CustomerDetails?.PostcodeReadOnly;

    if (postCode && ALLOWED_POSTCODES.includes(postCode.toLowerCase())) {
      return false;
    }
    if (
      this.omniJsonData.Case.isThisCustomerComplaint === "No" &&
      this.omniJsonData.Case.CustomerDetails?.SearchAddressRadio ===
        "Manual Address Entry" &&
      (!Object.prototype.hasOwnProperty.call(
        this.omniJsonData.Case.CustomerDetails,
        "PostcodeReadOnly"
      ) ||
        postCode === "" ||
        !postCode.match(compare))
    ) {
      return true;
    }
    if (this.omniJsonData.Case?.apiDown) {
      return false;
    }

    if (
      this.omniJsonData.Case.CustomerDetails?.SearchAddressRadio ===
        "Manual Address Entry" &&
      postCode !== this.omniJsonData.Case?.selectedpostcode
    ) {
      return true;
    }

    return false;
  }
  checkForThirdPartyCode() {
    let compare = /^[0-9]{4}$/;
    let thirdPartyCode =
      "" + this.omniJsonData.Case.CustomerDetails?.thirdPartyPostCode;
    if (
      thirdPartyCode &&
      ALLOWED_POSTCODES.includes(thirdPartyCode.toLowerCase())
    ) {
      return false;
    }
    if (
      this.omniJsonData.Case.CustomerDetails.thirdPartyRepCheckbox === "Yes" &&
      this.omniJsonData.Case.CustomerDetails?.thirdPartyAddress ===
        "Manual Address Entry" &&
      (!Object.prototype.hasOwnProperty.call(
        this.omniJsonData.Case.CustomerDetails,
        "thirdPartyPostCode"
      ) ||
        thirdPartyCode === "" ||
        !thirdPartyCode.match(compare))
    ) {
      return true;
    }
    if (this.omniJsonData.Case?.apiDown) {
      return false;
    }
    if (
      this.omniJsonData.Case.CustomerDetails?.thirdPartyAddress ===
        "Manual Address Entry" &&
      thirdPartyCode !== this.omniJsonData.Case?.selectedThirdPartypostcode
    ) {
      return true;
    }
    return false;
  }
  isValidEmailAddress() {
    let emailRegex = /^(?![.\s,])([^\s@]+@[^\s@]+\.[^\s@]+)$/;
    if (this.omniJsonData.Case.isThisCustomerComplaint !== "No") {
      return false;
    }
    if (
      this.omniJsonData.Case.CustomerDetails.thirdPartyRepCheckbox !== "Yes"
    ) {
      return false;
    }
    return !this.omniJsonData.Case.CustomerDetails?.thirdPartyEmail?.match(
      emailRegex
    );
  }
}
