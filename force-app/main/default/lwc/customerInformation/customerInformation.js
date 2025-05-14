import { LightningElement, api, wire, track } from "lwc";
import getCustomerData from "@salesforce/apex/IDRAPIRepository.getCustomerInfoLWC";
import { getRecord, getFieldValue } from "lightning/uiRecordApi";
import getFinancialAccounts from "@salesforce/apex/GetCustomerInformation.fetchCustomerFinancialAccounts";
import { updateRecord } from "lightning/uiRecordApi";
import { refreshApex } from "@salesforce/apex";
import { ShowToastEvent } from "lightning/platformShowToastEvent";

import CAP_ID_FIELD from "@salesforce/schema/Case.IDR_Customer_Number__c";
import CUSTOMER_IDENTIFIER from "@salesforce/schema/Case.IDR_Customer_Identifier__c";
import COMPLAINANT_TYPE from "@salesforce/schema/Case.IDR_Complainant_Type__c";
import FIRST_NAME from "@salesforce/schema/Case.IDR_NC_First_Name__c";
import LAST_NAME from "@salesforce/schema/Case.IDR_NC_Last_Name__c";
import MIDDLE_NAME from "@salesforce/schema/Case.IDR_NC_Middle_Names__c";
import EMAIL_FIELD from "@salesforce/schema/Case.IDR_NC_Email__c";
import RM_COMPLAINT from "@salesforce/schema/Case.Relationship_Managed_Complaint__c";
import OCV_ID from "@salesforce/schema/Case.OCV_Id__c";
import CP_ID from "@salesforce/schema/Case.CPID__c";
import ID_FIELD from "@salesforce/schema/Case.Id";

const FIELDS = [
  CAP_ID_FIELD,
  FIRST_NAME,
  MIDDLE_NAME,
  LAST_NAME,
  RM_COMPLAINT,
  CUSTOMER_IDENTIFIER,
  COMPLAINANT_TYPE,
  "Case.AccountId",
  "Case.Account.LastName",
  "Case.Account.FirstName",
  "Case.Account.MiddleName",
  "Case.Relationship_Managed_Complaint__c",
  "Case.Account.CPID__c",
  "Case.Account.OCV_ID__c",
  "Case.Account.PersonBirthdate",
  "Case.Account.Other_Email__c",
  "Case.Account.PersonEmail",
  "Case.Account.PersonOtherPhone",
  "Case.Account.PersonMobilePhone",
  "Case.Account.BillingStreet",
  "Case.Account.BillingCity",
  "Case.Account.BillingPostalCode",
  "Case.Account.BillingCountry",
  "Case.Account.BillingState",
  "Case.Account.PersonOtherCity",
  "Case.Account.PersonOtherCountry",
  "Case.Account.PersonOtherState",
  "Case.Account.PersonOtherPostalCode",
  "Case.Account.PersonOtherStreet",
  "Case.Account.ShippingCity",
  "Case.Account.ShippingCountry",
  "Case.Account.ShippingPostalCode",
  "Case.Account.ShippingState",
  "Case.Account.ShippingStreet",
  "Case.Account.FinServ__Age__pc",
  "Case.Account.Gender__pc",
  "Case.Account.RecordType.Name",
  "Case.Account.Migration_Status__c",
  "Case.Account.Migration_Status_Date__c",
  "Case.Account.Controlling_Post__r.Responsible_Employee_Name__c",
  "Case.Account.Controlling_Post__r.CPID_Phone__c",
  "Case.Account.Controlling_Post__r.CPID_Address__c"
];

export default class CustomerInformation extends LightningElement {
  @track isLoading = false;
  @track customerInfo;
  @track showMore = false;
  @api recordId;
  @track error;
  @track isRMDetails;
  @track rmDetailsError;
  @api showAsGrid;
  @api custIdentifier;
  firstName;
  lastName;

  @api
  get customerId() {
    return this._customerId;
  }

  set customerId(customerId = "") {
    this._customerId = customerId;
    if (this.customerId) {
      this.isLoading = true;
      this.customerInfo = null;
      this.custData(this.customerId.replace(/^0+/, ""), this.custIdentifier);
    }
  }

