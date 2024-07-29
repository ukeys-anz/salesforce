const CLOSED_STATUS = "Closed",
  ESCALATED_STATUS = "Escalated",
  FAILURE_TO_RESPOND = "61",
  FINANCIAL_REMEDY = "1",
  OTHER = "99",
  REFERRED_TO_FIRM = "3",
  SERVICE_QUALITY = "9",
  SUB_REMS = ["16", "20", "Repayment arrangement"],
  SUB_REMS_PAYMENT = ["10", "18"],
  CUSTOMER_AGREES = "Yes",
  CUSTOMER_DISAGREES = "No";

var itype, subtype;

export class CaseFormValidator {
  constructor(omniJsonData) {
    this.omniJsonData = omniJsonData;
    this.missingFields = [];
  }

  async validate() {
    await this.validateCustomerComplaint();
    await this.validateNonCustomerComplaint();
    await this.validateComplaintRemedies();
    await this.validateResolutionInformation();
    return this.missingFields;
  }

  async validateCustomerComplaint() {
    let details = this.omniJsonData.Case.ComplaintDetails;
    let cmpMap = JSON.parse(JSON.stringify(this.omniJsonData.cmpMap));
    if (this.omniJsonData.Case.isThisCustomerComplaint === CUSTOMER_AGREES) {
      this.checkFields(
        this.omniJsonData.Case.CustomerDetails,
        this.omniJsonData.custMap
      );
      this.checkCustomerIdentifier();

      cmpMap.push({ AccountPolicyNumber: "Account/Policy Number" });
      this.checkCommonValidations(details);
    }
    this.checkFields(details, cmpMap);
  }

  checkCustomerIdentifier() {
    if (
      this.omniJsonData.Case.CustomerDetails.CustomerIdentifier ===
        "CACHE ID" &&
      !this.omniJsonData.Case.CustomerDetails.Customer1
    ) {
      this.missingFields.push("Customer Number");
    }
    if (
      this.omniJsonData.Case.CustomerDetails.CustomerIdentifier !==
        "CACHE ID" &&
      !this.omniJsonData.Case.CustomerDetails.Customer
    ) {
      this.missingFields.push("Customer Number");
    }
  }

  async validateNonCustomerComplaint() {
    let details = this.omniJsonData.Case.ComplaintDetails;
    if (
      this.omniJsonData.Case.isThisCustomerComplaint === CUSTOMER_DISAGREES &&
      !this.omniJsonData.Case.CustomerDecision
    ) {
      this.missingFields.push("Customer Decision");
    }

    if (this.omniJsonData.Case.isThisCustomerComplaint === CUSTOMER_DISAGREES) {
      this.validateNonCustMap(this.omniJsonData.Case.CustomerDetails);
      this.checkCommonValidations(details);
    }
  }

  validateNonCustMap(details) {
    let nonCustMap = JSON.parse(JSON.stringify(this.omniJsonData.nonCustMap));
    if (this.omniJsonData.Case.CustomerDecision === "Agrees") {
      nonCustMap.push({ firstName: "First Name" });
      nonCustMap.push({ LastName: "Last Name" });
    }
    let temp = this.omniJsonData.Case.ResolutionInformation;
    if (
      temp.custWrittenResponse === CUSTOMER_AGREES ||
      temp.complaintRelatedHardship === CUSTOMER_AGREES
    ) {
      nonCustMap.push({ Street: "Street" });
      nonCustMap.push({ Suburb: "Suburb" });
      nonCustMap.push({ State: "State" });
    }

    this.checkFields(details, nonCustMap);
  }

  checkCommonValidations(details) {
    itype = details.IssueType;
    subtype = details.SubSequentIssueType;

    if (details.thirdPartyRepCheckbox === CUSTOMER_AGREES) {
      this.checkFields(details, this.omniJsonData.thirdPartyMap);
    }
    if (details.Issue2Checkbox === CUSTOMER_AGREES) {
      let secCmpMap = JSON.parse(JSON.stringify(this.omniJsonData.secCmpMap));
      this.checkForAccountPolicyNumber(details, secCmpMap, "2");
      itype = details.IssueType2;
      subtype = details.SubsequentIssueType2;
    }
    if (details.Issue3Checkbox === CUSTOMER_AGREES) {
      let thirdCmpMap = JSON.parse(
        JSON.stringify(this.omniJsonData.thirdCmpMap)
      );
      this.checkForAccountPolicyNumber(details, thirdCmpMap, "3");
      itype = details.IssueType3;
      subtype = details.SubsequentIssueType3;
    }
    if (
      this.omniJsonData.Case.CustomerDetails.expressCaseCreationCheckbox ===
        CUSTOMER_AGREES &&
      !this.omniJsonData.Case.CustomerDetails.complaintAbout
    ) {
      this.missingFields.push("This Complaint Is About");
    }
  }

  checkForAccountPolicyNumber(details, issueMap, issueNumber) {
    if (this.omniJsonData.Case.isThisCustomerComplaint === CUSTOMER_AGREES) {
      if (issueNumber === "2") {
        issueMap.push({
          AccountPolicyNumber2: "Account/Policy Number " + issueNumber
        });
      } else {
        issueMap.push({
          AccountPolicyNumber3: "Account/Policy Number " + issueNumber
        });
      }
    }
    this.checkFields(details, issueMap);
  }

