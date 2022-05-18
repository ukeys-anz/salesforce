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

//Remedy 3

import COMPLAINT_REMEDY3 from "@salesforce/schema/Case.IDR_Complaint_Remedy_3__c";
import FINANCIAL_COMPENSATION3 from "@salesforce/schema/Case.IDR_Financial_Compensation_3__c";
import THIRD_PARTY_IS_DETAILS_PROVIDED_TO_PRODUCT_MANUFACTURER3 from "@salesforce/schema/Case.Provided_details_to_Prod_Manufacturer_3__c";
import COMPLAINT_SUB_REMEDY3 from "@salesforce/schema/Case.IDR_Complaint_Sub_Remedy_3__c";
import REMEDY_POINTS3 from "@salesforce/schema/Case.IDR_Financial_Remedy_Points_3__c";
import OTHER_REMDY3 from "@salesforce/schema/Case.IDR_Other_Remedy_Provided_3__c";

const PROVISIONALLYCLOSED_STATUS_API_NAME = "Provisionally Closed";
const CLOSED_STATUS_API_NAME = "Closed";
const COMPLAINT_REMEDY_FIN_VALUE = "1";
const COMPLAINT_REMEDY_NON_FIN_VALUE = "2";
const COMPLAINT_REMEDY_PRODUCT_MANU = "3";
const OTHER = "99";
const ERROR_UNKNOWN_TITLE = "An error has occurred.";
const DEBT_WAIVER = "10";
const SETTEL_FOR_LESS = "18";
const REWARD_POINTS = "Reward Points";
const MORATORIUM = "16";
//const REPAYMENT_ARRAGMENT = "";
const TIME_TO_SELL_REFINANCE_SURRENDER = "20";

export default class closeComplaint extends NavigationMixin(LightningElement) {
  @api recordId;
  recordTypeId;
  loadChild = false;
  saveFields = {};
  errMsg = "Complete Required Fields:";

  showModal = false;
  modalMessage = ERROR_UNKNOWN_TITLE;
  modalHeader = "Error";
  remedy2 = false;
  remedy3 = false;

  //Get the recordType to send to the API
  @wire(getRecord, { recordId: "$recordId", fields: [Case_RecordTypeId] })
  wiredProject({ data }) {
    if (data) {
      this.recordTypeId = data.fields.RecordTypeId.value;
      this.loadChild = true;
    }
  }

  get statusOptions() {
    //future use:  { label: ONHOLD_STATUS_API_NAME, value: ONHOLD_STATUS_API_NAME },
    return [
      {
        label: PROVISIONALLYCLOSED_STATUS_API_NAME,
        value: PROVISIONALLYCLOSED_STATUS_API_NAME
      },
      { label: CLOSED_STATUS_API_NAME, value: CLOSED_STATUS_API_NAME }
    ];
  }

  handleStatusChange(event) {
    this.saveFields[STATUS_FIELD.fieldApiName] = event.target.value;
  }

