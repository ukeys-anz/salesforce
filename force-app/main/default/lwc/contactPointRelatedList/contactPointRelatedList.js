import { api, LightningElement, wire } from "lwc";
import getContactPointObjectRecords from "@salesforce/apex/ContactPointObjectsController.getContactPointObjectRecords";
import { handleErrorShowToast, handleErrors } from "c/utils";

//object api names
const OBJ_CONTACTPOINTADDRESS = "ContactPointAddress";
const OBJ_CONTACTPOINTEMAIL = "ContactPointEmail";
const OBJ_CONTACTPOINTPHONE = "ContactPointPhone";

//list titles
const TITLE_CONTACTPOINTADDRESS = "Addresses";
const TITLE_CONTACTPOINTEMAIL = "Email Addresses";
const TITLE_CONTACTPOINTPHONE = "Phone Numbers";

//icons
const ICON_CONTACTPOINTADDRESS = "standard:address";
const ICON_CONTACTPOINTEMAIL = "custom:custom105";
const ICON_CONTACTPOINTPHONE = "standard:log_a_call";

//columns
const COLUMNS_CONTACTPOINTPHONE = [
  {
    label: "Persona Type",
    fieldName: "Persona_Type__c",
    hideDefaultActions: true
  },
  {
    label: "Phone Number",
    fieldName: "TelephoneNumber",
    type: "phone",
    hideDefaultActions: true
  },
  {
    label: "Phone Type",
    fieldName: "PhoneType",
    hideDefaultActions: true
  },
  {
    label: "Preferred",
    fieldName: "Preferred_Indicator__c",
    hideDefaultActions: true
  }
];

const COLUMNS_CONTACTPOINTADDRESS = [
  {
    label: "Persona Type",
    fieldName: "Persona_Type__c",
    hideDefaultActions: true
  },
  {
    label: "Address",
    fieldName: "FullAddress",
    hideDefaultActions: true
  },
  {
    label: "Address Type",
    fieldName: "AddressType",
    hideDefaultActions: true
  },
  {
    label: "Preferred",
    fieldName: "IsPreferred",
    hideDefaultActions: true
  }
];

const COLUMNS_CONTACTPOINTEMAIL = [
  {
    label: "Persona Type",
    fieldName: "Persona_Type__c",
    hideDefaultActions: true
  },
  {
    label: "Email Address",
    fieldName: "EmailAddress",
    type: "email"
  },
  {
    label: "Preferred",
    fieldName: "Preferred_Indicator__c",
    hideDefaultActions: true
  }
];

export default class ContactPhoneRelatedList extends LightningElement {
  @api recordId;
  @api contactPointObjectApiName;
  records;
  columns;
  error;

  @wire(getContactPointObjectRecords, {
    objectApiName: "$contactPointObjectApiName",
    recordId: "$recordId"
  })
  wiredRecords({ data, error }) {
    if (data?.length > 0) {
      this.records = this.processRecords(data);
      this.error = undefined;
    } else if (error) {
      this.records = undefined;
      this.error = error;
      this.handleError(error);
    }
    this.setProperties();
  }

  processRecords(records) {
    let tmpRecords = [];
    if (this.contactPointObjectApiName === OBJ_CONTACTPOINTADDRESS) {
      records.forEach((rec) => {
        rec = {
          ...rec,
          FullAddress: rec.Address
            ? `${rec.Address.street} ${rec.Address.city} ${rec.Address.state} ${rec.Address.postalCode} ${rec.Address.country}`
            : "",
          IsPreferred: rec.IsDefault ? "Yes" : "No"
        };
        tmpRecords.push(rec);
      });
    }
    return tmpRecords?.length > 0 ? tmpRecords : records;
  }

  setProperties() {
    switch (this.contactPointObjectApiName) {
      case OBJ_CONTACTPOINTADDRESS: {
        this.title = TITLE_CONTACTPOINTADDRESS;
        this.icon = ICON_CONTACTPOINTADDRESS;
        this.columns = COLUMNS_CONTACTPOINTADDRESS;
        break;
      }
      case OBJ_CONTACTPOINTEMAIL: {
        this.title = TITLE_CONTACTPOINTEMAIL;
        this.icon = ICON_CONTACTPOINTEMAIL;
        this.columns = COLUMNS_CONTACTPOINTEMAIL;
        break;
      }
      case OBJ_CONTACTPOINTPHONE: {
        this.title = TITLE_CONTACTPOINTPHONE;
        this.icon = ICON_CONTACTPOINTPHONE;
        this.columns = COLUMNS_CONTACTPOINTPHONE;
        break;
      }
      default:
        break;
    }
  }

  handleError = (error) => {
    const errorMessage = handleErrors.call(this, error);

    handleErrorShowToast(
      this,
      "Error.",
      error,
      `Error while retrieving records from ${this.title}: ${errorMessage}`,
      "pester"
    );
  };
}
