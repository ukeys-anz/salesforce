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

const REGEX_MOBILE = /^(\+614[0-9]{8}$|^\+615[0-9]{8}$)/;
const REGEX_PHONE = /^\+61[0-9]{9}$/;

const ERROR_MESSAGES = {
  MOBILE_PHONE:
    "Mobile Phone number needs to be in the format of +614 or +615 followed by 8 digits. Eg. +61412345678 or +61512345678",
  WORK_PHONE:
    "Work Phone number needs to be in the format of +61 followed by 9 digits. Eg. +61312345678",
  HOME_PHONE:
    "Home Phone number needs to be in the format of +61 followed by 9 digits. Eg. +61312345678"
};

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

  get selectedAccount() {
    return this.selectedRecord?.FinServ__RelatedAccount__r || null;
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
        this.individualCustomerList = result.map((item) => ({
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

  populateContactMethod() {
    if (!this.selectedAccount) {
      return null;
    }
    return this.selectedAccount.PersonOtherPhone
      ? "Mobile"
      : this.selectedAccount.Phone
        ? "Work Phone"
        : "Home Phone";
  }

  validatePhone(fieldLabel, phone, regex) {
    if (!phone) {
      return true;
    }
    if (!regex.test(phone)) {
      let errorMsg = "";
      switch (fieldLabel) {
        case "Mobile Phone":
          errorMsg = ERROR_MESSAGES.MOBILE_PHONE;
          break;
        case "Work Phone":
          errorMsg = ERROR_MESSAGES.WORK_PHONE;
          break;
        case "Home Phone":
          errorMsg = ERROR_MESSAGES.HOME_PHONE;
          break;
        default:
          errorMsg = "Invalid phone number format.";
          break;
      }
      showToast(this, "Error", errorMsg, "", "error");
      return false;
    }
    return true;
  }

  handleUpdate() {
    this.isLoading = true;

    const mobilePhone = this.selectedAccount?.PersonOtherPhone;
    const workPhone = this.selectedAccount?.Phone;
    const homePhone = this.selectedAccount?.PersonHomePhone;

    // Validate all phone numbers
    const allPhonesValid = [
      { type: "Mobile Phone", phone: mobilePhone, regex: REGEX_MOBILE },
      { type: "Work Phone", phone: workPhone, regex: REGEX_PHONE },
      { type: "Home Phone", phone: homePhone, regex: REGEX_PHONE }
    ].every(({ type, phone, regex }) => this.validatePhone(type, phone, regex));

    if (!allPhonesValid) {
      this.isLoading = false;
      return;
    }

    const fields = {
      [LEAD_ID_FIELD.fieldApiName]: this.recordId,
      [INDIVIDUAL_PROFILE_FIELD.fieldApiName]: this.selectedAccount?.Id,
      [SALUTATION_FIELD.fieldApiName]: this.selectedAccount?.Salutation ?? "",
      [FIRST_NAME_FIELD.fieldApiName]: this.selectedAccount?.FirstName ?? "",
      [MIDDLE_NAME_FIELD.fieldApiName]: this.selectedAccount?.MiddleName ?? "",
      [LAST_NAME_FIELD.fieldApiName]: this.selectedAccount?.LastName,
      [MOBILE_PHONE_FIELD.fieldApiName]: mobilePhone ?? "",
      [WORK_PHONE_FIELD.fieldApiName]: workPhone ?? "",
      [HOME_PHONE_FIELD.fieldApiName]: homePhone ?? "",
      [EMAIL_FIELD.fieldApiName]: this.selectedAccount?.Other_Email__c ?? "",
      [CONTACT_METHOD_FIELD.fieldApiName]: this.populateContactMethod()
    };

    updateRecord({ fields })
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
        const errorMsg = this.extractErrorMessage(error);
        showToast(this, "Error", errorMsg, error, "error", "dismissable");
      })
      .finally(() => {
        this.isLoading = false;
        this.dispatchEvent(new CloseActionScreenEvent());
      });
  }

  extractErrorMessage(error) {
    let message = "Something went wrong";
    // Field-level validation errors
    if (error?.body?.output?.fieldErrors) {
      const fieldErrors = error.body.output.fieldErrors;
      const firstField = Object.keys(fieldErrors)[0];
      if (fieldErrors[firstField] && fieldErrors[firstField][0]?.message) {
        return fieldErrors[firstField][0].message;
      }
    }
    // Page-level validation rules errors
    if (error?.body?.output?.errors?.length > 0) {
      return error.body.output.errors[0].message;
    }
    // General message
    if (error?.body?.message) {
      return error.body.message;
    }
    return message;
  }
}
