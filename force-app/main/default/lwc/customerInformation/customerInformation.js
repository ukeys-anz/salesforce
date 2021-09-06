import { LightningElement, api, wire, track } from "lwc";
import getCustomerData from "@salesforce/apex/CMOSAPIRepository.getCustomerInfoLWC";
import { getRecord, getFieldValue } from "lightning/uiRecordApi";
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

export default class CustomerInformation extends LightningElement {
  isCustomerDataBeUpdated = false;
  @track loaded = true;
  @track customerInfo;
  @track showMore = false;
  @api recordId;
  @track error;
  @track isRMDetails;
  @track rmDetailsError;
  @api showAsGrid;
  @api custIdentifier;
  @api
  get customerId() {
    return this._customerId;
  }

  set customerId(customerId = "") {
    this._customerId = customerId;
    if (this.customerId) {
      this.loaded = false;
      this.customerInfo = null;
      this.custData(this.customerId.replace(/^0+/, ""), this.custIdentifier);
    }
  }

  @wire(getRecord, {
    recordId: "$recordId",
    fields: [
      CAP_ID_FIELD,
      FIRST_NAME,
      MIDDLE_NAME,
      LAST_NAME,
      RM_COMPLAINT,
      CUSTOMER_IDENTIFIER,
      COMPLAINANT_TYPE
    ]
  })
  wiredProject({ error, data }) {
    if (data && this.record !== data) {
      this.record = data;

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
        if (
          customerData1.first_name == null &&
          customerData1.last_name == null
        ) {
          this.isCustomerDataBeUpdated = true;
        }
      }
    } else if (error) {
      this.handleError(error);
    }
  }

  showAllCustomerData() {
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
    fields[CP_ID.fieldApiName] = this.customerInfo.capId;
    fields[RM_COMPLAINT.fieldApiName] = this.customerInfo.isRmPresent;
    fields[EMAIL_FIELD.fieldApiName] = this.customerInfo.email;

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

  custData(customerId, custIdentifier) {
    // calling apex class method to make callout
    this.loaded = false;
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
          isRmPresent: false,
          accounts: [],
          rmData: { name: "", phone: "", officeAddress: "" }
        };
        // retrieving the response data
        let responseData = result.profile;
        let accountsData = result.accounts;
        let relationshipData = result.relationshipManager;
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
        customerData.ocvId = responseData.ocvId;
        customerData.cpId = responseData.cpId;
        customerData.dob = responseData.dob;
        let x;
        for (x in accountsData) {
          if (accountsData[x].accountNumber != null) {
            accounts.push(accountsData[x].accountNumber);
          }
        }
        customerData.accounts = accounts;
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
        this.loaded = true;
        this.customerInfo = customerData;
        this.showMore = true;
        if (this.isCustomerDataBeUpdated === true) {
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
    if (!this.error.includes("No data found for the given customerId")) {
      this.dispatchEvent(new CustomEvent("custinfochecked"));
    }

    this.record = undefined;
  }
}
