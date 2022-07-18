import { LightningElement, api, wire } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { CloseActionScreenEvent } from "lightning/actions";
import { getRecord } from "lightning/uiRecordApi";
import { NavigationMixin } from "lightning/navigation";
import getValidAddresses from "@salesforce/apex/CCRMAPIRepository.getAddressesLWC";
import getSelectedAddress from "@salesforce/apex/CCRMAPIRepository.getSelectedAddressLWC";
import LEAD_STREET from "@salesforce/schema/Lead.Street";
import LEAD_CITY from "@salesforce/schema/Lead.City";
import LEAD_STATE from "@salesforce/schema/Lead.State";
import LEAD_COUNTRY from "@salesforce/schema/Lead.Country";
import LEAD_POSTAL_CODE from "@salesforce/schema/Lead.PostalCode";
import LEAD_IS_VALID_ADDRESS from "@salesforce/schema/Lead.Is_Valid_Address__c";

// Util methods
import { handleErrorShowToast } from "c/utils";
export default class AddressLwc extends NavigationMixin(LightningElement) {
  @api recordId;
  @api objectAPIName = "Lead";
  strStreet;
  strCity;
  strState;
  strCountry;
  strPostalCode;
  strLatitude;
  strLongitude;
  streetFullName;
  isModalOpen = false;
  showAddresses = false;
  addressList = [];
  searchString;
  selectedAddress;
  keyLength = 0;
  disabled = true;
  message;
  isDataValid = true;
  loading = false;
  isValidAddress = false;
  displayAddresses = false;
  displayMessage = false;
  resetValidationError = false;

  @wire(getRecord, {
    recordId: "$recordId",
    fields: [
      LEAD_STREET,
      LEAD_CITY,
      LEAD_STATE,
      LEAD_COUNTRY,
      LEAD_POSTAL_CODE,
      LEAD_IS_VALID_ADDRESS
    ]
  })
  wiredProject({ error, data }) {
    if (data) {
      this.strStreet = data.fields.Street.value;
      this.strCity = data.fields.City.value;
      this.strState = data.fields.State.value;
      this.strCountry = data.fields.Country.value;
      this.strPostalCode = data.fields.PostalCode.value;
    } else if (error) {
      this.closeQuickAction();
      handleErrorShowToast(
        this,
        "Failed to load Address record",
        error,
        error.body.message,
        "pester"
      );
    }
  }

  handleSuccess() {
    this.closeQuickAction();
    this.loading = false;
    this.dispatchEvent(
      new ShowToastEvent({
        message: "Lead Address Updated Successfully",
        variant: "success"
      })
    );
  }

  handleSubmit(event) {
    event.preventDefault();
    if (this.isDataValid) {
      this.loading = true;
      let fields = event.detail.fields;
      if (this.objectAPIName === "Lead") {
        fields.Street = this.strStreet;
        fields.City = this.strCity;
        fields.State = this.strState;
        fields.Country = this.strCountry;
        fields.PostalCode = this.strPostalCode.toString();
        if (this.isValidAddress) {
          fields.Is_Valid_Address__c = true;
        } else {
          fields.Is_Valid_Address__c = false;
        }
        if (this.selectedAddress) {
          if (
            this.strStreet !== this.streetFullName ||
            this.strCity !== this.selectedAddress.city ||
            this.strState !== this.selectedAddress.state ||
            this.strCountry !== this.selectedAddress.countryCode ||
            this.strPostalCode !== this.selectedAddress.postalCode
          ) {
            fields.Is_Valid_Address__c = false;
            this.strLatitude = "";
            this.strLongitude = "";
          }
        }
        if (this.strLatitude) {
          fields.Latitude = this.strLatitude;
        }
        if (this.strLongitude) {
          fields.Longitude = this.strLongitude;
        }
      }
      this.template.querySelector("lightning-record-edit-form").submit(fields);
    }
  }

  addressInputChange(event) {
    this.strStreet = event.target.street;
    this.strCity = event.target.city;
    this.strState = event.target.province;
    this.strCountry = event.target.country;
    this.strPostalCode = event.target.postalCode;
  }

  handleSearchKeyChange(event) {
    this.searchString = event.target.value;
    let keyCode = event.keyCode;
    if ((keyCode >= 48 && keyCode <= 57) || (keyCode >= 65 && keyCode <= 90)) {
      this.keyLength = this.keyLength + 1;
    } else if (keyCode === 8 && this.keyLength > 0) {
      this.keyLength = this.keyLength - 1;
    }
    if (this.searchString && this.keyLength > 4) {
      this.getAddresses(this.searchString);
      this.showAddresses = true;
    } else {
      this.showAddresses = false;
    }
    if (!this.searchString) {
      this.showAddresses = false;
      this.keyLength = 0;
    }
  }

  closeQuickAction() {
    this.dispatchEvent(new CloseActionScreenEvent());
  }

  getAddresses() {
    let lookupString = encodeURIComponent(this.searchString);
    getValidAddresses({ lookupString: lookupString })
      .then((result) => {
        this.addressList = result.result;
        if (this.addressList === undefined || this.addressList.length === 0) {
          this.message = "No results found. Please enter address manually";
          this.displayAddresses = false;
          this.displayMessage = true;
        } else {
          this.message = "Enter Address Manually";
          this.displayMessage = false;
          this.displayAddresses = true;
        }
      })
      .catch((error) => {
        this.closeQuickAction();
        handleErrorShowToast(
          this,
          "Error while loading the addresses. Please contact your administrator",
          error,
          error.body.message,
          "pester"
        );
      });
  }

  selectAddress(event) {
    var selectedAddressId = event.currentTarget.dataset.id;
    this.resetValidation();
    if (selectedAddressId) {
      getSelectedAddress({ encodedAddressId: selectedAddressId })
        .then((result) => {
          this.selectedAddress = result;
          if (
            this.selectedAddress.levelNumber !== undefined &&
            this.selectedAddress.levelNumber !== null
          ) {
            this.streetFullName =
              this.selectedAddress.levelNumber +
              " " +
              this.selectedAddress.streetNumber +
              " " +
              this.selectedAddress.streetName;
          } else {
            this.streetFullName =
              this.selectedAddress.streetNumber +
              " " +
              this.selectedAddress.streetName;
          }
          this.strStreet = this.streetFullName;
          this.strCity = this.selectedAddress.city;
          this.strState = this.selectedAddress.state;
          this.strCountry = this.selectedAddress.countryCode;
          this.strPostalCode = this.selectedAddress.postalCode;
          this.strLatitude = this.selectedAddress.latitude;
          this.strLongitude = this.selectedAddress.longitude;
          this.isValidAddress = true;
        })
        .catch((error) => {
          this.closeQuickAction();
          handleErrorShowToast(
            this,
            "Error while selecting the address. Please contact your administrator",
            error,
            error.body.message,
            "pester"
          );
        });
    }
    this.showAddresses = false;
    this.disabled = false;
  }

  displayAddressFields() {
    this.isValidAddress = false;
    this.strLatitude = "";
    this.strLongitude = "";
    this.showAddresses = false;
    this.disabled = false;
  }

  validateFields() {
    if (
      !this.strStreet ||
      !this.strCity ||
      !this.strState ||
      !this.strPostalCode
    ) {
      this.isDataValid = false;
    } else {
      this.isDataValid = true;
    }
  }

  resetValidation() {
    this.resetValidationError = true;
  }

  renderedCallback() {
    if (this.resetValidationError) {
      this.resetValidationError = false;
    }
  }
}
