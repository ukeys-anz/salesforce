import { LightningElement, api, wire } from "lwc";
import { getRecord, updateRecord } from "lightning/uiRecordApi";
import { NavigationMixin } from "lightning/navigation";
import Case_RecordTypeId from "@salesforce/schema/Case.RecordTypeId";
import ID_FIELD from "@salesforce/schema/Case.Id";
//complaint resolution fields
import STATUS_FIELD from "@salesforce/schema/Case.Status";
import COMPLAINT_OUTCOME from "@salesforce/schema/Case.IDR_Complaint_Outcome__c";
import OUTCOME_DESCRIPTION from "@salesforce/schema/Case.IDR_Description_of_Outcome__c";
import REAL_FORM_REQUIRED from "@salesforce/schema/Case.IDR_Real_Form_Req__c";
import REAL_FORM_REF_NO from "@salesforce/schema/Case.IDR_Real_Form_Ref_No__c";
import COMMON_COMPLAINT from "@salesforce/schema/Case.IDR_Is_Common__c";

import COMPLAINT_REMEDY from "@salesforce/schema/Case.IDR_Complaint_Remedy__c";
import FINANCIAL_COMPENSATION from "@salesforce/schema/Case.IDR_Financial_Compensation__c";
import THIRD_PARTY_IS_DETAILS_PROVIDED_TO_PRODUCT_MANUFACTURER from "@salesforce/schema/Case.Provided_details_to_Product_Manufacturer__c";
import COMPLAINT_SUB_REMEDY from "@salesforce/schema/Case.IDR_Complaint_Sub_Remedy__c";
import REMEDY_POINTS1 from "@salesforce/schema/Case.IDR_Financial_Remedy_Points__c";
import OTHER_REMDY1 from "@salesforce/schema/Case.IDR_Other_Remedy_Provided__c";
import REMEDY_DURATION from "@salesforce/schema/Case.IDR_Duration_of_Remedy__c";

//Remedy 2

import COMPLAINT_REMEDY2 from "@salesforce/schema/Case.IDR_Complaint_Remedy_2__c";
import FINANCIAL_COMPENSATION2 from "@salesforce/schema/Case.IDR_Financial_Compensation_2__c";
import THIRD_PARTY_IS_DETAILS_PROVIDED_TO_PRODUCT_MANUFACTURER2 from "@salesforce/schema/Case.Provided_details_to_Prod_Manufacturer_2__c";
import COMPLAINT_SUB_REMEDY2 from "@salesforce/schema/Case.IDR_Complaint_Sub_Remedy_2__c";
import REMEDY_POINTS2 from "@salesforce/schema/Case.IDR_Financial_Remedy_Points_2__c";
import OTHER_REMDY2 from "@salesforce/schema/Case.IDR_Other_Remedy_Provided_2__c";
import REMEDY_DURATION2 from "@salesforce/schema/Case.IDR_Duration_of_Remedy_2__c";

//Remedy 3

import COMPLAINT_REMEDY3 from "@salesforce/schema/Case.IDR_Complaint_Remedy_3__c";
import FINANCIAL_COMPENSATION3 from "@salesforce/schema/Case.IDR_Financial_Compensation_3__c";
import THIRD_PARTY_IS_DETAILS_PROVIDED_TO_PRODUCT_MANUFACTURER3 from "@salesforce/schema/Case.Provided_details_to_Prod_Manufacturer_3__c";
import COMPLAINT_SUB_REMEDY3 from "@salesforce/schema/Case.IDR_Complaint_Sub_Remedy_3__c";
import REMEDY_POINTS3 from "@salesforce/schema/Case.IDR_Financial_Remedy_Points_3__c";
import OTHER_REMDY3 from "@salesforce/schema/Case.IDR_Other_Remedy_Provided_3__c";
import REMEDY_DURATION3 from "@salesforce/schema/Case.IDR_Duration_of_Remedy_3__c";

//Avoidable Escalation fields
import AVOIDABLE_ESCALATION from "@salesforce/schema/Case.IDR_Avoidable_Escalation__c";
import AVOIDABLE_ESCALATION_REASON from "@salesforce/schema/Case.IDR_Avoidable_Escalation_Reason__c";

//Product field
import PRODUCT_OR_SERVICE_NAME from "@salesforce/schema/Case.Product__c";

//Product2 and Product3 fields
import HAS_SECOND_ISSUE from "@salesforce/schema/Case.IDR_Second_Issue__c";
import HAS_THIRD_ISSUE from "@salesforce/schema/Case.IDR_Third_Issue__c";
import PRODUCT_OR_SERVICE_NAME_2 from "@salesforce/schema/Case.IDR_Product_2__c";
import PRODUCT_OR_SERVICE_NAME_3 from "@salesforce/schema/Case.IDR_Product_3__c";

//Systemic Issue Fields
import SYSTEMIC_ISSUE_DESCRIPTION from "@salesforce/schema/Case.IDR_Systemic_Issue_Description__c";
import SYSTEMIC_ISSUE_CATEGORY from "@salesforce/schema/Case.IDR_Systemic_Issue_Category__c";
import POSSIBLE_SYSTEM_ISSUES from "@salesforce/schema/Case.IDR_Possible_Systemic_Issues__c";