  handleFieldUpdate(event) {
    let fieldApi = event.detail.field;
    let value = event.detail.value;

    switch (fieldApi) {
      case "IDR_Complaint_Outcome__c":
        this.saveFields[COMPLAINT_OUTCOME.fieldApiName] = value;
        break;
      case "IDR_Description_of_Outcome__c":
        this.saveFields[OUTCOME_DESCRIPTION.fieldApiName] = value;
        break;
      case "IDR_Complaint_Remedy__c":
        this.saveFields[COMPLAINT_REMEDY.fieldApiName] = value;
        break;
      case "Provided_details_to_Product_Manufacturer__c":
        this.saveFields[
          THIRD_PARTY_IS_DETAILS_PROVIDED_TO_PRODUCT_MANUFACTURER.fieldApiName
        ] = value;
        break;
      case "IDR_Financial_Compensation__c":
        this.saveFields[FINANCIAL_COMPENSATION.fieldApiName] = value;
        break;
      case "IDR_Complaint_Sub_Remedy__c":
        this.saveFields[COMPLAINT_SUB_REMEDY.fieldApiName] = value;
        break;
      case "IDR_Financial_Remedy_Points__c":
        this.saveFields[REMEDY_POINTS1.fieldApiName] = value;
        break;
      case "IDR_Other_Remedy_Provided__c":
        this.saveFields[OTHER_REMDY1.fieldApiName] = value;
        break;
      case "Remedy2":
        this.remedy2 = value;
        break;
      case "IDR_Complaint_Remedy_2__c":
        this.saveFields[COMPLAINT_REMEDY2.fieldApiName] = value;
        break;
      case "Provided_details_to_Prod_Manufacturer_2__c":
        this.saveFields[
          THIRD_PARTY_IS_DETAILS_PROVIDED_TO_PRODUCT_MANUFACTURER2.fieldApiName
        ] = value;
        break;
      case "IDR_Financial_Compensation_2__c":
        this.saveFields[FINANCIAL_COMPENSATION2.fieldApiName] = value;
        break;
      case "IDR_Complaint_Sub_Remedy_2__c":
        this.saveFields[COMPLAINT_SUB_REMEDY2.fieldApiName] = value;
        break;
      case "IDR_Financial_Remedy_Points_2__c":
        this.saveFields[REMEDY_POINTS2.fieldApiName] = value;
        break;
      case "IDR_Other_Remedy_Provided_2__c":
        this.saveFields[OTHER_REMDY2.fieldApiName] = value;
        break;
      case "Remedy3":
        this.remedy3 = value;
        break;
      case "IDR_Complaint_Remedy_3__c":
        this.saveFields[COMPLAINT_REMEDY3.fieldApiName] = value;
        break;
      case "Provided_details_to_Prod_Manufacturer_3__c":
        this.saveFields[
          THIRD_PARTY_IS_DETAILS_PROVIDED_TO_PRODUCT_MANUFACTURER3.fieldApiName
        ] = value;
        break;
      case "IDR_Financial_Compensation_3__c":
        this.saveFields[FINANCIAL_COMPENSATION3.fieldApiName] = value;
        break;
      case "IDR_Complaint_Sub_Remedy_3__c":
        this.saveFields[COMPLAINT_SUB_REMEDY3.fieldApiName] = value;
        break;
      case "IDR_Financial_Remedy_Points_3__c":
        this.saveFields[REMEDY_POINTS3.fieldApiName] = value;
        break;
      case "IDR_Other_Remedy_Provided_3__c":
        this.saveFields[OTHER_REMDY3.fieldApiName] = value;
        break;
      case "IDR_Duration_of_Remedy__c":
        this.saveFields[REMEDY_DURATION.fieldApiName] = value;
        console.log("Duration receieved");
        break;
    }
  }

  validateFields() {
    this.errMsg = "Complete Required Fields:";
    let validToSave = true;

    if (this.saveFields[STATUS_FIELD.fieldApiName] == null) {
      validToSave = false;
      this.errMsg = this.errMsg + STATUS_FIELD.fieldApiName + " ;";
    }

    validToSave = this.validateRemedy1Fields();

    if (this.remedy2) {
      validToSave = this.validateRemedy2Fields();
    }

    if (this.remedy3) {
      validToSave = this.validateRemedy3Fields();
    }

    if (validToSave) {
      this.saveFields[ID_FIELD.fieldApiName] = this.recordId;

      const fields = this.saveFields;
      const recordInput = { fields };

      updateRecord(recordInput)
        .then(() => {
          // Display fresh data
          window.location.reload();
        })
        .catch((error) => {
          this.openModal("Update Failed: " + error);
        });
    } else {
      this.openModal(this.errMsg);
    }
  }

