import { LightningElement, wire, api, track } from "lwc";
import { getRecord, notifyRecordUpdateAvailable } from "lightning/uiRecordApi";
import { getPicklistValues } from "lightning/uiObjectInfoApi";
import STATUS_FIELD from "@salesforce/schema/Case.Status";
import SUBJECT_FIELD from "@salesforce/schema/Case.Subject";
import PRIMARY_FAILED_REASON_FIELD from "@salesforce/schema/Case.OnboardingVerificationFailedReason__c";
import SECONDARY_FAILED_REASON_FIELD from "@salesforce/schema/Case.SecondaryVerificationFailedReason__c";
import EVALUATION_ID from "@salesforce/schema/Case.Evaluation_Id__c";
import KYC_CHECK from "@salesforce/schema/Case.Fraud_Customer_Details__c";
import MIDDLE_NAME_CHECK from "@salesforce/schema/Case.Fraud_MiddleNameCheck__c";
import SELFIE_COMPARISON_CHECK from "@salesforce/schema/Case.Fraud_Selfie_Comparison_Match__c";
import RESIDENTIAL_ADDRESS_CHECK from "@salesforce/schema/Case.Fraud_Address_Valid__c";
import CUSTOMER_PHOTO_LEGI_CHECK from "@salesforce/schema/Case.Fraud_ID_Legible__c";
import PIC_OF_PIC_CHECK from "@salesforce/schema/Case.Fraud_ID_Not_Picture__c";
import CUSTOMER_PHOTO_MOD_CHECK from "@salesforce/schema/Case.Fraud_Customer_Photo_Modified__c";
import ID_DOC_SECUIRTY_CHECK from "@salesforce/schema/Case.Fraud_Security_Features__c";
import IS_CLOSED from "@salesforce/schema/Case.IsClosed";
import RECORD_TYPE_FIELD from "@salesforce/schema/Case.RecordTypeId";
import StatusUpdateModal from "c/trustMeCaseStatusUpdateModal";

export default class TrustMeCaseStatusPath extends LightningElement {
  @api recordId;
  recordTypeInfo;
  statusOptions;
  isLoading = true;
  caseData = {};
  primaryFailedReasonFieldInfo;
  secondaryFailedReasonFieldInfo;
  @track pathSteps = [];

  @wire(getRecord, {
    recordId: "$recordId",
    fields: [
      RECORD_TYPE_FIELD,
      STATUS_FIELD,
      SUBJECT_FIELD,
      PRIMARY_FAILED_REASON_FIELD,
      SECONDARY_FAILED_REASON_FIELD,
      EVALUATION_ID,
      KYC_CHECK,
      MIDDLE_NAME_CHECK,
      SELFIE_COMPARISON_CHECK,
      RESIDENTIAL_ADDRESS_CHECK,
      CUSTOMER_PHOTO_LEGI_CHECK,
      PIC_OF_PIC_CHECK,
      CUSTOMER_PHOTO_MOD_CHECK,
      ID_DOC_SECUIRTY_CHECK,
      IS_CLOSED
    ]
  })
  wiredCaseFields({ data }) {
    if (!data) {
      return;
    }
    this.recordTypeInfo = data.recordTypeInfo;
    this.caseData.Status = data.fields.Status.value;
    this.caseData.Id = this.recordId;
    this.caseData.Subject = data.fields.Subject.value;
    this.caseData.RecordTypeId = data.recordTypeInfo.recordTypeId;
    this.caseData.OnboardingVerificationFailedReason__c =
      data.fields.OnboardingVerificationFailedReason__c.value;
    this.caseData.SecondaryVerificationFailedReason__c =
      data.fields.SecondaryVerificationFailedReason__c.value;
    this.caseData.Evaluation_Id__c = data.fields.Evaluation_Id__c.value;
    this.caseData.IsClosed = data.fields.IsClosed.value;
    this.caseData.Fraud_Customer_Details__c =
      data.fields.Fraud_Customer_Details__c.value;
    this.caseData.Fraud_MiddleNameCheck__c =
      data.fields.Fraud_MiddleNameCheck__c.value;
    this.caseData.Fraud_Selfie_Comparison_Match__c =
      data.fields.Fraud_Selfie_Comparison_Match__c.value;
    this.caseData.Fraud_Address_Valid__c =
      data.fields.Fraud_Address_Valid__c.value;
    this.caseData.Fraud_ID_Legible__c = data.fields.Fraud_ID_Legible__c.value;
    this.caseData.Fraud_ID_Not_Picture__c =
      data.fields.Fraud_ID_Not_Picture__c.value;
    this.caseData.Fraud_Customer_Photo_Modified__c =
      data.fields.Fraud_Customer_Photo_Modified__c.value;
    this.caseData.Fraud_Security_Features__c =
      data.fields.Fraud_Security_Features__c.value;
  }

