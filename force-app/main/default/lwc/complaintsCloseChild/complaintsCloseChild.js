import { LightningElement, api } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import CASE_OBJECT from "@salesforce/schema/Case";
import COMPLAINT_OUTCOME from "@salesforce/schema/Case.IDR_Complaint_Outcome__c";
import OUTCOME_DESCRIPTION from "@salesforce/schema/Case.IDR_Description_of_Outcome__c";

//Remedy1 fields
import COMPLAINT_REMEDY from "@salesforce/schema/Case.IDR_Complaint_Remedy__c";
import COMPLAINT_SUB_REMEDY from "@salesforce/schema/Case.IDR_Complaint_Sub_Remedy__c";
import REMEDY_POINTS1 from "@salesforce/schema/Case.IDR_Financial_Remedy_Points__c";
import OTHER_REMDY1 from "@salesforce/schema/Case.IDR_Other_Remedy_Provided__c";
import REMEDY_DURATION from "@salesforce/schema/Case.IDR_Duration_of_Remedy__c";

//Remedy 2 fields
import COMPLAINT_REMEDY2 from "@salesforce/schema/Case.IDR_Complaint_Remedy_2__c";
import COMPLAINT_SUB_REMEDY2 from "@salesforce/schema/Case.IDR_Complaint_Sub_Remedy_2__c";
import REMEDY_POINTS2 from "@salesforce/schema/Case.IDR_Financial_Remedy_Points_2__c";
import OTHER_REMDY2 from "@salesforce/schema/Case.IDR_Other_Remedy_Provided_2__c";
import REMEDY_DURATION2 from "@salesforce/schema/Case.IDR_Duration_of_Remedy_2__c";

//Remedy 3 fields
import COMPLAINT_REMEDY3 from "@salesforce/schema/Case.IDR_Complaint_Remedy_3__c";
import COMPLAINT_SUB_REMEDY3 from "@salesforce/schema/Case.IDR_Complaint_Sub_Remedy_3__c";
import REMEDY_POINTS3 from "@salesforce/schema/Case.IDR_Financial_Remedy_Points_3__c";
import OTHER_REMDY3 from "@salesforce/schema/Case.IDR_Other_Remedy_Provided_3__c";
import REMEDY_DURATION3 from "@salesforce/schema/Case.IDR_Duration_of_Remedy_3__c";