  validateRemedy1Fields() {
    let validToSave = true;

    if (this.saveFields[COMPLAINT_OUTCOME.fieldApiName] == null) {
      validToSave = false;
      this.errMsg = this.errMsg + COMPLAINT_OUTCOME.fieldApiName + " ;";
    }
    if (this.saveFields[OUTCOME_DESCRIPTION.fieldApiName] == null) {
      validToSave = false;
      this.errMsg = this.errMsg + OUTCOME_DESCRIPTION.fieldApiName + " ;";
    }
    if (this.saveFields[COMPLAINT_REMEDY.fieldApiName] == null) {
      validToSave = false;
      this.errMsg = this.errMsg + COMPLAINT_REMEDY.fieldApiName + " ;";
    }

    if (this.saveFields[COMPLAINT_SUB_REMEDY.fieldApiName] == null) {
      validToSave = false;
      this.errMsg = this.errMsg + COMPLAINT_SUB_REMEDY.fieldApiName + ";";
    }

    if (
      this.saveFields[COMPLAINT_REMEDY.fieldApiName] ==
        COMPLAINT_REMEDY_FIN_VALUE &&
      this.saveFields[FINANCIAL_COMPENSATION.fieldApiName] == null
    ) {
      validToSave = false;
      this.errMsg = this.errMsg + FINANCIAL_COMPENSATION.fieldApiName + " ;";
    }

    if (
      this.saveFields[COMPLAINT_SUB_REMEDY.fieldApiName] == REWARD_POINTS &&
      this.saveFields[REMEDY_POINTS1.fieldApiName] == null
    ) {
      validToSave = false;
      this.errMsg = this.errMsg + REMEDY_POINTS1.fieldApiName + ";";
    }

    if (
      (this.saveFields[COMPLAINT_SUB_REMEDY.fieldApiName] == DEBT_WAIVER ||
        this.saveFields[COMPLAINT_SUB_REMEDY.fieldApiName] ==
          SETTEL_FOR_LESS) &&
      this.saveFields[FINANCIAL_COMPENSATION.fieldApiName] == null
    ) {
      validToSave = false;
      this.errMsg = this.errMsg + FINANCIAL_COMPENSATION.fieldApiName + " ;";
    }

    if (
      this.saveFields[COMPLAINT_SUB_REMEDY.fieldApiName] == OTHER &&
      this.saveFields[OTHER_REMDY1.fieldApiName] == null
    ) {
      validToSave = false;
      this.errMsg = this.errMsg + OTHER_REMDY1.fieldApiName + " ;";
    }

    if (
      (this.saveFields[COMPLAINT_SUB_REMEDY.fieldApiName] == MORATORIUM ||
        this.saveFields[COMPLAINT_SUB_REMEDY.fieldApiName] ==
          TIME_TO_SELL_REFINANCE_SURRENDER) &&
      this.saveFields[REMEDY_DURATION.fieldApiName] == null
    ) {
      validToSave = false;
      this.errMsg = this.errMsg + REMEDY_DURATION.fieldApiName + " ;";
    }

    if (
      this.saveFields[COMPLAINT_REMEDY.fieldApiName] ==
        COMPLAINT_REMEDY_PRODUCT_MANU &&
      (this.saveFields[
        THIRD_PARTY_IS_DETAILS_PROVIDED_TO_PRODUCT_MANUFACTURER.fieldApiName
      ] == null ||
        this.saveFields[
          THIRD_PARTY_IS_DETAILS_PROVIDED_TO_PRODUCT_MANUFACTURER.fieldApiName
        ] == false)
    ) {
      validToSave = false;
      this.errMsg =
        this.errMsg +
        THIRD_PARTY_IS_DETAILS_PROVIDED_TO_PRODUCT_MANUFACTURER.fieldApiName +
        " ;";
    }
    return validToSave;
  }

  validateRemedy2Fields() {
    let validToSave = true;

    if (this.saveFields[COMPLAINT_REMEDY2.fieldApiName] == null) {
      validToSave = false;
      this.errMsg = this.errMsg + COMPLAINT_REMEDY2.fieldApiName + " ;";
    }

    if (this.saveFields[COMPLAINT_SUB_REMEDY2.fieldApiName] == null) {
      validToSave = false;
      this.errMsg = this.errMsg + COMPLAINT_SUB_REMEDY2.fieldApiName + ";";
    }

    if (
      this.saveFields[COMPLAINT_REMEDY2.fieldApiName] ==
        COMPLAINT_REMEDY_FIN_VALUE &&
      this.saveFields[FINANCIAL_COMPENSATION2.fieldApiName] == null
    ) {
      validToSave = false;
      this.errMsg = this.errMsg + FINANCIAL_COMPENSATION2.fieldApiName + " ;";
    }

    if (
      this.saveFields[COMPLAINT_SUB_REMEDY2.fieldApiName] == REWARD_POINTS &&
      this.saveFields[REMEDY_POINTS2.fieldApiName] == null
    ) {
      validToSave = false;
      this.errMsg = this.errMsg + REMEDY_POINTS2.fieldApiName + ";";
    }

    if (
      (this.saveFields[COMPLAINT_SUB_REMEDY2.fieldApiName] == DEBT_WAIVER ||
        this.saveFields[COMPLAINT_SUB_REMEDY2.fieldApiName] ==
          SETTEL_FOR_LESS) &&
      this.saveFields[FINANCIAL_COMPENSATION2.fieldApiName] == null
    ) {
      validToSave = false;
      this.errMsg = this.errMsg + FINANCIAL_COMPENSATION2.fieldApiName + " ;";
    }

    if (
      this.saveFields[COMPLAINT_SUB_REMEDY2.fieldApiName] == OTHER &&
      this.saveFields[OTHER_REMDY2.fieldApiName] == null
    ) {
      validToSave = false;
      this.errMsg = this.errMsg + OTHER_REMDY2.fieldApiName + " ;";
    }

    if (
      this.saveFields[COMPLAINT_REMEDY2.fieldApiName] ==
        COMPLAINT_REMEDY_PRODUCT_MANU &&
      (this.saveFields[
        THIRD_PARTY_IS_DETAILS_PROVIDED_TO_PRODUCT_MANUFACTURER2.fieldApiName
      ] == null ||
        this.saveFields[
          THIRD_PARTY_IS_DETAILS_PROVIDED_TO_PRODUCT_MANUFACTURER2.fieldApiName
        ] == false)
    ) {
      validToSave = false;
      this.errMsg =
        this.errMsg +
        THIRD_PARTY_IS_DETAILS_PROVIDED_TO_PRODUCT_MANUFACTURER2.fieldApiName +
        " ;";
    }
    return validToSave;
  }