  @wire(getRecord, {
    recordId: "$recordId",
    fields: FIELDS
  })
  wiredProject({ error, data }) {
    if (data && this.record !== data) {
      this.record = data;
      let accId = this.record.fields.AccountId?.value;
      if (!this.customerInfo && accId) {
        let accountData = this.record.fields.Account.value.fields;
        let customerAccountData = this.setCustomerData(accountData);
        this.customerInfo = customerAccountData;
        this.firstName = customerAccountData.first_name;
        this.lastName = customerAccountData.last_name;
      }

      if (!this.customerInfo) {
        let customerData1 = {
          complainant_type: "",
          first_name: "",
          last_name: "",
          middlename: "",
          isRmPresent: false
        };
        customerData1.first_name = getFieldValue(this.record, FIRST_NAME);
        customerData1.last_name = getFieldValue(this.record, LAST_NAME);
        customerData1.middlename = getFieldValue(this.record, MIDDLE_NAME);
        customerData1.isRmPresent = getFieldValue(this.record, RM_COMPLAINT);
        customerData1.complainant_type =
          getFieldValue(this.record, COMPLAINANT_TYPE) === "1"
            ? "Individual"
            : "Business";
        this.customerInfo = customerData1;
        this.firstName = customerData1.first_name;
        this.lastName = customerData1.last_name;
      }
    } else if (error) {
      this.handleError(error);
    }
  }
  setCustomerData(accountData) {
    let customerAccountData = {
      accId: "",
      complainant_type: "",
      first_name: "",
      last_name: "",
      middlename: "",
      isRmPresent: "",
      gender: "",
      age: "",
      cpId: "",
      ocvId: "",
      emailclassic: "",
      emailanzplus: "",
      mobileclassic: "",
      mobileanzplus: "",
      street: "",
      suburb: "",
      state: "",
      postcode: "",
      country: "",
      migrationStatusType: "",
      migrationStatusDate: "",
      rmData: { name: "", phone: "", officeAddress: "" },
      accounts: []
    };
    let controllingPost = accountData.Controlling_Post__r?.value;
    let address = this.populateAddress(accountData);
    customerAccountData.first_name = accountData.FirstName?.value;
    customerAccountData.last_name = accountData.LastName?.value;
    customerAccountData.accId = this.record.fields.AccountId?.value;
    customerAccountData.middlename = accountData.MiddleName?.value;
    customerAccountData.isRmPresent =
      this.record.fields.Relationship_Managed_Complaint__c?.value;
    customerAccountData.gender = accountData.Gender__pc?.value;
    customerAccountData.age = accountData.FinServ__Age__pc?.value
      ? Math.trunc(Number(accountData.FinServ__Age__pc.value))
      : "";
    customerAccountData.cpId = accountData.CPID__c?.value;
    customerAccountData.ocvId = accountData.OCV_ID__c?.value;
    customerAccountData.emailclassic = accountData.Other_Email__c?.value;
    customerAccountData.emailanzplus = accountData.PersonEmail?.value;
    customerAccountData.mobileclassic = accountData.PersonOtherPhone?.value;
    customerAccountData.mobileanzplus = accountData.PersonMobilePhone?.value;
    customerAccountData.street = address?.street;
    customerAccountData.suburb = address?.suburb;
    customerAccountData.state = address?.state;
    customerAccountData.postcode = address?.postCode;
    customerAccountData.country = address?.country;
    customerAccountData.migrationStatusType =
      accountData.Migration_Status__c?.value;
    customerAccountData.migrationStatusDate =
      accountData.Migration_Status_Date__c?.value;
    customerAccountData.complainant_type =
      accountData.RecordType.value.fields.Name?.value;
    customerAccountData.rmData.name =
      controllingPost === null
        ? ""
        : controllingPost.fields.Responsible_Employee_Name__c?.value;
    customerAccountData.rmData.phone =
      controllingPost === null
        ? ""
        : controllingPost.fields.CPID_Phone__c?.value;
    customerAccountData.rmData.officeAddress =
      controllingPost === null
        ? ""
        : controllingPost.fields.CPID_Address__c?.value;
    return customerAccountData;
  }

  showAllCustomerData() {
    if (this.customerInfo.accId) {
      getFinancialAccounts({
        accId: this.customerInfo.accId,
        ocvId: this.customerInfo.ocvId
      }).then((result) => {
        this.customerInfo.accounts = result.map((i) => ({
          accountNumber: i.Account_Key__c.substring(
            0,
            i.Account_Key__c.indexOf("_")
          )
        }));
      });

      if (this.customerInfo.rmData.name) this.isRMDetails = true;
      this.showMore = true;
      return;
    }
    this.custData(
      this.record.fields.IDR_Customer_Number__c.value.replace(/^0+/, ""),
      this.record.fields.IDR_Customer_Identifier__c.value
    );
  }

  updateCustomerDetailsonCase() {
    const fields = {};
    fields[ID_FIELD.fieldApiName] = this.recordId;
    fields[FIRST_NAME.fieldApiName] = this.customerInfo.first_name;
    fields[LAST_NAME.fieldApiName] = this.customerInfo.last_name;
    fields[MIDDLE_NAME.fieldApiName] = this.customerInfo.middlename;
    fields[OCV_ID.fieldApiName] = this.customerInfo.ocvId;
    fields[CP_ID.fieldApiName] = this.customerInfo.cpId;
    fields[RM_COMPLAINT.fieldApiName] = this.customerInfo.isRmPresent;
    fields[EMAIL_FIELD.fieldApiName] = this.customerInfo.email;

    const recordInput = { fields };
    if (this.recordId) {
      updateRecord(recordInput)
        .then(() => {
          this.dispatchEvent(
            new ShowToastEvent({
              title: "Success",
              message: "Customer name is updated ",
              variant: "success"
            })
          );
          // Display fresh data in the form
          return refreshApex(this.record);
        })
        .catch((error) => {
          this.dispatchEvent(
            new ShowToastEvent({
              title: "Error creating record",
              message: error.body.message,
              variant: "error"
            })
          );
        });
    }
  }

