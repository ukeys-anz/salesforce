import { LightningElement, api, wire, track } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { CloseActionScreenEvent } from "lightning/actions";
import { getRecord } from "lightning/uiRecordApi";
import { NavigationMixin } from "lightning/navigation";
import RecordType from "@salesforce/schema/Case.RecordType.Name";
import POSTCODE_FIELD from "@salesforce/schema/Case.IDR_NC_Postcode__c";
import TPPOSTCODE_FIELD from "@salesforce/schema/Case.IDR_3rdParty_Postcode__c";
import { handleErrorShowToast } from "c/utils";
const POSTCODE_VALIDATED = "Manual Address Postcode Validated";
const POSTCODE_NOT_VALIDATED = "Manual Address not Validated";
const ADDRESS_VALIDATED = "Search Address Validated";
export default class AddressLwc extends NavigationMixin(LightningElement) {
  @api recordId;
  @api objectAPIName = "Case";
  defaultAddressInputNC = "manualAddress";
  defaultAddressInputTP = "manualAddress";
  defaultThirdPartySwitch = "No";
  @track activeSections = ["customerDetails"];
  postCodeInputCustomer;
  postCodeInputTP;
  apiPostcodeError = false;
  apiPostcodeErrorTP = false;
  customerManualPostcode;
  thirdPartyManualPostcode;
  ncStreet;
  ncSuburb;
  ncState;
  ncCountry;
  ncPostCode;
  searchButtonSelected = false;
  tpStreet;
  tpSuburb;
  tpState;
  tpCountry;
  tpPostCode;
  searchButtonSelectedForTP = false;
  searchAddressFieldCustomerShow = "slds-hide";
  searchAddressFieldTPShow = "slds-hide";
  hideThirdPartyToggleClass = "slds-hide";
  hideSearchPostCodeClass = "slds-show";
  hideSearchPostCodeClassTP = "slds-show";
  hideManualPostCodeClass = "slds-hide";
  hideManualPostCodeClassTP = "slds-hide";
  hideCustomerAddressFields = false;
  disableCustomerAddressFields;
  hideThirdPartyAddressFields = false;
  disableThirdPartyAddressFields;
  hideCustAddInputClass;
  hideTPAddressInputClass;
  hideCustomerSection;
  selectedContactAddress;
  selectedTPAddress;
  loading = false;
  recordTypeName;
  customerFieldsRequired = true;
  thirdPartyFieldsRequired = false;
  searchButtonValue = "";
  searchButtonValueTP = "";
  fields = {};
  requiredCustomerFields = {
    IDR_NC_Street__c: "Street",
    IDR_NC_Suburb__c: "Suburb",
    IDR_NC_State__c: "State",
    IDR_NC_Country__c: "Country",
    IDR_NC_Postcode__c: "Postcode"
  };
  requiredThirdPartyFields = {
    IDR_3rdParty_Street__c: "3rd Party Street",
    IDR_3rdParty_State__c: "3rd Party State",
    IDR_3rdParty_Country__c: "3rd Party Country",
    IDR_3rdParty_Postcode__c: "3rd Party Postcode"
  };