const PROVISIONALLYCLOSED_STATUS_API_NAME = "Provisionally Closed";
const CLOSED_STATUS_API_NAME = "Closed";
const COMPLAINT_REMEDY_FIN_VALUE = "1";
const COMPLAINT_REMEDY_PRODUCT_MANU = "3";
const SUB_REMEDY_OTHER = "99";
const ERROR_UNKNOWN_TITLE = "An error has occurred.";
const DEBT_WAIVER = "10";
const SETTEL_FOR_LESS = "18";
const REWARD_POINTS = "Reward Points";
const MORATORIUM = "16";
const REPAYMENT_ARRAGMENT = "Repayment arrangement";
const TIME_TO_SELL_REFINANCE_SURRENDER = "20";
const YES_VALUE = "Yes";

const FIELDS = [
  Case_RecordTypeId,
  STATUS_FIELD,
  REAL_FORM_REQUIRED,
  REAL_FORM_REF_NO,
  COMMON_COMPLAINT,
  COMPLAINT_OUTCOME,
  SYSTEMIC_ISSUE_DESCRIPTION,
  SYSTEMIC_ISSUE_CATEGORY,
  POSSIBLE_SYSTEM_ISSUES,
  OUTCOME_DESCRIPTION,
  COMPLAINT_REMEDY,
  FINANCIAL_COMPENSATION,
  THIRD_PARTY_IS_DETAILS_PROVIDED_TO_PRODUCT_MANUFACTURER,
  COMPLAINT_SUB_REMEDY,
  REMEDY_POINTS1,
  OTHER_REMDY1,
  REMEDY_DURATION,
  COMPLAINT_REMEDY2,
  FINANCIAL_COMPENSATION2,
  THIRD_PARTY_IS_DETAILS_PROVIDED_TO_PRODUCT_MANUFACTURER2,
  COMPLAINT_SUB_REMEDY2,
  REMEDY_POINTS2,
  OTHER_REMDY2,
  REMEDY_DURATION2,
  COMPLAINT_REMEDY3,
  FINANCIAL_COMPENSATION3,
  THIRD_PARTY_IS_DETAILS_PROVIDED_TO_PRODUCT_MANUFACTURER3,
  COMPLAINT_SUB_REMEDY3,
  REMEDY_POINTS3,
  OTHER_REMDY3,
  REMEDY_DURATION3,
  AVOIDABLE_ESCALATION,
  AVOIDABLE_ESCALATION_REASON,
  PRODUCT_OR_SERVICE_NAME,
  HAS_SECOND_ISSUE,
  HAS_THIRD_ISSUE,
  PRODUCT_OR_SERVICE_NAME_2,
  PRODUCT_OR_SERVICE_NAME_3
];

export default class closeComplaint extends NavigationMixin(LightningElement) {
  @api recordId;
  recordTypeId;
  loadChild = false;
  loading = false;
  closeFields = {};
  errMsg = "Complete Required Fields:";

  showModal = false;
  modalMessage = ERROR_UNKNOWN_TITLE;
  modalHeader = "Error";
  remedy2 = false;
  remedy3 = false;
  caseStatus = CLOSED_STATUS_API_NAME;

  isValidToClose = true;
  validityMessage = "";
  validityMessageFields = new Array();

  isRealFormNeeded;
  isRealFormSubmitted;
  realFormRefNo = "";
  expressCaseCreationData = {};
  isCommonComplaintYesNo;
  systemicIssueDescription;
  systemicIssueCategory;
  possibleSystemicIssues;

  commoncomplaintoptions = [
    { label: "Yes", value: "Yes" },
    { label: "No", value: "No" }
  ];

  realFormReqOptions = [
    { label: "Yes", value: "Yes" },
    { label: "No", value: "No" }
  ];

  //Get the recordType to send to the API
  @wire(getRecord, { recordId: "$recordId", fields: FIELDS })
  wiredProject({ data }) {
    if (data) {
      this.recordTypeId = data.fields.RecordTypeId.value;
      this.isRealFormNeeded =
        data.fields[REAL_FORM_REQUIRED.fieldApiName].value;
      this.realFormRefNo = data.fields[REAL_FORM_REF_NO.fieldApiName].value;
      this.systemicIssueDescription =
        data.fields[SYSTEMIC_ISSUE_DESCRIPTION.fieldApiName].value;
      this.systemicIssueCategory =
        data.fields[SYSTEMIC_ISSUE_CATEGORY.fieldApiName].value;
      this.possibleSystemicIssues =
        data.fields[POSSIBLE_SYSTEM_ISSUES.fieldApiName].value;
      this.isCommonComplaintYesNo =
        data.fields[COMMON_COMPLAINT.fieldApiName].value;

      //check validity before closing
      if (!data.fields[PRODUCT_OR_SERVICE_NAME.fieldApiName].value) {
        this.isValidToClose = false;
        this.validityMessageFields.push("Product or Service Name");
      }
      if (
        data.fields[HAS_SECOND_ISSUE.fieldApiName].value &&
        !data.fields[PRODUCT_OR_SERVICE_NAME_2.fieldApiName].value
      ) {
        this.isValidToClose = false;
        this.validityMessageFields.push("Product or Service Name 2");
      }
      if (
        data.fields[HAS_THIRD_ISSUE.fieldApiName].value &&
        !data.fields[PRODUCT_OR_SERVICE_NAME_3.fieldApiName].value
      ) {
        this.isValidToClose = false;
        this.validityMessageFields.push("Product or Service Name 3");
      }
      if (this.isValidToClose) {
        this.updateCloseFieldsWithExistingValues(data);
      } else {
        this.validityMessage =
          "Please update " +
          this.validityMessageFields.join() +
          " before closing the case.";
      }
    }
  }

