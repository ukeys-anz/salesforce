import { LightningElement, api, track, wire } from "lwc";
import getValidAddresses from "@salesforce/apex/CCRMAPIRepository.getAddressesLwcV3";
import getSelectedAddress from "@salesforce/apex/CCRMAPIRepository.getSelectedAddressLwcV3";
import getCountryNameToCodeMap from "@salesforce/apex/MLCRMCommonUtils.getCountryNameToCodeMap";
import getStateNameToCodeMap from "@salesforce/apex/MLCRMCommonUtils.getStateNameToCodeMap";
import { handleErrorShowToast } from "c/utils";

const SELECT_ADDRESS_ERROR =
  "Error while selecting the address. Please contact your administrator";
const SEARCH_ADDRESS_ERROR =
  "Error while loading the addresses. Please contact your administrator";

export default class AddressLookupUtil extends LightningElement {
  @api required = false;
  @api addressLabel = "Address";
  @api useCountryFullName = false;
  @api allowManualInput = false;
  @track currentAddress = {};
  maxAllowedCharInProvince = 15;
  maxAllowedCharInPostalCode = 9;
  errorInProvince = false;
  errorInPostalCode = false;
  provinceErrorMessage =
    "Maximum of " + this.maxAllowedCharInProvince + " characters is allowed.";
  postalCodeErrorMessage =
    "Postcode to be capped to a maximum 9-characters (may include alphabets or special chars like hivens) to comply with CAP field length.";
  showAddresses = false;
  addressList = [];
  searchString;
  selectedAddress;
  keyLength = 0;
  disabled = true;
  message;
  isSearching = false;
  isSelecting = false;
  displayAddresses = false;
  displayMessage = false;
  resetValidationError = false;
  pendingSearchRequest;

  @wire(getCountryNameToCodeMap) countryMetadataRecords;
  @wire(getStateNameToCodeMap) stateMetadataRecords;

