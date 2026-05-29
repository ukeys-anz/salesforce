import { OmniscriptBaseMixin } from "omnistudio/omniscriptBaseMixin";
import { api, LightningElement, wire, track } from "lwc";
import { getPicklistValuesByRecordType } from "lightning/uiObjectInfoApi";
import COMPLAINT_RESOLUTION_OBJECT from "@salesforce/schema/Complaint_Resolution__c";
import AWARENESS_TRIGGER_FIELD from "@salesforce/schema/Complaint_Resolution__c.Awareness_Trigger__c";
import SCAM_REIMBURSEMENT_TRIGGER_FIELD from "@salesforce/schema/Complaint_Resolution__c.Scam_Reimbursement_Trigger__c";
import NON_FINANCIAL_REMEDY from "@salesforce/schema/Complaint_Resolution__c.Non_Financial_Loss_Trigger__c";
import { handleErrorShowToast } from "c/utils";
const SCAM = "Scam";
const SRF_AWARENESS_TRIGGER = "SRF Awareness Trigger";
const EPAYMENTS_CODE = "ePayments Code";

export default class ScamAssistFields extends OmniscriptBaseMixin(
  LightningElement
) {
  @track _omniData;
  scamIdShowClass;
  awarenessTriggerOptions = [];
  scamOptions = [];
  nonFinancialOptions = [];
  showScamReimbursementClass = "slds-hide";
  showAwarenessTriggerClass = "slds-hide";
  showNonFinLossTriggerClass = "slds-hide";
  selectedScamValue;
  selectedAwarenessValues = [];
  selectedNonFinLossValues = [];

  @api set omniJsonData(data) {
    this._omniData = data;
    this.setScamFieldsOnLoad(this._omniData);
    if (!this._omniData || !this._omniData.Case) {
      handleErrorShowToast(
        this,
        "Error",
        undefined,
        "No Case data found. Please contact your System Administrator."
      );
      return;
    }
    if (!this.checkIssueTypeScam(this._omniData)) {
      this.showScamReimbursementClass = "slds-hide";
      this.showNonFinLossTriggerClass = "slds-hide";
      this.showAwarenessTriggerClass = "slds-hide";
      return;
    }
    this.scamIdShowClass = "slds-show";
    if (
      this.checkIssueTypeScam(this._omniData) &&
      this.checkSubRemedyFinancial(this._omniData)
    ) {
      this.showScamReimbursementClass = "slds-show";
      this.showNonFinLossTriggerClass = "slds-hide";
      this.showAwarenessTriggerClass =
        this.selectedScamValue === SRF_AWARENESS_TRIGGER
          ? "slds-show"
          : "slds-hide";
    } else if (
      this.checkIssueTypeScam(this._omniData) &&
      this.checkSubRemedyNonFinancial(this._omniData)
    ) {
      this.showScamReimbursementClass = "slds-hide";
      this.showNonFinLossTriggerClass = "slds-show";
      this.showAwarenessTriggerClass = "slds-hide";
    } else {
      this.showScamReimbursementClass = "slds-hide";
      this.showNonFinLossTriggerClass = "slds-hide";
      this.showAwarenessTriggerClass = "slds-hide";
    }
  }

  get omniJsonData() {
    return this._omniData;
  }

  @wire(getPicklistValuesByRecordType, {
    objectApiName: COMPLAINT_RESOLUTION_OBJECT,
    recordTypeId: "012000000000000AAA"
  })
  wiredPicklistValues({ error, data }) {
    if (data) {
      const awpicklistValues =
        data.picklistFieldValues[AWARENESS_TRIGGER_FIELD.fieldApiName];
      const scamPicklistValues =
        data.picklistFieldValues[SCAM_REIMBURSEMENT_TRIGGER_FIELD.fieldApiName];
      const nonFinancialPicklistValues =
        data.picklistFieldValues[NON_FINANCIAL_REMEDY.fieldApiName];

      this.awarenessTriggerOptions = awpicklistValues.values.map((item) => ({
        label: item.label,
        value: item.value
      }));
      this.scamOptions = scamPicklistValues.values.map((item) => ({
        label: item.label,
        value: item.value
      }));
      this.nonFinancialOptions = nonFinancialPicklistValues.values.map(
        (item) => ({
          label: item.label,
          value: item.value
        })
      );
    } else if (error) {
      handleErrorShowToast(
        this,
        "Error loading picklist values",
        undefined,
        error.body.message
      );
    }
  }

  handleScamReimbursementChange(event) {
    let scamNode = this.omniJsonDef?.name + "scamOption";
    let awarenessNode = this.omniJsonDef?.name + "awarenessOption";
    this.selectedScamValue = event.detail.value;
    if (this.selectedScamValue === SRF_AWARENESS_TRIGGER) {
      this.showAwarenessTriggerClass = "slds-show";
      this.omniApplyCallResp({
        Case: {
          [scamNode]: this.selectedScamValue,
          [awarenessNode]: null
        }
      });
    } else if (this.selectedScamValue === EPAYMENTS_CODE) {
      this.showAwarenessTriggerClass = "slds-hide";
      this.selectedAwarenessValues = [];
      this.omniApplyCallResp({
        Case: {
          [scamNode]: this.selectedScamValue,
          [awarenessNode]: null
        }
      });
    }
  }

  handleAwarenessTriggerChange(event) {
    this.selectedAwarenessValues = event.detail.value;
    let awarenessNode = this.omniJsonDef?.name + "awarenessOption";
    let nonFinancialNode = this.omniJsonDef?.name + "nonFinancialOption";
    this.omniApplyCallResp({
      Case: {
        [awarenessNode]: this.selectedAwarenessValues.join(";"),
        [nonFinancialNode]: null
      }
    });
  }

  handleNonFinLossTriggerChange(event) {
    this.selectedNonFinLossValues = event.detail.value;
    this.selectedAwarenessValues = [];
    let awarenessNode = this.omniJsonDef?.name + "awarenessOption";
    let nonFinancialNode = this.omniJsonDef?.name + "nonFinancialOption";
    this.omniApplyCallResp({
      Case: {
        [nonFinancialNode]: this.selectedNonFinLossValues.join(";"),
        [awarenessNode]: null
      }
    });
  }

  checkIssueTypeScam(data) {
    if (
      data.Case?.Type === SCAM ||
      data.Case?.IDR_Issue_Type_2__c === SCAM ||
      data.Case?.IDR_Issue_Type_3__c === SCAM
    ) {
      return true;
    }
    return false;
  }

  checkSubRemedyFinancial(data) {
    if (
      (this.omniJsonDef.name === "scamAssistFields1" &&
        data.Case.ComplaintSubRemedy1 === "2") ||
      (this.omniJsonDef.name === "scamAssistFields2" &&
        data.Case.ComplaintSubRemedy2 === "2") ||
      (this.omniJsonDef.name === "scamAssistFields3" &&
        data.Case.ComplaintSubRemedy3 === "2") ||
      (this.omniJsonDef.name === "scamAssistFields1" &&
        data.Case.ComplaintSubRemedy1Offered === "2") ||
      (this.omniJsonDef.name === "scamAssistFields2" &&
        data.Case.ComplaintSubRemedy2Offered === "2") ||
      (this.omniJsonDef.name === "scamAssistFields3" &&
        data.Case.ComplaintSubRemedy3Offered === "2") ||
      (this.omniJsonDef.name === "scamAssistFields1" &&
        data.Case.ComplaintSubRemedy1Accepted === "2") ||
      (this.omniJsonDef.name === "scamAssistFields2" &&
        data.Case.ComplaintSubRemedy2Accepted === "2") ||
      (this.omniJsonDef.name === "scamAssistFields3" &&
        data.Case.ComplaintSubRemedy3Accepted === "2")
    ) {
      return true;
    }
    return false;
  }

  checkSubRemedyNonFinancial(data) {
    if (
      (this.omniJsonDef.name === "scamAssistFields1" &&
        data.Case.ComplaintSubRemedy1 === "3") ||
      (this.omniJsonDef.name === "scamAssistFields2" &&
        data.Case.ComplaintSubRemedy2 === "3") ||
      (this.omniJsonDef.name === "scamAssistFields3" &&
        data.Case.ComplaintSubRemedy3 === "3") ||
      (this.omniJsonDef.name === "scamAssistFields1" &&
        data.Case.ComplaintSubRemedy1Offered === "3") ||
      (this.omniJsonDef.name === "scamAssistFields2" &&
        data.Case.ComplaintSubRemedy2Offered === "3") ||
      (this.omniJsonDef.name === "scamAssistFields3" &&
        data.Case.ComplaintSubRemedy3Offered === "3") ||
      (this.omniJsonDef.name === "scamAssistFields1" &&
        data.Case.ComplaintSubRemedy1Accepted === "3") ||
      (this.omniJsonDef.name === "scamAssistFields2" &&
        data.Case.ComplaintSubRemedy2Accepted === "3") ||
      (this.omniJsonDef.name === "scamAssistFields3" &&
        data.Case.ComplaintSubRemedy3Accepted === "3")
    ) {
      return true;
    }
    return false;
  }

  setScamFieldsOnLoad(data) {
    this.selectedScamValue = data?.Case?.[this.omniJsonDef.name + "scamOption"];
    this.selectedAwarenessValues = data?.Case?.[
      this.omniJsonDef.name + "awarenessOption"
    ]
      ? data.Case[this.omniJsonDef.name + "awarenessOption"].split(";")
      : [];
    this.selectedNonFinLossValues = data?.Case?.[
      this.omniJsonDef.name + "nonFinancialOption"
    ]
      ? data.Case[this.omniJsonDef.name + "nonFinancialOption"].split(";")
      : [];
  }
}