  updateCloseFieldsWithExistingValues(data) {
    this.closeFields[COMPLAINT_OUTCOME.fieldApiName] =
      data.fields[COMPLAINT_OUTCOME.fieldApiName].value;
    this.closeFields[OUTCOME_DESCRIPTION.fieldApiName] =
      data.fields[OUTCOME_DESCRIPTION.fieldApiName].value;
    this.closeFields[COMPLAINT_REMEDY.fieldApiName] =
      data.fields[COMPLAINT_REMEDY.fieldApiName].value;
    this.closeFields[
      THIRD_PARTY_IS_DETAILS_PROVIDED_TO_PRODUCT_MANUFACTURER.fieldApiName
    ] =
      data.fields[
        THIRD_PARTY_IS_DETAILS_PROVIDED_TO_PRODUCT_MANUFACTURER.fieldApiName
      ].value;
    this.closeFields[FINANCIAL_COMPENSATION.fieldApiName] =
      data.fields[FINANCIAL_COMPENSATION.fieldApiName].value;
    this.closeFields[COMPLAINT_SUB_REMEDY.fieldApiName] =
      data.fields[COMPLAINT_SUB_REMEDY.fieldApiName].value;
    this.closeFields[REMEDY_POINTS1.fieldApiName] =
      data.fields[REMEDY_POINTS1.fieldApiName].value;
    this.closeFields[OTHER_REMDY1.fieldApiName] =
      data.fields[OTHER_REMDY1.fieldApiName].value;
    this.closeFields[REMEDY_DURATION.fieldApiName] =
      data.fields[REMEDY_DURATION.fieldApiName].value;
    if (data.fields[COMPLAINT_REMEDY2.fieldApiName].value !== null) {
      this.remedy2 = true;
    }
    this.closeFields[COMPLAINT_REMEDY2.fieldApiName] =
      data.fields[COMPLAINT_REMEDY2.fieldApiName].value;
    this.closeFields[
      THIRD_PARTY_IS_DETAILS_PROVIDED_TO_PRODUCT_MANUFACTURER2.fieldApiName
    ] =
      data.fields[
        THIRD_PARTY_IS_DETAILS_PROVIDED_TO_PRODUCT_MANUFACTURER2.fieldApiName
      ].value;
    this.closeFields[COMMON_COMPLAINT.fieldApiName] =
      data.fields[COMMON_COMPLAINT.fieldApiName].value;
    this.closeFields[REAL_FORM_REF_NO.fieldApiName] =
      data.fields[REAL_FORM_REF_NO.fieldApiName].value;
    this.closeFields[REAL_FORM_REQUIRED.fieldApiName] =
      data.fields[REAL_FORM_REQUIRED.fieldApiName].value;
    this.closeFields[FINANCIAL_COMPENSATION2.fieldApiName] =
      data.fields[FINANCIAL_COMPENSATION2.fieldApiName].value;
    this.closeFields[COMPLAINT_SUB_REMEDY2.fieldApiName] =
      data.fields[COMPLAINT_SUB_REMEDY2.fieldApiName].value;
    this.closeFields[REMEDY_POINTS2.fieldApiName] =
      data.fields[REMEDY_POINTS2.fieldApiName].value;
    this.closeFields[OTHER_REMDY2.fieldApiName] =
      data.fields[OTHER_REMDY2.fieldApiName].value;
    this.closeFields[REMEDY_DURATION2.fieldApiName] =
      data.fields[REMEDY_DURATION2.fieldApiName].value;
    if (data.fields[COMPLAINT_REMEDY3.fieldApiName].value !== null) {
      this.remedy3 = true;
    }
    this.closeFields[COMPLAINT_REMEDY3.fieldApiName] =
      data.fields[COMPLAINT_REMEDY3.fieldApiName].value;
    this.closeFields[
      THIRD_PARTY_IS_DETAILS_PROVIDED_TO_PRODUCT_MANUFACTURER3.fieldApiName
    ] =
      data.fields[
        THIRD_PARTY_IS_DETAILS_PROVIDED_TO_PRODUCT_MANUFACTURER3.fieldApiName
      ].value;
    this.closeFields[FINANCIAL_COMPENSATION3.fieldApiName] =
      data.fields[FINANCIAL_COMPENSATION3.fieldApiName].value;
    this.closeFields[COMPLAINT_SUB_REMEDY3.fieldApiName] =
      data.fields[COMPLAINT_SUB_REMEDY3.fieldApiName].value;
    this.closeFields[REMEDY_POINTS3.fieldApiName] =
      data.fields[REMEDY_POINTS3.fieldApiName].value;
    this.closeFields[OTHER_REMDY3.fieldApiName] =
      data.fields[OTHER_REMDY3.fieldApiName].value;
    this.closeFields[REMEDY_DURATION3.fieldApiName] =
      data.fields[REMEDY_DURATION3.fieldApiName].value;
    this.closeFields[AVOIDABLE_ESCALATION.fieldApiName] =
      data.fields[AVOIDABLE_ESCALATION.fieldApiName].value;
    this.closeFields[AVOIDABLE_ESCALATION_REASON.fieldApiName] =
      data.fields[AVOIDABLE_ESCALATION_REASON.fieldApiName].value;
    this.loadChild = true;
  }