  @wire(getPicklistValues, {
    recordTypeId: "$recordTypeInfo.recordTypeId",
    fieldApiName: STATUS_FIELD
  })
  wiredStatusFieldInfo({ data }) {
    if (!data) {
      return;
    }
    this.statusOptions = data.values;
    this.processPicklistValues(data);
    this.isLoading = false;
  }

  processPicklistValues(data) {
    let picklistValues = data.values.map((item) => ({
      label: item.label,
      value: item.value,
      closed: item.attributes.closed
    }));
    // Filter out closed statuses
    this.pathSteps = picklistValues.filter((item) => !item.closed);
    const currentClosedItem = picklistValues.find(
      (item) => item.value === this.caseData.Status
    );
    if (currentClosedItem?.closed && currentClosedItem?.label) {
      this.pathSteps.push({
        label: this.caseData.Status,
        value: this.caseData.Status
      });
    } else {
      this.pathSteps.push({
        label: "Closed",
        value: "Closed"
      });
    }
  }

  @wire(getPicklistValues, {
    recordTypeId: "$recordTypeInfo.recordTypeId",
    fieldApiName: PRIMARY_FAILED_REASON_FIELD
  })
  wiredPrimaryFailedReasonFieldInfo({ data }) {
    if (data) {
      this.primaryFailedReasonFieldInfo = data;
    }
  }

  @wire(getPicklistValues, {
    recordTypeId: "$recordTypeInfo.recordTypeId",
    fieldApiName: SECONDARY_FAILED_REASON_FIELD
  })
  wiredSecondaryFailedReasonFieldInfo({ data }) {
    if (data) {
      this.secondaryFailedReasonFieldInfo = data;
    }
  }

  handleClickUpdate() {
    let statusOptions = this.statusOptions;
    let caseData = this.caseData;
    let primaryFailedReasonFieldInfo = this.primaryFailedReasonFieldInfo;
    let secondaryFailedReasonFieldInfo = this.secondaryFailedReasonFieldInfo;
    StatusUpdateModal.open({
      label: "Case Update Modal",
      size: "small",
      options: {
        statusOptions,
        caseData,
        primaryFailedReasonFieldInfo,
        secondaryFailedReasonFieldInfo
      },
      onrefresh: (e) => {
        e.stopPropagation();
        notifyRecordUpdateAvailable([{ recordId: this.recordId }]);
        const newClosedStatus = e.detail.status;
        const selectedPicklistItem = this.statusOptions.find(
          (item) => item.value === newClosedStatus
        );
        if (selectedPicklistItem && selectedPicklistItem.attributes.closed) {
          this.updateCaseStatusOptions(newClosedStatus);
        }
      }
    });
  }
  updateCaseStatusOptions(newClosedStatus) {
    this.pathSteps = this.pathSteps.map((item) => {
      return item.value === "Closed"
        ? { label: newClosedStatus, value: newClosedStatus }
        : item;
    });
  }
}
