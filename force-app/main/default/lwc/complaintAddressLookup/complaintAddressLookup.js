import { LightningElement, api, wire } from "lwc";
import getValidAddresses from "@salesforce/apex/CCRMAPIRepository.getAddressesLwcV3";
import getSelectedAddress from "@salesforce/apex/CCRMAPIRepository.getSelectedAddressLwcV3";
import getCountryNameToCodeMap from "@salesforce/apex/MLCRMCommonUtils.getCountryNameToCodeMap";
import getAddressPostcode from "@salesforce/apex/GetCustomerInformation.fetchAddress";

import STATEOBJ from "@salesforce/schema/Case.IDR_3rdParty_State__c";
import { getPicklistValues, getObjectInfo } from "lightning/uiObjectInfoApi";
import Case_OBJECT from "@salesforce/schema/Case";
import { handleErrorShowToast } from "c/utils";
import { OmniscriptBaseMixin } from "omnistudio/omniscriptBaseMixin";

const SELECT_ADDRESS_ERROR =
  "Error while selecting the address. Please contact your administrator";
const SEARCH_ADDRESS_ERROR =
  "Address Search functionality is unavailable, please select Manual Address Entry on the top button to proceed.";

export default class AddressLookupUtil extends OmniscriptBaseMixin(
  LightningElement
) {
  @api thirdPartyCheck;
  @api isAutoSearch;
  @api searchPostcode;
  @api postcodeLabel;
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
  addressPostCodeList = [];

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
  handleSearchPostcode(event) {
    clearTimeout(this.pendingSearchRequest);
    const searchString = event.detail.value.trim();
    let postCode =
      searchString?.length === 4 && searchString?.match(/^[0-9]+$/);
    if (postCode) {
      // eslint-disable-next-line @lwc/lwc/no-async-operation
      this.pendingSearchRequest = setTimeout(() => {
        this.isSearching = true;
        this.showAddresses = postCode;
        this.getPostCodeAddresses(searchString);
      }, 300);
    }
    this.omniUpdateDataJson(searchString);
    this.setParentAddress("postcodechanged", searchString);
  }
  async getAddresses(searchString) {
    try {
      const response = await getValidAddresses({
        lookupString: searchString
      });

      this.addressList = response.result;
      let isValidArray =
        !Array.isArray(this.addressList) || this.addressList.length === 0;

      this.message = isValidArray ? "No results are returned" : "";
      this.displayAddresses = !isValidArray;
      this.displayMessage = isValidArray;
    } catch (error) {
      this.setReadonly(false);
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
        response.result.components !== undefined &&
        response.result.components !== null
      ) {
        this.selectedAddress.country = this.getCountry(
          this.getCountryOptions(),
          response.result.components.country_iso_3
        );
      }

      this.omniApplyCallResp(this.populateAddress(this.selectedAddress));
      this.setParentAddress(
        "addressselected",
        this.populateAddress(this.selectedAddress)
      );
    } catch (error) {
      this.setReadonly(false);
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
  async getPostCodeAddresses(searchString) {
    try {
      const response = await getAddressPostcode({
        postCode: searchString
      });
      this.isSearching = false;
      this.displayMessage = false;
      this.addressPostCodeList = response.result.map(
        ({ postCode, suburb }) => ({ postCode, suburb })
      );
    } catch (error) {
      if (error?.body?.message === "Invalid Request") {
        this.displayMessage = true;
        this.message = "No results are returned";
        this.isSearching = false;
        return;
      }
      handleErrorShowToast(
        this,
        SELECT_ADDRESS_ERROR,
        error,
        error.body.message,
        "pester"
      );
      this.dispatchEvent(
        new CustomEvent("postcodeapierror", {
          detail: {
            error: error,
            message: error.body.message
          }
        })
      );
    }
  }
  handleSelectedAddress(event) {
    const clickedIndex = event.currentTarget.dataset.index;
    this.omniApplyCallResp({ Case: { validAddress: true } });
    this.showAddresses = false;
    this.setParentAddress(
      "postcodeselected",
      this.addressPostCodeList[clickedIndex]?.postCode
    );
  }
  setParentAddress(eventName, eventValue) {
    this.dispatchEvent(
      new CustomEvent(eventName, {
        detail: eventValue
      })
    );
  }

  setReadonly(readonly) {
    this.omniApplyCallResp({ Case: { disablAddress: readonly } });
  }
  populateAddress(address) {
    let stateMap = this.getProvinceOptions();
    if (this.thirdPartyCheck === "false") {
      return {
        Case: {
          disablAddress: true,
          CustomerDetails: {
            Country: address.country,
            Postcode: address.postal_code,
            State: stateMap.get(address.region),
            Street: address.street,
            Suburb: address.locality
          }
        }
      };
    }
    return {
      Case: {
        disablThirdAddress: true,
        CustomerDetails: {
          thirdPartyCountryReadOnly: address.country,
          thirdPartyPostCodeReadOnly: address.postal_code,
          thirdPartyStateReadOnly: stateMap.get(address.region),
          thirdPartyStreetReadOnly: address.street
        }
      }
    };
  }

  getCountry(countryMap, value) {
    return Object.keys(countryMap).find((key) => countryMap[key] === value);
  }
}