  get isCommonComplaint() {
    return this.isCommonComplaintYesNo === YES_VALUE;
  }

  get statusOptions() {
    //future use:  { label: ONHOLD_STATUS_API_NAME, value: ONHOLD_STATUS_API_NAME },]
    if (!this.closeFields[STATUS_FIELD.fieldApiName]) {
      this.closeFields[STATUS_FIELD.fieldApiName] = CLOSED_STATUS_API_NAME;
    }

    return [
      {
        label: PROVISIONALLYCLOSED_STATUS_API_NAME,
        value: PROVISIONALLYCLOSED_STATUS_API_NAME
      },
      { label: CLOSED_STATUS_API_NAME, value: CLOSED_STATUS_API_NAME }
    ];
  }

  handleStatusChange(event) {
    this.caseStatus = event.target.value;
    this.closeFields[STATUS_FIELD.fieldApiName] = event.target.value;

    this.caseStatus = event.target.value;
  }

  handleRealFormNeeded(event) {
    if (event.detail !== YES_VALUE) {
      this.isRealFormNeeded = "No";
    } else {
      this.isRealFormNeeded = "Yes";
    }
  }

  handleCommonComplaint(event) {
    this.isCommonComplaintYesNo = event.detail;
  }

  handleRealFormRefNoChange(event) {
    this.realFormRefNo = event.detail;
  }

  handleSystemicIssueDescriptionChange(event) {
    this.systemicIssueDescription = event.detail;
  }

  handleSystemicIssueCategoryChange(event) {
    this.systemicIssueCategory = event.detail;
  }

  handlePossibleSystemicIssuesChange(event) {
    this.possibleSystemicIssues = event.detail;
  }

  handleFieldUpdate(event) {
    let fieldApi = event.detail.field;
    let value = event.detail.value;

    switch (fieldApi) {
      case "IDR_Complaint_Outcome__c":
        this.closeFields[COMPLAINT_OUTCOME.fieldApiName] = value;
        break;
      case "IDR_Description_of_Outcome__c":
        this.closeFields[OUTCOME_DESCRIPTION.fieldApiName] = value;
        break;
      case "IDR_Complaint_Remedy__c":
        this.closeFields[COMPLAINT_REMEDY.fieldApiName] = value;
        break;
      case "Provided_details_to_Product_Manufacturer__c":
        this.closeFields[
          THIRD_PARTY_IS_DETAILS_PROVIDED_TO_PRODUCT_MANUFACTURER.fieldApiName
        ] = value;
        break;
      case "IDR_Financial_Compensation__c":
        this.closeFields[FINANCIAL_COMPENSATION.fieldApiName] = value;
        break;
      case "IDR_Complaint_Sub_Remedy__c":
        this.closeFields[COMPLAINT_SUB_REMEDY.fieldApiName] = value;
        break;
      case "IDR_Financial_Remedy_Points__c":
        this.closeFields[REMEDY_POINTS1.fieldApiName] = value;
        break;
      case "IDR_Other_Remedy_Provided__c":
        this.closeFields[OTHER_REMDY1.fieldApiName] = value;
        break;
      case "IDR_Duration_of_Remedy__c":
        this.closeFields[REMEDY_DURATION.fieldApiName] = value;
        break;
      case "Remedy2":
        this.remedy2 = value;
        break;
      case "IDR_Complaint_Remedy_2__c":
        this.closeFields[COMPLAINT_REMEDY2.fieldApiName] = value;
        break;
      case "Provided_details_to_Prod_Manufacturer_2__c":
        this.closeFields[
          THIRD_PARTY_IS_DETAILS_PROVIDED_TO_PRODUCT_MANUFACTURER2.fieldApiName
        ] = value;
        break;
      case "IDR_Financial_Compensation_2__c":
        this.closeFields[FINANCIAL_COMPENSATION2.fieldApiName] = value;
        break;
      case "IDR_Complaint_Sub_Remedy_2__c":
        this.closeFields[COMPLAINT_SUB_REMEDY2.fieldApiName] = value;
        break;
      case "IDR_Financial_Remedy_Points_2__c":
        this.closeFields[REMEDY_POINTS2.fieldApiName] = value;
        break;
      case "IDR_Other_Remedy_Provided_2__c":
        this.closeFields[OTHER_REMDY2.fieldApiName] = value;
        break;
      case "IDR_Duration_of_Remedy_2__c":
        this.closeFields[REMEDY_DURATION2.fieldApiName] = value;
        break;
      case "Remedy3":
        this.remedy3 = value;
        break;
      case "IDR_Complaint_Remedy_3__c":
        this.closeFields[COMPLAINT_REMEDY3.fieldApiName] = value;
        break;
      case "Provided_details_to_Prod_Manufacturer_3__c":
        this.closeFields[
          THIRD_PARTY_IS_DETAILS_PROVIDED_TO_PRODUCT_MANUFACTURER3.fieldApiName
        ] = value;
        break;
      case "IDR_Financial_Compensation_3__c":
        this.closeFields[FINANCIAL_COMPENSATION3.fieldApiName] = value;
        break;
      case "IDR_Complaint_Sub_Remedy_3__c":
        this.closeFields[COMPLAINT_SUB_REMEDY3.fieldApiName] = value;
        break;
      case "IDR_Financial_Remedy_Points_3__c":
        this.closeFields[REMEDY_POINTS3.fieldApiName] = value;
        break;
      case "IDR_Other_Remedy_Provided_3__c":
        this.closeFields[OTHER_REMDY3.fieldApiName] = value;
        break;
      case "IDR_Duration_of_Remedy_3__c":
        this.closeFields[REMEDY_DURATION3.fieldApiName] = value;
        break;
      case "IDR_Avoidable_Escalation__c":
        this.closeFields[AVOIDABLE_ESCALATION.fieldApiName] = value;
        break;
      case "IDR_Avoidable_Escalation_Reason__c":
        this.closeFields[AVOIDABLE_ESCALATION_REASON.fieldApiName] = value;
        break;
      default:
    }
  }

