import { LightningElement, api, wire, track } from "lwc";
import getCustomerData from "@salesforce/apex/GetCustomerInformation.getCustomerData";
import { getRecord, getFieldValue } from "lightning/uiRecordApi";
import { updateRecord } from "lightning/uiRecordApi";
import { refreshApex } from "@salesforce/apex";
import { ShowToastEvent } from "lightning/platformShowToastEvent";

import CAP_ID_FIELD from "@salesforce/schema/Case.IDR_Customer_Number__c";
import FIRST_NAME from "@salesforce/schema/Case.IDR_NC_First_Name__c";
import LAST_NAME from "@salesforce/schema/Case.IDR_NC_Last_Name__c";
import MIDDLE_NAME from "@salesforce/schema/Case.IDR_NC_Middle_Names__c";
import ID_FIELD from "@salesforce/schema/Case.Id";

export default class CustomerInformation extends LightningElement {
  isCustomerDataBeUpdated = false;
  @track loaded = false;
  @track customerInfo;
  @api recordId;
  @track error;
  @api showAsGrid;
  @api
  get customerId() {
    return this._customerId;
  }

  set customerId(customerId = "") {
    this._customerId = customerId;
    if (this.customerId) {
      this.loaded = false;
      this.customerInfo = null;
      this.custData(this.customerId.replace(/^0+/, ""));
    }
  }

  @wire(getRecord, {
    recordId: "$recordId",
    fields: [CAP_ID_FIELD, FIRST_NAME, MIDDLE_NAME]
  })
  wiredProject({ error, data }) {
    if (data && this.record !== data) {
      this.record = data;
      if (
        getFieldValue(this.record.data, FIRST_NAME) == null &&
        getFieldValue(this.record, LAST_NAME) == null
      ) {
        this.isCustomerDataBeUpdated = true;
      }
      this.custData(
        this.record.fields.IDR_Customer_Number__c.value.replace(/^0+/, "")
      );
    } else if (error) {
      this.handleError(error);
    }
  }

  updateCustomerDetailsonCase() {
    const fields = {};
    fields[ID_FIELD.fieldApiName] = this.recordId;
    fields[FIRST_NAME.fieldApiName] = this.customerInfo.first_name;
    fields[LAST_NAME.fieldApiName] = this.customerInfo.last_name;
    fields[MIDDLE_NAME.fieldApiName] = this.customerInfo.middlename;

    const recordInput = { fields };
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

  custData(customerId) {
    // calling apex class method to make callout
    if (!this.loaded) {
      this.error = null;
      getCustomerData({ capId: customerId })
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
            country: ""
          };
          // retrieving the response data
          let responseData = result.profile;
          let accountsData = result.accounts;
          let accounts = [];
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
          console.log(accountsData[0].accountNumber);
          for (i = 0; i < accountsData.length; i++) {
            accounts[i]=(accountsData[i].accountNumber);
          }
          //console.log("Afreeb"+accounts);
          // adding data object to show in UI
          this.loaded = true;
          this.customerInfo = customerData;
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
  }
  handleError(err) {
    this.loaded = true;
    this.error = "Unknown error";
    if (err.body) {
      if (Array.isArray(err.body)) {
        this.error = err.body.map((e) => e.message).join(", ");
      } else if (typeof err.body.message === "string") {
        this.error = err.body.message;
      }
    }
    // if the customer Id couldnt be validated against CAP at the moment throw this event so that case can be created.
    console.log("this.error:" + this.error);
    if (!this.error.includes("No data found for the given customerId")) {
      this.dispatchEvent(new CustomEvent("custinfochecked"));
    }
    this.record = undefined;
  }
}