  get getProvinceOptions() {
    // Format: [{label:Austrail, value: AUS},{label:India, value:IND}]
    var stateOptions = [];

    // If country is other then AUS then do nothing.
    if (
      !(
        this.currentAddress.country == null ||
        this.currentAddress.country === "AUS"
      ) ||
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
    if (this.countryMetadataRecords == null) {
      return null;
    }
    // Format: [{label:StateName1, value: StateCode1},{label:StateName2, value:StateCode2}]
    let countryOptions = [{ label: "Australia", value: "AUS" }]; // First Country must be australia
    let listOfCountriesMap = this.countryMetadataRecords.data; // format: CountryName-> CountryCode map
    if (listOfCountriesMap == null) {
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

  @api
  get value() {
    return { ...this.currentAddress };
  }
  set value(val) {
    this.currentAddress = { ...val };
  }

  @api reportValidity() {
    this.template.querySelector("lightning-input-address").reportValidity();
    return (
      !this.required ||
      (this.currentAddress.street &&
        this.currentAddress.city &&
        this.currentAddress.state &&
        this.currentAddress.postalCode &&
        !this.errorInPostalCode &&
        !this.errorInProvince)
    );
  }

  handleCustomValidation(event) {
    const address = this.template.querySelector("lightning-input-address");

    // if province exceed max char then add error, else remove error
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
    // if postal code is non-numeric then show error
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

  addressInputChange(event) {
    // Country is changed and (if current country is AUS then will show dropdown, if old country was AUS then need to empty provience)
    if (
      this.currentAddress.country !== event.target.country &&
      (this.currentAddress.country === "AUS" || event.target.country === "AUS")
    ) {
      event.target.province = "";
    }
    this.currentAddress.street = event.target.street;
    this.currentAddress.city = event.target.city;
    this.currentAddress.state = event.target.province;
    this.currentAddress.country = event.target.country;
    this.currentAddress.postalCode = event.target.postalCode;
    this.currentAddress.isValidAddress =
      this.selectedAddress &&
      this.currentAddress.street === this.streetFullName &&
      this.currentAddress.city === this.selectedAddress.locality &&
      this.currentAddress.state === this.selectedAddress.region &&
      this.currentAddress.country === this.selectedAddress.country &&
      this.currentAddress.postalCode === this.selectedAddress.postal_code;
    if (!this.currentAddress.isValidAddress) {
      this.currentAddress.globalAddressKey = null;
      this.currentAddress.dpid = null;
    }
    this.handleCustomValidation(event); // add custom validation on Provience and PostCode.
    this.eventDispatchers.addressChange();
  }

  handleSearchKeyChange(event) {
    clearTimeout(this.pendingSearchRequest);
    const searchString = event.detail.value.trim();
    if (searchString && searchString.length > 4) {
      // eslint-disable-next-line @lwc/lwc/no-async-operation
      this.pendingSearchRequest = setTimeout(() => {
        this.isSearching = true;
        this.showAddresses = searchString && searchString.length > 4;
        this.services.getAddresses(searchString);
      }, 300);
    }
  }

  handleSelectAddress(event) {
    const globalAddressKey = event.currentTarget.dataset.id;
    this.services.selectAddress(globalAddressKey);
  }

  displayAddressFields() {
    this.currentAddress = {};
    this.currentAddress.country = "AUS"; // CC-7217 setting default country to Australia
    this.selectedAddress = null;
    this.showAddresses = false;
    this.disabled = false;
    this.dispatchEvent(
      new CustomEvent("handleselecion", {
        detail: this.disabled
      })
    );
    this.eventDispatchers.inputEnable();
  }

  resetValidation() {
    this.resetValidationError = true;
  }

  renderedCallback() {
    if (this.resetValidationError) {
      this.resetValidationError = false;
    }
  }

  services = {
    getAddresses: async (searchString) => {
      try {
        const response = await getValidAddresses({
          lookupString: searchString
        });

        this.addressList = response.result;
        if (this.addressList === undefined || this.addressList.length === 0) {
          this.message = "No results found. Please enter address manually";
          this.displayAddresses = false;
          this.displayMessage = true;
        } else {
          this.message = "Enter Address Manually";
          this.displayMessage = false;
          this.displayAddresses = true;
        }
      } catch (error) {
        this.eventDispatchers.searchError();
        handleErrorShowToast(
          this,
          SEARCH_ADDRESS_ERROR,
          error,
          error.body.message,
          "pester"
        );
      } finally {
        this.isSearching = false;
        this.resetValidation();
      }
    },
    selectAddress: async (globalAddressKey) => {
      try {
        const response = await getSelectedAddress({
          globalAddressKey: globalAddressKey
        });
        this.selectedAddress = {
          ...response.result.address,
          street: [
            response.result.address.address_line_1,
            response.result.address.address_line_2,
            response.result.address.address_line_3
          ]
            .filter((x) => x)
            .join(", ")
        };
        if (
          response.metadata !== undefined &&
          response.metadata !== null &&
          response.metadata.address_info.identifier.dpid
        ) {
          this.selectedAddress.dpid =
            response.metadata.address_info.identifier.dpid;
          this.currentAddress.dpid = this.selectedAddress.dpid;
        }
        if (
          !this.useCountryFullName &&
          response.result.components !== undefined &&
          response.result.components !== null
        ) {
          this.selectedAddress.country =
            response.result.components.country_iso_3;
        }
        this.currentAddress.street = this.selectedAddress.street;
        this.currentAddress.city = this.selectedAddress.locality;
        this.currentAddress.state = this.selectedAddress.region;
        this.currentAddress.country = this.selectedAddress.country;
        this.currentAddress.postalCode = this.selectedAddress.postal_code;
        this.currentAddress.globalAddressKey = globalAddressKey;
        this.currentAddress.isValidAddress = true;
        this.disabled = true;
        this.eventDispatchers.addressChange();
      } catch (error) {
        this.eventDispatchers.selectError();
        handleErrorShowToast(
          this,
          SELECT_ADDRESS_ERROR,
          error,
          error.body.message,
          "pester"
        );
      } finally {
        this.showAddresses = false;
        if (this.allowManualInput) {
          this.disabled = false;
          this.eventDispatchers.inputEnable();
        }
      }
    }
  };

  eventDispatchers = {
    selectError: () =>
      this.dispatchEvent(
        new CustomEvent("error", {
          detail: SELECT_ADDRESS_ERROR
        })
      ),
    searchError: () =>
      this.dispatchEvent(
        new CustomEvent("error", {
          detail: SEARCH_ADDRESS_ERROR
        })
      ),
    inputEnable: () => this.dispatchEvent(new CustomEvent("inputenable")),
    addressChange: () =>
      this.dispatchEvent(
        new CustomEvent("addresschange", {
          detail: this.currentAddress
        })
      )
  };
}