  @wire(getRecord, {
    recordId: "$recordId",
    fields: [RecordType, POSTCODE_FIELD, TPPOSTCODE_FIELD]
  })
  wiredProject({ error, data }) {
    if (error) {
      this.closeQuickAction();
      handleErrorShowToast(this, "Error in loading complaint data", "pester");
      return;
    }
    if (data) {
      this.recordTypeName = data.fields.RecordType.value.fields.Name.value;
      this.postCodeInputCustomer = data.fields.IDR_NC_Postcode__c.value;
      this.postCodeInputTP = data.fields.IDR_3rdParty_Postcode__c.value;
    }
    if (this.recordTypeName === "Customer Complaint") {
      this.hideCustomerSection = "slds-hide";
      this.customerFieldsRequired = false;
    }
  }
  get addressOptions() {
    return [
      { label: "Search Address", value: "searchAddress" },
      { label: "Manually Enter Address", value: "manualAddress" }
    ];
  }
  get thirdPartySwitchOptions() {
    return [
      { label: "Yes", value: "Yes" },
      { label: "No", value: "No" }
    ];
  }
  handleCustAddressInputChange(event) {
    this.defaultAddressInputNC = event.target.value;
    if (event.target.value === "searchAddress") {
      this.searchAddressFieldCustomerShow = "slds-show";
      this.hideCustAddInputClass = "slds-hide";
      this.disableCustomerAddressFields = true;
      this.hideSearchPostCodeClass = "slds-hide";
      this.searchButtonSelected = true;
      return;
    }
    if (event.target.value === "manualAddress") {
      this.searchAddressFieldCustomerShow = "slds-hide";
      this.hideCustAddInputClass = "slds-show";
      this.hideSearchPostCodeClass = "slds-show";
      this.hideManualPostCodeClass = "slds-hide";
      this.disableCustomerAddressFields = false;
      this.searchButtonSelected = false;
    }
  }
  handleTPAddressInputChange(event) {
    this.defaultAddressInputTP = event.target.value;
    if (event.target.value === "searchAddress") {
      this.searchAddressFieldTPShow = "slds-show";
      this.hideTPAddressInputClass = "slds-hide";
      this.disableThirdPartyAddressFields = true;
      this.hideSearchPostCodeClassTP = "slds-hide";
      this.searchButtonSelectedForTP = true;
      return;
    }
    if (event.target.value === "manualAddress") {
      this.searchAddressFieldTPShow = "slds-hide";
      this.hideTPAddressInputClass = "slds-show";
      this.hideSearchPostCodeClassTP = "slds-show";
      this.hideManualPostCodeClassTP = "slds-hide";
      this.disableThirdPartyAddressFields = false;
      this.searchButtonSelectedForTP = false;
    }
  }
  handleAddressSelected(event) {
    this.selectedContactAddress = event.detail;
    this.ncStreet = this.selectedContactAddress?.Case.CustomerDetails.Street;
    this.ncSuburb = this.selectedContactAddress?.Case.CustomerDetails.Suburb;
    this.ncState = this.selectedContactAddress?.Case.CustomerDetails.State;
    this.ncCountry = this.selectedContactAddress?.Case.CustomerDetails.Country;
    this.ncPostCode =
      this.selectedContactAddress?.Case.CustomerDetails.Postcode;
    this.searchButtonSelected = true;
    this.hideCustAddInputClass = "slds-show";
    this.hideManualPostCodeClass = "slds-show";
    this.hideSearchPostCodeClass = "slds-hide";
    this.disableCustomerAddressFields = true;
    this.searchButtonValue = ADDRESS_VALIDATED;
  }
  handlePostCodeSelected(event) {
    this.ncPostCode = event.detail.toString();
    this.searchButtonValue = POSTCODE_VALIDATED;
  }
  handleManualPostCodeChanged(event) {
    this.customerManualPostcode = event.detail.toString();
  }
  handlePostCodeApiError() {
    this.apiPostcodeError = true;
    this.searchButtonValue = POSTCODE_NOT_VALIDATED;
  }
  validateCustomerPostcode() {
    if (
      this.apiPostcodeError ||
      this.customerManualPostcode === "Overseas" ||
      this.customerManualPostcode === "Not Applicable"
    ) {
      this.ncPostCode = this.customerManualPostcode;
      return true;
    }
    if (
      this.ncPostCode === this.customerManualPostcode ||
      this.customerManualPostcode === "Overseas" ||
      this.customerManualPostcode === "Not Applicable"
    ) {
      return true;
    }
    return false;
  }
  handleTPAddressSelected(event) {
    this.selectedTPAddress = event.detail;
    this.tpStreet =
      this.selectedTPAddress?.Case.CustomerDetails.thirdPartyStreetReadOnly;
    this.tpSuburb =
      this.selectedTPAddress?.Case.CustomerDetails.thirdPartySuburbReadOnly;
    this.tpState =
      this.selectedTPAddress?.Case.CustomerDetails.thirdPartyStateReadOnly;
    this.tpCountry =
      this.selectedTPAddress?.Case.CustomerDetails.thirdPartyCountryReadOnly;
    this.tpPostCode =
      this.selectedTPAddress?.Case.CustomerDetails.thirdPartyPostCodeReadOnly;
    this.searchButtonSelectedForTP = true;
    this.hideTPAddressInputClass = "slds-show";
    this.hideManualPostCodeClassTP = "slds-show";
    this.hideSearchPostCodeClassTP = "slds-hide";
    this.disableThirdPartyAddressFields = true;
    this.searchButtonValueTP = ADDRESS_VALIDATED;
  }
  handlePostCodeSelectedTP(event) {
    this.tpPostCode = event.detail.toString();
    this.searchButtonValueTP = POSTCODE_VALIDATED;
  }
  handleManualPostCodeChangedTP(event) {
    this.thirdPartyManualPostcode = event.detail.toString();
  }
  handlePostCodeApiErrorTP() {
    this.apiPostcodeErrorTP = true;
    this.searchButtonValueTP = POSTCODE_NOT_VALIDATED;
  }
  validatePostcodeTP() {
    if (
      this.apiPostcodeErrorTP ||
      this.thirdPartyManualPostcode === "Overseas" ||
      this.thirdPartyManualPostcode === "Not Applicable"
    ) {
      this.tpPostCode = this.thirdPartyManualPostcode;
      return true;
    }
    if (
      this.tpPostCode === this.thirdPartyManualPostcode ||
      this.thirdPartyManualPostcode === "Overseas" ||
      this.thirdPartyManualPostcode === "Not Applicable"
    ) {
      return true;
    }
    return false;
  }
  validateCustomerSearchAddress() {
    if (!this.searchButtonSelected) {
      return true;
    }
    if (this.searchButtonSelected && this.selectedContactAddress) {
      return true;
    }
    return false;
  }
  validateThirdPartySearchAddress() {
    if (!this.searchButtonSelectedForTP) {
      return true;
    }
    if (this.searchButtonSelectedForTP && this.selectedTPAddress) {
      return true;
    }
    return false;
  }
  validateCustomerDetails(event) {
    if (this.recordTypeName === "Customer Complaint") {
      return true;
    }
    this.fields = event.detail.fields;
    let missingCustomerFields = Object.keys(this.requiredCustomerFields).filter(
      (f) =>
        !(f in this.fields) || !this.fields[f] || this.fields[f].trim() === ""
    );
    if (missingCustomerFields.length === 0) {
      return true;
    }
    let missingFieldsLabels = missingCustomerFields
      .map((f) => this.requiredCustomerFields[f])
      .join(", ");
    handleErrorShowToast(
      this,
      "Please fill all the mandatory customer details fields by selecting Address in Search Address Field: " +
        missingFieldsLabels,
      "pester"
    );
    this.loading = false;
    return false;
  }
  validateThirdPartyAddressDetails(event) {
    this.fields = event.detail.fields;
    const missingTPFields = Object.keys(this.requiredThirdPartyFields).filter(
      (f) =>
        !(f in this.fields) || !this.fields[f] || this.fields[f].trim() === ""
    );
    if (missingTPFields.length === 0 || !this.thirdPartyFieldsRequired) {
      return true;
    }
    const missingTPFieldsLabels = missingTPFields
      .map((f) => this.requiredThirdPartyFields[f])
      .join(", ");
    handleErrorShowToast(
      this,
      "Please fill all the mandatory 3rd Party details fields by selecting Address in Search Address Field: " +
        missingTPFieldsLabels,
      "pester"
    );
    this.loading = false;
    return false;
  }
  handleThirdPartySwitch(event) {
    if (event.target.value === "Yes") {
      this.hideThirdPartyToggleClass = "slds-show";
      this.activeSections = ["customerDetails", "thirdPartyDetails"];
      this.thirdPartyFieldsRequired = true;
      return;
    }
    if (event.target.value === "No") {
      this.hideThirdPartyToggleClass = "slds-hide";
      this.activeSections = ["customerDetails"];
      this.thirdPartyFieldsRequired = false;
    }
  }
  handleSubmit(event) {
    event.preventDefault();
    if (!this.validateCustomerPostcode() && !this.searchButtonSelected) {
      handleErrorShowToast(
        this,
        "Please select an valid postcode from postcode field to save the address on Customer Details",
        "pester"
      );
      this.loading = false;
      return;
    }
    if (!this.validatePostcodeTP() && !this.searchButtonSelectedForTP) {
      handleErrorShowToast(
        this,
        "Please select an valid postcode from postcode field to save the address on Nominated 3rd Party Details",
        "pester"
      );
      this.loading = false;
      return;
    }
    if (!this.validateCustomerSearchAddress()) {
      handleErrorShowToast(
        this,
        "Please select an address from the search address field on Customer Details",
        "pester"
      );
      this.loading = false;
      return;
    }
    if (!this.validateThirdPartySearchAddress()) {
      handleErrorShowToast(
        this,
        "Please select an address from the search address field on Nominated 3rd Party Details",
        "pester"
      );
      this.loading = false;
      return;
    }
    if (
      !this.validateCustomerDetails(event) ||
      !this.validateThirdPartyAddressDetails(event)
    ) {
      handleErrorShowToast(this, "Error in saving address", "pester");
      this.loading = false;
      return;
    }
    this.loading = true;
    this.template
      .querySelector("lightning-record-edit-form")
      .submit(this.fields);
  }
  handleSuccess() {
    this.closeQuickAction();
    this.loading = false;
    this.dispatchEvent(
      new ShowToastEvent({
        message: "Address Updated Successfully",
        variant: "success"
      })
    );
  }
  closeQuickAction() {
    this.dispatchEvent(new CloseActionScreenEvent());
  }
  handleError() {
    this.loading = false;
  }
}
