import { OmniscriptBaseMixin } from "omnistudio/omniscriptBaseMixin";
import { LightningElement, track } from "lwc";
import { handleErrorShowToast } from "c/utils";

const SUB_REMS = ["16", "20", "Repayment arrangement"];
const SERVICE_QUALITY = "9";
const FAILURE_TO_RESPOND = "61";
const REFERRED_TO_FIRM = "3";
const OTHER = "99";
const FINANCIAL_REMEDY = "1";
const SUB_REMS_PAYMENT = ["10", "18"];
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

  callCreateCaseIP() {
    this.missingFields = [];
    this.modalMsg = "";
    this.valCustomerFields();
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
      this.omniJsonData.Response === false
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

  // validate that all the required fields data has been provided
  valCustomerFields() {
    if (
      this.omniJsonData.Case.isThisCustomerComplaint === "No" &&
      !this.omniJsonData.Case.CustomerDecision
    )
      this.missingFields.push("Customer Decision");
    let details = this.omniJsonData.Case.CustomerDetails;
    if (this.omniJsonData.Case.isThisCustomerComplaint === "Yes") {
      if (
        this.omniJsonData.Case.CustomerDetails.CustomerIdentifier ===
          "CACHE ID" &&
        !this.omniJsonData.Case.CustomerDetails.Customer1
      ) {
        this.missingFields.push("Customer Number");
      } else if (
        this.omniJsonData.Case.CustomerDetails.CustomerIdentifier !==
          "CACHE ID" &&
        !this.omniJsonData.Case.CustomerDetails.Customer
      ) {
        this.missingFields.push("Customer Number");
      }

      this.checkFields(details, this.omniJsonData.custMap);
    } else if (this.omniJsonData.Case.isThisCustomerComplaint === "No") {
      let nonCustMap = JSON.parse(JSON.stringify(this.omniJsonData.nonCustMap));
      if (this.omniJsonData.Case.CustomerDecision === "Agrees") {
        nonCustMap.push({ firstName: "First Name" });
        nonCustMap.push({ LastName: "Last Name" });
      }
      let temp = this.omniJsonData.Case.ResolutionInformation;
      if (
        temp.custWrittenResponse === "Yes" ||
        temp.complaintRelatedHardship === "Yes"
      ) {
        nonCustMap.push({ Street: "Street" });
        nonCustMap.push({ Suburb: "Suburb" });
        nonCustMap.push({ State: "State" });
      }
      this.checkFields(details, nonCustMap);
    }
    if (details.thirdPartyRepCheckbox === "Yes") {
      this.checkFields(details, this.omniJsonData.thirdPartyMap);
    }
    details = this.omniJsonData.Case.ComplaintDetails;
    let itype = details.IssueType;
    let subtype = details.SubSequentIssueType;
    let cmpMap = JSON.parse(JSON.stringify(this.omniJsonData.cmpMap));
    if (this.omniJsonData.Case.isThisCustomerComplaint === "Yes")
      cmpMap.push({ AccountPolicyNumber: "Account/Policy Number" });
    this.checkFields(details, cmpMap);
    if (details.Issue2Checkbox === "Yes") {
      let secCmpMap = JSON.parse(JSON.stringify(this.omniJsonData.secCmpMap));
      if (this.omniJsonData.Case.isThisCustomerComplaint === "Yes")
        secCmpMap.push({ AccountPolicyNumber2: "Account/Policy Number 2" });
      this.checkFields(details, secCmpMap);
      itype = details.IssueType2;
      subtype = details.SubsequentIssueType2;
    }
    if (details.Issue3Checkbox === "Yes") {
      let thirdCmpMap = JSON.parse(
        JSON.stringify(this.omniJsonData.thirdCmpMap)
      );
      if (this.omniJsonData.Case.isThisCustomerComplaint === "Yes")
        thirdCmpMap.push({ AccountPolicyNumber3: "Account/Policy Number 3" });
      this.checkFields(details, thirdCmpMap);
      itype = details.IssueType3;
      subtype = details.SubsequentIssueType3;
    }
    details = this.omniJsonData.Case.ResolutionInformation;
    if (this.omniJsonData.Case.CustomerDecision !== "Disagrees") {
      this.checkFields(details, this.omniJsonData.resInfoMap);
    }
    if (details.ComplaintStatus === "Closed") {
      this.checkFields(details, this.omniJsonData.closeCmpMap);
    }
    if (details.realFormRequired === "Yes")
      this.checkFields(details, this.omniJsonData.realMap);
    if (details.systemicIssue === "Yes")
      this.checkFields(details, this.omniJsonData.sysIssueMap);
    if (
      details.systemicIssue === "Yes" &&
      this.omniJsonData.Case.ComplaintDetails.Issue2Checkbox === "Yes"
    ) {
      if (!details.additionalissues)
        this.missingFields.push("Which issue is possibly systemic?");
    }
    if (details.CAC === "Yes")
      this.checkFields(details, this.omniJsonData.cacMap);
    if (
      itype === SERVICE_QUALITY &&
      subtype === FAILURE_TO_RESPOND &&
      details.ComplaintStatus === "Closed"
    ) {
      if (!details.CAC)
        this.missingFields.push("Is this a complaint about a complaint?");
    }
    if (
      details.ComplaintRemedy1 === REFERRED_TO_FIRM &&
      !details.detailsOfComplaint1
    )
      this.missingFields.push(
        "The details of this complaint have been provided to the product manufacturer"
      );
    if (
      SUB_REMS.includes(details.ComplaintSubRemedy1) &&
      !details.durationOfRemedy1
    )
      this.missingFields.push("Duration Of Remedy (months) 1");
    if (details.ComplaintSubRemedy1 === OTHER && !details.otherRemedy1)
      this.missingFields.push("Other Remedy 1");
    if (
      details.ComplaintSubRemedy1 === "Reward Points" &&
      !details.rewardPoints1
    )
      this.missingFields.push("Reward Points 1");
    if (
      (FINANCIAL_REMEDY.includes(details.ComplaintRemedy1) ||
        SUB_REMS_PAYMENT.includes(details.ComplaintSubRemedy1)) &&
      !details.PaymentAmountProvided1
    ) {
      this.missingFields.push("Payment Amount Provided 1");
    }
    if (details.secondComplaintRemedyCheckbox === "Yes") {
      this.checkFields(details, this.omniJsonData.secRemedyMap);
      if (
        details.ComplaintRemedy2 === REFERRED_TO_FIRM &&
        !details.detailsOfComplaint2
      )
        this.missingFields.push(
          "The details of this complaint have been provided to the product manufacturer 2"
        );
      if (
        SUB_REMS.includes(details.ComplaintSubRemedy2) &&
        !details.durationOfRemedy2
      )
        this.missingFields.push("Duration Of Remedy (months) 2");
      if (details.ComplaintSubRemedy2 === OTHER && !details.otherRemedy2)
        this.missingFields.push("Other Remedy 2");
      if (
        details.ComplaintSubRemedy2 === "Reward Points" &&
        !details.rewardPoints2
      )
        this.missingFields.push("Reward Points 2");
      if (
        (FINANCIAL_REMEDY.includes(details.ComplaintRemedy2) ||
          SUB_REMS_PAYMENT.includes(details.ComplaintSubRemedy2)) &&
        !details.PaymentAmountProvided2
      ) {
        this.missingFields.push("Payment Amount Provided 2");
      }
    }
    if (details.thirdComplaintRemedyCheckbox === "Yes") {
      this.checkFields(details, this.omniJsonData.thirdRemedyMap);
      if (
        details.ComplaintRemedy3 === REFERRED_TO_FIRM &&
        !details.detailsOfComplaint3
      )
        this.missingFields.push(
          "The details of this complaint have been provided to the product manufacturer 3"
        );
      if (
        SUB_REMS.includes(details.ComplaintSubRemedy3) &&
        !details.durationOfRemedy3
      )
        this.missingFields.push("Duration Of Remedy (months) 3");
      if (details.ComplaintSubRemedy3 === OTHER && !details.otherRemedy3)
        this.missingFields.push("Other Remedy 3");
      if (
        details.ComplaintSubRemedy3 === "Reward Points" &&
        !details.rewardPoints3
      )
        this.missingFields.push("Reward Points 3");
      if (
        (FINANCIAL_REMEDY.includes(details.ComplaintRemedy3) ||
          SUB_REMS_PAYMENT.includes(details.ComplaintSubRemedy3)) &&
        !details.PaymentAmountProvided3
      ) {
        this.missingFields.push("Payment Amount Provided 3");
      }
    }
    if (details.ComplaintStatus === "Escalated")
      this.checkFields(details, this.omniJsonData.escMap);
  }

  checkFields(detail, reMap) {
    reMap.forEach((field) => {
      let ele = Object.keys(field)[0];
      if (ele.includes("Block")) {
        if (!detail[ele] || (detail[ele] && !detail[ele].Id)) {
          this.missingFields.push(Object.values(field)[0]);
        }
      } else if (!detail[ele]) {
        this.missingFields.push(Object.values(field)[0]);
      }
    });
  }
}
