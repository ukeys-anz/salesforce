import { LightningElement, api, wire } from "lwc";
import { getRecord, updateRecord } from "lightning/uiRecordApi";
import { NavigationMixin } from "lightning/navigation";
import Case_RecordTypeId from "@salesforce/schema/Case.RecordTypeId";
import ID_FIELD from "@salesforce/schema/Case.Id";
//complaint resolution fields
import STATUS_FIELD from "@salesforce/schema/Case.Status";
import COMPLAINT_OUTCOME from "@salesforce/schema/Case.IDR_Complaint_Outcome__c";
import OUTCOME_DESCRIPTION from "@salesforce/schema/Case.IDR_Description_of_Outcome__c";

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

const FIELDS = [
  Case_RecordTypeId,
  COMPLAINT_OUTCOME,
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
  REMEDY_DURATION3
];

export default class closeComplaint extends NavigationMixin(LightningElement) {
  @api recordId;
  recordTypeId;
  loadChild = false;
  closeFields = {};
  errMsg = "Complete Required Fields:";

  showModal = false;
  modalMessage = ERROR_UNKNOWN_TITLE;
  modalHeader = "Error";
  remedy2 = false;
  remedy3 = false;
  caseStatus = CLOSED_STATUS_API_NAME;

  //Get the recordType to send to the API
  @wire(getRecord, { recordId: "$recordId", fields: FIELDS })
  wiredProject({ data }) {
    if (data) {
      this.recordTypeId = data.fields.RecordTypeId.value;
      this.updateCloseFieldsWithExistingValues(data);
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
    this.loadChild = true;
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
      default:
    }
  }

  validateFields() {
    this.errMsg = "Complete Required Fields:";
    let validToSave = true;
    let validToSave1 = true;
    let validToSave2 = true;
    let validToSave3 = true;

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

    if (validToSave && validToSave1 && validToSave2 && validToSave3) {
      this.closeFields[ID_FIELD.fieldApiName] = this.recordId;

      const fields = this.closeFields;
      const recordInput = { fields };

      updateRecord(recordInput)
        .then(() => {
          // Display fresh data
          window.location.reload();
        })
        .catch((error) => {
          let message = "Unknown error";
          if (error.body.output) {
            message = message = error.body.output.message;
          } else if (Array.isArray(error.body)) {
            message = error.body.map((e) => e.message).join(", ");
          } else if (typeof error.body.message === "string") {
            message = error.body.message;
          } else if (typeof error === "string") {
            message = error;
          }
          this.openModal("Update Failed: " + message);
        });
    } else {
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

    if (
      this.closeFields[COMPLAINT_SUB_REMEDY.fieldApiName] === REWARD_POINTS &&
      (!this.closeFields[REMEDY_POINTS1.fieldApiName] ||
        this.closeFields[REMEDY_POINTS1.fieldApiName] === null)
    ) {
      validToSave = false;
      this.errMsg += "Financial Remedy Points 1 ,";
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

    if (
      (this.closeFields[COMPLAINT_SUB_REMEDY.fieldApiName] === MORATORIUM ||
        this.closeFields[COMPLAINT_SUB_REMEDY.fieldApiName] ===
          TIME_TO_SELL_REFINANCE_SURRENDER ||
        this.closeFields[COMPLAINT_SUB_REMEDY.fieldApiName] ===
          REPAYMENT_ARRAGMENT) &&
      (!this.closeFields[REMEDY_DURATION.fieldApiName] ||
        this.closeFields[REMEDY_DURATION.fieldApiName] === null)
    ) {
      validToSave = false;
      this.errMsg += "Duration of Remedy(months) ,";
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

    if (
      this.closeFields[COMPLAINT_SUB_REMEDY2.fieldApiName] === REWARD_POINTS &&
      (!this.closeFields[REMEDY_POINTS2.fieldApiName] ||
        this.closeFields[REMEDY_POINTS2.fieldApiName] === null)
    ) {
      validToSave = false;
      this.errMsg += "Financial Remedy Points 2 ,";
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
    if (
      (this.closeFields[COMPLAINT_SUB_REMEDY2.fieldApiName] === MORATORIUM ||
        this.closeFields[COMPLAINT_SUB_REMEDY2.fieldApiName] ===
          TIME_TO_SELL_REFINANCE_SURRENDER ||
        this.closeFields[COMPLAINT_SUB_REMEDY2.fieldApiName] ===
          REPAYMENT_ARRAGMENT) &&
      (!this.closeFields[REMEDY_DURATION2.fieldApiName] ||
        this.closeFields[REMEDY_DURATION2.fieldApiName] === null)
    ) {
      validToSave = false;
      this.errMsg += "Duration of Remedy(months) 2 ,";
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

    if (
      this.closeFields[COMPLAINT_SUB_REMEDY3.fieldApiName] === REWARD_POINTS &&
      (!this.closeFields[REMEDY_POINTS3.fieldApiName] ||
        this.closeFields[REMEDY_POINTS3.fieldApiName] === null)
    ) {
      validToSave = false;
      this.errMsg += "Financial Remedy Points 3 ,";
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

    if (
      (this.closeFields[COMPLAINT_SUB_REMEDY3.fieldApiName] === MORATORIUM ||
        this.closeFields[COMPLAINT_SUB_REMEDY3.fieldApiName] ===
          TIME_TO_SELL_REFINANCE_SURRENDER ||
        this.closeFields[COMPLAINT_SUB_REMEDY3.fieldApiName] ===
          REPAYMENT_ARRAGMENT) &&
      (!this.closeFields[REMEDY_DURATION3.fieldApiName] ||
        this.closeFields[REMEDY_DURATION3.fieldApiName] === null)
    ) {
      validToSave = false;
      this.errMsg += "Duration of Remedy(months) 3 ,";
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
  openModal(msg) {
    // this.template.querySelector(".slds-card").classList.add("slds-hide");
    this.modalMessage = msg;
    this.showModal = true;
  }

  closeModal() {
    this.showModal = false;
  }
}
