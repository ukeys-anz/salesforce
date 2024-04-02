import { LightningElement, api, wire } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { CloseActionScreenEvent } from "lightning/actions";
import { getRecord } from "lightning/uiRecordApi";
import { NavigationMixin } from "lightning/navigation";
import getValidAddresses from "@salesforce/apex/CCRMAPIRepository.getAddressesLwcV3";
import getSelectedAddress from "@salesforce/apex/CCRMAPIRepository.getSelectedAddressLWC";
import validateManualAddress from "@salesforce/apex/MLCRMAPIRepository.validateManualAddressesV3LWC";
import LEAD_STREET from "@salesforce/schema/Lead.Street";
import LEAD_CITY from "@salesforce/schema/Lead.City";
import LEAD_STATE from "@salesforce/schema/Lead.State";
import LEAD_COUNTRY from "@salesforce/schema/Lead.Country";
import LEAD_POSTAL_CODE from "@salesforce/schema/Lead.PostalCode";
import LEAD_IS_VALID_ADDRESS from "@salesforce/schema/Lead.Is_Valid_Address__c";
import getCountryNameToCodeMap from "@salesforce/apex/MLCRMCommonUtils.getCountryNameToCodeMap";
import getStateNameToCodeMap from "@salesforce/apex/MLCRMCommonUtils.getStateNameToCodeMap";

// Util methods
import { handleErrorShowToast } from "c/utils";
export default class AddressLwc extends NavigationMixin(LightningElement) {
  @api recordId;
  @api objectAPIName = "Lead";
  maxAllowedCharInProvince = 15;
  maxAllowedCharInPostalCode = 9;
  errorInProvince = false;
  errorInPostalCode = false;
  provinceErrorMessage =
    "Maximum of " + this.maxAllowedCharInProvince + " characters is allowed.";
  postalCodeErrorMessage =
    "Postcode to be capped to a maximum 9-characters (may include alphabets or special chars like hivens) to comply with CAP field length.";
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
  enabled = false;
  isAddressDisabled = true; // CC-5929
  message;
  isDataValid = true;
  loading = false;
  isValidAddress = false;
  displayAddresses = false;
  displayMessage = false;
  resetValidationError = false;
  hasValidAddress = true;
  lookUpAddressResult;
  CONSTANT = {
    VALID_COUNTRY: "AUS"
  };
  fields = {};
  disabled = false;
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

  @wire(getCountryNameToCodeMap) countryMetadataRecords;
  @wire(getStateNameToCodeMap) stateMetadataRecords;

  get title() {
    return this.hasValidAddress
      ? "Add/ Edit Address"
      : "Pick Suburb / State / Postcode";
  }

  get getProvinceOptions() {
    // Format: [{label:Austrail, value: AUS},{label:India, value:IND}]
    var stateOptions = [];

    // If country is other then AUS then do nothing.
    if (
      !(this.strCountry == null || this.strCountry === "AUS") ||
      this.stateMetadataRecords == null
    ) {
      return null;
    }
    let listOfStatesMap = this.stateMetadataRecords.data; // format: CountryName-> CountryCode map
    if (listOfStatesMap == null) {
      return null;
    }
    for (let key in listOfStatesMap) {
      if (key) {
        let temp = {
          label: key,
          value: listOfStatesMap[key]
        };
        stateOptions.push(temp);
      }
    }
    return stateOptions;
  }