const COMPLAINT_REMEDY_FIN_VALUE = "1";
const COMPLAINT_REMEDY_NON_FIN_VALUE = "2";
const COMPLAINT_REMDY_PRODUCT_MANU = "3";
const SUB_REMEDY_OTHER = "99";
const REWARD_POINTS = "Reward Points";
const DEBT_WAIVER = "10";
const SETTEL_FOR_LESS = "18";
const MORATORIUM = "16";
const REPAYMENT_ARRAGMENT = "Repayment arrangement";
const TIME_TO_SELL_REFINANCE_SURRENDER = "20";
export default class complaintsResolveLWC extends NavigationMixin(
  LightningElement
) {
  complaintOutcome = COMPLAINT_OUTCOME;
  complaintRemedy = COMPLAINT_REMEDY;
  complaintSubRemedy = COMPLAINT_SUB_REMEDY;
  outcomeDescription = OUTCOME_DESCRIPTION;
  remedyPoints1 = REMEDY_POINTS1;
  otherNonFinRemedy = OTHER_REMDY1;
  remedyDuration = REMEDY_DURATION;
  caseObject = CASE_OBJECT;

  //remedy2
  complaintRemedy2 = COMPLAINT_REMEDY2;
  complaintSubRemedy2 = COMPLAINT_SUB_REMEDY2;
  remedyPoints2 = REMEDY_POINTS2;
  otherNonFinRemedy2 = OTHER_REMDY2;
  remedyDuration2 = REMEDY_DURATION2;

  //remedy3
  complaintRemedy3 = COMPLAINT_REMEDY3;
  complaintSubRemedy3 = COMPLAINT_SUB_REMEDY3;
  remedyPoints3 = REMEDY_POINTS3;
  otherNonFinRemedy3 = OTHER_REMDY3;
  remedyDuration3 = REMEDY_DURATION3;

  showRemedy2 = false;
  showRemedy3 = false;

  @api recordId;
  @api recordTypeId;
  @api expressCaseCreationData = {};
  showOptions = true;

  draftValues = [];
  showFinancialCompensation = false;
  showFinancialCompensation2 = false;
  showFinancialCompensation3 = false;
  isRewardPoints = false;
  isRewardPoints2 = false;
  isRewardPoints3 = false;
  showDuration = false;
  showDuration2 = false;
  showDuration3 = false;
  //uiControl
  isFinancialComplaintRemedy = false;
  isNonFinancialComplaintRemedy = false;
  isReferredToProductManufacturer = false;
  thirdPartyIsDetailsProvidedToProductManufacturer = false;
  isOtherSubFinRemedy = false;

  isFinancialComplaintRemedy2 = false;
  isNonFinancialComplaintRemedy2 = false;
  isReferredToProductManufacturer2 = false;
  thirdPartyIsDetailsProvidedToProductManufacturer2 = false;
  isOtherSubFinRemedy2 = false;

  isFinancialComplaintRemedy3 = false;
  isNonFinancialComplaintRemedy3 = false;
  isReferredToProductManufacturer3 = false;
  thirdPartyIsDetailsProvidedToProductManufacturer3 = false;
  isOtherSubFinRemedy3 = false;

  showSuccess = false;
  showAuthError = false;

  outcomeOptions = [];
  remedyOptions = [];
  productManufacturerOptions = [];
  nonFinancialRemedyOptions = [];
  pageLoadComplete = false;

  //initialize components
  handelPageLoad() {
    if (!this.pageLoadComplete) {
      if (this.expressCaseCreationData) {
        if (!this.isNonFinancialComplaintRemedy) {
          this.knownIssueChangeHandler();
        } else {
          this.knownIssueChangeHandlerNF();
        }
      }
    }
  }

  knownIssueChangeHandler() {
    this.pageLoadComplete = true;
    const complaintOutcomeElement = this.template.querySelector(
      '[data-id="compOutCome-id"]'
    );

    if (complaintOutcomeElement !== null) {
      complaintOutcomeElement.value =
        this.expressCaseCreationData === undefined
          ? ""
          : this.expressCaseCreationData.detail.IDR_Complaint_Outcome__c;
      complaintOutcomeElement.dispatchEvent(
        new CustomEvent("change", {
          detail: { value: complaintOutcomeElement.value }
        })
      );
    }

    const descOfOutcomeElement = this.template.querySelector(
      '[data-id="descOutcome-id"]'
    );
    if (descOfOutcomeElement !== null) {
      descOfOutcomeElement.value =
        this.expressCaseCreationData === undefined
          ? ""
          : this.expressCaseCreationData.detail.IDR_Description_of_Outcome__c;
      descOfOutcomeElement.dispatchEvent(
        new CustomEvent("change", {
          detail: { value: descOfOutcomeElement.value }
        })
      );
    }

    const complaintRemedyElement = this.template.querySelector(
      '[data-id="compRemedy-id"]'
    );
    if (complaintRemedyElement !== null) {
      complaintRemedyElement.value =
        this.expressCaseCreationData === undefined
          ? ""
          : this.expressCaseCreationData.detail.IDR_Complaint_Remedy__c;
      complaintRemedyElement.dispatchEvent(
        new CustomEvent("change", {
          detail: { value: complaintRemedyElement.value }
        })
      );
    }
  }
  knownIssueChangeHandlerNF() {
    this.pageLoadComplete = true;
    const nonFinancialRemedyElement = this.template.querySelector(
      '[data-id="compSubRemedy-id"]'
    );
    if (nonFinancialRemedyElement !== null) {
      nonFinancialRemedyElement.value =
        this.expressCaseCreationData === undefined
          ? ""
          : this.expressCaseCreationData.detail.IDR_Non_Financial_Remedy__c;
    }
    nonFinancialRemedyElement.dispatchEvent(
      new CustomEvent("change", {
        detail: { value: nonFinancialRemedyElement.value }
      })
    );
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

  handleComplaintRemedy(event) {
    let sendVal = {
      field: "",
      value: ""
    };
    sendVal.field = "IDR_Complaint_Remedy__c";
    sendVal.value = event.detail.value;
    if (event.detail.value === COMPLAINT_REMEDY_FIN_VALUE) {
      this.isFinancialComplaintRemedy = true;
      this.showFinancialCompensation = true;
      this.isNonFinancialComplaintRemedy = false;
      this.isReferredToProductManufacturer = false;
    } else if (event.detail.value === COMPLAINT_REMEDY_NON_FIN_VALUE) {
      if (this.expressCaseCreationData) {
        this.pageLoadComplete = false;
      }
      this.isFinancialComplaintRemedy = false;
      this.showFinancialCompensation = false;
      this.isNonFinancialComplaintRemedy = true;
      this.isReferredToProductManufacturer = false;
    } else if (event.detail.value === COMPLAINT_REMDY_PRODUCT_MANU) {
      this.isFinancialComplaintRemedy = false;
      this.showFinancialCompensation = false;
      this.isNonFinancialComplaintRemedy = false;
      this.isReferredToProductManufacturer = true;
    } else {
      this.isFinancialComplaintRemedy = false;
      this.isNonFinancialComplaintRemedy = false;
      this.isReferredToProductManufacturer = false;
    }

    this.sendFieldValue(sendVal);
  }

  handleComplaintSubRemedy(event) {
    let sendVal = {
      field: "",
      value: ""
    };
    sendVal.field = "IDR_Complaint_Sub_Remedy__c";
    sendVal.value = event.detail.value;

    if (event.target.value === SUB_REMEDY_OTHER) {
      this.isOtherSubFinRemedy = true;
    } else {
      this.isOtherSubFinRemedy = false;
    }

    if (
      event.target.value === DEBT_WAIVER ||
      event.target.value === SETTEL_FOR_LESS
    ) {
      this.showFinancialCompensation = true;
    } else if (!this.isFinancialComplaintRemedy) {
      this.showFinancialCompensation = false;
    }

    if (event.target.value === REWARD_POINTS) {
      this.isRewardPoints = true;
    } else {
      this.isRewardPoints = false;
    }

    if (
      event.target.value === MORATORIUM ||
      event.target.value === TIME_TO_SELL_REFINANCE_SURRENDER ||
      event.target.value === REPAYMENT_ARRAGMENT
    ) {
      this.showDuration = true;
    } else {
      this.showDuration = false;
    }

    this.sendFieldValue(sendVal);
  }

  handleFinancialCompensation(event) {
    let sendVal = {
      field: "",
      value: ""
    };
    sendVal.field = "IDR_Financial_Compensation__c";
    sendVal.value = event.target.value;
    this.showFinancialCompensation = true;
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

  handleotherNonFinRemedy(event) {
    let sendVal = {
      field: "",
      value: ""
    };
    sendVal.field = "IDR_Other_Remedy_Provided__c";
    sendVal.value = event.target.value;
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

  handleremedyDuration(event) {
    let sendVal = {
      field: "",
      value: ""
    };

    sendVal.field = "IDR_Duration_of_Remedy__c";
    sendVal.value = event.detail.value;
    this.sendFieldValue(sendVal);
  }

  // remedy 2

  handle2ndRemedyToggleChange(event) {
    this.showRemedy2 = event.target.checked;
    let sendVal = {
      field: "",
      value: ""
    };
    sendVal.field = "Remedy2";
    sendVal.value = event.target.checked;
    this.sendFieldValue(sendVal);
    if (!event.target.checked) {
      this.clearRemedy2();
    }
  }

  handleComplaintRemedy2(event) {
    let sendVal = {
      field: "",
      value: ""
    };
    sendVal.field = "IDR_Complaint_Remedy_2__c";
    sendVal.value = event.detail.value;
    if (event.detail.value === COMPLAINT_REMEDY_FIN_VALUE) {
      this.isFinancialComplaintRemedy2 = true;
      this.isNonFinancialComplaintRemedy2 = false;
      this.isReferredToProductManufacturer2 = false;
      this.showFinancialCompensation2 = true;
    } else if (event.detail.value === COMPLAINT_REMEDY_NON_FIN_VALUE) {
      this.isFinancialComplaintRemedy2 = false;
      this.isNonFinancialComplaintRemedy2 = true;
      this.isReferredToProductManufacturer2 = false;
      this.showFinancialCompensation2 = false;
    } else if (event.detail.value === COMPLAINT_REMDY_PRODUCT_MANU) {
      this.isFinancialComplaintRemedy2 = false;
      this.isNonFinancialComplaintRemedy2 = false;
      this.showFinancialCompensation2 = false;
      this.isReferredToProductManufacturer2 = true;
    } else {
      this.isFinancialComplaintRemedy2 = false;
      this.isNonFinancialComplaintRemedy2 = false;
      this.isReferredToProductManufacturer2 = false;
      this.showFinancialCompensation2 = false;
    }
    this.sendFieldValue(sendVal);
  }

  handleComplaintSubRemedy2(event) {
    let sendVal = {
      field: "",
      value: ""
    };
    sendVal.field = "IDR_Complaint_Sub_Remedy_2__c";
    sendVal.value = event.detail.value;

    if (event.target.value === SUB_REMEDY_OTHER) {
      this.isOtherSubFinRemedy2 = true;
    } else {
      this.isOtherSubFinRemedy2 = false;
    }

    if (
      event.target.value === DEBT_WAIVER ||
      event.target.value === SETTEL_FOR_LESS
    ) {
      this.showFinancialCompensation2 = true;
    } else if (!this.isFinancialComplaintRemedy2) {
      this.showFinancialCompensation2 = false;
    }

    if (event.target.value === REWARD_POINTS) {
      this.isRewardPoints2 = true;
    } else {
      this.isRewardPoints2 = false;
    }

    if (
      event.target.value === MORATORIUM ||
      event.target.value === TIME_TO_SELL_REFINANCE_SURRENDER ||
      event.target.value === REPAYMENT_ARRAGMENT
    ) {
      this.showDuration2 = true;
    } else {
      this.showDuration2 = false;
    }

    this.sendFieldValue(sendVal);
  }

  handleFinancialCompensation2(event) {
    let sendVal = {
      field: "",
      value: ""
    };
    sendVal.field = "IDR_Financial_Compensation_2__c";
    sendVal.value = event.target.value;
    this.showFinancialCompensation2 = true;
    this.sendFieldValue(sendVal);
  }

  handleFinRemedyPoints2(event) {
    let sendVal = {
      field: "",
      value: ""
    };
    sendVal.field = "IDR_Financial_Remedy_Points_2__c";
    sendVal.value = event.detail.value;
    this.sendFieldValue(sendVal);
  }

  handleotherNonFinRemedy2(event) {
    let sendVal = {
      field: "",
      value: ""
    };
    sendVal.field = "IDR_Other_Remedy_Provided_2__c";
    sendVal.value = event.target.value;
    this.sendFieldValue(sendVal);
  }

  handleIsDetailsProvidedToProductManufacturer2(event) {
    let sendVal = {
      field: "",
      value: ""
    };
    sendVal.field = "Provided_details_to_Product_Manufacturer_2__c";
    sendVal.value = event.detail.checked;
    this.thirdPartyIsDetailsProvidedToProductManufacturer =
      event.detail.checked;
    this.sendFieldValue(sendVal);
  }

  handleremedyDuration2(event) {
    let sendVal = {
      field: "",
      value: ""
    };

    sendVal.field = "IDR_Duration_of_Remedy_2__c";
    sendVal.value = event.detail.value;
    this.sendFieldValue(sendVal);
  }

  clearRemedy2() {
    let sendVal = {
      field: "",
      value: ""
    };

    sendVal.field = "IDR_Complaint_Remedy_2__c";
    this.sendFieldValue(sendVal);
    sendVal.field = "IDR_Complaint_Sub_Remedy_2__c";
    this.sendFieldValue(sendVal);
    sendVal.field = "IDR_Financial_Compensation_2__c";
    this.sendFieldValue(sendVal);
    sendVal.field = "IDR_Financial_Remedy_Points_2__c";
    this.sendFieldValue(sendVal);
    sendVal.field = "IDR_Other_Remedy_Provided_2__c";
    this.sendFieldValue(sendVal);
    sendVal.field = "Provided_details_to_Product_Manufacturer_2__c";
    this.sendFieldValue(sendVal);
    sendVal.field = "IDR_Duration_of_Remedy_2__c";
    this.sendFieldValue(sendVal);
    sendVal.field = "Remedy2";
    sendVal.value = false;
    this.sendFieldValue(sendVal);
    if (this.showRemedy3) {
      this.showRemedy3 = false;
      this.clearRemedy3();
    }
  }
  // remedy 3

  handle3ndRemedyToggleChange(event) {
    this.showRemedy3 = event.target.checked;
    let sendVal = {
      field: "",
      value: ""
    };
    sendVal.field = "Remedy3";
    sendVal.value = event.target.checked;
    this.sendFieldValue(sendVal);
  }

  handleComplaintRemedy3(event) {
    let sendVal = {
      field: "",
      value: ""
    };
    sendVal.field = "IDR_Complaint_Remedy_3__c";
    sendVal.value = event.detail.value;
    if (event.detail.value === COMPLAINT_REMEDY_FIN_VALUE) {
      this.isFinancialComplaintRemedy3 = true;
      this.isNonFinancialComplaintRemedy3 = false;
      this.isReferredToProductManufacturer3 = false;
      this.showFinancialCompensation3 = true;
    } else if (event.detail.value === COMPLAINT_REMEDY_NON_FIN_VALUE) {
      this.isFinancialComplaintRemedy3 = false;
      this.isNonFinancialComplaintRemedy3 = true;
      this.isReferredToProductManufacturer3 = false;
      this.showFinancialCompensation3 = false;
    } else if (event.detail.value === COMPLAINT_REMDY_PRODUCT_MANU) {
      this.isFinancialComplaintRemedy3 = false;
      this.isNonFinancialComplaintRemedy3 = false;
      this.showFinancialCompensation3 = false;
      this.isReferredToProductManufacturer3 = true;
    } else {
      this.isFinancialComplaintRemedy3 = false;
      this.isNonFinancialComplaintRemedy3 = false;
      this.isReferredToProductManufacturer3 = false;
      this.showFinancialCompensation3 = false;
    }
    this.sendFieldValue(sendVal);
  }

  handleComplaintSubRemedy3(event) {
    let sendVal = {
      field: "",
      value: ""
    };
    sendVal.field = "IDR_Complaint_Sub_Remedy_3__c";
    sendVal.value = event.detail.value;

    if (event.target.value === SUB_REMEDY_OTHER) {
      this.isOtherSubFinRemedy3 = true;
    } else {
      this.isOtherSubFinRemedy3 = false;
    }

    if (
      event.target.value === DEBT_WAIVER ||
      event.target.value === SETTEL_FOR_LESS
    ) {
      this.showFinancialCompensation3 = true;
    } else if (!this.isFinancialComplaintRemedy3) {
      this.showFinancialCompensation3 = false;
    }

    if (event.target.value === REWARD_POINTS) {
      this.isRewardPoints3 = true;
    } else {
      this.isRewardPoints3 = false;
    }

    if (
      event.target.value === MORATORIUM ||
      event.target.value === TIME_TO_SELL_REFINANCE_SURRENDER ||
      event.target.value === REPAYMENT_ARRAGMENT
    ) {
      this.showDuration3 = true;
    } else {
      this.showDuration3 = false;
    }

    this.sendFieldValue(sendVal);
  }

  handleFinancialCompensation3(event) {
    let sendVal = {
      field: "",
      value: ""
    };
    sendVal.field = "IDR_Financial_Compensation_3__c";
    sendVal.value = event.target.value;
    this.showFinancialCompensation3 = true;
    this.sendFieldValue(sendVal);
  }

  handleFinRemedyPoints3(event) {
    let sendVal = {
      field: "",
      value: ""
    };
    sendVal.field = "IDR_Financial_Remedy_Points_3__c";
    sendVal.value = event.detail.value;
    this.sendFieldValue(sendVal);
  }

  handleotherNonFinRemedy3(event) {
    let sendVal = {
      field: "",
      value: ""
    };
    sendVal.field = "IDR_Other_Remedy_Provided_3__c";
    sendVal.value = event.target.value;
    this.sendFieldValue(sendVal);
  }

  handleIsDetailsProvidedToProductManufacturer3(event) {
    let sendVal = {
      field: "",
      value: ""
    };
    sendVal.field = "Provided_details_to_Product_Manufacturer_3__c";
    sendVal.value = event.detail.checked;
    this.thirdPartyIsDetailsProvidedToProductManufacturer3 =
      event.detail.checked;
    this.sendFieldValue(sendVal);
  }

  handleremedyDuration3(event) {
    let sendVal = {
      field: "",
      value: ""
    };

    sendVal.field = "IDR_Duration_of_Remedy_3__c";
    sendVal.value = event.detail.value;
    this.sendFieldValue(sendVal);
  }
  clearRemedy3() {
    let sendVal = {
      field: "",
      value: ""
    };

    sendVal.field = "IDR_Complaint_Remedy_3__c";
    this.sendFieldValue(sendVal);
    sendVal.field = "IDR_Complaint_Sub_Remedy_3__c";
    this.sendFieldValue(sendVal);
    sendVal.field = "IDR_Financial_Compensation_3__c";
    this.sendFieldValue(sendVal);
    sendVal.field = "IDR_Financial_Remedy_Points_3__c";
    this.sendFieldValue(sendVal);
    sendVal.field = "IDR_Other_Remedy_Provided_3__c";
    this.sendFieldValue(sendVal);
    sendVal.field = "Provided_details_to_Product_Manufacturer_3__c";
    this.sendFieldValue(sendVal);
    sendVal.field = "IDR_Duration_of_Remedy_3__c";
    this.sendFieldValue(sendVal);
    sendVal.field = "Remedy3";
    sendVal.value = false;
    this.sendFieldValue(sendVal);
  }

  sendFieldValue(sendVal) {
    this.dispatchEvent(
      new CustomEvent("fieldvalueupdate", { detail: sendVal })
    );
  }
}
