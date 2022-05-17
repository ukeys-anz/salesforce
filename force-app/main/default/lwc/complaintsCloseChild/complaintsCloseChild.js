import { LightningElement, api } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import COMPLAINT_OUTCOME from "@salesforce/schema/Case.IDR_Complaint_Outcome__c";
import COMPLAINT_REMEDY from "@salesforce/schema/Case.IDR_Complaint_Remedy__c";
import COMPLAINT_SUB_REMEDY from "@salesforce/schema/Case.IDR_Complaint_Sub_Remedy__c";
import OUTCOME_DESCRIPTION from "@salesforce/schema/Case.IDR_Description_of_Outcome__c";
import REMEDY_POINTS1 from "@salesforce/schema/Case.IDR_Financial_Remedy_Points__c";
import OTHER_REMDY1 from "@salesforce/schema/Case.IDR_Other_Remedy_Provided__c";
import CASE_OBJECT from "@salesforce/schema/Case";

const COMPLAINT_REMEDY_FIN_VALUE = "1";
const COMPLAINT_REMEDY_NON_FIN_VALUE = "2";
const COMPLAINT_REMDY_PRODUCT_MANU = "3";
const OTHER = "Other";
const MONETARY = "Monetary";
const REWARD_POINTS = "Rewards Points";
const OTHER_NONFIN_REMEDY = "99";
const DEBT_WAIVER = "10";
const SETTEL_FOR_LESS = "18";
export default class complaintsResolveLWC extends NavigationMixin(
  LightningElement
) {
  complaintOutcome = COMPLAINT_OUTCOME;
  complaintRemedy = COMPLAINT_REMEDY;
  complaintSubRemedy = COMPLAINT_SUB_REMEDY;
  outcomeDescription = OUTCOME_DESCRIPTION;
  remedyPoints1 = REMEDY_POINTS1;
  otherNonFinRemedy = OTHER_REMDY1;
  caseObject = CASE_OBJECT;

  @api recordId;
  @api recordTypeId;
  showOptions = true;

  draftValues = [];
  showFinancialCompensation = false;
  isRewardPoints = false;
  //uiControl
  isFinancialComplaintRemedy;
  isNonFinancialComplaintRemedy;
  isReferredToProductManufacturer = false;
  isOtherProductManufacturer = false;
  thirdPartyIsDetailsProvidedToProductManufacturer = false;
  isOtherNonFinRemedy = false;

  showSuccess = false;
  showAuthError = false;

  outcomeOptions = [];
  remedyOptions = [];
  productManufacturerOptions = [];
  nonFinancialRemedyOptions = [];

  get FinancialRemedyTypeOptions() {
    return [
      { label: MONETARY, value: MONETARY },
      {
        label: REWARD_POINTS,
        value: REWARD_POINTS
      }
    ];
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

    if (event.target.value == OTHER_NONFIN_REMEDY) {
      this.isOtherNonFinRemedy = true;
    } else {
      this.isOtherNonFinRemedy = false;
    }
    if (
      event.target.value == DEBT_WAIVER ||
      event.target.value == SETTEL_FOR_LESS
    ) {
      this.showFinancialCompensation = true;
    } else {
      this.showFinancialCompensation = false;
    }
    this.sendFieldValue(sendVal);
  }
  handleFinancialRemedyTypeChange(event) {
    if (event.detail.value === MONETARY) {
      this.showFinancialCompensation = true;
      this.isRewardPoints = false;
    } else {
      this.isRewardPoints = true;
      this.showFinancialCompensation = false;
    }
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
    } else if (event.detail.value === COMPLAINT_REMDY_PRODUCT_MANU) {
      this.isFinancialComplaintRemedy = false;
      this.isNonFinancialComplaintRemedy = false;
      this.isReferredToProductManufacturer = true;
    } else {
      this.isFinancialComplaintRemedy = false;
      this.isNonFinancialComplaintRemedy = false;
      this.isReferredToProductManufacturer = false;
    }
    this.sendFieldValue(sendVal);
  }

  handleFinRemedyPoints(event) {
    let sendVal = {
      field: "",
      value: ""
    };
    sendVal.field = "IDR_Financial_Remedy_Points__c";
    sendVal.value = event.detail.value;
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

  handleotherNonFinRemedy(event) {
    let sendVal = {
      field: "",
      value: ""
    };
    sendVal.field = "IDR_Other_Remedy_Provided__c";
    sendVal.value = event.target.value;
    this.sendFieldValue(sendVal);
  }
  sendFieldValue(sendVal) {
    this.dispatchEvent(
      new CustomEvent("fieldvalueupdate", { detail: sendVal })
    );
  }
}
