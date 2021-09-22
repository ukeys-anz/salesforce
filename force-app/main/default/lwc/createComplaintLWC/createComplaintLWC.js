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
import THIRD_PARTY_RELATIONSHIP from "@salesforce/schema/Case.IDR_3rdParty_Relationship_To_Complainant__c";
import THIRD_PARTY_COMMS from "@salesforce/schema/Case.IDR_SwicthOff_3rd_Party_Notification__c";
import RECORDTYPE_FIELD from "@salesforce/schema/Case.RecordTypeId";
import THIRD_PARTY_PRODUCT_MANUFACTURER from "@salesforce/schema/Case.IDR_Product_Manufacturer__c";
import THIRD_PARTY_OTHER_PRODUCT_MANUFACTURER from "@salesforce/schema/Case.Name_of_product_manufacturer__c";
import THIRD_PARTY_IS_DETAILS_PROVIDED_TO_PRODUCT_MANUFACTURER from "@salesforce/schema/Case.Provided_details_to_Product_Manufacturer__c";

//Non Customer complaints
import COMPLAINT_TYPE_FIELD from "@salesforce/schema/Case.IDR_Complainant_Type__c";
import BUSINESS_NAME_FIELD from "@salesforce/schema/Case.IDR_NC_Business_Name__c";
import FIRST_NAME_FIELD from "@salesforce/schema/Case.IDR_NC_First_Name__c";
import MIDDLE_NAME_FIELD from "@salesforce/schema/Case.IDR_NC_Middle_Names__c";
import LAST_NAME_FIELD from "@salesforce/schema/Case.IDR_NC_Last_Name__c";
import AGE_FIELD from "@salesforce/schema/Case.IDR_NC_Age__c";
import GENDER_FIELD from "@salesforce/schema/Case.IDR_NC_Gender__c";
import EMAIL_FIELD from "@salesforce/schema/Case.IDR_NC_Email__c";
import MOBILE_FIELD from "@salesforce/schema/Case.IDR_NC_Mobile__c";
import PHONE_FIELD from "@salesforce/schema/Case.IDR_NC_Phone__c";
import STREET_FIELD from "@salesforce/schema/Case.IDR_NC_Street__c";
import SUBURB_FIELD from "@salesforce/schema/Case.IDR_NC_Suburb__c";
import POSTCODE_FIELD from "@salesforce/schema/Case.IDR_NC_Postcode__c";
import COUNTRY_FIELD from "@salesforce/schema/Case.IDR_NC_Country__c";
import STATE_FIELD from "@salesforce/schema/Case.IDR_NC_State__c";
import CONSENT_OBTAINED from "@salesforce/schema/Case.IDR_NC_Is_Consent_Obtained__c";
import CUSTOMER_COMMS from "@salesforce/schema/Case.IDR_SwitchOff_Customer_Notification__c";

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

//Systemic issue & compliance fields
import IS_COMMON_COMPLAINT_FIELD from "@salesforce/schema/Case.IDR_Is_Common__c";
import IS_REAL_FORM_NEED_FIELD from "@salesforce/schema/Case.IDR_Real_Form_Req__c";
import SYSTEMIC_ISSUE_DESCRIPTION from "@salesforce/schema/Case.IDR_Systemic_Issue_Description__c";
import SYSTEMIC_ISSUE_CATEGORY from "@salesforce/schema/Case.IDR_Systemic_Issue_Category__c";
import IS_REAL_FORM_SUBMITTED from "@salesforce/schema/Case.IDR_Real_Form_Submitted__c";
import REAL_FORM_REF_NO from "@salesforce/schema/Case.IDR_Real_Form_Ref_No__c";

//Is Escalated fields
import ESCALATED_TO from "@salesforce/schema/Case.IDR_Escalated_to__c";
import ESCALATION_REASON from "@salesforce/schema/Case.IDR_Escalation_Reason__c";