  async validateResolutionInformation() {
    let details = this.omniJsonData.Case.ResolutionInformation;
    if (this.checkIssueType()) {
      this.checkFields(details, this.omniJsonData.resInfoMap);
    }
    if (details.ComplaintStatus === CLOSED_STATUS) {
      this.checkFields(details, this.omniJsonData.closeCmpMap);
    }
    if (details.realFormRequired === CUSTOMER_AGREES)
      this.checkFields(details, this.omniJsonData.realMap);
    if (details.systemicIssue === CUSTOMER_AGREES)
      this.checkFields(details, this.omniJsonData.sysIssueMap);
    if (
      details.systemicIssue === CUSTOMER_AGREES &&
      this.omniJsonData.Case.ComplaintDetails.Issue2Checkbox === CUSTOMER_AGREES
    ) {
      if (!details.additionalissues)
        this.missingFields.push("Which issue is possibly systemic?");
    }
    if (details.CAC === CUSTOMER_AGREES)
      this.checkFields(details, this.omniJsonData.cacMap);
    if (
      itype === SERVICE_QUALITY &&
      subtype === FAILURE_TO_RESPOND &&
      details.ComplaintStatus === CLOSED_STATUS &&
      !details.CAC
    ) {
      this.missingFields.push("Is this a complaint about a complaint?");
    }
    if (details.ComplaintStatus === ESCALATED_STATUS)
      this.checkFields(details, this.omniJsonData.escMap);
  }
  checkIssueType() {
    let details = this.omniJsonData.Case;
    if (
      details.CustomerDecision !== "Disagrees" &&
      details.ComplaintDetails.IssueType !== "4" &&
      details.ComplaintDetails.IssueType2 !== "4" &&
      details.ComplaintDetails.IssueType3 !== "4"
    ) {
      return true;
    }
    return false;
  }

  async validateComplaintRemedies() {
    let details = this.omniJsonData.Case.ResolutionInformation;
    this.checkReferredToFirm(
      details.ComplaintRemedy1,
      details.detailsOfComplaint1,
      "1"
    );
    this.checkRemedyInfo(
      details.ComplaintSubRemedy1,
      details.durationOfRemedy1,
      "1",
      details.otherRemedy1,
      details.rewardPoints1
    );
    this.checkPaymentProvided(
      details.ComplaintRemedy1,
      details.ComplaintSubRemedy1,
      details.PaymentAmountProvided1,
      "1"
    );
    this.validateSecondaryComplaintRemedies(details);
    this.validateTertiaryComplaintRemedies(details);
  }

  validateSecondaryComplaintRemedies(details) {
    if (details.secondComplaintRemedyCheckbox === CUSTOMER_AGREES) {
      this.checkFields(details, this.omniJsonData.secRemedyMap);

      this.checkReferredToFirm(
        details.ComplaintRemedy2,
        details.detailsOfComplaint2,
        "2"
      );
      this.checkRemedyInfo(
        details.ComplaintSubRemedy2,
        details.durationOfRemedy2,
        "2",
        details.otherRemedy2,
        details.rewardPoints2
      );
      this.checkPaymentProvided(
        details.ComplaintRemedy2,
        details.ComplaintSubRemedy2,
        details.PaymentAmountProvided2,
        "2"
      );
    }
  }

  validateTertiaryComplaintRemedies(details) {
    if (details.thirdComplaintRemedyCheckbox === CUSTOMER_AGREES) {
      this.checkFields(details, this.omniJsonData.thirdRemedyMap);
      this.checkReferredToFirm(
        details.ComplaintRemedy3,
        details.detailsOfComplaint3,
        "3"
      );
      this.checkRemedyInfo(
        details.ComplaintSubRemedy3,
        details.durationOfRemedy3,
        "3",
        details.otherRemedy3,
        details.rewardPoints3
      );
      this.checkPaymentProvided(
        details.ComplaintRemedy3,
        details.ComplaintSubRemedy3,
        details.PaymentAmountProvided3,
        "3"
      );
    }
  }
  checkReferredToFirm(complaintRemedy, detailsOfComplaint, manufacturerNumber) {
    if (complaintRemedy === REFERRED_TO_FIRM && !detailsOfComplaint) {
      this.missingFields.push(
        "The details of this complaint have been provided to the product manufacturer " +
          manufacturerNumber
      );
    }
  }
  checkRemedyInfo(
    complaintSubRemedy,
    durationOfRemedy,
    remedyNumber,
    otherRemedy,
    rewardPoints
  ) {
    if (SUB_REMS.includes(complaintSubRemedy) && !durationOfRemedy) {
      this.missingFields.push("Duration Of Remedy (months) " + remedyNumber);
    }

    if (complaintSubRemedy === OTHER && !otherRemedy) {
      this.missingFields.push("Other Remedy " + remedyNumber);
    }

    if (complaintSubRemedy === "Reward Points" && !rewardPoints) {
      this.missingFields.push("Reward Points " + remedyNumber);
    }
  }

  checkPaymentProvided(
    complaintRemedy,
    complaintSubRemedy,
    paymentAmountProvided,
    remedyNumber
  ) {
    if (
      (FINANCIAL_REMEDY.includes(complaintRemedy) ||
        SUB_REMS_PAYMENT.includes(complaintSubRemedy)) &&
      !paymentAmountProvided
    ) {
      this.missingFields.push("Payment Amount Provided " + remedyNumber);
    }
  }

  checkFields(detail, reMap) {
    reMap.forEach((field) => {
      const [key, label] = Object.entries(field)[0];
      if (
        (key.includes("Block") && (!detail[key] || !detail[key].Id)) ||
        (!key.includes("Block") && !detail[key])
      ) {
        this.missingFields.push(label);
      }
    });
  }
}
