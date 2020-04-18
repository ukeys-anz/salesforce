import { LightningElement, track, api } from "lwc";
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
import DECENT_FIELD from "@salesforce/schema/Case.IDR_NC_Descent__c";
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
import PRODUCT_LINE_FIELD from "@salesforce/schema/Case.IDR_Product_or_Service_Line__c";
import PRODUCT_CATEGORY_FIELD from "@salesforce/schema/Case.IDR_Product_or_Service_Category__c";
import PRODUCT_TYPE_FIELD from "@salesforce/schema/Case.IDR_Product_or_Service_Type__c";
import ACCOUNT_POLICY_FIELD from "@salesforce/schema/Case.IDR_Account_Card_Policy_Number__c";
import DESCRIPTION_FIELD from "@salesforce/schema/Case.Description";
import DESIRED_OUTCOME_FIELD from "@salesforce/schema/Case.IDR_Complainant_Desired_Outcome__c";

//complaint resolution fields

import COMPLAINT_OUTCOME from "@salesforce/schema/Case.IDR_Complaint_Outcome__c";
import COMPLAINT_REMEDY from "@salesforce/schema/Case.IDR_Complaint_Remedy__c";
import FINANCIAL_COMPENSATION from "@salesforce/schema/Case.IDR_Financial_Compensation__c";
import OUTCOME_DESCRIPTION from "@salesforce/schema/Case.IDR_Description_of_Outcome__c";
import STATUS_FIELD from "@salesforce/schema/Case.Status";

//Systemic issue fields
import IS_COMMON_COMPLAINT_FIELD from "@salesforce/schema/Case.IDR_Is_Common__c";
import IS_REAL_FORM_NEED_FIELD from "@salesforce/schema/Case.IDR_Real_Form_Req__c";

const ERROR = "error";
const ERROR_TITLE = "Please complete all required fields.";
const SUCCESS = "success";
const SUCCESS_TITLE = "Complaint has been created successfully.";
const BUSINESS_TYPE_API = 2;
const RESOLVED_STATUS_API_NAME = "Resolved";
const YES_VALUE = "Yes";

export default class CreateComplaintLWC extends NavigationMixin(
  LightningElement
) {
  caseObject = CASE_OBJECT;

  //common case fields
  Priority = PRIORITY;
  ChannelReceived = CHANNEL_RECEIVED;
  complaintIssue = COMPLAINT_ISSUE;
  ProductorServiceLine = PRODUCT_LINE_FIELD;
  ProductorServiceCategory = PRODUCT_CATEGORY_FIELD;
  ProductorServiceType = PRODUCT_TYPE_FIELD;
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
  decent = DECENT_FIELD;
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
  financialCompensation = FINANCIAL_COMPENSATION;
  outcomeDescription = OUTCOME_DESCRIPTION;

  //systemic fields
  commonComplaint = IS_COMMON_COMPLAINT_FIELD;
  isRealFormNeeded = IS_REAL_FORM_NEED_FIELD;

  @api recordTypeId;
  @api recordTypeDevName;

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
  showComplianceFields;
  showSections;
  isComplaintResolved;
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

  //initialize components
  connectedCallback() {
    this.recordType = this.recordTypeId;
    this.isCustomerComplaint = this.recordTypeDevName === "Customer_Complaint";
    this.showComplianceFields = this.isCustomerComplaint || this.consentValue;
    this.showSections = this.isCustomerComplaint;
    this.isAddressRequired = false;
  }

  handleComplaintTypeChange(event) {
    this.isBusiness = event.detail.value == BUSINESS_TYPE_API;
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

  handleSectionToggle(event) {}

  handleConsentChange(event) {
    this.consentOptionValue = event.detail.value;
    this.consentValue = this.consentOptionValue === "Agrees";
    this.showComplianceFields = this.consentValue || this.isCustomerComplaint;
    this.showSections = true;
  }

  handleSearch(event) {
    this.displayCustomerInfo = true;
    this.customerId = this.customerIdValue;
  }
  handleCustomerNumberChange(event) {
    this.customerIdValue = event.target.value;
  }

  handleWrittenResponseChange(event) {
    this.writtenResponseValue = event.detail.value;
    this.isAddressRequired =
      this.writtenResponseValue == YES_VALUE ||
      (this.writtenRequiredValue != null &&
        this.writtenRequiredValue == YES_VALUE);
  }

  handleWrittenRequiredChange(event) {
    this.writtenRequiredValue = event.detail.value;
    this.isAddressRequired =
      this.writtenRequiredValue == YES_VALUE ||
      (this.writtenResponseValue != null &&
        this.writtenResponseValue == YES_VALUE);
  }

  handleSubmit(event) {
    event.preventDefault(); // stop the form from submitting
    this.template.querySelector(".saveButton").disabled = true;
    const fields = event.detail.fields;
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
    let valid = this.checkRequiredFields(fields);
    if (valid) {
      this.loading = true;
      const recordInput = { apiName: CASE_OBJECT.objectApiName, fields };
      createRecord(recordInput)
        .then(response => {
          if (response) {
            let caseId = response.id;
            this.template.querySelector(".saveButton").disabled = false;
            this.handleCaseSuccess(caseId);
          }
        })
        .catch(error => {
          let errormsg = error.body;
          console.log(errormsg);
          this.handleError();
        });
    } else {
      this.handleError();
    }
  }

  checkRequiredFields(fields) {
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
  }

  handleError() {
    this.loading = false;
    this.template.querySelector(".saveButton").disabled = false;
    const evt = new ShowToastEvent({
      title: ERROR_TITLE,
      variant: ERROR
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
