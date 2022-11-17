import { LightningElement, api, track } from "lwc";
import getValidAddresses from "@salesforce/apex/CCRMAPIRepository.getAddressesLwcV2";
import getSelectedAddress from "@salesforce/apex/CCRMAPIRepository.getSelectedAddressLwcV2";
import { handleErrorShowToast } from "c/utils";

const SELECT_ADDRESS_ERROR =
  "Error while selecting the address. Please contact your administrator";
const SEARCH_ADDRESS_ERROR =
  "Error while loading the addresses. Please contact your administrator";

export default class AddressLookupUtil extends LightningElement {
  @api required = false;
  @api addressLabel = "Address";
  @track currentAddress = {};
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
        this.currentAddress.postalCode)
    );
  }

  addressInputChange(event) {
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
    }
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
    this.selectedAddress = null;
    this.showAddresses = false;
    this.disabled = false;
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
          lookupString: encodeURIComponent(searchString)
        });

        this.addressList = response.result.suggestions;
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
        this.currentAddress.street = this.selectedAddress.street;
        this.currentAddress.city = this.selectedAddress.locality;
        this.currentAddress.state = this.selectedAddress.region;
        this.currentAddress.country = this.selectedAddress.country;
        this.currentAddress.postalCode = this.selectedAddress.postal_code;
        this.currentAddress.globalAddressKey = globalAddressKey;
        this.currentAddress.isValidAddress = true;
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
        this.disabled = false;
        this.eventDispatchers.inputEnable();
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
          detail: this.value
        })
      )
  };
}
