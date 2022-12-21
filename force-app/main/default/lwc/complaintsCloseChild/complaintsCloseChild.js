import { LightningElement, api, wire } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import { getRecord } from "lightning/uiRecordApi";
import CASE_OBJECT from "@salesforce/schema/Case";
import COMPLAINT_OUTCOME from "@salesforce/schema/Case.IDR_Complaint_Outcome__c";
import OUTCOME_DESCRIPTION from "@salesforce/schema/Case.IDR_Description_of_Outcome__c";
import STATUS_FIELD from "@salesforce/schema/Case.Status";
import REAL_FORM_REQUIRED_FIELD from "@salesforce/schema/Case.IDR_Real_Form_Req__c";
import REAL_FORM_REF_NUMBER_FIELD from "@salesforce/schema/Case.IDR_Real_Form_Ref_No__c";
import IS_COMMON_FIELD from "@salesforce/schema/Case.IDR_Is_Common__c";
import SYSTEMIC_ISSUE_DESCRIPTION from "@salesforce/schema/Case.IDR_Systemic_Issue_Description__c";
import SYSTEMIC_ISSUE_CATEGORY from "@salesforce/schema/Case.IDR_Systemic_Issue_Category__c";
import POSSIBLE_SYSTEMIC_ISSUES from "@salesforce/schema/Case.IDR_Possible_Systemic_Issues__c";

//Remedy1 fields
import COMPLAINT_REMEDY from "@salesforce/schema/Case.IDR_Complaint_Remedy__c";
import COMPLAINT_SUB_REMEDY from "@salesforce/schema/Case.IDR_Complaint_Sub_Remedy__c";
import REMEDY_POINTS1 from "@salesforce/schema/Case.IDR_Financial_Remedy_Points__c";
import OTHER_REMDY1 from "@salesforce/schema/Case.IDR_Other_Remedy_Provided__c";
import REMEDY_DURATION from "@salesforce/schema/Case.IDR_Duration_of_Remedy__c";
import FINANCIAL_COMPENSATION from "@salesforce/schema/Case.IDR_Financial_Compensation__c";
import THIRD_PARTY_IS_DETAILS_PROVIDED_TO_PRODUCT_MANUFACTURER from "@salesforce/schema/Case.Provided_details_to_Product_Manufacturer__c";

//Remedy 2 fields
import COMPLAINT_REMEDY2 from "@salesforce/schema/Case.IDR_Complaint_Remedy_2__c";
import COMPLAINT_SUB_REMEDY2 from "@salesforce/schema/Case.IDR_Complaint_Sub_Remedy_2__c";
import REMEDY_POINTS2 from "@salesforce/schema/Case.IDR_Financial_Remedy_Points_2__c";
import OTHER_REMDY2 from "@salesforce/schema/Case.IDR_Other_Remedy_Provided_2__c";
import REMEDY_DURATION2 from "@salesforce/schema/Case.IDR_Duration_of_Remedy_2__c";
import FINANCIAL_COMPENSATION2 from "@salesforce/schema/Case.IDR_Financial_Compensation_2__c";
import THIRD_PARTY_IS_DETAILS_PROVIDED_TO_PRODUCT_MANUFACTURER2 from "@salesforce/schema/Case.Provided_details_to_Prod_Manufacturer_2__c";

//Remedy 3 fields
import COMPLAINT_REMEDY3 from "@salesforce/schema/Case.IDR_Complaint_Remedy_3__c";
import COMPLAINT_SUB_REMEDY3 from "@salesforce/schema/Case.IDR_Complaint_Sub_Remedy_3__c";
import REMEDY_POINTS3 from "@salesforce/schema/Case.IDR_Financial_Remedy_Points_3__c";
import OTHER_REMDY3 from "@salesforce/schema/Case.IDR_Other_Remedy_Provided_3__c";
import REMEDY_DURATION3 from "@salesforce/schema/Case.IDR_Duration_of_Remedy_3__c";
import FINANCIAL_COMPENSATION3 from "@salesforce/schema/Case.IDR_Financial_Compensation_3__c";
import THIRD_PARTY_IS_DETAILS_PROVIDED_TO_PRODUCT_MANUFACTURER3 from "@salesforce/schema/Case.Provided_details_to_Prod_Manufacturer_3__c";

//Avoidable Escalation fields
import AVOIDABLE_ESCALATION from "@salesforce/schema/Case.IDR_Avoidable_Escalation__c";
import AVOIDABLE_ESCALATION_REASON from "@salesforce/schema/Case.IDR_Avoidable_Escalation_Reason__c";

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
const YES_VALUE = "Yes";