  validateFields() {
    this.closeFields[REAL_FORM_REQUIRED.fieldApiName] = this.isRealFormNeeded;
    this.closeFields[REAL_FORM_REF_NO.fieldApiName] = this.realFormRefNo;
    this.closeFields[
      COMMON_COMPLAINT.fieldApiName
    ] = this.isCommonComplaintYesNo;
    if (this.isCommonComplaint) {
      this.closeFields[
        SYSTEMIC_ISSUE_DESCRIPTION.fieldApiName
      ] = this.systemicIssueDescription;
      this.closeFields[
        SYSTEMIC_ISSUE_CATEGORY.fieldApiName
      ] = this.systemicIssueCategory;
      this.closeFields[
        POSSIBLE_SYSTEM_ISSUES.fieldApiName
      ] = this.possibleSystemicIssues;
    }
    this.errMsg = "Complete Required Fields:";
    let validToSave = true;
    let validToSave1 = true;
    let validToSave2 = true;
    let validToSave3 = true;
    let validToSave4 = true;

    if (
      typeof this.isRealFormNeeded === "undefined" ||
      this.isRealFormNeeded === null
    ) {
      validToSave = false;
      this.errMsg += " Is Real form required, ";
    }

    if (this.isRealFormNeeded === "Yes" && !this.realFormRefNo) {
      validToSave = false;
      this.errMsg += " REAL Form MAX ID/ServiceNow ID, ";
    }

    if (
      typeof this.isCommonComplaintYesNo === "undefined" ||
      this.isCommonComplaintYesNo === null
    ) {
      validToSave = false;
      this.errMsg += "Is this a possible systemic issue?, ";
    } else {
      if (this.isCommonComplaint && !this.systemicIssueDescription) {
        validToSave = false;
        this.errMsg += "Why is this a possible systemic issue?, ";
      }

      if (this.isCommonComplaint && !this.systemicIssueCategory) {
        validToSave = false;
        this.errMsg += "Possible Systemic Issue Category, ";
      }
    }

    let closeStatusInput = this.template.querySelector(
      "c-complaints-close-child"
    );

    if (closeStatusInput) {
      closeStatusInput.validateFields();
    }

    if (
      this.closeFields[STATUS_FIELD.fieldApiName] !==
        PROVISIONALLYCLOSED_STATUS_API_NAME &&
      this.closeFields[STATUS_FIELD.fieldApiName] !== CLOSED_STATUS_API_NAME
    ) {
      validToSave = false;
      this.errMsg = this.errMsg + STATUS_FIELD.fieldApiName + " ;";
    }

    validToSave1 = this.validateRemedy1Fields();

    if (this.remedy2) {
      validToSave2 = this.validateRemedy2Fields();
    }

    if (this.remedy3) {
      validToSave3 = this.validateRemedy3Fields();
    }

    if (this.closeFields[AVOIDABLE_ESCALATION.fieldApiName]) {
      validToSave4 = this.validateAvoidableEscalationFields();
    }

    if (
      validToSave &&
      validToSave1 &&
      validToSave2 &&
      validToSave3 &&
      validToSave4
    ) {
      this.closeFields[ID_FIELD.fieldApiName] = this.recordId;

      const fields = this.closeFields;
      const recordInput = { fields };
      this.loading = true;

      updateRecord(recordInput)
        .then(() => {
          this.loading = false;
          // Display fresh data
          window.location.reload();
        })
        .catch((error) => {
          let message = "Unknown error";
          if (error.body.output) {
            message = "";
            if (
              Array.isArray(error.body.output.errors) &&
              error.body.output.errors.length > 0
            ) {
              message =
                message +
                error.body.output.errors.map((e) => e.message).join(", ");
            }
            if (error.body.output.fieldErrors) {
              for (const i in error.body.output.fieldErrors) {
                if (
                  Array.isArray(error.body.output.fieldErrors[i]) &&
                  error.body.output.fieldErrors[i].length > 0
                ) {
                  message =
                    message +
                    error.body.output.fieldErrors[i]
                      .map((e) => e.message)
                      .join(", ");
                }
              }
            }
          } else if (Array.isArray(error.body)) {
            message = error.body.map((e) => e.message).join(", ");
          } else if (typeof error.body.message === "string") {
            message = error.body.message;
          } else if (typeof error === "string") {
            message = error;
          }
          this.loading = false;
          this.openModal("Update Failed: " + message);
        });
    } else {
      this.loading = false;
      this.openModal(this.errMsg);
    }
  }