  custData(customerId, custIdentifier) {
    // calling apex class method to make callout
    this.isLoading = true;
    this.error = null;
    this.rmDetailsError = null;
    this.isRMDetails = false;
    getCustomerData({
      customerId: customerId,
      customerIdentifier: custIdentifier
    })
      .then((result) => {
        let customerData = {
          complainant_type: "",
          first_name: "",
          last_name: "",
          middlename: "",
          mobile: "",
          businessname: "",
          gender: "",
          email: "",
          age: "",
          suburb: "",
          street: "",
          state: "",
          postcode: "",
          country: "",
          ocvId: "",
          cpId: "",
          dob: "",
          migrationStatusDate: "",
          migrationStatusType: "",
          isRmPresent: false,
          accounts: [],
          rmData: { name: "", phone: "", officeAddress: "" }
        };
        // retrieving the response data
        let responseData = result.profile;
        let accountsData = result.accounts;
        let relationshipData = result.relationshipManager;
        // adding data object by reading from JSON
        customerData.complainant_type = responseData.complainantType;
        customerData.first_name = responseData.firstName;
        customerData.last_name = responseData.lastName;
        customerData.middlename = responseData.middleName;
        customerData.mobile = responseData.mobile;
        customerData.businessname = responseData.businessName;
        customerData.age = responseData.age;
        customerData.country = responseData.country;
        customerData.email = responseData.email;
        customerData.gender = responseData.gender;
        customerData.postcode = responseData.postCode;
        customerData.state = responseData.state;
        customerData.street = responseData.street;
        customerData.suburb = responseData.suburb;
        customerData.ocvId = responseData.ocvId;
        customerData.cpId = responseData.cpId;
        customerData.dob = responseData.dob;
        customerData.migrationStatusDate = responseData.migrationStatusDate;
        customerData.migrationStatusType = responseData.migrationStatusType;

        customerData.accounts = JSON.parse(JSON.stringify(accountsData));
        if (
          !relationshipData &&
          relationshipData.details == null &&
          relationshipData.error == null
        ) {
          isRMDetails = false;
          customerData.isRmPresent = true;
        } else if (
          relationshipData.details != null &&
          relationshipData.error == null
        ) {
          this.isRMDetails = true;
          customerData.rmData.name = relationshipData.details.name;
          customerData.rmData.phone = relationshipData.details.phoneNumber;
          customerData.rmData.officeAddress =
            relationshipData.details.address[0].addressLine1 +
            ", " +
            relationshipData.details.address[0].addressLine2;
          customerData.isRmPresent = true;
        } else if (
          relationshipData.details == null &&
          relationshipData.error != null
        ) {
          this.rmDetailsError = relationshipData.error.message;
        }

        // adding data object to show in UI
        this.isLoading = false;
        this.customerInfo = customerData;
        this.showMore = true;
        if (
          (customerData.first_name !== undefined &&
            this.firstName !== customerData.first_name) ||
          (customerData.last_name !== undefined &&
            this.lastName !== customerData.last_name)
        ) {
          this.updateCustomerDetailsonCase();
        }
        this.dispatchEvent(
          new CustomEvent("custinfochecked", {
            detail: this.customerInfo
          })
        );
      })
      .catch((error) => {
        this.handleError(error);
      });
  }
  populateAddress(accountData) {
    let address = {
      street: "",
      country: "",
      postCode: "",
      state: "",
      suburb: ""
    };
    if (accountData.RecordType.value.fields.Name?.value === "Individual") {
      address.street = accountData.PersonOtherStreet?.value;
      address.country = accountData.PersonOtherCountry?.value;
      address.postCode = accountData.PersonOtherPostalCode?.value;
      address.state = accountData.PersonOtherState?.value;
      address.suburb = accountData.PersonOtherStreet?.value;
      return address;
    }
    if (accountData.RecordType.value.fields.Name?.value === "Organisation") {
      if (accountData.ShippingPostalCode?.value != null) {
        address.street = accountData.ShippingStreet?.value;
        address.country = accountData.ShippingCountry?.value;
        address.postCode = accountData.ShippingPostalCode?.value;
        address.state = accountData.ShippingState?.value;
        address.suburb = accountData.ShippingCity?.value;
        return address;
      }
      address.street = accountData.BillingStreet?.value;
      address.country = accountData.BillingCountry?.value;
      address.postCode = accountData.BillingPostalCode?.value;
      address.state = accountData.BillingState?.value;
      address.suburb = accountData.BillingCity?.value;
      return address;
    }
    return address;
  }
  handleError(err) {
    this.isLoading = false;
    this.error = "Unknown error";
    if (err.body) {
      if (Array.isArray(err.body)) {
        this.error = err.body.map((e) => e.message).join(", ");
      } else if (typeof err.body.message === "string") {
        this.error = err.body.message;
      }
    }
    // if the customer Id couldnt be validated against CAP at the moment throw this event so that case can be created.
    if (!this.error.includes("No data found for the given customerId")) {
      // Sending this event incorrectly flags the Customer Number as successful.
      //      this.dispatchEvent(new CustomEvent("custinfochecked"));
    }

    this.record = undefined;
  }
}
