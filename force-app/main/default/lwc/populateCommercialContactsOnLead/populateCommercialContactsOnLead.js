import { LightningElement, api, wire } from "lwc";
import { getRecord, getFieldValue, updateRecord } from "lightning/uiRecordApi";
import { CloseActionScreenEvent } from "lightning/actions";
import LEAD_ID_FIELD from "@salesforce/schema/Lead.Id";
import EXISTING_CUSTOMER_FIELD from "@salesforce/schema/Lead.FinServ__RelatedAccount__c";
import INDIVIDUAL_PROFILE_FIELD from "@salesforce/schema/Lead.Individual_Customer_Profile__c";
import SALUTATION_FIELD from "@salesforce/schema/Lead.Salutation";
import FIRST_NAME_FIELD from "@salesforce/schema/Lead.FirstName";
import MIDDLE_NAME_FIELD from "@salesforce/schema/Lead.MiddleName";
import LAST_NAME_FIELD from "@salesforce/schema/Lead.LastName";
import MOBILE_PHONE_FIELD from "@salesforce/schema/Lead.MobilePhone";
import WORK_PHONE_FIELD from "@salesforce/schema/Lead.Work_Phone__c";
import HOME_PHONE_FIELD from "@salesforce/schema/Lead.Home_Phone__c";
import EMAIL_FIELD from "@salesforce/schema/Lead.Email";
import CONTACT_METHOD_FIELD from "@salesforce/schema/Lead.Primary_Contact_Method__c";
import getIndividualCustomerRecord from "@salesforce/apex/LeadEnhmentUpdateCommContactController.getIndividualCustomerRecord";
import { publish, MessageContext } from "lightning/messageService";
import CloseModal from "@salesforce/messageChannel/CloseModal__c";
import { showToast, handleErrorShowToast } from "c/utils";

const COLUMNS = [
  {
    label: "Name",
    fieldName: "NameUrl",
    type: "url",
    typeAttributes: {
      label: { fieldName: "Name" },
      target: "_self"
    }
  },
  { label: "Mobile Phone", fieldName: "PersonOtherPhone", type: "text" },
  { label: "Work Phone", fieldName: "Phone", type: "text" },
  { label: "Home Phone", fieldName: "PersonHomePhone", type: "text" },
  { label: "Email", fieldName: "Other_Email__c", type: "text" }
];

export default class PopulateCommercialContactsOnLead extends LightningElement {
  individualCustomerList = [];
  isLoading = true;
  @api recordId;
  existingCustomerId;
  columns = COLUMNS;
  selectedRecord;

  @wire(MessageContext)
  messageContext;

  refresh() {
    publish(this.messageContext, CloseModal, {
      name: "populateCommercialContactsOnLead"
    });
  }

  @wire(getRecord, { recordId: "$recordId", fields: [EXISTING_CUSTOMER_FIELD] })
  leadRecord({ data }) {
    if (data) {
      this.existingCustomerId = getFieldValue(data, EXISTING_CUSTOMER_FIELD);
      this.fetchAccountAccountRelRecords();
    }
  }

  get showTable() {
    return (
      this.individualCustomerList && this.individualCustomerList.length > 0
    );
  }

  get showNoRecordsText() {
    return (
      !this.isLoading &&
      (!this.individualCustomerList || this.individualCustomerList.length === 0)
    );
  }

  fetchAccountAccountRelRecords() {
    getIndividualCustomerRecord({ accountId: this.existingCustomerId })
      .then((result) => {
        let customerList = result;
        this.individualCustomerList = customerList.map((item) => ({
          ...item,
          Name: item.FinServ__RelatedAccount__r?.Name,
          NameUrl: `/${item.FinServ__RelatedAccount__r?.Id}`,
          Phone: item.FinServ__RelatedAccount__r?.Phone,
          PersonOtherPhone: item.FinServ__RelatedAccount__r?.PersonOtherPhone,
          PersonHomePhone: item.FinServ__RelatedAccount__r?.PersonHomePhone,
          Other_Email__c: item.FinServ__RelatedAccount__r?.Other_Email__c
        }));
        this.isLoading = false;
      })
      .catch((error) => {
        this.isLoading = false;
        handleErrorShowToast(
          this,
          "Error",
          error,
          "Some error occurred while fetching records.",
          "dismissable"
        );
      });
  }

