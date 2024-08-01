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

var itype, subtype, missingFields, caseDetails;
// Validate all Required Fields for Customer/Non-Customer Complaints
export async function validate(omniJsonData) {
  caseDetails = omniJsonData.Case;
  missingFields = [];
  await validateCustomerComplaint(omniJsonData);
  await validateNonCustomerComplaint(omniJsonData);
  await validateComplaintRemedies(omniJsonData);
  await validateResolutionInformation(omniJsonData);

  return missingFields;
}
//  Validate Required fields for Customer Complaint
async function validateCustomerComplaint(omniJsonData) {
  let cmpMap = JSON.parse(JSON.stringify(omniJsonData.cmpMap));
  if (caseDetails.isThisCustomerComplaint === CUSTOMER_AGREES) {
    checkFields(caseDetails.CustomerDetails, omniJsonData.custMap);
    checkCustomerIdentifier(caseDetails.CustomerDetails);

    cmpMap.push({ AccountPolicyNumber: "Account/Policy Number" });
    checkCommonValidations(
      caseDetails.ComplaintDetails,
      caseDetails,
      omniJsonData
    );
  }

  checkFields(caseDetails.ComplaintDetails, cmpMap);
}
//  Validate Customer Number Identifier
function checkCustomerIdentifier(customerDetails) {
  if (
    customerDetails.CustomerIdentifier === "CACHE ID" &&
    !customerDetails.Customer1
  ) {
    missingFields.push("Customer Number");
  }
  if (
    customerDetails.CustomerIdentifier !== "CACHE ID" &&
    !customerDetails.Customer
  ) {
    missingFields.push("Customer Number");
  }
}
//  Validate Required fields for Non-Customer Complaint
async function validateNonCustomerComplaint(omniJsonData) {
  let Complaintdetails = caseDetails.ComplaintDetails;

  let customerDetails = caseDetails.CustomerDetails;
  if (
    caseDetails.isThisCustomerComplaint === CUSTOMER_DISAGREES &&
    !caseDetails.CustomerDecision
  ) {
    missingFields.push("Customer Decision");
  }

  if (caseDetails.isThisCustomerComplaint === CUSTOMER_DISAGREES) {
    validateNonCustMap(customerDetails, caseDetails, omniJsonData);
    checkCommonValidations(Complaintdetails, caseDetails, omniJsonData);
  }
}
//  Validate Required for Non-Customer Complaint if Customer Agrees
function validateNonCustMap(Complaintdetails, caseDetails, omniJsonData) {
  let nonCustMap = JSON.parse(JSON.stringify(omniJsonData.nonCustMap));
  if (caseDetails.CustomerDecision === "Agrees") {
    nonCustMap.push({ firstName: "First Name" });
    nonCustMap.push({ LastName: "Last Name" });
  }
  let temp = caseDetails.ResolutionInformation;
  if (
    temp.custWrittenResponse === CUSTOMER_AGREES ||
    temp.complaintRelatedHardship === CUSTOMER_AGREES
  ) {
    nonCustMap.push({ Street: "Street" });
    nonCustMap.push({ Suburb: "Suburb" });
    nonCustMap.push({ State: "State" });
  }

  checkFields(Complaintdetails, nonCustMap);
}
// Validate fields Common for Customer/Non-Customer Complaint
function checkCommonValidations(Complaintdetails, caseDetails, omniJsonData) {
  itype = Complaintdetails.IssueType;
  subtype = Complaintdetails.SubSequentIssueType;

  if (caseDetails.CustomerDetails.thirdPartyRepCheckbox === CUSTOMER_AGREES) {
    checkFields(caseDetails.CustomerDetails, omniJsonData.thirdPartyMap);
  }
  if (Complaintdetails.Issue2Checkbox === CUSTOMER_AGREES) {
    let secCmpMap = JSON.parse(JSON.stringify(omniJsonData.secCmpMap));
    checkForAccountPolicyNumber(Complaintdetails, secCmpMap, "2", caseDetails);
    itype = Complaintdetails.IssueType2;
    subtype = Complaintdetails.SubsequentIssueType2;
  }
  if (Complaintdetails.Issue3Checkbox === CUSTOMER_AGREES) {
    let thirdCmpMap = JSON.parse(JSON.stringify(omniJsonData.thirdCmpMap));
    checkForAccountPolicyNumber(
      Complaintdetails,
      thirdCmpMap,
      "3",
      caseDetails
    );
    itype = Complaintdetails.IssueType3;
    subtype = Complaintdetails.SubsequentIssueType3;
  }
  if (
    caseDetails.CustomerDetails.expressCaseCreationCheckbox ===
      CUSTOMER_AGREES &&
    !caseDetails.CustomerDetails.complaintAbout
  ) {
    missingFields.push("This Complaint Is About");
  }
}
// Validate Accout Policy fields
function checkForAccountPolicyNumber(
  details,
  issueMap,
  issueNumber,
  caseDetails
) {
  if (caseDetails.isThisCustomerComplaint === CUSTOMER_AGREES) {
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
  checkFields(details, issueMap);
}
// Validate Complaint's Resolution Information
async function validateResolutionInformation(omniJsonData) {
  let resolutionDetails = caseDetails.ResolutionInformation;
  if (checkIssueType(caseDetails)) {
    checkFields(resolutionDetails, omniJsonData.resInfoMap);
  }
  if (resolutionDetails.ComplaintStatus === CLOSED_STATUS) {
    checkFields(resolutionDetails, omniJsonData.closeCmpMap);
  }
  if (resolutionDetails.realFormRequired === CUSTOMER_AGREES)
    checkFields(resolutionDetails, omniJsonData.realMap);
  if (resolutionDetails.systemicIssue === CUSTOMER_AGREES)
    checkFields(resolutionDetails, omniJsonData.sysIssueMap);
  if (
    resolutionDetails.systemicIssue === CUSTOMER_AGREES &&
    caseDetails.ComplaintDetails.Issue2Checkbox === CUSTOMER_AGREES
  ) {
    if (!resolutionDetails.additionalissues)
      missingFields.push("Which issue is possibly systemic?");
  }
  if (resolutionDetails.CAC === CUSTOMER_AGREES)
    checkFields(resolutionDetails, omniJsonData.cacMap);
  if (
    itype === SERVICE_QUALITY &&
    subtype === FAILURE_TO_RESPOND &&
    resolutionDetails.ComplaintStatus === CLOSED_STATUS &&
    !resolutionDetails.CAC
  ) {
    missingFields.push("Is this a complaint about a complaint?");
  }
  if (resolutionDetails.ComplaintStatus === ESCALATED_STATUS)
    checkFields(resolutionDetails, omniJsonData.escMap);
}
// Validate Issue Type
function checkIssueType(caseDetails) {
  if (
    caseDetails.CustomerDecision !== "Disagrees" &&
    caseDetails.ComplaintDetails.IssueType !== "4" &&
    caseDetails.ComplaintDetails.IssueType2 !== "4" &&
    caseDetails.ComplaintDetails.IssueType3 !== "4"
  ) {
    return true;
  }
  return false;
}
// Validate Complaint Remedies Information
async function validateComplaintRemedies(omniJsonData) {
  let details = omniJsonData.Case.ResolutionInformation;
  checkReferredToFirm(
    details.ComplaintRemedy1,
    details.detailsOfComplaint1,
    "1"
  );
  checkRemedyInfo(
    details.ComplaintSubRemedy1,
    details.durationOfRemedy1,
    "1",
    details.otherRemedy1,
    details.rewardPoints1
  );
  checkPaymentProvided(
    details.ComplaintRemedy1,
    details.ComplaintSubRemedy1,
    details.PaymentAmountProvided1,
    "1"
  );
  validateSecondaryComplaintRemedies(details, omniJsonData);
  validateTertiaryComplaintRemedies(details, omniJsonData);
}
// Validate Secondary Complaint Remedies Information

function validateSecondaryComplaintRemedies(details, omniJsonData) {
  if (details.secondComplaintRemedyCheckbox === CUSTOMER_AGREES) {
    checkFields(details, omniJsonData.secRemedyMap);

    checkReferredToFirm(
      details.ComplaintRemedy2,
      details.detailsOfComplaint2,
      "2"
    );
    checkRemedyInfo(
      details.ComplaintSubRemedy2,
      details.durationOfRemedy2,
      "2",
      details.otherRemedy2,
      details.rewardPoints2
    );
    checkPaymentProvided(
      details.ComplaintRemedy2,
      details.ComplaintSubRemedy2,
      details.PaymentAmountProvided2,
      "2"
    );
  }
}
// Validate Third Complaint Remedies Information
function validateTertiaryComplaintRemedies(details, omniJsonData) {
  if (details.thirdComplaintRemedyCheckbox === CUSTOMER_AGREES) {
    checkFields(details, omniJsonData.thirdRemedyMap);
    checkReferredToFirm(
      details.ComplaintRemedy3,
      details.detailsOfComplaint3,
      "3"
    );
    checkRemedyInfo(
      details.ComplaintSubRemedy3,
      details.durationOfRemedy3,
      "3",
      details.otherRemedy3,
      details.rewardPoints3
    );
    checkPaymentProvided(
      details.ComplaintRemedy3,
      details.ComplaintSubRemedy3,
      details.PaymentAmountProvided3,
      "3"
    );
  }
}
// Validate Complaint Remedy's Referred to Firm
function checkReferredToFirm(
  complaintRemedy,
  detailsOfComplaint,
  manufacturerNumber
) {
  if (complaintRemedy === REFERRED_TO_FIRM && !detailsOfComplaint) {
    missingFields.push(
      "The details of this complaint have been provided to the product manufacturer " +
        manufacturerNumber
    );
  }
}
// Validate Complaint Duration, Other Remedy and Reward points related to Complaint Remedies
function checkRemedyInfo(
  complaintSubRemedy,
  durationOfRemedy,
  remedyNumber,
  otherRemedy,
  rewardPoints
) {
  if (SUB_REMS.includes(complaintSubRemedy) && !durationOfRemedy) {
    missingFields.push("Duration Of Remedy (months) " + remedyNumber);
  }

  if (complaintSubRemedy === OTHER && !otherRemedy) {
    missingFields.push("Other Remedy " + remedyNumber);
  }

  if (complaintSubRemedy === "Reward Points" && !rewardPoints) {
    missingFields.push("Reward Points " + remedyNumber);
  }
}
// Validate Payment Provided field on Complaint
function checkPaymentProvided(
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
    missingFields.push("Payment Amount Provided " + remedyNumber);
  }
}
// Check Required Field Map from Omniscript
function checkFields(detail, reMap) {
  reMap.forEach((field) => {
    const [key, label] = Object.entries(field)[0];
    if (
      (key.includes("Block") && (!detail[key] || !detail[key].Id)) ||
      (!key.includes("Block") && !detail[key])
    ) {
      missingFields.push(label);
    }
  });
}
