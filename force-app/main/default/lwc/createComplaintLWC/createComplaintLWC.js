import { LightningElement, api } from "lwc";
import { createRecord } from "lightning/uiRecordApi";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { NavigationMixin } from "lightning/navigation";
import CASE_OBJECT from "@salesforce/schema/Case";
import CAP_CIS_ID_FIELD from "@salesforce/schema/Case.IDR_Customer_Number__c";

//3rd Party Fields
import THIRD_PARTY_NAME_FIELD from "@salesforce/schema/Case.IDR_3rdParty_Name__c";
import THIRD_PARTY_EMAIL_FIELD from "@salesforce/schema/Case.IDR_3rdParty_Email__c";
import THIRD_PARTY_MOBILE_FIELD from "@salesforce/schema/Case.IDR_3rdParty_Mobile__c";
import THIRD_PARTY_PHONE_FIELD from "@salesforce/schema/Case.IDR_3rdParty_Phone__c";
import THIRD_PARTY_STREET_FIELD from "@salesforce/schema/Case.IDR_3rdParty_Street__c";
import THIRD_PARTY_SUBURB_FIELD from "@salesforce/schema/Case.IDR_3rdParty_Suburb__c";
import THIRD_PARTY_POSTCODE_FIELD from "@salesforce/schema/Case.IDR_3rdParty_Postcode__c";
import THIRD_PARTY_COUNTRY_FIELD from "@salesforce/schema/Case.IDR_3rdParty_Country__c";
import THIRD_PARTY_STATE_FIELD from "@salesforce/schema/Case.IDR_3rdParty_State__c";
import RECORDTYPE_FIELD from "@salesforce/schema/Case.RecordTypeId";

//Non Customer complaints
import COMPLAINT_TYPE_FIELD from "@salesforce/schema/Case.IDR_Complainant_Type__c";
import BUSINESS_NAME_FIELD from "@salesforce/schema/Case.IDR_NC_Business_Name__c";
import FIRST_NAME_FIELD from "@salesforce/schema/Case.IDR_NC_First_Name__c";
import MIDDLE_NAME_FIELD from "@salesforce/schema/Case.IDR_NC_Middle_Names__c";
import LAST_NAME_FIELD from "@salesforce/schema/Case.IDR_NC_Last_Name__c";
import AGE_FIELD from "@salesforce/schema/Case.IDR_NC_Age__c";
import GENDER_FIELD from "@salesforce/schema/Case.IDR_NC_Gender__c";
import DESCENT_FIELD from "@salesforce/schema/Case.IDR_NC_Descent__c";
import EMAIL_FIELD from "@salesforce/schema/Case.IDR_NC_Email__c";
import MOBILE_FIELD from "@salesforce/schema/Case.IDR_NC_Mobile__c";
import PHONE_FIELD from "@salesforce/schema/Case.IDR_NC_Phone__c";
import STREET_FIELD from "@salesforce/schema/Case.IDR_NC_Street__c";
import SUBURB_FIELD from "@salesforce/schema/Case.IDR_NC_Suburb__c";
import POSTCODE_FIELD from "@salesforce/schema/Case.IDR_NC_Postcode__c";
import COUNTRY_FIELD from "@salesforce/schema/Case.IDR_NC_Country__c";
import STATE_FIELD from "@salesforce/schema/Case.IDR_NC_State__c";
import CONSENT_OBTAINED from "@salesforce/schema/Case.IDR_NC_Is_Consent_Obtained__c";

//Is written Response Needed Fields
import WRITTEN_RESPONSE_REQUESTED_FIELD from "@salesforce/schema/Case.IDR_Is_Written_Resp_Requested__c";
import WRITTEN_RESPONSE_REQUIRED_FIELD from "@salesforce/schema/Case.IDR_Is_Written_Resp_Required__c";

//other details
import PRIORITY from "@salesforce/schema/Case.Priority";
import CHANNEL_RECEIVED from "@salesforce/schema/Case.Origin";
import COMPLAINT_ISSUE from "@salesforce/schema/Case.Type";
import COMPLAINT_SUBSEQUENT_ISSUE from "@salesforce/schema/Case.IDR_Subsequent_Issue__c";
import PRODUCT_LOOKUP_FIELD from "@salesforce/schema/Case.Product__c";
import ACCOUNT_POLICY_FIELD from "@salesforce/schema/Case.IDR_Account_Card_Policy_Number__c";
import DESCRIPTION_FIELD from "@salesforce/schema/Case.Description";
import DESIRED_OUTCOME_FIELD from "@salesforce/schema/Case.IDR_Complainant_Desired_Outcome__c";

