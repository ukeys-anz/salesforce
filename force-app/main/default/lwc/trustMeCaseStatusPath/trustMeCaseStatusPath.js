import { LightningElement, wire, api, track } from "lwc";
import {
  getRecord,
  getFieldValue,
  notifyRecordUpdateAvailable
} from "lightning/uiRecordApi";
import { getPicklistValues } from "lightning/uiObjectInfoApi";
import STATUS_FIELD from "@salesforce/schema/Case.Status";
import SUBJECT_FIELD from "@salesforce/schema/Case.Subject";
import CASENUMBER_FIELD from "@salesforce/schema/Case.CaseNumber";
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
import KYC_VERIFICATION_ID from "@salesforce/schema/Case.KYC_Verification_Id__c";

export default class TrustMeCaseStatusPath extends LightningElement {
  @api recordId;
  recordTypeInfo;
  statusOptions;
  allstatusOptions;
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
      IS_CLOSED,
      KYC_VERIFICATION_ID,
      CASENUMBER_FIELD
    ]
  })
  wiredCaseFields({ data }) {
    if (!data) {
      return;
    }
    this.recordTypeInfo = data.recordTypeInfo;
    this.caseData.Status = getFieldValue(data, STATUS_FIELD);
    this.caseData.CaseNumber = getFieldValue(data, CASENUMBER_FIELD);
    this.caseData.Id = this.recordId;
    this.caseData.Subject = getFieldValue(data, SUBJECT_FIELD);
    this.caseData.RecordTypeId = data.recordTypeInfo.recordTypeId;
    this.caseData.OnboardingVerificationFailedReason__c = getFieldValue(
      data,
      PRIMARY_FAILED_REASON_FIELD
    );
    this.caseData.SecondaryVerificationFailedReason__c = getFieldValue(
      data,
      SECONDARY_FAILED_REASON_FIELD
    );
    this.caseData.Evaluation_Id__c = getFieldValue(data, EVALUATION_ID);
    this.caseData.IsClosed = getFieldValue(data, IS_CLOSED);
    this.caseData.Fraud_Customer_Details__c = getFieldValue(data, KYC_CHECK);
    this.caseData.Fraud_MiddleNameCheck__c = getFieldValue(
      data,
      MIDDLE_NAME_CHECK
    );
    this.caseData.Fraud_Selfie_Comparison_Match__c = getFieldValue(
      data,
      SELFIE_COMPARISON_CHECK
    );
    this.caseData.Fraud_Address_Valid__c = getFieldValue(
      data,
      RESIDENTIAL_ADDRESS_CHECK
    );
    this.caseData.Fraud_ID_Legible__c = getFieldValue(
      data,
      CUSTOMER_PHOTO_LEGI_CHECK
    );
    this.caseData.Fraud_ID_Not_Picture__c = getFieldValue(
      data,
      PIC_OF_PIC_CHECK
    );
    this.caseData.Fraud_Customer_Photo_Modified__c = getFieldValue(
      data,
      CUSTOMER_PHOTO_MOD_CHECK
    );
    this.caseData.Fraud_Security_Features__c = getFieldValue(
      data,
      ID_DOC_SECUIRTY_CHECK
    );
    this.caseData.KYC_Verification_Id__c = getFieldValue(
      data,
      KYC_VERIFICATION_ID
    );
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
    this.allstatusOptions = data.values;
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
    this.statusOptions = picklistValues.filter((item) => item.closed);

    if (this.caseData.Status === "Rectify Defect") {
      this.statusOptions.unshift({
        label: "Refer to Fraud",
        value: "Refer to Fraud"
      });
    }

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
        const selectedPicklistItem = this.allstatusOptions.find(
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