  validateRemedy1Fields() {
    let validToSave = true;

    if (
      !this.closeFields[COMPLAINT_OUTCOME.fieldApiName] ||
      this.closeFields[COMPLAINT_OUTCOME.fieldApiName] === null
    ) {
      validToSave = false;
      this.errMsg += "Complaint Outcome ,";
    }
    if (
      !this.closeFields[OUTCOME_DESCRIPTION.fieldApiName] ||
      this.closeFields[OUTCOME_DESCRIPTION.fieldApiName] === null
    ) {
      validToSave = false;
      this.errMsg += "Description of Outcome ,";
    }
    if (
      !this.closeFields[COMPLAINT_REMEDY.fieldApiName] ||
      this.closeFields[COMPLAINT_REMEDY.fieldApiName] === null
    ) {
      validToSave = false;
      this.errMsg += "Complaint Remedy 1 ,";
    }

    if (
      !this.closeFields[COMPLAINT_SUB_REMEDY.fieldApiName] ||
      this.closeFields[COMPLAINT_SUB_REMEDY.fieldApiName] === null
    ) {
      validToSave = false;
      this.errMsg += "Complaint Sub Remedy 1 ,";
    }

    if (
      this.closeFields[COMPLAINT_REMEDY.fieldApiName] ===
        COMPLAINT_REMEDY_FIN_VALUE &&
      (!this.closeFields[FINANCIAL_COMPENSATION.fieldApiName] ||
        this.closeFields[FINANCIAL_COMPENSATION.fieldApiName] === null)
    ) {
      validToSave = false;
      this.errMsg += "Financial Amount ,";
    }

    let dotCheck = ".";

    if (
      this.closeFields[COMPLAINT_SUB_REMEDY.fieldApiName] === REWARD_POINTS &&
      (!this.closeFields[REMEDY_POINTS1.fieldApiName] ||
        this.closeFields[REMEDY_POINTS1.fieldApiName] === 0 ||
        this.closeFields[REMEDY_POINTS1.fieldApiName] === null)
    ) {
      validToSave = false;
      this.errMsg += "Financial Remedy Points 1 ,";
    } else if (
      this.closeFields[COMPLAINT_SUB_REMEDY.fieldApiName] === REWARD_POINTS &&
      this.closeFields[REMEDY_POINTS1.fieldApiName] &&
      (this.closeFields[REMEDY_POINTS1.fieldApiName].includes(dotCheck) ||
        this.closeFields[REMEDY_POINTS1.fieldApiName] < 0)
    ) {
      validToSave = false;
      this.errMsg +=
        "Financial Remedy Points 1 must be a positive value without decimals";
    }

    if (
      (this.closeFields[COMPLAINT_SUB_REMEDY.fieldApiName] === DEBT_WAIVER ||
        this.closeFields[COMPLAINT_SUB_REMEDY.fieldApiName] ===
          SETTEL_FOR_LESS) &&
      (!this.closeFields[FINANCIAL_COMPENSATION.fieldApiName] ||
        this.closeFields[FINANCIAL_COMPENSATION.fieldApiName] === null)
    ) {
      validToSave = false;
      this.errMsg += "Financial Amount ,";
    }
    if (
      this.closeFields[COMPLAINT_SUB_REMEDY.fieldApiName] ===
        SUB_REMEDY_OTHER &&
      (!this.closeFields[OTHER_REMDY1.fieldApiName] ||
        this.closeFields[OTHER_REMDY1.fieldApiName] === null)
    ) {
      validToSave = false;
      this.errMsg += "Other Remedy Provided 1 ,";
    }

    let remedyDurationErrMsg = this.validateDurationOfRemedy(
      COMPLAINT_SUB_REMEDY.fieldApiName,
      REMEDY_DURATION.fieldApiName,
      "Duration of Remedy(months)"
    );
    if (remedyDurationErrMsg !== "") {
      validToSave = false;
      this.errMsg += remedyDurationErrMsg;
    }

    if (
      this.closeFields[COMPLAINT_REMEDY.fieldApiName] ===
        COMPLAINT_REMEDY_PRODUCT_MANU &&
      (this.closeFields[
        THIRD_PARTY_IS_DETAILS_PROVIDED_TO_PRODUCT_MANUFACTURER.fieldApiName
      ] === null ||
        this.closeFields[
          THIRD_PARTY_IS_DETAILS_PROVIDED_TO_PRODUCT_MANUFACTURER.fieldApiName
        ] === false)
    ) {
      validToSave = false;
      this.errMsg +=
        "The details of this complaint have been provided to the product manufacturer ? ,";
    }
    return validToSave;
  }