const ERROR_REQUIRED_TITLE = "Please complete all required fields:\n";
const ERROR_UNKNOWN_TITLE = "An error has occurred.";
const SUCCESS = "success";
const SUCCESS_TITLE = "Complaint has been created successfully.";
const BUSINESS_TYPE_API = "2";
const OPEN_STATUS_API_NAME = "Open";
// Future use : const ONHOLD_STATUS_API_NAME = "On Hold";
const ESCALATED_STATUS_API_NAME = "Escalated";
const UNDERINVESTIGATION_STATUS_API_NAME = "Under Investigation";
const RESOLVED_STATUS_API_NAME = "Resolved";
const CLOSED_STATUS_API_NAME = "Closed";
const YES_VALUE = "Yes";
const COMPLAINT_REMEDY_FIN_VALUE = "1";
const COMPLAINT_REMEDY_NON_FIN_VALUE = "2";
const OTHER = "Other";

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
  thirdPartyRelationShip = THIRD_PARTY_RELATIONSHIP;
  thirdPartyProductManufacturer = THIRD_PARTY_PRODUCT_MANUFACTURER;
  thirdPartyOtherProductManufacturer = THIRD_PARTY_OTHER_PRODUCT_MANUFACTURER;

  //written response fields
  writtenResponseRequested = WRITTEN_RESPONSE_REQUESTED_FIELD;
  writtenResponseRequired = WRITTEN_RESPONSE_REQUIRED_FIELD;

  //complaint resolution fields
  complaintOutcome = COMPLAINT_OUTCOME;
  complaintRemedy = COMPLAINT_REMEDY;
  financialCompensation = "";
  outcomeDescription = OUTCOME_DESCRIPTION;
  nonFinancialRemedy = NON_FINANCIAL_REMEDY;

  //systemic issue & compliance fields
  commonComplaint = IS_COMMON_COMPLAINT_FIELD;
  systemicIssueDescription = SYSTEMIC_ISSUE_DESCRIPTION;
  systemicIssueCategory = SYSTEMIC_ISSUE_CATEGORY;

  // escalation fields
  escalatedTo = ESCALATED_TO;
  escalationReason = ESCALATION_REASON;

  @api recordTypeId;
  @api recordTypeDevName;
  @api contextRecordId;

  isCustomerNotification = false;
  hasNominatedThirdParty = false;
  is3rdPartyNotification = false;
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
  productValue;
  showComplianceFields;
  showSections;
  isComplaintResolved;
  isComplaintEscalated;
  // future use: isComplaintOnhold;
  isFinancialComplaintRemedy;
  isNonFinancialComplaintRemedy;
  isCommonComplaintYesNo;
  isCommonComplaint;
  isAddressRequired;
  isRealFormNeeded;
  isRealFormSubmitted;
  realFormRefNo = "";
  isReferredToProductManufacturer = false;
  isOtherProductManufacturer = false;
  thirdPartyIsDetailsProvidedToProductManufacturer = false;
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

  commoncomplaintoptions = [
    { label: "Yes", value: "Yes" },
    { label: "No", value: "No" }
  ];

  realFormReqOptions = [
    { label: "Yes", value: "Yes" },
    { label: "No", value: "No" }
  ];

  //form validation fields.
  missingDataFields = "";
  isDataValid = false;
  caseStatus = OPEN_STATUS_API_NAME;
  isCustNumValidated = false;
  searchDisabled = true;
  //initialize components
  connectedCallback() {
    this.recordType = this.recordTypeId;
    this.productValue =
      this.contextRecordId && this.contextRecordId.match(/01t[a-z0-9]+/i)
        ? this.contextRecordId
        : "";
    this.isCustomerComplaint = this.recordTypeDevName === "Customer_Complaint";
    this.showComplianceFields = this.isCustomerComplaint || this.consentValue;
    this.showSections = this.isCustomerComplaint;
    this.isAddressRequired = false;
  }

  get statusOptions() {
    //future use:  { label: ONHOLD_STATUS_API_NAME, value: ONHOLD_STATUS_API_NAME },
    return [
      { label: OPEN_STATUS_API_NAME, value: OPEN_STATUS_API_NAME },
      {
        label: UNDERINVESTIGATION_STATUS_API_NAME,
        value: UNDERINVESTIGATION_STATUS_API_NAME
      },
      { label: ESCALATED_STATUS_API_NAME, value: ESCALATED_STATUS_API_NAME },
      { label: RESOLVED_STATUS_API_NAME, value: RESOLVED_STATUS_API_NAME },
      { label: CLOSED_STATUS_API_NAME, value: CLOSED_STATUS_API_NAME }
    ];
  }
  handleComplaintTypeChange(event) {
    this.isBusiness = event.detail.value === BUSINESS_TYPE_API;
  }

  handleCustomerNotificationChange(event) {
    this.isCustomerNotification = event.target.checked;
  }

  handle3rdPartyToggleChange(event) {
    this.hasNominatedThirdParty = event.target.checked;
  }

  handle3rdPartyNotificationChange(event) {
    this.is3rdPartyNotification = event.target.checked;
  }

  handleCommonComplaint(event) {
    this.isCommonComplaintYesNo = event.target.value;
    this.isCommonComplaint =
      this.isCommonComplaintYesNo === "Yes" ? true : false;
  }
  handleStatusChange(event) {
    console.log("event.target.value:" + event.target.value);
    this.caseStatus = event.target.value;
    this.isComplaintEscalated = false;
    this.isComplaintResolved = false;
    //future use: this.isComplaintonHold = false;
    /* Future use : case "On Hold":
          this.isComplaintOnhold = true;
          break;*/
    switch (this.caseStatus) {
      case "Resolved":
        this.isComplaintResolved = true;
        break;
      case "Escalated":
        this.isComplaintEscalated = true;
        break;
      case "Closed":
        this.isComplaintResolved = true;
        break;
      case "Under Investigation":
        break;
      default:
        this.caseStatus = OPEN_STATUS_API_NAME;
    }
  }
  handleComplaintRemedy(event) {
    if (event.detail.value === COMPLAINT_REMEDY_FIN_VALUE) {
      this.isFinancialComplaintRemedy = true;
      this.isNonFinancialComplaintRemedy = false;
      this.isReferredToProductManufacturer = false;
      this.isOtherProductManufacturer = false;
    } else if (event.detail.value === COMPLAINT_REMEDY_NON_FIN_VALUE) {
      this.isFinancialComplaintRemedy = false;
      this.isNonFinancialComplaintRemedy = true;
      this.isReferredToProductManufacturer = false;
      this.isOtherProductManufacturer = false;
    } else {
      this.isFinancialComplaintRemedy = false;
      this.isNonFinancialComplaintRemedy = false;
      this.isReferredToProductManufacturer = true;
    }
  }

  handleThirdPartyProductManufacturer(event) {
    if (event.detail.value === OTHER) {
      this.isOtherProductManufacturer = true;
    } else {
      this.isOtherProductManufacturer = false;
    }
  }
  handleIsDetailsProvidedToProductManufacturer(event) {
    this.thirdPartyIsDetailsProvidedToProductManufacturer =
      event.detail.checked;
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
    //prevent 3rd party fields from persisting in the UI when user selects "Agree" and "Nominate" and then switches to "Disagree"
    if (this.consentValue === false) this.hasNominatedThirdParty = false;
  }

  handleSearch() {
    this.displayCustomerInfo = true;
    this.customerId = this.customerIdValue;
  }

  handleCustomerNumberChange(event) {
    this.isCustNumValidated = false;
    this.customerIdValue = event.target.value;
    if (this.customerIdValue.match("^[0-9]{10,15}$")) {
      this.searchDisabled = false;
    } else {
      this.searchDisabled = true;
    }
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

  handleRealFormNeeded(event) {
    if (event.detail.value !== YES_VALUE) {
      this.isRealFormNeeded = this.isRealFormSubmitted = false;
    } else {
      this.isRealFormNeeded = true;
    }
  }

  handleRealFormSubmitted(event) {
    this.isRealFormSubmitted = event.detail.value === YES_VALUE ? true : false;
  }

  handleProductChange(event) {
    this.productValue = event.detail.value[0];
  }

  handleDescriptionChange(event) {
    this.description = event.detail.value;
  }

  handleRealFormRefNoChange(event) {
    this.realFormRefNo = event.detail.value;
  }

  //form validation.
  validateFields() {
    this.loading = true;
    if (!this.checkAllFields()) {
      this.isDataValid = false;
      this.handleError(this.missingDataFields.replace(/^,\s/, ""));
      this.missingDataFields = "";
    } else {
      this.isDataValid = true;
    }
  }

  checkAllFields() {
    let requiredFields = this.getRequiredFields();
    // validate that all the required field data has been provided.
    let isFieldValid = [
      ...this.template.querySelectorAll("lightning-input-field")
    ].reduce((isValidSoFar, inputCmp) => {
      if (inputCmp.id) {
        let getId = inputCmp.id.split("-");
        if (requiredFields[getId[0]] && !inputCmp.value) {
          isValidSoFar = false;
          this.missingDataFields += requiredFields[getId[0]] + ", ";
        }
      }
      return isValidSoFar;
    }, true);

    if (!this.isCustomerComplaint && !this.showSections) {
      isFieldValid = false;
      this.missingDataFields += "Customer Decision";
    } else {
      if (this.consentValue && !this.writtenResponseValue) {
        isFieldValid = false;
        this.missingDataFields +=
          "Is the customer requesting a written response?, ";
      }
      if (this.consentValue && !this.writtenRequiredValue) {
        isFieldValid = false;
        this.missingDataFields +=
          "Is the complaint relating to hardship, a declined insurance claim, the value of an insurance claim or a decision of a superannuation trustee?, ";
      }
    }
    if (
      typeof this.isCommonComplaint === "undefined" ||
      this.isCommonComplaint === null
    ) {
      isFieldValid = false;
      this.missingDataFields += "Is this a possible systemic issue?, ";
    }
    //Check for Real Form Validations
    let isRadioGroupValid = [
      ...this.template.querySelectorAll("lightning-radio-group")
    ].reduce((isValidSoFar, inputCmp) => {
      let getId = inputCmp.id.split("-");
      //Currently only checking for realFormRequiredGroup Validations within radio-group
      if (getId[0].includes("realFormRequiredGroup")) {
        if (typeof inputCmp.value === "undefined") {
          isValidSoFar = false;
          this.missingDataFields += inputCmp.label + ", ";
        }
      }
      return isValidSoFar;
    });
    if (this.missingDataFields !== "") {
      this.missingDataFields =
        ERROR_REQUIRED_TITLE + this.missingDataFields.replace(/,\s$/, ". ");
    }

    // validate the data in customer number is as expected.
    if (
      this.isCustomerComplaint &&
      !this.customerIdValue.match("^[0-9]{10,}$")
    ) {
      isFieldValid = false;
      this.missingDataFields +=
        "Customer number must be numbers and at least 10 digits long. ";
    } else if (this.isCustomerComplaint && !this.isCustNumValidated) {
      isFieldValid = false;
      this.missingDataFields +=
        "Customer number is not valid or has not been validated, check the number and try again. ";
    }
    // validate the data in email address fields is correct.
    let isEmailValid = [
      ...this.template.querySelectorAll("lightning-input-field")
    ].reduce((isValidSoFar, inputCmp) => {
      if (inputCmp.id) {
        let getId = inputCmp.id.split("-");
        if (
          (getId[0].includes("email") || getId[0].includes("Email")) &&
          requiredFields[getId[0]] &&
          inputCmp.value
        ) {
          let emailRegex =
            '^(([^<>()\\[\\]\\.,;:\\s@"]+(\\.+[^<>()\\[\\]\\.,;:\\s@"]+)*)|(".+"))@(([^<>()[\\]\\.,;:\\s@"]+\\.)+[^<>()[\\]\\.,;:\\s@"]{2,})$';
          if (!inputCmp.value.match(emailRegex)) {
            isValidSoFar = false;
            this.missingDataFields +=
              requiredFields[getId[0]] + " is invalid. ";
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
    if (
      this.isComplaintResolved &&
      this.isReferredToProductManufacturer &&
      !this.thirdPartyIsDetailsProvidedToProductManufacturer
    ) {
      isFieldValid = false;
      this.missingDataFields +=
        "Acknowledgement that the complaint details have been provided to the product manufacturer is required";
    }

    return isFieldValid && isEmailValid && isFinCompValid && isRadioGroupValid;
  }

  handleSubmit(event) {
    event.preventDefault(); // stop the form from submitting
    //create case if form validation was successful
    if (this.isDataValid) {
      this.template.querySelector(".saveButton").disabled = true;
      const fields = event.detail.fields;
      fields[DESCRIPTION_FIELD.fieldApiName] = this.description;
      fields[PRODUCT_LOOKUP_FIELD.fieldApiName] = this.productValue;
      fields[CAP_CIS_ID_FIELD.fieldApiName] = this.customerIdValue.replace(
        /^0+/,
        ""
      );
      fields[
        WRITTEN_RESPONSE_REQUESTED_FIELD.fieldApiName
      ] = this.writtenResponseValue;
      fields[
        WRITTEN_RESPONSE_REQUIRED_FIELD.fieldApiName
      ] = this.writtenRequiredValue;
      fields[CONSENT_OBTAINED.fieldApiName] = this.consentValue;
      fields[RECORDTYPE_FIELD.fieldApiName] = this.recordType;
      fields[STATUS_FIELD.fieldApiName] = this.caseStatus;
      if (this.isComplaintResolved) {
        if (this.isFinancialComplaintRemedy) {
          fields[
            FINANCIAL_COMPENSATION.fieldApiName
          ] = this.financialCompensation;
        }
        if (this.isReferredToProductManufacturer) {
          fields[
            THIRD_PARTY_IS_DETAILS_PROVIDED_TO_PRODUCT_MANUFACTURER.fieldApiName
          ] = this.thirdPartyIsDetailsProvidedToProductManufacturer;
        }
      }
      //If user wants to create an escalated case. Set the case status to default status and set the isEscalated flag.
      // This is required to handle afterUpdate trigger logic.
      // Status will be set to escalated in 'HandleCaseEscalationRules' of IDRCaseActions class from the trigger.
      if (
        this.isComplaintEscalated &&
        fields[ESCALATED_TO.fieldApiName] === "1"
      ) {
        fields[STATUS_FIELD.fieldApiName] = OPEN_STATUS_API_NAME;
        fields.IsEscalated = true;
      }
      if (this.isRealFormNeeded) {
        fields[IS_REAL_FORM_NEED_FIELD.fieldApiName] = true;
        fields[IS_REAL_FORM_SUBMITTED.fieldApiName] = this.isRealFormSubmitted;
        if (this.isRealFormSubmitted) {
          fields[REAL_FORM_REF_NO.fieldApiName] = this.realFormRefNo;
        }
      }

      if (this.isCustomerNotification) {
        fields[CUSTOMER_COMMS.fieldApiName] = this.isCustomerNotification;
      }

      if (this.is3rdPartyNotification) {
        fields[THIRD_PARTY_COMMS.fieldApiName] = this.is3rdPartyNotification;
      }

      fields[
        IS_COMMON_COMPLAINT_FIELD.fieldApiName
      ] = this.isCommonComplaintYesNo;

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

  // add all the required fields for this complaint.
  getRequiredFields() {
    let requiredFields = {};
    // mandatory fields
    requiredFields.descOfIssue = "Description of Issue";
    requiredFields.custOutCome = "Customer Desired Outcome";
    requiredFields.priority = "Priority";
    requiredFields.channelReceived = "Channel Received";
    requiredFields.issueType = "Issue Type";
    requiredFields.product = "Product or Service Name";
    requiredFields.accPolicyNum = "Account or Policy Number";
    requiredFields.subsequentIssue = "Subsequent Issue Type";

    // conditionnally required fields
    if (this.isCustomerComplaint) {
      requiredFields.customerType = "Customer Type";
    } else {
      requiredFields.customerType2 = "Customer Type";
      requiredFields.age = "Age";
      requiredFields.gender = "Gender";
      if (this.consentValue) {
        requiredFields.firstName = "First Name";
        requiredFields.lastName = "Last Name";
      }
      if (this.isAddressRequired) {
        requiredFields.street = "Street";
        requiredFields.suburb = "Suburb";
        requiredFields.postcode = "Postcode";
      }
      requiredFields.country = "Country";
      requiredFields.state = "State";
    }
    if (this.hasNominatedThirdParty) {
      requiredFields.thirdPartyName = "Nominated 3rd party name";
      requiredFields.thirdPartyCountry = "Nominated 3rd party country";
      requiredFields.thirdPartyState = "Nominated 3rd party state";
      requiredFields.thirdPartyRelationShip = "Relationship to complainant";
    }
    if (this.isComplaintResolved) {
      requiredFields.compOutCome = "Complaint Outcome";
      requiredFields.compRemedy = "Complaint Remedy";
      requiredFields.descOutcome = "Description of Outcome";
      if (this.isReferredToProductManufacturer) {
        requiredFields.thirdPartyProductManufacturer = "Product Manufacturer";
        if (this.isOtherProductManufacturer) {
          requiredFields.thirdPartyOtherProductManufacturer =
            "Name of the product manufacturer";
        }
      }
    }
    if (this.isComplaintEscalated) {
      requiredFields.escalatedTo = "Escalated To";
      requiredFields.escalationReason = "Complaint Escalation Reason";
    }
    if (this.isNonFinancialComplaintRemedy) {
      requiredFields.nonFinancialRemedy = "Non-Financial Remedy";
    }
    if (this.isCommonComplaint) {
      requiredFields.systemicIssueDescription =
        "Why is this a possible systemic issue?";
      requiredFields.systemicIssueCategory = "Possible Systemic Issue Category";
    }
    return requiredFields;
  }

  validateFinancialCompensation() {
    const regex = "^[1-9]\\d{0,6}(\\.\\d{1,2})?$|^0\\.(?!0+$)\\d{1,2}$";
    if (!this.financialCompensation.match(regex)) {
      this.missingDataFields +=
        "Financial Compensation must be a positive value with up to 7 whole digits and 2 decimal digits. ";
      return false;
    }
    return true;
  }

  handleCustNumValidated(event) {
    if (event) {
      this.isCustNumValidated = true;
    }
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

  handleError(error) {
    console.log(error);
    let msg = ERROR_UNKNOWN_TITLE;
    if (typeof error === "string") {
      msg = error.replace(/\.\s?/gm, ".<br><br>");
    } else if (error.body) {
      if (Array.isArray(error.body)) {
        msg = error.body.map((e) => e.message).join(", ");
      } else if (typeof error.body.message === "string") {
        msg = error.body.message;
      }
    }
    this.loading = false;
    this.template.querySelector(".saveButton").disabled = false;
    this.openModal(msg);
  }

  showModal = false;
  modalMessage = ERROR_UNKNOWN_TITLE;
  modalHeader = "Error";

  openModal(msg) {
    this.template.querySelector(".slds-card").classList.add("slds-hide");
    this.modalMessage = msg;
    this.showModal = true;
  }

  closeModal() {
    this.template.querySelector(".slds-hide").classList.remove("slds-hide");
    this.showModal = false;
  }
}