//complaint resolution fields
import COMPLAINT_OUTCOME from "@salesforce/schema/Case.IDR_Complaint_Outcome__c";
import COMPLAINT_REMEDY from "@salesforce/schema/Case.IDR_Complaint_Remedy__c";
import FINANCIAL_COMPENSATION from "@salesforce/schema/Case.IDR_Financial_Compensation__c";
import NON_FINANCIAL_REMEDY from "@salesforce/schema/Case.IDR_Non_Financial_Remedy__c";
import OUTCOME_DESCRIPTION from "@salesforce/schema/Case.IDR_Description_of_Outcome__c";
import STATUS_FIELD from "@salesforce/schema/Case.Status";

//Systemic issue fields
import IS_COMMON_COMPLAINT_FIELD from "@salesforce/schema/Case.IDR_Is_Common__c";
import IS_REAL_FORM_NEED_FIELD from "@salesforce/schema/Case.IDR_Real_Form_Req__c";

const ERROR = "error";
const ERROR_REQUIRED_TITLE = "Please complete all required fields: ";
const ERROR_UNKNOWN_TITLE = "An error has occurred.";
const SUCCESS = "success";
const SUCCESS_TITLE = "Complaint has been created successfully.";
const BUSINESS_TYPE_API = "2";
const RESOLVED_STATUS_API_NAME = "Resolved";
const YES_VALUE = "Yes";
const COMPLAINT_REMEDY_FIN_VALUE = "1";
const COMPLAINT_REMEDY_NON_FIN_VALUE = "2";

