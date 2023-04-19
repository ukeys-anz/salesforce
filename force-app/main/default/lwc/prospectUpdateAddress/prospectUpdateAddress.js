import { LightningElement, api, wire, track } from "lwc";
import { getRecord } from "lightning/uiRecordApi";
import { getObjectInfo } from "lightning/uiObjectInfoApi";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { CloseActionScreenEvent } from "lightning/actions";
import { handleWireError } from "c/utils";

const FIELDS = [
  "ContactPointAddress.Street",
  "ContactPointAddress.City",
  "ContactPointAddress.State",
  "ContactPointAddress.PostalCode",
  "ContactPointAddress.Country",
  "ContactPointAddress.Global_Address_Key__c",
  "ContactPointAddress.Delivery_Identifier__c",
  "ContactPointAddress.Customer_Name__c"
];
export default class ProspectUpdateAddress extends LightningElement {
  loading;
  accountId;
  addressId;
  objectAPIName;
  recordTypeId;
  @track currentAddress = {};

  @api get recordId() {
    return null;
  }
  set recordId(val) {
    if (val.startsWith("001")) {
      this.accountId = val;
    } else if (val.startsWith("8lW")) {
      this.addressId = val;
    } else {
      this.closeQuickAction();
    }
  }

  @wire(getObjectInfo, { objectApiName: "ContactPointAddress" })
  getObjectInfo({ data, error }) {
    if (data) {
      this.recordTypeId = Object.values(data.recordTypeInfos).find(
        (x) => x.name === "Organisation"
      ).recordTypeId;
    }
    if (error) {
      this.closeQuickAction();
      handleWireError(this, "Failed to load Address object metadata", error);
    }
  }

  @wire(getRecord, { recordId: "$addressId", fields: FIELDS })
  getRecord({ data, error }) {
    if (data) {
      this.currentAddress = {
        street: data.fields.Street.value,
        city: data.fields.City.value,
        state: data.fields.State.value,
        country: data.fields.Country.value,
        postalCode: data.fields.PostalCode.value,
        globalAddressKey: data.fields.Global_Address_Key__c.value
      };
      this.accountId = data.fields.Customer_Name__c.value;
    }
    if (error) {
      this.closeQuickAction();
      handleWireError(this, "Failed to load Address record", error);
    }
  }

  get title() {
    return `${this.addressId ? "Edit" : "Add"} Address`;
  }

  handleError() {
    this.loading = false;
  }

  handleSuccess() {
    this.loading = false;
    this.dispatchEvent(
      new ShowToastEvent({
        message: `Address ${this.addressId ? "Updated" : "Added"} Successfully`,
        variant: "success"
      })
    );
    this.closeQuickAction();
  }
  handleSubmit(e) {
    e.preventDefault();
    const addressCmp = this.template.querySelector("c-address-lookup-util");
    if (!addressCmp.reportValidity()) {
      return;
    }
    const address = addressCmp.value;
    const record = e.detail.fields;
    if (this.addressId == null && this.accountId) {
      record.ParentId = record.Customer_Name__c = this.accountId;
      record.RecordTypeId = this.recordTypeId;
    }
    record.Name = record.AddressType;
    record.Street = address.street;
    record.City = address.city;
    record.State = address.state;
    record.Country = address.country;
    record.PostalCode = address.postalCode;
    record.Global_Address_Key__c = address.globalAddressKey;
    record.Delivery_Identifier__c = address.dpid;

    this.loading = true;
    this.template.querySelector("lightning-record-edit-form").submit(record);
  }

  closeQuickAction() {
    this.dispatchEvent(new CustomEvent("close"));
    this.dispatchEvent(new CloseActionScreenEvent());
  }
}
