import { LightningElement, api, wire } from "lwc";
import getValidAddresses from "@salesforce/apex/CCRMAPIRepository.getAddressesLwcV3";
import getSelectedAddress from "@salesforce/apex/CCRMAPIRepository.getSelectedAddressLwcV3";
import getCountryNameToCodeMap from "@salesforce/apex/MLCRMCommonUtils.getCountryNameToCodeMap";
import STATEOBJ from "@salesforce/schema/Case.IDR_3rdParty_State__c";
import { getPicklistValues, getObjectInfo } from "lightning/uiObjectInfoApi";
import Case_OBJECT from "@salesforce/schema/Case";
import { handleErrorShowToast } from "c/utils";
import { OmniscriptBaseMixin } from "omnistudio/omniscriptBaseMixin";

const SELECT_ADDRESS_ERROR =
  "Error while selecting the address. Please contact your administrator";
const SEARCH_ADDRESS_ERROR =
  "Error while loading the addresses. Please contact your administrator";

export default class AddressLookupUtil extends OmniscriptBaseMixin(
  LightningElement
) {
  @api required = false;
  @api addressLabel = "Address";
  @api useCountryFullName = false;
  @api label;
  showAddresses = false;
  addressList = [];
  searchString;
  selectedAddress;
  message;
  isSearching = false;
  isSelecting = false;
  displayAddresses = false;
  displayMessage = false;
  resetValidationError = false;
  pendingSearchRequest;
  recordTypeId;

  @wire(getCountryNameToCodeMap) countryMetadataRecords;
  @wire(getObjectInfo, { objectApiName: Case_OBJECT })
  getobjectInfo(result) {
    if (result.data) {
      const rtis = result.data.recordTypeInfos;
      this.recordTypeId = Object.keys(rtis).find(
        (rti) => rtis[rti].name === "Non-Customer Complaint"
      );
    }
  }
  @wire(getPicklistValues, {
    recordTypeId: "$recordTypeId",
    fieldApiName: STATEOBJ
  })
  stateMetadataRecords;

  getProvinceOptions() {
    let listOfStatesMap = this.stateMetadataRecords.data?.values;
    if (listOfStatesMap == null) {
      return null;
    }

    return new Map(listOfStatesMap.map((i) => [i.label, i.value]));
  }

  getCountryOptions() {
    if (this.countryMetadataRecords == null) {
      return null;
    }
    let listOfCountriesMap = this.countryMetadataRecords.data;
    if (listOfCountriesMap == null) {
      return null;
    }
    return listOfCountriesMap;
  }

  handleSearchKeyChange(event) {
    clearTimeout(this.pendingSearchRequest);
    const searchString = event.detail.value.trim();
    if (searchString && searchString.length > 4) {
      // eslint-disable-next-line @lwc/lwc/no-async-operation
      this.pendingSearchRequest = setTimeout(() => {
        this.isSearching = true;
        this.showAddresses = searchString && searchString.length > 4;
        this.getAddresses(searchString);
      }, 300);
    }
  }

  handleSelectAddress(event) {
    const globalAddressKey = event.currentTarget.dataset.id;
    this.selectAddress(globalAddressKey);
  }

  displayAddressFields() {
    this.selectedAddress = null;
    this.showAddresses = false;
    this.setReadonly(false);
  }

  resetValidation() {
    this.resetValidationError = true;
  }

  renderedCallback() {
    if (this.resetValidationError) {
      this.resetValidationError = false;
    }
  }
  async getAddresses(searchString) {
    try {
      const response = await getValidAddresses({
        lookupString: searchString
      });
      this.addressList = response.result;
      if (!Array.isArray(this.addressList) || this.addressList.length === 0) {
        this.message = "No results found. Please enter address manually";
        this.displayAddresses = false;
        this.displayMessage = true;
      } else {
        this.message = "Enter Address Manually";
        this.displayMessage = false;
        this.displayAddresses = true;
      }
    } catch (error) {
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
  }
  async selectAddress(globalAddressKey) {
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
        !this.useCountryFullName &&
        response.result.components !== undefined &&
        response.result.components !== null
      ) {
        this.selectedAddress.country = this.getCountry(
          this.getCountryOptions(),
          response.result.components.country_iso_3
        );
      }

      this.omniApplyCallResp(this.populateAddress(this.selectedAddress));
    } catch (error) {
      handleErrorShowToast(
        this,
        SELECT_ADDRESS_ERROR,
        error,
        error.body.message,
        "pester"
      );
    } finally {
      this.showAddresses = false;
    }
  }

  setReadonly(readonly) {
    this.omniApplyCallResp({ Case: { disablAddress: readonly } });
  }
  populateAddress(address) {
    let stateMap = this.getProvinceOptions();

    return {
      Case: {
        disablAddress: true,
        CustomerDetails: {
          Country: address.country,
          PostcodeReadOnly: address.postal_code,
          State: stateMap.get(address.region),
          Street: address.street,
          Suburb: address.locality
        }
      }
    };
  }

  getCountry(countryMap, value) {
    return Object.keys(countryMap).find((key) => countryMap[key] === value);
  }
}
