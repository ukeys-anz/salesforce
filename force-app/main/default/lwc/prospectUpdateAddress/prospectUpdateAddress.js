import { LightningElement, api, wire, track } from "lwc";
import { getRecord } from "lightning/uiRecordApi";
import { getObjectInfo } from "lightning/uiObjectInfoApi";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { CloseActionScreenEvent } from "lightning/actions";
import { handleWireError, handleErrorShowToast } from "c/utils";
import validateManualAddress from "@salesforce/apex/MLCRMAPIRepository.validateManualAddressesV3LWC";

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
  recordTypeName;
  @track currentAddress = {};
  hasValidAddress = true;
  mnaualSelectedAddress = {};
  strAddressType;
  strIsDefault;
  lookUpAddressResult;
  fields;
  CONSTANT = {
    VALID_COUNTRY: "AUS"
  };
  isManualAddress = false;
  columns = [
    {
      label: "Subrub",
      fieldName: "suburb",
      type: "text"
    },
    {
      label: "State",
      fieldName: "state",
      type: "text"
    },
    {
      label: "PostCode",
      fieldName: "postCode",
      type: "text"
    }
  ];
  record = {};
  address = {};
  disabled = false;

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
  @api get recordType() {
    return null;
  }
  set recordType(val) {
    if (val) {
      this.recordTypeName = val;
    } else {
      this.recordTypeName = "Organisation";
    }
  }

  @wire(getObjectInfo, { objectApiName: "ContactPointAddress" })
  getObjectInfo({ data, error }) {
    if (data) {
      if (
        this.recordTypeName !== undefined &&
        this.recordTypeName !== null &&
        this.recordTypeName !== ""
      ) {
        this.recordTypeId = Object.values(data.recordTypeInfos).find(
          (x) => x.name === this.recordTypeName
        ).recordTypeId;
      } else if (this.addressId === undefined || this.addressId === null) {
        this.recordTypeId = Object.values(data.recordTypeInfos).find(
          (x) => x.name === "Organisation"
        ).recordTypeId;
      }
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
    return this.hasValidAddress
      ? `${this.addressId ? "Edit" : "Add"} Address`
      : "Pick Suburb / State / Postcode";
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
    this.address =
      this.template.querySelector("c-address-lookup-util") !== null
        ? this.template.querySelector("c-address-lookup-util")
        : this.address;
    if (this.address && !this.address.reportValidity()) {
      return;
    }
    const address = this.address?.value;
    this.record =
      Object.keys(this.record).length === 0 ? e.detail.fields : this.record;
    this.loading = true;
    this.strAddressType = this.record.AddressType;
    this.strIsDefault = this.record.IsDefault;
    if (this.addressId == null && this.accountId) {
      this.record.ParentId = this.record.Customer_Name__c = this.accountId;
      this.record.RecordTypeId = this.recordTypeId;
    }
    this.record.Name = this.record.AddressType;
    if (
      this.isManualAddress === true &&
      this.hasValidAddress === true &&
      address.country === this.CONSTANT.VALID_COUNTRY
    ) {
      this.validateAddress(this.record);
    } else if (
      this.isManualAddress === true &&
      this.hasValidAddress === false &&
      address.country === this.CONSTANT.VALID_COUNTRY
    ) {
      let selectedData = this.template
        .querySelector("lightning-datatable")
        .getSelectedRows()[0];
      this.record.Street = address.street;
      this.record.City = selectedData.suburb;
      this.record.State = selectedData.state;
      this.record.latitude = undefined;
      this.record.longitute = undefined;
      this.record.Country = address.country;
      this.record.PostalCode = selectedData.postCode.toString();
      this.record.Delivery_Identifier__c = address.dpid;
      this.template
        .querySelector("lightning-record-edit-form")
        .submit(this.record);
    } else {
      this.record.Street = address.street;
      this.record.City = address.city;
      this.record.State = address.state;
      this.record.Country = address.country;
      this.record.PostalCode = address.postalCode;
      this.record.Delivery_Identifier__c = address.dpid;
      this.template
        .querySelector("lightning-record-edit-form")
        .submit(this.record);
    }
  }

  closeQuickAction() {
    this.dispatchEvent(new CustomEvent("close"));
    this.dispatchEvent(new CloseActionScreenEvent());
  }

  validateAddress(fields) {
    const addressCmp = this.template.querySelector("c-address-lookup-util");
    const address = addressCmp.value;
    validateManualAddress({
      state: address.state,
      postcode: address.postalCode,
      suburb: address.city
    })
      .then((objresult) => {
        if (objresult.hasValidAddress) {
          this.hasValidAddress = true;
          fields.Street = address.street;
          fields.City = address.city;
          fields.State = address.state;
          fields.latitude = undefined;
          fields.longitute = undefined;
          fields.Country = address.country;
          fields.PostalCode = address.postalCode.toString();
          this.template
            .querySelector("lightning-record-edit-form")
            .submit(fields);
        } else {
          this.disabled = true;
          this.hasValidAddress = false;
          this.lookUpAddressResult = objresult.result;
          this.loading = false;
        }
      })
      .catch((error) => {
        this.loading = false;
        handleErrorShowToast(
          this,
          "Error while validating the address. Please contact your administrator",
          error,
          error.body.message,
          "pester"
        );
      });
  }

  handleCancelSelection() {
    this.hasValidAddress = true;
    this.disabled = false;
  }

  handleaddresselection(event) {
    this.isManualAddress = !event.detail;
  }

  validatButton() {
    this.disabled = false;
  }
  handleAddressChange(event) {
    this.mnaualSelectedAddress = event.detail;
  }
}
