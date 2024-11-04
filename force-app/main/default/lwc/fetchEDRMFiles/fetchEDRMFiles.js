import { LightningElement, api, wire } from "lwc";
import { getRecord } from "lightning/uiRecordApi";
import { NavigationMixin } from "lightning/navigation";
import { handleErrorShowToast } from "c/utils";
import RecordType from "@salesforce/schema/Case.RecordType.Name";
import CustomerNumber from "@salesforce/schema/Case.IDR_Customer_Number__c";
import EdrmLabel from "@salesforce/label/c.EDRM_Business_Streams_Mapping";
import EdrmDevURL from "@salesforce/label/c.EDRM_URL_DEV";
import EdrmProdURl from "@salesforce/label/c.EDRM_URL_PROD";
import EdrmDesktopParam from "@salesforce/label/c.EDRM_Desktop_Params";

const fields = [RecordType, CustomerNumber];
const EDRMURLString = "&feature=GenericPaginatedSearch&appId=";
export default class FetchEDRMFiles extends NavigationMixin(LightningElement) {
  @api recordId;
  showCustomerComplaint = false;
  customerNumber;
  custNumActual;
  edrmMapping;
  accountNumber;
  applicationNumber;
  businessStream;
  edrmURL;

  @wire(getRecord, {
    recordId: "$recordId",
    fields: fields
  })
  wiredCaseRecord({ data, error }) {
    let recordTypeName = "";
    if (data) {
      this.custNumActual = data.fields.IDR_Customer_Number__c.value;
      this.customerNumber = this.custNumActual;
      recordTypeName = data.fields.RecordType.value.fields.Name.value;
    } else if (error) {
      this.showErrorToast(
        "Unable to get details for this Complaint, please contact your System Administrator"
      );
    }
    if (recordTypeName === "Customer Complaint") {
      this.showCustomerComplaint = true;
    }
    this.edrmMapping = this.getBusinessStreams();
  }
  getBusinessStreams() {
    let tempEDRMMap = [];
    let str_array = EdrmLabel.split(",");
    for (let i = 0; i < str_array.length; i++) {
      let tempArr = [];
      tempArr = str_array[i].split(":");
      tempEDRMMap.push({
        label: tempArr[0],
        value: tempArr[1]
      });
    }
    return tempEDRMMap;
  }
  updateAccountNumber(event) {
    this.accountNumber = event.target.value;
  }
  updateApplicationNumber(event) {
    this.applicationNumber = event.target.value;
  }
  updateCustomerNumber(event) {
    this.customerNumber = event.target.value;
  }
  updateBusinessStream(event) {
    this.businessStream = event.detail.value;
  }
  validateInputFields() {
    let validPattern = /^([0-9]{1,10})$/;

    if (this.checkIsEmpty(this.businessStream)) {
      this.showErrorToast("Please select a Business Stream");
      return false;
    }
    if (
      this.showCustomerComplaint &&
      this.checkIsEmpty(this.customerNumber) &&
      this.checkIsEmpty(this.applicationNumber)
    ) {
      this.showErrorToast(
        "Please enter Application Number if Customer Number is not there"
      );
      return false;
    }
    if (
      !this.showCustomerComplaint &&
      this.checkIsEmpty(this.accountNumber) &&
      this.checkIsEmpty(this.applicationNumber)
    ) {
      this.showErrorToast(
        "Please enter either Account Number or Application Number"
      );
      return false;
    }
    if (
      !this.checkIsEmpty(this.applicationNumber) &&
      !this.applicationNumber.match(validPattern)
    ) {
      this.showErrorToast(
        "Invalid Application Number, please enter a valid Application Number"
      );
      return false;
    }
    if (
      !this.checkIsEmpty(this.accountNumber) &&
      !this.accountNumber.match(validPattern)
    ) {
      this.showErrorToast(
        "Invalid Account Number, please enter a valid Account Number"
      );
      return false;
    }
    return true;
  }
  setEdrmURLPrefix() {
    if (window.location.origin.includes("sandbox")) {
      return EdrmDevURL;
    }
    return EdrmProdURl;
  }
  setEdrmURLSuffix() {
    let edrmURLSuffix = this.getDesktopUrl(this.businessStream) + EDRMURLString;
    if (this.applicationNumber) {
      edrmURLSuffix +=
        this.businessStream + "&OriginatingSourceID=" + this.applicationNumber;
    } else if (this.showCustomerComplaint && this.customerNumber) {
      edrmURLSuffix += this.businessStream + "&capId=" + this.customerNumber;
    } else if (!this.showCustomerComplaint && this.accountNumber) {
      edrmURLSuffix += this.businessStream + "&AccountID=" + this.accountNumber;
    }
    return edrmURLSuffix;
  }
  getDesktopUrl(businessStream) {
    let tempEDRMMap = new Map();
    let str_array = EdrmDesktopParam.split(",");
    for (let i = 0; i < str_array.length; i++) {
      let tempArr = [];
      tempArr = str_array[i].split(":");
      tempEDRMMap.set(tempArr[0], tempArr[1]);
    }
    return tempEDRMMap.get(businessStream);
  }
  handleNavigate() {
    if (!this.validateInputFields()) {
      return;
    }
    let navEDRMURL = this.setEdrmURLPrefix() + this.setEdrmURLSuffix();
    const config = {
      type: "standard__webPage",
      attributes: {
        url: navEDRMURL
      }
    };
    this[NavigationMixin.Navigate](config);
  }
  checkIsEmpty(field) {
    if (field === undefined || field === "" || field === null) {
      return true;
    }
    return false;
  }
  showErrorToast(errorMessage) {
    handleErrorShowToast(this, "Error", undefined, errorMessage);
  }
}