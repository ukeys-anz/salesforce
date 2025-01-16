import { LightningElement, api, wire } from "lwc";
import { CloseActionScreenEvent } from "lightning/actions";
import { getRecord } from "lightning/uiRecordApi";
import { NavigationMixin } from "lightning/navigation";
import getValidAddresses from "@salesforce/apex/CCRMAPIRepository.getAddressesLwcV3";
import getSelectedAddress from "@salesforce/apex/CCRMAPIRepository.getSelectedAddressLWC";
import validateManualAddress from "@salesforce/apex/MLCRMAPIRepository.validateManualAddressesV3LWC";
import getCountryNameToCodeMap from "@salesforce/apex/MLCRMCommonUtils.getCountryNameToCodeMap";
import getStateNameToCodeMap from "@salesforce/apex/MLCRMCommonUtils.getStateNameToCodeMap";

// Util methods
import { handleErrorShowToast, showToast } from "c/utils";

// Field imports for Circle of Influence (COI)
import COI_STREET from "@salesforce/schema/Circle_Of_Influence__c.Street_Name__c";
import COI_CITY from "@salesforce/schema/Circle_Of_Influence__c.City__c";
import COI_STATE from "@salesforce/schema/Circle_Of_Influence__c.State__c";
import COI_COUNTRY from "@salesforce/schema/Circle_Of_Influence__c.Country__c";
import COI_POSTAL_CODE from "@salesforce/schema/Circle_Of_Influence__c.Postal_Code__c";

export default class ValidateAddressCoi extends NavigationMixin(
  LightningElement
) {
  @api recordId;
  @api objectAPIName = "Circle_Of_Influence__c";
  maxAllowedCharInProvince = 15;
  maxAllowedCharInPostalCode = 9;
  errorInProvince = false;
  errorInPostalCode = false;
  provinceErrorMessage =
    "Maximum of " + this.maxAllowedCharInProvince + " characters is allowed.";
  postalCodeErrorMessage =
    "Postcode to be capped to a maximum 9-characters (may include alphabets or special chars like hyphens) to comply with CAP field length.";
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
      label: "Suburb",
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
    fields: [COI_STREET, COI_CITY, COI_STATE, COI_COUNTRY, COI_POSTAL_CODE]
  })
  wiredProject({ error, data }) {
    if (data) {
      this.strStreet = data.fields.Street_Name__c.value;
      this.strCity = data.fields.City__c.value;
      this.strState = data.fields.State__c.value;
      this.strCountry = data.fields.Country__c.value || "AUS";
      this.strPostalCode = data.fields.Postal_Code__c.value;
    } else if (error) {
      this.closeQuickAction();
      handleErrorShowToast(
        this,
        "Error while loading Address record",
        error,
        "An unexpected error occurred. Please try again later.",
        "pester"
      );
    }
  }

  handleSuccess() {
    this.closeQuickAction();
    this.loading = false;
    showToast(this, "COI Address Updated Successfully", "", "", "Success", "");
  }

  handleSubmit(event) {
    event.preventDefault();

    if (!this.isDataValid) {
      return; // Early return if data is not valid
    }

    this.loading = true;
    this.fields = this.fields || event.detail.fields;

    // Process address validation logic
    if (this.shouldValidateAddress()) {
      this.validateAddress(this.fields);
    } else if (this.shouldHandleManualAddress()) {
      this.handleManualAddressSubmission();
    } else {
      this.handleDefaultAddressSubmission();
    }
  }

  // Determine if address validation is required
  shouldValidateAddress() {
    return (
      !this.isAddressDisabled &&
      this.strCountry === this.CONSTANT.VALID_COUNTRY &&
      this.hasValidAddress
    );
  }

  // Check if manual address needs to be handled
  shouldHandleManualAddress() {
    return (
      !this.isAddressDisabled &&
      this.strCountry === this.CONSTANT.VALID_COUNTRY &&
      !this.hasValidAddress
    );
  }

  // Handle the submission for a valid address
  handleManualAddressSubmission() {
    let selectedData = this.template
      .querySelector("lightning-datatable")
      .getSelectedRows()[0];
    this.setCircleOfInfluenceAddress();
    this.fields.City__c = selectedData ? selectedData.suburb : this.strCity;
    this.fields.State__c = selectedData ? selectedData.state : this.strState;
    this.submitForm();
  }

  // Handle the default address submission
  handleDefaultAddressSubmission() {
    this.setCircleOfInfluenceAddress();
    this.submitForm();
  }

  // Set address for Circle of Influence object
  setCircleOfInfluenceAddress() {
    this.fields.Street_Name__c = this.strStreet;
    this.fields.City__c = this.strCity;
    this.fields.State__c = this.strState;
    this.fields.Country__c = this.strCountry;
    this.fields.Postal_Code__c = this.strPostalCode.toString();
  }

  // Submit the form
  submitForm() {
    this.template
      .querySelector("lightning-record-edit-form")
      .submit(this.fields);
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
          "An unexpected error occurred. Please try again later.",
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
            "An unexpected error occurred. Please try again later.",
            "pester"
          );
        });
    }
    this.showAddresses = false;
    this.enabled = true;
    this.isAddressDisabled = true;
  }

  displayAddressFields() {
    this.isValidAddress = false;
    this.strLatitude = "";
    this.strLongitude = "";
    this.showAddresses = false;
    this.enabled = true;
    this.isAddressDisabled = false;
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
          fields.Street_Name__c = this.strStreet;
          fields.City__c = this.strCity;
          fields.State__c = this.strState;
          fields.Country__c = this.strCountry;
          fields.Postal_Code__c = this.strPostalCode.toString();
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
          "An unexpected error occurred. Please try again later.",
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