export default class CreateComplaintLWC extends NavigationMixin(
  LightningElement
) {
  caseObject = CASE_OBJECT;

  //common case fields
  Priority = PRIORITY;
  ChannelReceived = CHANNEL_RECEIVED;
  complaintIssue = COMPLAINT_ISSUE;
  complaintSubIssue = COMPLAINT_SUBSEQUENT_ISSUE;
  Product = PRODUCT_LOOKUP_FIELD;
  DescriptionofIssue = DESCRIPTION_FIELD;
  ComplainantDesiredOutcome = DESIRED_OUTCOME_FIELD;

  //Customer complaint details
  accountOrPolicyNumber = ACCOUNT_POLICY_FIELD;
  CapCisID = CAP_CIS_ID_FIELD;

  //Non customer complaint details
  complaintType = COMPLAINT_TYPE_FIELD;
  businessName = BUSINESS_NAME_FIELD;
  firstName = FIRST_NAME_FIELD;
  middleNames = MIDDLE_NAME_FIELD;
  lastName = LAST_NAME_FIELD;
  age = AGE_FIELD;
  gender = GENDER_FIELD;
  descent = DESCENT_FIELD;
  email = EMAIL_FIELD;
  mobile = MOBILE_FIELD;
  phone = PHONE_FIELD;
  street = STREET_FIELD;
  suburb = SUBURB_FIELD;
  postcode = POSTCODE_FIELD;
  country = COUNTRY_FIELD;
  state = STATE_FIELD;
  consentObtained = CONSENT_OBTAINED;

  //3rd Party Fields
  thirdPartyName = THIRD_PARTY_NAME_FIELD;
  thirdPartyEmail = THIRD_PARTY_EMAIL_FIELD;
  thirdPartyMobile = THIRD_PARTY_MOBILE_FIELD;
  thirdPartyPhone = THIRD_PARTY_PHONE_FIELD;
  thirdPartyStreet = THIRD_PARTY_STREET_FIELD;
  thirdPartySuburb = THIRD_PARTY_SUBURB_FIELD;
  thirdPartyPostcode = THIRD_PARTY_POSTCODE_FIELD;
  thirdPartyCountry = THIRD_PARTY_COUNTRY_FIELD;
  thirdPartyState = THIRD_PARTY_STATE_FIELD;

  //written consent fields
  writtenResponseRequested = WRITTEN_RESPONSE_REQUESTED_FIELD;
  writtenResponseRequired = WRITTEN_RESPONSE_REQUIRED_FIELD;

  //complaint resolution fields
  complaintOutcome = COMPLAINT_OUTCOME;
  complaintRemedy = COMPLAINT_REMEDY;
  financialCompensation = "";
  outcomeDescription = OUTCOME_DESCRIPTION;
  nonFinancialRemedy = NON_FINANCIAL_REMEDY;

  //systemic fields
  commonComplaint = IS_COMMON_COMPLAINT_FIELD;
  isRealFormNeeded = IS_REAL_FORM_NEED_FIELD;

  @api recordTypeId;
  @api recordTypeDevName;
  @api contextRecordId;

  hasNominatedThirdParty = false;
  activeSections = ["A", "B", "C"];
  displayCustomerInfo = false;
  customerIdValue = "";
  customerId = "";
  writtenResponseValue;
  writtenRequiredValue;
  loading = false;
  isCustomerComplaint;
  consentValue = true; //start with true with an intention to capture non anz complainant details
  consentOptionValue;
  isBusiness = false;
  recordType;
  product;
  showComplianceFields;
  showSections;
  isComplaintResolved;
  isFinancialComplaintRemedy;
  isNonFinancialComplaintRemedy;
  isCommonComplaint;
  isRealFormNeeded;
  isAddressRequired;
  consentOptions = [
    { label: "Agrees", value: "Agrees" },
    { label: "Disagrees", value: "Disagrees" }
  ];

  writtenresponseoptions = [
    { label: "Yes", value: "Yes" },
    { label: "No", value: "No" }
  ];

  writtenrequiredoptions = [
    { label: "Yes", value: "Yes" },
    { label: "No", value: "No" }
  ];

  //form validation fields.
  missingDataField = "";
  dataValid = false;

  //initialize components
  connectedCallback() {
    this.recordType = this.recordTypeId;
    this.product =
      this.contextRecordId && this.contextRecordId.match(/01t[a-z0-9]+/i)
        ? this.contextRecordId
        : "";
    this.isCustomerComplaint = this.recordTypeDevName === "Customer_Complaint";
    this.showComplianceFields = this.isCustomerComplaint || this.consentValue;
    this.showSections = this.isCustomerComplaint;
    this.isAddressRequired = false;
  }

  handleComplaintTypeChange(event) {
    this.isBusiness = event.detail.value === BUSINESS_TYPE_API;
  }

  handle3rdPartyToggleChange(event) {
    this.hasNominatedThirdParty = event.target.checked;
  }

  handleCommonComplaint(event) {
    this.isCommonComplaint = event.target.checked;
  }

  handleRealFormNeeded(event) {
    this.isRealFormNeeded = event.target.checked;
  }

  handleComplaintResolved(event) {
    this.isComplaintResolved = event.target.checked;
  }

  handleComplaintRemedy(event) {
    if (event.detail.value === COMPLAINT_REMEDY_FIN_VALUE) {
      this.isFinancialComplaintRemedy = true;
      this.isNonFinancialComplaintRemedy = false;
    } else if (event.detail.value === COMPLAINT_REMEDY_NON_FIN_VALUE) {
      this.isFinancialComplaintRemedy = false;
      this.isNonFinancialComplaintRemedy = true;
    } else {
      this.isFinancialComplaintRemedy = false;
      this.isNonFinancialComplaintRemedy = false;
    }
  }

  handleFinancialCompensation(event) {
    this.financialCompensation = event.target.value;
  }

  handleSectionToggle() {}

  handleConsentChange(event) {
    this.consentOptionValue = event.detail.value;
    this.consentValue = this.consentOptionValue === "Agrees";
    this.showComplianceFields = this.consentValue || this.isCustomerComplaint;
    this.showSections = true;
  }

  handleSearch() {
    this.displayCustomerInfo = true;
    this.customerId = this.customerIdValue;
  }

  handleCustomerNumberChange(event) {
    this.customerIdValue = event.target.value;
  }

  handleWrittenResponseChange(event) {
    this.writtenResponseValue = event.detail.value;
    this.isAddressRequired =
      this.writtenResponseValue === YES_VALUE ||
      (this.writtenRequiredValue != null &&
        this.writtenRequiredValue === YES_VALUE);
  }

  handleWrittenRequiredChange(event) {
    this.writtenRequiredValue = event.detail.value;
    this.isAddressRequired =
      this.writtenRequiredValue === YES_VALUE ||
      (this.writtenResponseValue != null &&
        this.writtenResponseValue === YES_VALUE);
  }

  handleProductChange(event) {
    this.product = event.detail.value[0];
  }

  //form validation.
  validateFields() {
    this.loading = true;
    let fieldsValid = this.CheckAllFields();
    if (!fieldsValid) {
      this.dataValid = false;
      this.handleError(this.missingDataField.replace(/^,\s/, ""));
      this.missingDataField = "";
    } else {
      this.dataValid = true;
    }
  }

  CheckAllFields() {
    let requiredField = this.getRequiredFields();
    // validate the all the required field data has been provided.
    let isFieldValid = [
      ...this.template.querySelectorAll("lightning-input-field")
    ].reduce((isValidSoFar, inputCmp) => {
      if (inputCmp.id) {
        let getId = inputCmp.id.split("-");
        if (requiredField[getId[0]] && !inputCmp.value) {
          isValidSoFar = false;
          this.missingDataField += requiredField[getId[0]] + ", ";
        }
      }
      return isValidSoFar;
    }, true);

    if (!this.writtenResponseValue) {
      isFieldValid = false;
      this.missingDataField +=
        "Is the customer requesting a written response?, ";
    }
    if (!this.writtenRequiredValue) {
      isFieldValid = false;
      this.missingDataField +=
        "Is the complaint relating to hardship, a declined insurance claim, the value of an insurance claim or a decision of a superannuation trustee?, ";
    }
    if (this.missingDataField !== "") {
      this.missingDataField =
        ERROR_REQUIRED_TITLE + this.missingDataField.replace(/,\s$/, ". ");
    }

    // validate the data in customer number is as expected.
    if (
      this.isCustomerComplaint &&
      !this.customerIdValue.match("^[0-9]{10,}$")
    ) {
      isFieldValid = false;
      this.missingDataField +=
        "Customer number must be numbers and at least 10 digits long. ";
    }
    // validate the data in email address fields is correct.
    let isEmailValid = [
      ...this.template.querySelectorAll("lightning-input-field")
    ].reduce((isValidSoFar, inputCmp) => {
      if (inputCmp.id) {
        let getId = inputCmp.id.split("-");
        if (
          getId[0].includes("email") &&
          requiredField[getId[0]] &&
          inputCmp.value
        ) {
          let emailRegex =
            '^(([^<>()\\[\\]\\.,;:\\s@"]+(\\.+[^<>()\\[\\]\\.,;:\\s@"]+)*)|(".+"))@(([^<>()[\\]\\.,;:\\s@"]+\\.)+[^<>()[\\]\\.,;:\\s@"]{2,})$';
          if (!inputCmp.value.match(emailRegex)) {
            isValidSoFar = false;
            this.missingDataField += requiredField[getId[0]] + " is invalid. ";
          }
        }
      }
      return isValidSoFar;
    }, true);

    // ensure data in the financial compensation field is correct if this complaint has financial remedy
    let isFinCompValid = true;
    if (this.isFinancialComplaintRemedy) {
      isFinCompValid = this.validateFinancialCompensation();
    }
    return isFieldValid && isEmailValid && isFinCompValid;
  }

  handleSubmit(event) {
    event.preventDefault(); // stop the form from submitting

    //create case if form validation was successful
    if (this.dataValid) {
      this.template.querySelector(".saveButton").disabled = true;
      const fields = event.detail.fields;
      fields[PRODUCT_LOOKUP_FIELD.fieldApiName] = this.product;
      fields[CAP_CIS_ID_FIELD.fieldApiName] = this.customerIdValue;
      fields[
        WRITTEN_RESPONSE_REQUESTED_FIELD.fieldApiName
      ] = this.writtenResponseValue;
      fields[
        WRITTEN_RESPONSE_REQUIRED_FIELD.fieldApiName
      ] = this.writtenRequiredValue;
      fields[CONSENT_OBTAINED.fieldApiName] = this.consentValue;
      fields[RECORDTYPE_FIELD.fieldApiName] = this.recordType;
      if (this.isComplaintResolved) {
        fields[STATUS_FIELD.fieldApiName] = RESOLVED_STATUS_API_NAME;
        if (this.isFinancialComplaintRemedy) {
          fields[
            FINANCIAL_COMPENSATION.fieldApiName
          ] = this.financialCompensation;
        }
      }
      if (this.isRealFormNeeded) {
        fields[IS_REAL_FORM_NEED_FIELD.fieldApiName] = true;
      }
      if (this.isCommonComplaint) {
        fields[IS_COMMON_COMPLAINT_FIELD.fieldApiName] = true;
      }
      if (!this.hasNominatedThirdParty) {
        fields[THIRD_PARTY_COUNTRY_FIELD.fieldApiName] = "";
      }
      const recordInput = { apiName: CASE_OBJECT.objectApiName, fields };
      createRecord(recordInput)
        .then((response) => {
          if (response) {
            let caseId = response.id;
            this.template.querySelector(".saveButton").disabled = false;
            this.handleCaseSuccess(caseId);
          }
        })
        .catch((error) => {
          this.handleError(error);
        });
    }
  }

  handleCustomerNumberOnblur() {
    let capCisfield = this.template.querySelector(".inputCapCisId");
    if (!this.customerIdValue.match("^[0-9]{10,}$")) {
      //set an error
      capCisfield.setCustomValidity(
        "Customer number must be numbers and at least 10 digits long"
      );
      capCisfield.reportValidity();
    } else {
      //reset an error
      capCisfield.setCustomValidity("");
      capCisfield.reportValidity();
    }
  }

  /* checkRequiredFields() {
    let isValid = true;
    if (this.isCustomerComplaint || this.consentValue) {
      if (
        this.writtenRequiredValue != null &&
        this.writtenResponseValue != null
      ) {
        isValid = true;
      } else {
        isValid = false;
      }
    }
    return isValid;
  }*/

  // add all the required fields for this complaint.
  getRequiredFields() {
    let requiredField = [];
    if (this.isCustomerComplaint) {
      requiredField.CustomerType = "Customer Type";
      requiredField.descent = "Aboriginal or Torres Strait Islander";
    } else {
      requiredField.customerType2 = "Customer Type";
      requiredField.age = "Age";
      requiredField.gender = "Gender";
      requiredField.descent2 = "Aboriginal or Torres Strait Islander";

      if (this.consentValue) {
        requiredField.firstName = "First Name";
        requiredField.lastName = "Last Name";
        requiredField.email = "Email";
        requiredField.mobileinput = "Mobile";
      }
      if (this.isAddressRequired) {
        requiredField.street = "Street";
        requiredField.suburb = "Suburb";
        requiredField.postcode = "Postcode";
      }
      requiredField.country = "Country";
      requiredField.state = "State";
    }

    if (this.hasNominatedThirdParty) {
      requiredField.thirdPartyName = "Nominated 3rd party name";
      requiredField.thirdPartyemail = "Nominated 3rd party email address";
      requiredField.thirdPartyMobile = "Nominated 3rd party mobile";
      requiredField.thirdPartyCountry = "Nominated 3rd party country";
      requiredField.thirdPartyState = "Nominated 3rd party state";
    }

    requiredField.descOfIssue = "Description of Issue";
    requiredField.custOutCome = "Customer Desired Outcome";
    requiredField.priority = "Priority";
    requiredField.ChannelReceived = "Channel Received";
    requiredField.issueType = "Issue Type";
    requiredField.product = "Product";
    requiredField.accPolicyNum = "Account or Policy Number";
    requiredField.subsequentIssue = "Subsequent Issue Type";

    if (this.isComplaintResolved) {
      requiredField.compOutCome = "Complaint Outcome";
      requiredField.compRemedy = "Complaint Remedy";
      requiredField.descOutcome = "Description of Outcome";
    }

    if (this.isNonFinancialComplaintRemedy) {
      requiredField.nonFinancialRemedy = "Non-Financial Remedy";
    }
    return requiredField;
  }

  validateFinancialCompensation() {
    let isValid = true;
    const regex = "^[1-9]\\d{0,6}(\\.\\d{1,2})?$|^0\\.(?!0+$)\\d{1,2}$";
    if (!this.financialCompensation.match(regex)) {
      isValid = false;
      this.missingDataField +=
        "Financial Compensation must be a positive value with up to 7 whole digits and 2 decimal digits. ";
    }
    return isValid;
  }

  handleError(error) {
    console.log(error);
    let msg = ERROR_UNKNOWN_TITLE;
    if (typeof error === "string") {
      msg = error;
    } else if (error.body) {
      if (Array.isArray(error.body)) {
        msg = error.body.map((e) => e.message).join(", ");
      } else if (typeof error.body.message === "string") {
        msg = error.body.message;
      }
    }
    this.loading = false;
    this.template.querySelector(".saveButton").disabled = false;
    const evt = new ShowToastEvent({
      title: msg,
      variant: ERROR,
      mode: "sticky"
    });
    this.dispatchEvent(evt);
  }

  handleCaseSuccess(event) {
    this.loading = false;
    const toastEvent = new ShowToastEvent({
      message: SUCCESS_TITLE,
      variant: SUCCESS
    });
    this.dispatchEvent(toastEvent);
    const selectEvent = new CustomEvent("navigaterecord", {
      detail: { caseId: event }
    });
    this.dispatchEvent(selectEvent);
  }
}