  validateRemedy2Fields() {
    let validToSave = true;

    if (
      !this.closeFields[COMPLAINT_REMEDY2.fieldApiName] ||
      this.closeFields[COMPLAINT_REMEDY2.fieldApiName] === null
    ) {
      validToSave = false;
      this.errMsg += "Complaint Remedy 2 ,";
    }

    if (
      !this.closeFields[COMPLAINT_SUB_REMEDY2.fieldApiName] ||
      this.closeFields[COMPLAINT_SUB_REMEDY2.fieldApiName] === null
    ) {
      validToSave = false;
      this.errMsg += "Complaint Sub Remedy 2 ,";
    }

    if (
      this.closeFields[COMPLAINT_REMEDY2.fieldApiName] ===
        COMPLAINT_REMEDY_FIN_VALUE &&
      (!this.closeFields[FINANCIAL_COMPENSATION2.fieldApiName] ||
        this.closeFields[FINANCIAL_COMPENSATION2.fieldApiName] === null)
    ) {
      validToSave = false;
      this.errMsg += "Financial Amount 2 ,";
    }

    let dotCheck = ".";

    if (
      this.closeFields[COMPLAINT_SUB_REMEDY2.fieldApiName] === REWARD_POINTS &&
      (!this.closeFields[REMEDY_POINTS2.fieldApiName] ||
        this.closeFields[REMEDY_POINTS2.fieldApiName] === 0 ||
        this.closeFields[REMEDY_POINTS2.fieldApiName] === null)
    ) {
      validToSave = false;
      this.errMsg += "Financial Remedy Points 2 ,";
    } else if (
      this.closeFields[COMPLAINT_SUB_REMEDY2.fieldApiName] === REWARD_POINTS &&
      this.closeFields[REMEDY_POINTS2.fieldApiName] &&
      (this.closeFields[REMEDY_POINTS2.fieldApiName].includes(dotCheck) ||
        this.closeFields[REMEDY_POINTS2.fieldApiName] < 0)
    ) {
      this.errMsg +=
        "Financial Remedy Points 2 must be a positive value without decimals";
    }

    if (
      (this.closeFields[COMPLAINT_SUB_REMEDY2.fieldApiName] === DEBT_WAIVER ||
        this.closeFields[COMPLAINT_SUB_REMEDY2.fieldApiName] ===
          SETTEL_FOR_LESS) &&
      (!this.closeFields[FINANCIAL_COMPENSATION2.fieldApiName] ||
        this.closeFields[FINANCIAL_COMPENSATION2.fieldApiName] === null)
    ) {
      validToSave = false;
      this.errMsg += "Financial Amount 2 ,";
    }

    if (
      this.closeFields[COMPLAINT_SUB_REMEDY2.fieldApiName] ===
        SUB_REMEDY_OTHER &&
      (!this.closeFields[OTHER_REMDY2.fieldApiName] ||
        this.closeFields[OTHER_REMDY2.fieldApiName] === null)
    ) {
      validToSave = false;
      this.errMsg += "Other Remedy Provided 2 ,";
    }

    let remedyDurationErrMsg = this.validateDurationOfRemedy(
      COMPLAINT_SUB_REMEDY2.fieldApiName,
      REMEDY_DURATION2.fieldApiName,
      "Duration of Remedy(months) 2"
    );
    if (remedyDurationErrMsg !== "") {
      validToSave = false;
      this.errMsg += remedyDurationErrMsg;
    }

    if (
      this.closeFields[COMPLAINT_REMEDY2.fieldApiName] ===
        COMPLAINT_REMEDY_PRODUCT_MANU &&
      (this.closeFields[
        THIRD_PARTY_IS_DETAILS_PROVIDED_TO_PRODUCT_MANUFACTURER2.fieldApiName
      ] === null ||
        this.closeFields[
          THIRD_PARTY_IS_DETAILS_PROVIDED_TO_PRODUCT_MANUFACTURER2.fieldApiName
        ] === false)
    ) {
      validToSave = false;
      this.errMsg +=
        "The details of this complaint have been provided to the product manufacturer 2 ? ,";
    }
    return validToSave;
  }