export default class complaintsResolveLWC extends NavigationMixin(
  LightningElement
) {
  systemicIssueDescriptionField = SYSTEMIC_ISSUE_DESCRIPTION;
  systemicIssueCategoryField = SYSTEMIC_ISSUE_CATEGORY;
  possibleSystemicIssuesField = POSSIBLE_SYSTEMIC_ISSUES;

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
  complaintRemedy2value = "";

  //remedy3
  complaintRemedy3 = COMPLAINT_REMEDY3;
  complaintSubRemedy3 = COMPLAINT_SUB_REMEDY3;
  remedyPoints3 = REMEDY_POINTS3;
  otherNonFinRemedy3 = OTHER_REMDY3;
  remedyDuration3 = REMEDY_DURATION3;

  //Avoidable Escalation
  avoidableEscalation = AVOIDABLE_ESCALATION;
  avoidableEscalationReason = AVOIDABLE_ESCALATION_REASON;

  showRemedy2 = false;
  showRemedy3 = false;
  showAvoidableEscalation = false;

  @api recordId;
  @api recordTypeId;
  @api systemicIssueDescriptionPublic;
  systemicIssueDescription;
  @api systemicIssueCategoryPublic;
  systemicIssueCategory;
  @api possibleSystemicIssuesPublic;
  possibleSystemicIssues;

  expressCaseCreationData;

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

  finRem1;
  finRem2;
  finRem3;
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
  pageRendered = false;

  remedy2Toggle = false;
  remedy3Toggle = false;

  prodManuCheckBox;
  prodManu2CheckBox;
  prodManu3CheckBox;

  dataChange = false;

  caseRemedyValue = "";
  caseRemedy2Value = "";
  caseRemedy3Value = "";

  subRemedyValue = "";
  subRemedy2Value = "";
  subRemedy3Value = "";

  remedyPointsValue = "";
  remedyPoints2Value = "";
  remedyPoints3Value = "";

  otherRemedyValue = "";
  otherRemedy2value = "";
  otherRemedy3value = "";

  remedyDurationValue = "";
  remedyDurationValue2 = "";
  remedyDurationValue3 = "";

  avoidableEscalationToggle = false;
  avoidableEscalationReasonValue = "";
  showAvoidableEscalationReason = false;

  @api
  isRealFormNeededPublic;
  isRealFormNeeded;

  @api
  realFormReqOptions;

  @api
  realFormRefNoPublic;
  realFormRefNo;

  @api
  isCommonComplaintYesNoPublic;
  isCommonComplaintYesNo;

  @api
  isCommonComplaintPublic;
  isCommonComplaint;

  @api
  commoncomplaintoptions;

  @api
  isRealFormSubmitted;

  @api
  hasSecondIssue;

  @api set expressCaseCreationDataObj(value) {
    this.dataChange = true;
    if (value !== undefined) {
      this.expressCaseCreationData = value.detail;
    } else {
      this.expressCaseCreationData = value;
    }

    if (
      this.pageRendered &
      (this.recordId === null || this.recordId === undefined)
    ) {
      this.pageLoadComplete = false;
      this.intializeExpressCaseCreationData();
    }
  }

  get radioStyle() {
    return this.recordId
      ? "slds-col slds-size_2-of-4 slds-m-right_large slds-p-top_medium"
      : "slds-col slds-grid slds-size_2-of-4 slds-p-right_large slds-p-top_medium";
  }

  get elementStyle() {
    return this.recordId
      ? "slds-col slds-size_2-of-4 slds-m-right_large slds-p-top_medium"
      : "slds-col slds-size_2-of-4 slds-p-right_large slds-p-top_medium";
  }

  get realFormRequiredValue() {
    return typeof this.isRealFormNeeded != "undefined" &&
      this.isRealFormNeeded != null &&
      this.isRealFormNeeded
      ? "Yes"
      : typeof this.isRealFormNeeded != "undefined" &&
        this.isRealFormNeeded != null &&
        !this.isRealFormNeeded
      ? "No"
      : null;
  }

  get expressCaseCreationDataObj() {
    return this.expressCaseCreationData;
  }

  get showAdditionalIssues() {
    return this.hasSecondIssue || this.recordId;
  }

  connectedCallback() {
    this.realFormRefNo = this.realFormRefNoPublic;
    this.isRealFormNeeded = this.isRealFormNeededPublic;
    this.isCommonComplaintYesNo = this.isCommonComplaintYesNoPublic;
    this.isCommonComplaint = this.isCommonComplaintPublic;
    this.systemicIssueCategory = this.systemicIssueCategoryPublic;
    this.systemicIssueDescription = this.systemicIssueDescriptionPublic;
    this.possibleSystemicIssues = this.possibleSystemicIssuesPublic;
  }

  @wire(getRecord, {
    recordId: "$recordId",
    fields: [
      STATUS_FIELD,
      REAL_FORM_REQUIRED_FIELD,
      REAL_FORM_REF_NUMBER_FIELD,
      IS_COMMON_FIELD,
      COMPLAINT_REMEDY,
      COMPLAINT_REMEDY2,
      COMPLAINT_REMEDY3,
      FINANCIAL_COMPENSATION,
      FINANCIAL_COMPENSATION2,
      FINANCIAL_COMPENSATION3,
      COMPLAINT_SUB_REMEDY,
      COMPLAINT_SUB_REMEDY2,
      COMPLAINT_SUB_REMEDY3,
      REMEDY_POINTS1,
      REMEDY_POINTS2,
      REMEDY_POINTS3,
      OTHER_REMDY1,
      OTHER_REMDY2,
      OTHER_REMDY3,
      REMEDY_DURATION,
      REMEDY_DURATION2,
      REMEDY_DURATION3,
      THIRD_PARTY_IS_DETAILS_PROVIDED_TO_PRODUCT_MANUFACTURER,
      THIRD_PARTY_IS_DETAILS_PROVIDED_TO_PRODUCT_MANUFACTURER2,
      THIRD_PARTY_IS_DETAILS_PROVIDED_TO_PRODUCT_MANUFACTURER3,
      AVOIDABLE_ESCALATION,
      AVOIDABLE_ESCALATION_REASON
    ]
  })
  wiredProject({ data }) {
    if (data) {
      this.isRealFormNeeded = data.fields.IDR_Real_Form_Req__c.value;
      if (this.recordId) {
        this.isRealFormNeeded = this.isRealFormNeeded ? true : false;
      }
      this.realFormRefNo = data.fields.IDR_Real_Form_Ref_No__c.value;
      this.isCommonComplaintYesNo = data.fields.IDR_Is_Common__c.value;
      this.isCommonComplaint = this.isCommonComplaintYesNo === YES_VALUE;
      this.caseRemedyValue = data.fields.IDR_Complaint_Remedy__c.value;
      this.caseRemedy2Value = data.fields.IDR_Complaint_Remedy_2__c.value;
      this.caseRemedy3Value = data.fields.IDR_Complaint_Remedy_3__c.value;

      this.subRemedyValue = data.fields.IDR_Complaint_Sub_Remedy__c.value;
      this.subRemedy2Value = data.fields.IDR_Complaint_Sub_Remedy_2__c.value;
      this.subRemedy3Value = data.fields.IDR_Complaint_Sub_Remedy_3__c.value;

      this.finRem1 = data.fields.IDR_Financial_Compensation__c.value;
      this.finRem2 = data.fields.IDR_Financial_Compensation_2__c.value;
      this.finRem3 = data.fields.IDR_Financial_Compensation_3__c.value;

      this.prodManuCheckBox =
        data.fields.Provided_details_to_Product_Manufacturer__c.value;
      this.prodManu2CheckBox =
        data.fields.Provided_details_to_Prod_Manufacturer_2__c.value;
      this.prodManu3CheckBox =
        data.fields.Provided_details_to_Prod_Manufacturer_3__c.value;

      this.remedyPointsValue = data.fields.IDR_Financial_Remedy_Points__c.value;
      this.remedyPoints2Value =
        data.fields.IDR_Financial_Remedy_Points_2__c.value;
      this.remedyPoints3Value =
        data.fields.IDR_Financial_Remedy_Points_3__c.value;

      this.otherRemedyValue = data.fields.IDR_Other_Remedy_Provided__c.value;
      this.otherRemedy2value = data.fields.IDR_Other_Remedy_Provided_2__c.value;
      this.otherRemedy3value = data.fields.IDR_Other_Remedy_Provided_3__c.value;

      this.remedyDurationValue = data.fields.IDR_Duration_of_Remedy__c.value;
      this.remedyDurationValue2 = data.fields.IDR_Duration_of_Remedy_2__c.value;
      this.remedyDurationValue3 = data.fields.IDR_Duration_of_Remedy_3__c.value;

      this.avoidableEscalationToggle =
        data.fields.IDR_Avoidable_Escalation__c.value;
      this.avoidableEscalationReasonValue =
        data.fields.IDR_Avoidable_Escalation_Reason__c.value;

      switch (this.caseRemedyValue) {
        case COMPLAINT_REMEDY_FIN_VALUE:
          this.showFinancialCompensation = true;
          break;
        case COMPLAINT_REMEDY_NON_FIN_VALUE:
          this.isNonFinancialComplaintRemedy = true;
          break;
        case COMPLAINT_REMDY_PRODUCT_MANU:
          this.isReferredToProductManufacturer = true;
          break;
        default:
      }

      switch (this.subRemedyValue) {
        case SUB_REMEDY_OTHER:
          this.isOtherSubFinRemedy = true;
          break;
        case REWARD_POINTS:
          this.isRewardPoints = true;
          break;
        case DEBT_WAIVER:
          this.showFinancialCompensation = true;
          break;
        case SETTEL_FOR_LESS:
          this.showFinancialCompensation = true;
          break;
        case MORATORIUM:
          this.showDuration = true;
          break;
        case REPAYMENT_ARRAGMENT:
          this.showDuration = true;
          break;
        case TIME_TO_SELL_REFINANCE_SURRENDER:
          this.showDuration = true;
          break;
        default:
      }

      if (this.caseRemedy2Value !== null) {
        this.remedy2Toggle = true;
        this.showRemedy2 = true;
      }

      switch (this.caseRemedy2Value) {
        case COMPLAINT_REMEDY_FIN_VALUE:
          this.showFinancialCompensation2 = true;
          break;
        case COMPLAINT_REMEDY_NON_FIN_VALUE:
          this.isNonFinancialComplaintRemedy2 = true;
          break;
        case COMPLAINT_REMDY_PRODUCT_MANU:
          this.isReferredToProductManufacturer2 = true;
          break;
        default:
      }

      switch (this.subRemedy2Value) {
        case SUB_REMEDY_OTHER:
          this.isOtherSubFinRemedy2 = true;
          break;
        case REWARD_POINTS:
          this.isRewardPoints2 = true;
          break;
        case DEBT_WAIVER:
          this.showFinancialCompensation2 = true;
          break;
        case SETTEL_FOR_LESS:
          this.showFinancialCompensation2 = true;
          break;
        case MORATORIUM:
          this.showDuration2 = true;
          break;
        case REPAYMENT_ARRAGMENT:
          this.showDuration2 = true;
          break;
        case TIME_TO_SELL_REFINANCE_SURRENDER:
          this.showDuration2 = true;
          break;
        default:
      }

      if (this.caseRemedy3Value !== null) {
        this.remedy3Toggle = true;
        this.showRemedy3 = true;
      }
      switch (this.caseRemedy3Value) {
        case COMPLAINT_REMEDY_FIN_VALUE:
          this.showFinancialCompensation3 = true;
          break;
        case COMPLAINT_REMEDY_NON_FIN_VALUE:
          this.isNonFinancialComplaintRemedy3 = true;
          break;
        case COMPLAINT_REMDY_PRODUCT_MANU:
          this.isReferredToProductManufacturer3 = true;
          break;
        default:
      }
      switch (this.subRemedy3Value) {
        case SUB_REMEDY_OTHER:
          this.isOtherSubFinRemedy3 = true;
          break;
        case REWARD_POINTS:
          this.isRewardPoints3 = true;
          break;
        case DEBT_WAIVER:
          this.showFinancialCompensation3 = true;
          break;
        case SETTEL_FOR_LESS:
          this.showFinancialCompensation3 = true;
          break;
        case MORATORIUM:
          this.showDuration3 = true;
          break;
        case REPAYMENT_ARRAGMENT:
          this.showDuration3 = true;
          break;
        case TIME_TO_SELL_REFINANCE_SURRENDER:
          this.showDuration3 = true;
          break;
        default:
      }

      if (data.fields.Status.value === "Escalated") {
        this.showAvoidableEscalation = true;
        if (this.avoidableEscalationToggle === true) {
          this.showAvoidableEscalationReason = true;
        }
      }
    }
  }

  //initialize components
  renderedCallback() {
    this.pageRendered = true;
    this.intializeExpressCaseCreationData();
  }

  intializeExpressCaseCreationData() {
    if (
      !this.pageLoadComplete &
      (this.recordId === null || this.recordId === undefined)
    ) {
      if (this.dataChange === true) {
        this.dataChange = "false";
        this.knownIssueChangeHandler();
      } else {
        this.knownIssueChangeHandlerNF();
      }
    }
  }
  knownIssueChangeHandler() {
    this.pageLoadComplete = true;
    const complaintOutcomeElement = this.template.querySelector(
      '[data-id="compOutCome-id"]'
    );

    if (complaintOutcomeElement !== null) {
      complaintOutcomeElement.reset();
      complaintOutcomeElement.value =
        this.expressCaseCreationData === undefined
          ? ""
          : this.expressCaseCreationData.IDR_Complaint_Outcome__c;
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
      descOfOutcomeElement.reset();
      descOfOutcomeElement.value =
        this.expressCaseCreationData === undefined
          ? ""
          : this.expressCaseCreationData.IDR_Description_of_Outcome__c;
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
      complaintRemedyElement.reset();

      //clear sub remedy to handle remedy change
      let sendVal = {
        field: "",
        value: ""
      };

      sendVal.field = "IDR_Complaint_Sub_Remedy__c";
      sendVal.value = "";

      this.sendFieldValue(sendVal);

      complaintRemedyElement.value =
        this.expressCaseCreationData === undefined
          ? ""
          : this.expressCaseCreationData.IDR_Complaint_Remedy__c;
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
          : this.expressCaseCreationData.IDR_Non_Financial_Remedy__c;

      nonFinancialRemedyElement.dispatchEvent(
        new CustomEvent("change", {
          detail: { value: nonFinancialRemedyElement.value }
        })
      );
    }
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

    if (event.detail.value === COMPLAINT_REMEDY_FIN_VALUE) {
      this.isFinancialComplaintRemedy = true;
      this.showFinancialCompensation = true;
      this.isNonFinancialComplaintRemedy = false;
      this.isReferredToProductManufacturer = false;
    } else if (event.detail.value === COMPLAINT_REMEDY_NON_FIN_VALUE) {
      if (this.expressCaseCreationData) {
        this.pageLoadComplete = false;
      }
      if (this.isFinancialComplaintRemedy) {
        this.isFinancialComplaintRemedy = false;
        this.showFinancialCompensation = false;
        sendVal.field = "IDR_Financial_Compensation__c";
        sendVal.value = "";
        this.sendFieldValue(sendVal);
      }
      this.isNonFinancialComplaintRemedy = true;
      this.isReferredToProductManufacturer = false;
    } else if (event.detail.value === COMPLAINT_REMDY_PRODUCT_MANU) {
      if (this.isFinancialComplaintRemedy) {
        this.isFinancialComplaintRemedy = false;
        this.showFinancialCompensation = false;
        sendVal.field = "IDR_Financial_Compensation__c";
        sendVal.value = "";
        this.sendFieldValue(sendVal);
      }
      this.isNonFinancialComplaintRemedy = false;
      this.isReferredToProductManufacturer = true;
    } else {
      if (this.isFinancialComplaintRemedy) {
        this.isFinancialComplaintRemedy = false;
        this.showFinancialCompensation = false;
        sendVal.field = "IDR_Financial_Compensation__c";
        sendVal.value = "";
        this.sendFieldValue(sendVal);
      }
      this.isNonFinancialComplaintRemedy = false;
      this.isReferredToProductManufacturer = false;
    }

    sendVal.field = "IDR_Complaint_Remedy__c";
    sendVal.value = event.detail.value;
    this.caseRemedyValue = event.detail.value;
    this.sendFieldValue(sendVal);
  }

  handleComplaintSubRemedy(event) {
    let sendVal = {
      field: "",
      value: ""
    };

    if (event.target.value === SUB_REMEDY_OTHER) {
      this.isOtherSubFinRemedy = true;
    } else {
      this.isOtherSubFinRemedy = false;
      sendVal.field = "IDR_Other_Remedy_Provided__c";
      sendVal.value = "";
      this.sendFieldValue(sendVal);
    }

    if (
      event.target.value === DEBT_WAIVER ||
      event.target.value === SETTEL_FOR_LESS
    ) {
      this.showFinancialCompensation = true;
    } else if (!this.isFinancialComplaintRemedy) {
      this.showFinancialCompensation = false;
      sendVal.field = "IDR_Financial_Compensation___c";
      sendVal.value = "";
      this.sendFieldValue(sendVal);
    }

    if (event.target.value === REWARD_POINTS) {
      this.isRewardPoints = true;
    } else if (this.isRewardPoints) {
      this.isRewardPoints = false;
      sendVal.field = "IDR_Financial_Remedy_Points__c";
      sendVal.value = "";
      this.sendFieldValue(sendVal);
    }

    if (
      event.target.value === MORATORIUM ||
      event.target.value === TIME_TO_SELL_REFINANCE_SURRENDER ||
      event.target.value === REPAYMENT_ARRAGMENT
    ) {
      this.showDuration = true;
    } else if (this.showDuration) {
      this.showDuration = false;
      sendVal.field = "IDR_Duration_of_Remedy__c";
      sendVal.value = "";
      this.sendFieldValue(sendVal);
    }
    sendVal.field = "IDR_Complaint_Sub_Remedy__c";
    sendVal.value = event.detail.value;
    this.subRemedyValue = event.detail.value;

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
    this.finRem1 = event.target.value;
    this.sendFieldValue(sendVal);
  }

  handleRealFormNeeded(event) {
    if (event.detail.value !== YES_VALUE) {
      this.isRealFormNeeded = false;
    } else {
      this.isRealFormNeeded = true;
    }
    let realFormNeededInput = this.template.querySelector(
      "[data-id='realFormRequiredGroup-id']"
    );
    if (
      typeof this.isRealFormNeeded === "undefined" ||
      this.isRealFormNeeded === null
    ) {
      realFormNeededInput.setCustomValidity("Complete this field.");
    } else {
      realFormNeededInput.setCustomValidity("");
    }
    realFormNeededInput.reportValidity();
    this.dispatchEvent(
      new CustomEvent("handlerealformneeded", { detail: event.detail.value })
    );
  }

  handleRealFormRefNoChange(event) {
    this.realFormRefNo = event.detail.value;
    let realFormRefInput = this.template.querySelector(
      "[data-id='realFormRefNoGroup-id']"
    );
    if (!this.realFormRefNo) {
      realFormRefInput.setCustomValidity("Complete this field.");
    } else {
      realFormRefInput.setCustomValidity("");
    }
    realFormRefInput.reportValidity();
    this.dispatchEvent(
      new CustomEvent("handlerealformrefnochange", {
        detail: event.detail.value
      })
    );
  }

  handleCommonComplaint(event) {
    this.isCommonComplaintYesNo = event.target.value;
    this.isCommonComplaint =
      this.isCommonComplaintYesNo === "Yes" ? true : false;
    let possibleSysIssueInput = this.template.querySelector(
      "[data-id='commoncomplaintGroup-id']"
    );
    if (
      typeof this.isCommonComplaint === "undefined" ||
      this.isCommonComplaint === null
    ) {
      possibleSysIssueInput.setCustomValidity("Complete this field.");
    } else {
      possibleSysIssueInput.setCustomValidity("");
    }
    possibleSysIssueInput.reportValidity();
    this.dispatchEvent(
      new CustomEvent("handlecommoncomplaint", { detail: event.detail.value })
    );
  }

  handleFinRemedyPoints(event) {
    let sendVal = {
      field: "",
      value: ""
    };
    sendVal.field = "IDR_Financial_Remedy_Points__c";
    sendVal.value = event.detail.value;
    this.remedyPointsValue = event.detail.value;
    this.sendFieldValue(sendVal);
  }

  handleotherNonFinRemedy(event) {
    let sendVal = {
      field: "",
      value: ""
    };
    sendVal.field = "IDR_Other_Remedy_Provided__c";
    sendVal.value = event.target.value;
    this.otherRemedyValue = event.target.value;
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
    this.remedyDurationValue = event.detail.value;
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
    this.clearRemedy2();
    if (event.detail.value === COMPLAINT_REMEDY_FIN_VALUE) {
      this.isFinancialComplaintRemedy2 = true;
      this.isNonFinancialComplaintRemedy2 = false;
      this.isReferredToProductManufacturer2 = false;
      this.showFinancialCompensation2 = true;
    } else if (event.detail.value === COMPLAINT_REMEDY_NON_FIN_VALUE) {
      if (this.isFinancialComplaintRemedy2) {
        this.isFinancialComplaintRemedy2 = false;
        this.showFinancialCompensation2 = false;
        sendVal.field = "IDR_Financial_Compensation_2___c";
        sendVal.value = "";
        this.sendFieldValue(sendVal);
      }
      this.isNonFinancialComplaintRemedy2 = true;
      this.isReferredToProductManufacturer2 = false;
    } else if (event.detail.value === COMPLAINT_REMDY_PRODUCT_MANU) {
      if (this.isFinancialComplaintRemedy2) {
        this.isFinancialComplaintRemedy2 = false;
        this.showFinancialCompensation2 = false;
        sendVal.field = "IDR_Financial_Compensation_2___c";
        sendVal.value = "";
        this.sendFieldValue(sendVal);
      }
      this.isNonFinancialComplaintRemedy2 = false;
      this.isReferredToProductManufacturer2 = true;
    } else {
      if (this.isFinancialComplaintRemedy2) {
        this.isFinancialComplaintRemedy2 = false;
        this.showFinancialCompensation2 = false;
        sendVal.field = "IDR_Financial_Compensation_2___c";
        sendVal.value = "";
        this.sendFieldValue(sendVal);
      }
      this.isNonFinancialComplaintRemedy2 = false;
      this.isReferredToProductManufacturer2 = false;
    }
    sendVal.field = "IDR_Complaint_Remedy_2__c";
    sendVal.value = event.detail.value;
    this.caseRemedy2Value = event.detail.value;
    this.sendFieldValue(sendVal);
  }

  handleComplaintSubRemedy2(event) {
    let sendVal = {
      field: "",
      value: ""
    };

    if (event.target.value === SUB_REMEDY_OTHER) {
      this.isOtherSubFinRemedy2 = true;
    } else {
      this.isOtherSubFinRemedy2 = false;
      sendVal.field = "IDR_Other_Remedy_Provided_2__c";
      sendVal.value = "";
      this.sendFieldValue(sendVal);
    }

    if (
      event.target.value === DEBT_WAIVER ||
      event.target.value === SETTEL_FOR_LESS
    ) {
      this.showFinancialCompensation2 = true;
    } else if (!this.isFinancialComplaintRemedy2) {
      this.showFinancialCompensation2 = false;
      sendVal.field = "IDR_Financial_Compensation_2___c";
      sendVal.value = "";
      this.sendFieldValue(sendVal);
    }

    if (event.target.value === REWARD_POINTS) {
      this.isRewardPoints2 = true;
    } else if (this.isRewardPoints2) {
      this.isRewardPoints2 = false;
      sendVal.field = "IDR_Financial_Remedy_Points_2__c";
      sendVal.value = "";
      this.sendFieldValue(sendVal);
    }

    if (
      event.target.value === MORATORIUM ||
      event.target.value === TIME_TO_SELL_REFINANCE_SURRENDER ||
      event.target.value === REPAYMENT_ARRAGMENT
    ) {
      this.showDuration2 = true;
    } else if (this.showDuration2) {
      this.showDuration2 = false;
      sendVal.field = "IDR_Duration_of_Remedy_2__c";
      sendVal.value = "";
      this.sendFieldValue(sendVal);
    }

    sendVal.field = "IDR_Complaint_Sub_Remedy_2__c";
    sendVal.value = event.detail.value;
    this.subRemedy2Value = event.detail.value;
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
    this.finRem2 = event.target.value;
    this.sendFieldValue(sendVal);
  }

  handleFinRemedyPoints2(event) {
    let sendVal = {
      field: "",
      value: ""
    };
    sendVal.field = "IDR_Financial_Remedy_Points_2__c";
    sendVal.value = event.detail.value;
    this.remedyPoints2Value = event.detail.value;
    this.sendFieldValue(sendVal);
  }

  handleotherNonFinRemedy2(event) {
    let sendVal = {
      field: "",
      value: ""
    };
    sendVal.field = "IDR_Other_Remedy_Provided_2__c";
    sendVal.value = event.target.value;
    this.otherRemedy2value = event.target.value;
    this.sendFieldValue(sendVal);
  }

  handleIsDetailsProvidedToProductManufacturer2(event) {
    let sendVal = {
      field: "",
      value: ""
    };
    sendVal.field = "Provided_details_to_Prod_Manufacturer_2__c";
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
    this.remedyDurationValue2 = event.detail.value;
    this.sendFieldValue(sendVal);
  }

  clearRemedy2() {
    let sendVal = {
      field: "",
      value: ""
    };

    this.caseRemedy2Value = "";
    this.subRemedy2Value = "";
    this.finRem2 = "";
    this.prodManu2CheckBox = false;
    this.remedyPoints2Value = "";
    this.otherRemedy2value = "";
    this.remedyDurationValue2 = "";

    this.isOtherSubFinRemedy2 = false;
    this.showFinancialCompensation2 = false;
    this.isRewardPoints2 = false;
    this.showDuration2 = false;

    this.remedy2Toggle = false;
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
    sendVal.field = "IDR_Duration_of_Remedy_2__c";
    this.sendFieldValue(sendVal);
    sendVal.field = "Provided_details_to_Prod_Manufacturer_2__c";
    sendVal.value = false;
    this.sendFieldValue(sendVal);
    if (this.showRemedy3 & !this.showRemedy2) {
      this.showRemedy3 = false;
      sendVal.field = "Remedy3";
      sendVal.value = false;
      this.sendFieldValue(sendVal);
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
    if (!event.target.checked) {
      this.clearRemedy3();
    }
  }

  handleComplaintRemedy3(event) {
    let sendVal = {
      field: "",
      value: ""
    };
    this.clearRemedy3();
    if (event.detail.value === COMPLAINT_REMEDY_FIN_VALUE) {
      this.isFinancialComplaintRemedy3 = true;
      this.isNonFinancialComplaintRemedy3 = false;
      this.isReferredToProductManufacturer3 = false;
      this.showFinancialCompensation3 = true;
    } else if (event.detail.value === COMPLAINT_REMEDY_NON_FIN_VALUE) {
      if (this.isFinancialComplaintRemedy3) {
        this.isFinancialComplaintRemedy3 = false;
        this.showFinancialCompensation3 = false;
        sendVal.field = "IDR_Financial_Compensation_3___c";
        sendVal.value = "";
        this.sendFieldValue(sendVal);
      }
      this.isNonFinancialComplaintRemedy3 = true;
      this.isReferredToProductManufacturer3 = false;
    } else if (event.detail.value === COMPLAINT_REMDY_PRODUCT_MANU) {
      if (this.isFinancialComplaintRemedy3) {
        this.isFinancialComplaintRemedy3 = false;
        this.showFinancialCompensation3 = false;
        sendVal.field = "IDR_Financial_Compensation_3___c";
        sendVal.value = "";
        this.sendFieldValue(sendVal);
      }
      this.isNonFinancialComplaintRemedy3 = false;
      this.isReferredToProductManufacturer3 = true;
    } else {
      if (this.isFinancialComplaintRemedy3) {
        this.isFinancialComplaintRemedy3 = false;
        this.showFinancialCompensation3 = false;
        sendVal.field = "IDR_Financial_Compensation_3___c";
        sendVal.value = "";
        this.sendFieldValue(sendVal);
      }
      this.isNonFinancialComplaintRemedy3 = false;
      this.isReferredToProductManufacturer3 = false;
    }
    sendVal.field = "IDR_Complaint_Remedy_3__c";
    sendVal.value = event.detail.value;
    this.caseRemedy3Value = event.detail.value;
    this.sendFieldValue(sendVal);
  }

  handleComplaintSubRemedy3(event) {
    let sendVal = {
      field: "",
      value: ""
    };

    if (event.target.value === SUB_REMEDY_OTHER) {
      this.isOtherSubFinRemedy3 = true;
    } else {
      this.isOtherSubFinRemedy3 = false;
      sendVal.field = "IDR_Other_Remedy_Provided_3__c";
      sendVal.value = "";
      this.sendFieldValue(sendVal);
    }

    if (
      event.target.value === DEBT_WAIVER ||
      event.target.value === SETTEL_FOR_LESS
    ) {
      this.showFinancialCompensation3 = true;
    } else if (!this.isFinancialComplaintRemedy3) {
      this.showFinancialCompensation3 = false;
      sendVal.field = "IDR_Financial_Compensation_3__c";
      sendVal.value = "";
      this.sendFieldValue(sendVal);
    }

    if (event.target.value === REWARD_POINTS) {
      this.isRewardPoints3 = true;
    } else if (this.isRewardPoints3) {
      this.isRewardPoints3 = false;
      sendVal.field = "IDR_Financial_Remedy_Points_3__c";
      sendVal.value = "";
      this.sendFieldValue(sendVal);
    }

    if (
      event.target.value === MORATORIUM ||
      event.target.value === TIME_TO_SELL_REFINANCE_SURRENDER ||
      event.target.value === REPAYMENT_ARRAGMENT
    ) {
      this.showDuration3 = true;
    } else if (this.showDuration3) {
      this.showDuration3 = false;
      sendVal.field = "IDR_Duration_of_Remedy_3__c";
      sendVal.value = event.detail.value;
      this.sendFieldValue(sendVal);
    }

    sendVal.field = "IDR_Complaint_Sub_Remedy_3__c";
    sendVal.value = event.detail.value;
    this.subRemedy3Value = event.detail.value;

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
    this.finRem3 = event.target.value;
    this.sendFieldValue(sendVal);
  }

  handleFinRemedyPoints3(event) {
    let sendVal = {
      field: "",
      value: ""
    };
    sendVal.field = "IDR_Financial_Remedy_Points_3__c";
    sendVal.value = event.detail.value;
    this.remedyPoints3Value = event.detail.value;

    this.sendFieldValue(sendVal);
  }

  handleotherNonFinRemedy3(event) {
    let sendVal = {
      field: "",
      value: ""
    };
    sendVal.field = "IDR_Other_Remedy_Provided_3__c";
    sendVal.value = event.target.value;

    this.otherRemedy3value = event.target.value;
    this.sendFieldValue(sendVal);
  }

  handleIsDetailsProvidedToProductManufacturer3(event) {
    let sendVal = {
      field: "",
      value: ""
    };
    sendVal.field = "Provided_details_to_Prod_Manufacturer_3__c";
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
    this.remedyDurationValue3 = event.detail.value;

    this.sendFieldValue(sendVal);
  }
  clearRemedy3() {
    let sendVal = {
      field: "",
      value: ""
    };

    this.caseRemedy3Value = "";
    this.subRemedy3Value = "";
    this.finRem3 = "";
    this.prodManu3CheckBox = false;
    this.remedyPoints3Value = "";
    this.otherRemedy3value = "";
    this.remedyDurationValue3 = "";

    this.isOtherSubFinRemedy3 = false;
    this.showFinancialCompensation3 = false;
    this.isRewardPoints3 = false;
    this.showDuration3 = false;

    this.remedy3Toggle = false;
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
    sendVal.field = "IDR_Duration_of_Remedy_3__c";
    this.sendFieldValue(sendVal);
    sendVal.field = "Provided_details_to_Prod_Manufacturer_3__c";
    sendVal.value = false;
    this.sendFieldValue(sendVal);
  }

  handleAvoidableEscalation(event) {
    let sendVal = {
      field: "",
      value: ""
    };

    sendVal.field = "IDR_Avoidable_Escalation__c";
    sendVal.value = event.detail.checked;
    this.avoidableEscalationToggle = event.detail.checked;
    this.showAvoidableEscalationReason = event.detail.checked;

    this.updateAvoidableEscalationReason();

    this.sendFieldValue(sendVal);
  }

  updateAvoidableEscalationReason() {
    let sendVal = {
      field: "",
      value: ""
    };

    sendVal.field = "IDR_Avoidable_Escalation_Reason__c";

    if (
      this.showAvoidableEscalationReason === false ||
      !this.avoidableEscalationReasonValue
    ) {
      sendVal.value = "";
    } else {
      sendVal.value = this.avoidableEscalationReasonValue;
    }

    this.sendFieldValue(sendVal);
  }

  handleAvoidableEscalationReason(event) {
    let sendVal = {
      field: "",
      value: ""
    };

    sendVal.field = "IDR_Avoidable_Escalation_Reason__c";
    sendVal.value = event.detail.value;
    this.avoidableEscalationReasonValue = event.detail.value;

    this.sendFieldValue(sendVal);
  }

  handleSystemicIssueDescriptionChange(event) {
    this.systemicIssueDescription = event.detail.value;
    this.dispatchEvent(
      new CustomEvent("systemicissuedescriptionchange", {
        detail: event.detail.value
      })
    );
  }

  handleSystemicIssueCategoryChange(event) {
    this.systemicIssueCategory = event.detail.value;
    this.dispatchEvent(
      new CustomEvent("systemicissuecategorychange", {
        detail: event.detail.value
      })
    );
  }

  handlePossibleSystemicIssuesChange(event) {
    this.possibleSystemicIssues = event.detail.value;
    this.dispatchEvent(
      new CustomEvent("possiblesystemicissueschange", {
        detail: event.detail.value
      })
    );
  }

  sendFieldValue(sendVal) {
    this.dispatchEvent(
      new CustomEvent("fieldvalueupdate", { detail: sendVal })
    );
  }

  @api
  validateFields() {
    let realFormNeededInput = this.template.querySelector(
      "[data-id='realFormRequiredGroup-id']"
    );
    if (
      typeof this.isRealFormNeeded === "undefined" ||
      this.isRealFormNeeded === null
    ) {
      realFormNeededInput.setCustomValidity("Complete this field.");
    } else {
      realFormNeededInput.setCustomValidity("");
    }
    realFormNeededInput.reportValidity();
    if (this.isRealFormNeeded) {
      let realFormRefInput = this.template.querySelector(
        "[data-id='realFormRefNoGroup-id']"
      );
      if (!this.realFormRefNo) {
        realFormRefInput.setCustomValidity("Complete this field.");
      } else {
        realFormRefInput.setCustomValidity("");
      }
      realFormRefInput.reportValidity();
    }
    let possibleSysIssueInput = this.template.querySelector(
      "[data-id='commoncomplaintGroup-id']"
    );
    if (
      typeof this.isCommonComplaint === "undefined" ||
      this.isCommonComplaint === null
    ) {
      possibleSysIssueInput.setCustomValidity("Complete this field.");
    } else {
      possibleSysIssueInput.setCustomValidity("");
    }
    possibleSysIssueInput.reportValidity();
    this.template
      .querySelectorAll("lightning-input-field")
      .forEach((element) => {
        element.reportValidity();
      });
  }
}
