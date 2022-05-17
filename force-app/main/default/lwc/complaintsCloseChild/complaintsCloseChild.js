import { LightningElement, api } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import COMPLAINT_OUTCOME from "@salesforce/schema/Case.IDR_Complaint_Outcome__c";
import COMPLAINT_REMEDY from "@salesforce/schema/Case.IDR_Complaint_Remedy__c";
import COMPLAINT_SUB_REMEDY from "@salesforce/schema/Case.IDR_Complaint_Sub_Remedy__c";
import NON_FINANCIAL_REMEDY from "@salesforce/schema/Case.IDR_Non_Financial_Remedy__c";
import OUTCOME_DESCRIPTION from "@salesforce/schema/Case.IDR_Description_of_Outcome__c";
import CASE_OBJECT from "@salesforce/schema/Case";

const ERROR_UNKNOWN_TITLE = "An error has occurred.";
const COMPLAINT_REMEDY_FIN_VALUE = "1";
const COMPLAINT_REMEDY_NON_FIN_VALUE = "2";
const OTHER = "Other";

export default class complaintsResolveLWC extends NavigationMixin(
  LightningElement
) {
  complaintOutcome = COMPLAINT_OUTCOME;
  complaintRemedy = COMPLAINT_REMEDY;
  complaintSubRemedy = COMPLAINT_SUB_REMEDY;
  outcomeDescription = OUTCOME_DESCRIPTION;
  nonFinancialRemedy = NON_FINANCIAL_REMEDY;
  caseObject = CASE_OBJECT;

  @api recordId;
  @api recordTypeId;
  showOptions = true;
  showModal = false;
  modalMessage = ERROR_UNKNOWN_TITLE;
  modalHeader = "Error";
  draftValues = [];

  //uiControl
  isFinancialComplaintRemedy;
  isNonFinancialComplaintRemedy;
  isReferredToProductManufacturer = false;
  isOtherProductManufacturer = false;
  thirdPartyIsDetailsProvidedToProductManufacturer = false;

  showSuccess = false;
  showAuthError = false;

  outcomeOptions = [];
  remedyOptions = [];
  productManufacturerOptions = [];
  nonFinancialRemedyOptions = [];

  openModal(msg) {
    this.modalMessage = msg;
    this.showModal = true;
  }

  handleComplaintOutcomeChange(event) {
    let sendVal = {
      field: "",
      value: ""
    };
    sendVal.field = "IDR_Complaint_Outcome__c";
    sendVal.value = event.detail.value;
    this.sendFieldValue(sendVal);
  }

  handleOutcomeDescriptionChange(event) {
    let sendVal = {
      field: "",
      value: ""
    };
    sendVal.field = "IDR_Description_of_Outcome__c";
    sendVal.value = event.detail.value;
    this.sendFieldValue(sendVal);
  }
  handleProductManufacturerNameChange(event) {
    let sendVal = {
      field: "",
      value: ""
    };
    sendVal.field = "Name_of_product_manufacturer__c";
    sendVal.value = event.detail.value;
    this.sendFieldValue(sendVal);
  }
  handleComplaintSubRemedy(event) {
    let sendVal = {
      field: "",
      value: ""
    };
    sendVal.field = "IDR_Complaint_Sub_Remedy__c";
    sendVal.value = event.detail.value;
    this.sendFieldValue(sendVal);
  }
  handleComplaintRemedy(event) {
    let sendVal = {
      field: "",
      value: ""
    };
    sendVal.field = "IDR_Complaint_Remedy__c";
    sendVal.value = event.detail.value;
    if (event.detail.value === COMPLAINT_REMEDY_FIN_VALUE) {
      this.isFinancialComplaintRemedy = true;
      this.isNonFinancialComplaintRemedy = false;
      this.isReferredToProductManufacturer = false;
      this.isOtherProductManufacturer = false;
    } else if (event.detail.value === COMPLAINT_REMEDY_NON_FIN_VALUE) {
      this.isFinancialComplaintRemedy = false;
      this.isNonFinancialComplaintRemedy = true;
      this.isReferredToProductManufacturer = false;
      this.isOtherProductManufacturer = false;
    } else {
      this.isFinancialComplaintRemedy = false;
      this.isNonFinancialComplaintRemedy = false;
      this.isReferredToProductManufacturer = true;
    }
    this.sendFieldValue(sendVal);
  }

  handleThirdPartyProductManufacturer(event) {
    let sendVal = {
      field: "",
      value: ""
    };
    sendVal.field = "IDR_Product_Manufacturer__c";
    sendVal.value = event.detail.value;
    if (event.detail.value === OTHER) {
      this.isOtherProductManufacturer = true;
    } else {
      this.isOtherProductManufacturer = false;
    }
    this.sendFieldValue(sendVal);
  }
  handleIsDetailsProvidedToProductManufacturer(event) {
    let sendVal = {
      field: "",
      value: ""
    };
    sendVal.field = "Provided_details_to_Product_Manufacturer__c";
    sendVal.value = event.detail.checked;
    this.thirdPartyIsDetailsProvidedToProductManufacturer =
      event.detail.checked;
    this.sendFieldValue(sendVal);
  }

  handleFinancialCompensation(event) {
    let sendVal = {
      field: "",
      value: ""
    };
    sendVal.field = "IDR_Financial_Compensation__c";
    sendVal.value = event.target.value;
    this.financialCompensation = event.target.value;
    this.sendFieldValue(sendVal);
  }

  handleNonFinacialRemedy(event) {
    let sendVal = {
      field: "",
      value: ""
    };
    sendVal.field = "IDR_Non_Financial_Remedy__c";
    sendVal.value = event.target.value;
    this.sendFieldValue(sendVal);
  }

  sendFieldValue(sendVal) {
    this.dispatchEvent(
      new CustomEvent("fieldvalueupdate", { detail: sendVal })
    );
  }

  openModal(msg) {
    this.template.querySelector(".slds-card").classList.add("slds-hide");
    this.modalMessage = msg;
    this.showModal = true;
  }

  closeModal() {
    this.showModal = false;
  }
}