  validateRemedy3Fields() {
    let validToSave = true;

    if (
      !this.closeFields[COMPLAINT_REMEDY3.fieldApiName] ||
      this.closeFields[COMPLAINT_REMEDY3.fieldApiName] === null
    ) {
      validToSave = false;
      this.errMsg += "Complaint Remedy 3 ,";
    }

    if (
      !this.closeFields[COMPLAINT_SUB_REMEDY3.fieldApiName] ||
      this.closeFields[COMPLAINT_SUB_REMEDY3.fieldApiName] === null
    ) {
      validToSave = false;
      this.errMsg += "Complaint Sub Remedy 3 ,";
    }

    if (
      this.closeFields[COMPLAINT_REMEDY3.fieldApiName] ===
        COMPLAINT_REMEDY_FIN_VALUE &&
      (!this.closeFields[FINANCIAL_COMPENSATION3.fieldApiName] ||
        this.closeFields[FINANCIAL_COMPENSATION3.fieldApiName] === null)
    ) {
      validToSave = false;
      this.errMsg += "Financial Amount 3 ,";
    }

    let dotCheck = ".";

    if (
      this.closeFields[COMPLAINT_SUB_REMEDY3.fieldApiName] === REWARD_POINTS &&
      (!this.closeFields[REMEDY_POINTS3.fieldApiName] ||
        this.closeFields[REMEDY_POINTS3.fieldApiName] === 0 ||
        this.closeFields[REMEDY_POINTS3.fieldApiName] === null)
    ) {
      validToSave = false;
      this.errMsg += "Financial Remedy Points 3 ,";
    } else if (
      this.closeFields[COMPLAINT_SUB_REMEDY3.fieldApiName] === REWARD_POINTS &&
      this.closeFields[REMEDY_POINTS3.fieldApiName] &&
      (this.closeFields[REMEDY_POINTS3.fieldApiName].includes(dotCheck) ||
        this.closeFields[REMEDY_POINTS3.fieldApiName] < 0)
    ) {
      validToSave = false;
      this.errMsg +=
        "Financial Remedy Points 3 must be a positive value without decimals";
    }

    if (
      (this.closeFields[COMPLAINT_SUB_REMEDY3.fieldApiName] === DEBT_WAIVER ||
        this.closeFields[COMPLAINT_SUB_REMEDY3.fieldApiName] ===
          SETTEL_FOR_LESS) &&
      (!this.closeFields[FINANCIAL_COMPENSATION3.fieldApiName] ||
        this.closeFields[FINANCIAL_COMPENSATION3.fieldApiName] === null)
    ) {
      validToSave = false;
      this.errMsg += "Financial Amount 3 ,";
    }

    if (
      this.closeFields[COMPLAINT_SUB_REMEDY3.fieldApiName] ===
        SUB_REMEDY_OTHER &&
      (!this.closeFields[OTHER_REMDY3.fieldApiName] ||
        this.closeFields[OTHER_REMDY3.fieldApiName] === null)
    ) {
      validToSave = false;
      this.errMsg += "Other Remedy Provided 3 ,";
    }

    let remedyDurationErrMsg = this.validateDurationOfRemedy(
      COMPLAINT_SUB_REMEDY3.fieldApiName,
      REMEDY_DURATION3.fieldApiName,
      "Duration of Remedy(months) 3"
    );
    if (remedyDurationErrMsg !== "") {
      validToSave = false;
      this.errMsg += remedyDurationErrMsg;
    }

    if (
      this.closeFields[COMPLAINT_REMEDY3.fieldApiName] ===
        COMPLAINT_REMEDY_PRODUCT_MANU &&
      (this.closeFields[
        THIRD_PARTY_IS_DETAILS_PROVIDED_TO_PRODUCT_MANUFACTURER3.fieldApiName
      ] === null ||
        this.closeFields[
          THIRD_PARTY_IS_DETAILS_PROVIDED_TO_PRODUCT_MANUFACTURER3.fieldApiName
        ] === false)
    ) {
      validToSave = false;
      this.errMsg +=
        "The details of this complaint have been provided to the product manufacturer 3 ? ,";
    }
    return validToSave;
  }

  validateAvoidableEscalationFields() {
    if (!this.closeFields[AVOIDABLE_ESCALATION_REASON.fieldApiName]) {
      this.errMsg += "Avoidable Escalation Reason";
      return false;
    }
    return true;
  }

  openModal(msg) {
    // this.template.querySelector(".slds-card").classList.add("slds-hide");
    this.modalMessage = msg;
    this.showModal = true;
  }

  closeModal() {
    this.showModal = false;
  }

  validateDurationOfRemedy(
    complaintSubRemedyApiName,
    remedyDurationApiName,
    remedyDurationLabel
  ) {
    if (
      this.closeFields[complaintSubRemedyApiName] === MORATORIUM ||
      this.closeFields[complaintSubRemedyApiName] ===
        TIME_TO_SELL_REFINANCE_SURRENDER ||
      this.closeFields[complaintSubRemedyApiName] === REPAYMENT_ARRAGMENT
    ) {
      if (
        !this.closeFields[remedyDurationApiName] ||
        this.closeFields[remedyDurationApiName] === null
      ) {
        return remedyDurationLabel + " ,";
      } else if (
        this.closeFields[remedyDurationApiName] > 999 ||
        this.closeFields[remedyDurationApiName].toString().includes(".") ||
        this.closeFields[remedyDurationApiName] < 0
      ) {
        return (
          remedyDurationLabel +
          " must be a positive value with up to 3 whole digits. "
        );
      }
    }
    return "";
  }
}
