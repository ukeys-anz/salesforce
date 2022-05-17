import { LightningElement, api, wire } from "lwc";
import { getRecord, updateRecord } from "lightning/uiRecordApi";
import { NavigationMixin } from "lightning/navigation";
import Case_RecordTypeId from "@salesforce/schema/Case.RecordTypeId";
//complaint resolution fields
import COMPLAINT_OUTCOME from "@salesforce/schema/Case.IDR_Complaint_Outcome__c";
import COMPLAINT_REMEDY from "@salesforce/schema/Case.IDR_Complaint_Remedy__c";
import FINANCIAL_COMPENSATION from "@salesforce/schema/Case.IDR_Financial_Compensation__c";
import NON_FINANCIAL_REMEDY from "@salesforce/schema/Case.IDR_Non_Financial_Remedy__c";
import OUTCOME_DESCRIPTION from "@salesforce/schema/Case.IDR_Description_of_Outcome__c";
import STATUS_FIELD from "@salesforce/schema/Case.Status";
import THIRD_PARTY_PRODUCT_MANUFACTURER from "@salesforce/schema/Case.IDR_Product_Manufacturer__c";
import THIRD_PARTY_OTHER_PRODUCT_MANUFACTURER from "@salesforce/schema/Case.Name_of_product_manufacturer__c";
import THIRD_PARTY_IS_DETAILS_PROVIDED_TO_PRODUCT_MANUFACTURER from "@salesforce/schema/Case.Provided_details_to_Product_Manufacturer__c";
import COMPLAINT_SUB_REMEDY from "@salesforce/schema/Case.IDR_Complaint_Sub_Remedy__c";
import ID_FIELD from "@salesforce/schema/Contact.Id";

const PROVISIONALLYCLOSED_STATUS_API_NAME = "Provisionally Closed";
const CLOSED_STATUS_API_NAME = "Closed";
const COMPLAINT_REMEDY_FIN_VALUE = "1";
const COMPLAINT_REMEDY_NON_FIN_VALUE = "2";
const COMPLAINT_REMEDY_PRODUCT_MANU = "3";
const OTHER = "Other";

export default class closeComplaint extends NavigationMixin(LightningElement) {
  @api recordId;
  recordTypeId;
  loadChild = false;
  saveFields = {};

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
      case "IDR_Product_Manufacturer__c":
        this.saveFields[THIRD_PARTY_PRODUCT_MANUFACTURER.fieldApiName] = value;
        break;
      case "Provided_details_to_Product_Manufacturer__c":
        this.saveFields[
          THIRD_PARTY_IS_DETAILS_PROVIDED_TO_PRODUCT_MANUFACTURER.fieldApiName
        ] = value;
        break;
      case "IDR_Financial_Compensation__c":
        this.saveFields[FINANCIAL_COMPENSATION.fieldApiName] = value;
        break;
      case "IDR_Non_Financial_Remedy__c":
        this.saveFields[NON_FINANCIAL_REMEDY.fieldApiName] = value;
        break;
      case "Name_of_product_manufacturer__c":
        this.saveFields[
          THIRD_PARTY_OTHER_PRODUCT_MANUFACTURER.fieldApiName
        ] = value;
        break;
      case "IDR_Complaint_Sub_Remedy__c":
        this.saveFields[COMPLAINT_SUB_REMEDY.fieldApiName] = value;
    }
  }

  validateFields() {
    let validToSave = true;
    if (
      this.saveFields[COMPLAINT_OUTCOME.fieldApiName] == null ||
      this.saveFields[OUTCOME_DESCRIPTION.fieldApiName] == null ||
      this.saveFields[COMPLAINT_REMEDY.fieldApiName] == null
    ) {
      validToSave = false;
    }

    if (
      this.saveFields[COMPLAINT_REMEDY.fieldApiName] ==
        COMPLAINT_REMEDY_FIN_VALUE &&
      this.saveFields[FINANCIAL_COMPENSATION.fieldApiName] == null
    ) {
      validToSave = false;
    }
    if (
      this.saveFields[COMPLAINT_REMEDY.fieldApiName] ==
        COMPLAINT_REMEDY_NON_FIN_VALUE &&
      this.saveFields[NON_FINANCIAL_REMEDY.fieldApiName] == null
    ) {
      validToSave = false;
    }

    if (
      this.saveFields[COMPLAINT_REMEDY.fieldApiName] ==
        COMPLAINT_REMEDY_NON_FIN_VALUE &&
      this.saveFields[NON_FINANCIAL_REMEDY.fieldApiName] == null
    ) {
      validToSave = false;
    }

    if (
      this.saveFields[COMPLAINT_REMEDY.fieldApiName] ==
        COMPLAINT_REMEDY_PRODUCT_MANU &&
      this.saveFields[THIRD_PARTY_PRODUCT_MANUFACTURER.fieldApiName] == null
    ) {
      validToSave = false;
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
    }

    if (
      this.saveFields[THIRD_PARTY_PRODUCT_MANUFACTURER.fieldApiName] == OTHER &&
      this.saveFields[THIRD_PARTY_OTHER_PRODUCT_MANUFACTURER.fieldApiName] ==
        null
    ) {
      validToSave = false;
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
          console.log("error:" + error.body.message);
        });
    }
  }
}