  validateRemedy3Fields() {
    let validToSave = true;

    if (this.saveFields[COMPLAINT_REMEDY3.fieldApiName] == null) {
      validToSave = false;
      this.errMsg = this.errMsg + COMPLAINT_REMEDY3.fieldApiName + " ;";
    }

    if (this.saveFields[COMPLAINT_SUB_REMEDY3.fieldApiName] == null) {
      validToSave = false;
      this.errMsg = this.errMsg + COMPLAINT_SUB_REMEDY3.fieldApiName + ";";
    }

    if (
      this.saveFields[COMPLAINT_REMEDY3.fieldApiName] ==
        COMPLAINT_REMEDY_FIN_VALUE &&
      this.saveFields[FINANCIAL_COMPENSATION3.fieldApiName] == null
    ) {
      validToSave = false;
      this.errMsg = this.errMsg + FINANCIAL_COMPENSATION3.fieldApiName + " ;";
    }

    if (
      this.saveFields[COMPLAINT_SUB_REMEDY3.fieldApiName] == REWARD_POINTS &&
      this.saveFields[REMEDY_POINTS3.fieldApiName] == null
    ) {
      validToSave = false;
      this.errMsg = this.errMsg + REMEDY_POINTS3.fieldApiName + ";";
    }

    if (
      (this.saveFields[COMPLAINT_SUB_REMEDY3.fieldApiName] == DEBT_WAIVER ||
        this.saveFields[COMPLAINT_SUB_REMEDY3.fieldApiName] ==
          SETTEL_FOR_LESS) &&
      this.saveFields[FINANCIAL_COMPENSATION3.fieldApiName] == null
    ) {
      validToSave = false;
      this.errMsg = this.errMsg + FINANCIAL_COMPENSATION3.fieldApiName + " ;";
    }

    if (
      this.saveFields[COMPLAINT_SUB_REMEDY3.fieldApiName] == OTHER &&
      this.saveFields[OTHER_REMDY3.fieldApiName] == null
    ) {
      validToSave = false;
      this.errMsg = this.errMsg + OTHER_REMDY3.fieldApiName + " ;";
    }

    if (
      this.saveFields[COMPLAINT_REMEDY3.fieldApiName] ==
        COMPLAINT_REMEDY_PRODUCT_MANU &&
      (this.saveFields[
        THIRD_PARTY_IS_DETAILS_PROVIDED_TO_PRODUCT_MANUFACTURER3.fieldApiName
      ] == null ||
        this.saveFields[
          THIRD_PARTY_IS_DETAILS_PROVIDED_TO_PRODUCT_MANUFACTURER3.fieldApiName
        ] == false)
    ) {
      validToSave = false;
      this.errMsg =
        this.errMsg +
        THIRD_PARTY_IS_DETAILS_PROVIDED_TO_PRODUCT_MANUFACTURER3.fieldApiName +
        " ;";
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