  handleRowSelection(event) {
    const rows = event.detail.selectedRows;
    this.selectedRecord = rows.length > 0 ? rows[0] : null;
  }

  get disableSave() {
    return !this.selectedRecord;
  }

  handleCancel() {
    this.dispatchEvent(new CloseActionScreenEvent());
  }

  populateContactMethod(selectedRecord) {
    if (!selectedRecord || !selectedRecord.FinServ__RelatedAccount__r) {
      return null;
    }
    return selectedRecord.FinServ__RelatedAccount__r.PersonOtherPhone
      ? "Mobile"
      : selectedRecord.FinServ__RelatedAccount__r.Phone
        ? "Work Phone"
        : "Home Phone";
  }

  sanitizePhoneNumber(phoneNumber) {
    if (!phoneNumber) {
      return phoneNumber;
    }
    phoneNumber = phoneNumber.toString();
    if (phoneNumber.startsWith("0")) {
      return "+614" + phoneNumber.substring(1);
    }
    return phoneNumber;
  }

  handleUpdate() {
    this.isLoading = true;
    const fields = {};
    fields[LEAD_ID_FIELD.fieldApiName] = this.recordId;
    fields[INDIVIDUAL_PROFILE_FIELD.fieldApiName] =
      this.selectedRecord.FinServ__RelatedAccount__r.Id;
    fields[SALUTATION_FIELD.fieldApiName] =
      this.selectedRecord.FinServ__RelatedAccount__r.Salutation;
    fields[FIRST_NAME_FIELD.fieldApiName] =
      this.selectedRecord.FinServ__RelatedAccount__r.FirstName;
    fields[MIDDLE_NAME_FIELD.fieldApiName] =
      this.selectedRecord.FinServ__RelatedAccount__r.MiddleName;
    fields[LAST_NAME_FIELD.fieldApiName] =
      this.selectedRecord.FinServ__RelatedAccount__r.LastName;
    fields[MOBILE_PHONE_FIELD.fieldApiName] = this.sanitizePhoneNumber(
      this.selectedRecord.FinServ__RelatedAccount__r.PersonOtherPhone
    );
    fields[WORK_PHONE_FIELD.fieldApiName] = this.sanitizePhoneNumber(
      this.selectedRecord.FinServ__RelatedAccount__r.Phone
    );
    fields[HOME_PHONE_FIELD.fieldApiName] = this.sanitizePhoneNumber(
      this.selectedRecord.FinServ__RelatedAccount__r.PersonHomePhone
    );
    fields[EMAIL_FIELD.fieldApiName] =
      this.selectedRecord.FinServ__RelatedAccount__r.Other_Email__c;
    fields[CONTACT_METHOD_FIELD.fieldApiName] = this.populateContactMethod(
      this.selectedRecord
    );

    const recordInput = { fields };
    updateRecord(recordInput)
      .then(() => {
        showToast(
          this,
          "Success",
          "Contact details updated successfully.",
          "",
          "success",
          "dismissable"
        );
      })
      .catch((error) => {
        let errorMsg = error?.body?.output?.fieldErrors;
        if (errorMsg) {
          let firstField = Object.keys(errorMsg)[0];
          errorMsg = errorMsg[firstField][0].message;
        } else if (error?.body?.message) {
          errorMsg = error.body.message;
        }
        showToast(this, "Error", errorMsg, error, "error", "dismissable");
      })
      .finally(() => {
        this.isLoading = false;
        this.dispatchEvent(new CloseActionScreenEvent());
      });
  }
}