  get getCountryOptions() {
    // Format: [{label:StateName1, value: StateCode1},{label:StateName2, value:StateCode2}]
    let countryOptions = [{ label: "Australia", value: "AUS" }]; // First Country must be Australia

    if (this.countryMetadataRecords == null) {
      return null;
    }
    let listOfCountriesMap = this.countryMetadataRecords.data; // format: CountryName-> CountryCode map
    if (listOfCountriesMap === undefined || listOfCountriesMap === null) {
      return null;
    }
    for (let key in listOfCountriesMap) {
      if (key !== "Australia") {
        let temp = {
          label: key,
          value: listOfCountriesMap[key]
        };
        countryOptions.push(temp);
      }
    }
    return countryOptions;
  }

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
      //CC-7217 : Making AUS default Country for Add/Edit Address
      if (data.fields.Country.value == null) {
        this.strCountry = "AUS";
      }
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
      this.fields =
        Object.keys(this.fields).length === 0
          ? event.detail.fields
          : this.fields;
      if (
        this.isAddressDisabled === false &&
        this.strCountry === this.CONSTANT.VALID_COUNTRY &&
        this.hasValidAddress === true
      ) {
        this.validateAddress(this.fields);
      } else if (
        this.isAddressDisabled === false &&
        this.strCountry === this.CONSTANT.VALID_COUNTRY &&
        this.hasValidAddress === false
      ) {
        let selectedData = this.template
          .querySelector("lightning-datatable")
          .getSelectedRows()[0];
        this.fields.Street = this.strStreet;
        this.fields.City = selectedData.suburb;
        this.fields.State = selectedData.state;
        this.fields.Country = this.strCountry;
        this.fields.latitude = undefined;
        this.fields.longitute = undefined;
        this.fields.PostalCode = this.strPostalCode.toString();
        this.fields.Is_Valid_Address__c = true;
        this.template
          .querySelector("lightning-record-edit-form")
          .submit(this.fields);
      } else {
        this.fields.Street = this.strStreet;
        this.fields.City = this.strCity;
        this.fields.State = this.strState;
        this.fields.Country = this.strCountry;
        this.fields.PostalCode = this.strPostalCode.toString();
        if (this.isValidAddress) {
          this.fields.Is_Valid_Address__c = true;
        } else {
          this.fields.Is_Valid_Address__c = false;
        }
        if (this.selectedAddress) {
          if (
            this.strStreet !== this.streetFullName ||
            this.strCity !== this.selectedAddress.city ||
            this.strState !== this.selectedAddress.state ||
            this.strCountry !== this.selectedAddress.countryCodeThree ||
            this.strPostalCode !== this.selectedAddress.postalCode
          ) {
            this.fields.Is_Valid_Address__c = false;
            this.strLatitude = "";
            this.strLongitude = "";
          }
        }
        if (this.strLatitude) {
          this.fields.Latitude = this.strLatitude;
        }
        if (this.strLongitude) {
          this.fields.Longitude = this.strLongitude;
        }
        this.template
          .querySelector("lightning-record-edit-form")
          .submit(this.fields);
      }
    }
  }

  addressInputChange(event) {
    // Country is changed and (if current country is AUS then will show dropdown, if old country was AUS then need to empty provience)
    if (
      this.strCountry !== event.target.country &&
      (this.strCountry === "AUS" || event.target.country === "AUS")
    ) {
      event.target.province = "";
    }
    this.strStreet = event.target.street;
    this.strCity = event.target.city;
    this.strState = event.target.province;
    this.strCountry = event.target.country;
    this.strPostalCode = event.target.postalCode;
    this.handleCustomValidation(event); // add custom validation on Provience and PostCode.
  }

  handleCustomValidation(event) {
    const address = this.template.querySelector("lightning-input-address");

    // if province exceed max char then add error, else remove error
    // if postal code is non-numeric then show error
    if (
      event.target.province &&
      event.target.province.length > this.maxAllowedCharInProvince
    ) {
      address.setCustomValidityForField(this.provinceErrorMessage, "province");
      this.errorInProvince = true;
    } else {
      address.setCustomValidityForField("", "province");
      this.errorInProvince = false;
    }

    // if postalCode exceed max char then add error, else remove error
    if (
      event.target.postalCode &&
      event.target.postalCode.length > this.maxAllowedCharInPostalCode
    ) {
      address.setCustomValidityForField(
        this.postalCodeErrorMessage,
        "postalCode"
      );
      this.errorInPostalCode = true;
    } else {
      address.setCustomValidityForField("", "postalCode");
      this.errorInPostalCode = false;
    }
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
    //let lookupString = encodeURIComponent(this.searchString);
    getValidAddresses({ lookupString: this.searchString })
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
          this.strCountry = this.selectedAddress.countryCodeThree;
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
    this.enabled = true;
    this.isAddressDisabled = true; // CC-5929
  }

  displayAddressFields() {
    this.isValidAddress = false;
    this.strLatitude = "";
    this.strLongitude = "";
    this.showAddresses = false;
    this.enabled = true;
    this.isAddressDisabled = false; // CC-5929
  }

  validateFields() {
    if (
      !this.strStreet ||
      !this.strCity ||
      !this.strState ||
      !this.strPostalCode ||
      this.errorInPostalCode ||
      this.errorInProvince
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

  // method to validate manual address
  validateAddress(fields) {
    validateManualAddress({
      state: this.strState,
      postcode: this.strPostalCode,
      suburb: this.strCity
    })
      .then((objresult) => {
        if (objresult.hasValidAddress) {
          this.hasValidAddress = true;
          fields.Street = this.strStreet;
          fields.City = this.strCity;
          fields.State = this.strState;
          fields.latitude = undefined;
          fields.longitute = undefined;
          fields.Country = this.strCountry;
          fields.Is_Valid_Address__c = true;
          fields.PostalCode = this.strPostalCode.toString();
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

  // method to go back to first screen when user click cancel on second screen
  handleCancelSelection() {
    this.hasValidAddress = true;
    this.disabled = false;
  }
  validatButton() {
    this.disabled = false;
  }

  handleError() {
    this.loading = false;
  }
}
