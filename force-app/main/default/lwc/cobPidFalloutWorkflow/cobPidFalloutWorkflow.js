import { LightningElement, api, wire } from "lwc";
import hasAccessAegisFeature from "@salesforce/customPermission/AccessAegisFeatures";
import {
  getRecord,
  getFieldValue,
  notifyRecordUpdateAvailable
} from "lightning/uiRecordApi";
import { getRelatedListRecords } from "lightning/uiRelatedListApi";
import { SimpleToast } from "c/utils";

import USER_ID from "@salesforce/user/Id";
import USER_ROLE_FIELD from "@salesforce/schema/User.UserRole.DeveloperName";

import FIELD_PID_COBID from "@salesforce/schema/COBPrimaryIDDocument__c.CustomerOnboardingApplication__c";
import FIELD_PID_DAONLOCATIONURI from "@salesforce/schema/COBPrimaryIDDocument__c.DaonLocationUri__c";
import FIELD_PID_DOCUMENTTYPE from "@salesforce/schema/COBPrimaryIDDocument__c.IdDocumentType__c";
import FIELD_PID_EXTRACTEDFACEID from "@salesforce/schema/COBPrimaryIDDocument__c.idxExtractedFaceId__c";
import FIELD_PID_VERIFICATIONSTATUS from "@salesforce/schema/COBPrimaryIDDocument__c.Verification_Status__c";
import FIELD_COB_OCVID from "@salesforce/schema/COBPrimaryIDDocument__c.CustomerOnboardingApplication__r.OCVId__c";
import FIELD_COB_ONBOARDINGATTEMPTCOUNT from "@salesforce/schema/COBPrimaryIDDocument__c.CustomerOnboardingApplication__r.OnboardingAttemptCount__c";
import FIELD_COB_ONBOARDINGSTAGE from "@salesforce/schema/COBPrimaryIDDocument__c.CustomerOnboardingApplication__r.CXOnboardingStage__c";
import FIELD_COB_PERSONAID from "@salesforce/schema/COBPrimaryIDDocument__c.CustomerOnboardingApplication__r.PersonaId__c";
import FIELD_COB_PERSONID from "@salesforce/schema/COBPrimaryIDDocument__c.CustomerOnboardingApplication__r.PersonId__c";

import FIELD_CASE_SUBJECT from "@salesforce/schema/Case.Subject";
import FIELD_CASE_WORKFLOW_ID from "@salesforce/schema/Case.Aegis_Workflow_Id__c";

import ApprovalModal from "c/manageOpsWorkflowApproval";
import RejectModal from "c/manageOpsWorkflowReject";

export default class CobPidFalloutWorkflow extends LightningElement {
  @api recordId;
  cobPidData;
  caseData;
  userData;
  relatedListFilter;
  aegisWorkflowId;
  cobId;
  daonLocationUri;
  imgStyle;
  isSelfieMatched = false;
  isValidDocument = false;
  hasAegisAccess = hasAccessAegisFeature;

  toast = new SimpleToast(this);

  FILES_BY_DOCUMENTTYPE = {
    Passport: [
      {
        fileType: "DAON_FILE_TYPE_FRONT_PROCESSED",
        title: "Processed Document Image"
      },
      {
        fileType: "DAON_FILE_TYPE_FRONT_UNPROCESSED",
        title: "Unprocessed Document Image"
      }
    ],
    Other: [
      {
        fileType: "DAON_FILE_TYPE_FRONT_PROCESSED",
        title: "Processed Document Image Front"
      },
      {
        fileType: "DAON_FILE_TYPE_FRONT_UNPROCESSED",
        title: "Unprocessed Document Image Front"
      },
      {
        fileType: "DAON_FILE_TYPE_BACK_PROCESSED",
        title: "Processed Document Image Back"
      },
      {
        fileType: "DAON_FILE_TYPE_BACK_UNPROCESSED",
        title: "Unprocessed Document Image Back"
      }
    ]
  };

  @wire(getRecord, {
    recordId: "$recordId",
    fields: [
      FIELD_PID_COBID,
      FIELD_PID_DAONLOCATIONURI,
      FIELD_PID_DOCUMENTTYPE,
      FIELD_PID_EXTRACTEDFACEID,
      FIELD_PID_VERIFICATIONSTATUS,
      FIELD_COB_OCVID,
      FIELD_COB_ONBOARDINGATTEMPTCOUNT,
      FIELD_COB_ONBOARDINGSTAGE,
      FIELD_COB_PERSONAID,
      FIELD_COB_PERSONID
    ]
  })
  async wireCobPid({ error, data }) {
    if (error) {
      this.toast.error("Error fetching onboarding document details", error);
    } else if (data) {
      this.cobPidData = data;
      this.getPropValues();
    }
  }

  @wire(getRecord, {
    recordId: USER_ID,
    fields: [USER_ROLE_FIELD]
  })
  wireUser({ error, data }) {
    if (error) {
      this.toast.error("Error fetching user data:", error);
    } else if (data) {
      this.userData = data;
    }
  }

  @wire(getRelatedListRecords, {
    parentRecordId: "$cobId",
    relatedListId: "Cases__r",
    fields: [
      "Case.Subject",
      "Case.Aegis_Workflow_Id__c",
      "Case.CreatedDate",
      "Case.PersonaAttemptCount__c"
    ],
    where: "$relatedListFilter",
    sortBy: ["-Case.CreatedDate"]
  })
  wireCase({ error, data }) {
    if (error) {
      this.toast.error("Error fetching related case records", error);
    }
    if (!data?.records?.length) {
      return;
    }
    this.caseData = data.records[0];
    this.aegisWorkflowId = getFieldValue(this.caseData, FIELD_CASE_WORKFLOW_ID);

    // Set custom style if the subject contains "FAILED_DOC"
    const showRedBorder = getFieldValue(
      this.caseData,
      FIELD_CASE_SUBJECT
    )?.includes("FAILED_DOC");
    this.imgStyle = showRedBorder ? "border: 4px solid red;" : "";
  }

  get showCheckboxes() {
    if (!this.cobPidData || !this.userData || !this.caseData) {
      return false;
    }

    if (!this.daonLocationUri || !this.aegisWorkflowId) {
      return false;
    }

    if (
      getFieldValue(this.userData, USER_ROLE_FIELD) === "Join_Operations_Reader"
    ) {
      return false;
    }

    if (
      !getFieldValue(this.cobPidData, FIELD_COB_ONBOARDINGSTAGE) ===
      "Assisted Selfie"
    ) {
      return false;
    }

    const verificationStatus = getFieldValue(
      this.cobPidData,
      FIELD_PID_VERIFICATIONSTATUS
    );
    if (
      ["ID Ops: Daon OK", "Failed", "Potential Fraud"].includes(
        verificationStatus
      )
    ) {
      return false;
    }

    return true;
  }

  get pidLayout() {
    if (!this.cobPidData) {
      return null;
    }
    const documentType = getFieldValue(this.cobPidData, FIELD_PID_DOCUMENTTYPE);
    const files =
      this.FILES_BY_DOCUMENTTYPE[documentType] ??
      this.FILES_BY_DOCUMENTTYPE.Other;
    files.forEach((file) => {
      file.imgStyle = this.imgStyle;
    });
    return [
      {
        size: 6,
        hideHeader: true,
        title: "Documents",
        files
      }
    ];
  }

  get selfieLayout() {
    if (!this.cobPidData) {
      return null;
    }
    const files = [
      { fileType: "DAON_FILE_TYPE_EXTRACTED_FACE" },
      { fileType: "DAON_FILE_TYPE_SELFIE_TO_BE_ENROLLED" }
    ];
    files.forEach((file) => {
      file.imgStyle = this.imgStyle;
    });
    return [
      {
        size: 6,
        hideHeader: true,
        title: "Selfie",
        files
      }
    ];
  }

  get metadata() {
    if (!this.cobPidData) {
      return null;
    }
    const extractedFaceId = getFieldValue(
      this.cobPidData,
      FIELD_PID_EXTRACTEDFACEID
    );
    const daonLocationUri = this.daonLocationUri?.split("/");
    const customerToken = {
      customerId: getFieldValue(this.cobPidData, FIELD_COB_PERSONID),
      customerIdType: "UUID"
    };

    return {
      idxDocumentId: daonLocationUri?.[8],
      idxIdCheckId: daonLocationUri?.[6],
      idxUserId: daonLocationUri?.[4],
      idxExtractedFaceId: extractedFaceId,
      workflowId: this.aegisWorkflowId,
      relatedRecordId: this.recordId,
      ...customerToken
    };
  }

  get isApproveButtonDisable() {
    return !this.isSelfieMatched || !this.isValidDocument;
  }

  get isRejectButtonDisable() {
    return !this.showCheckboxes;
  }

  get workflowDetails() {
    if (!this.cobPidData || !this.caseData) {
      return null;
    }
    return {
      caseId: this.caseData.id,
      cobId: this.cobPidData.id,
      IdValue: getFieldValue(this.cobPidData, FIELD_COB_PERSONID),
      parentComponent: "Onboarding",
      workflowId: this.aegisWorkflowId
    };
  }

  getPropValues() {
    this.cobId = getFieldValue(this.cobPidData, FIELD_PID_COBID);
    this.daonLocationUri = getFieldValue(
      this.cobPidData,
      FIELD_PID_DAONLOCATIONURI
    );

    const personaId = getFieldValue(this.cobPidData, FIELD_COB_PERSONAID);
    const onboardingAttemptCount = getFieldValue(
      this.cobPidData,
      FIELD_COB_ONBOARDINGATTEMPTCOUNT
    );
    const personaAttemptCount = `${personaId}${onboardingAttemptCount}`;
    this.relatedListFilter = `{ PersonaAttemptCount__c: { eq: ${personaAttemptCount} } }`;
  }

  checkboxHandler(event) {
    let name = event.target.name;
    if (name === "validDocument") {
      this.isValidDocument = event.target.checked;
    }
    if (name === "selfieMatch") {
      this.isSelfieMatched = event.target.checked;
    }
  }

  handleApproval() {
    ApprovalModal.open({
      label: "Approval Modal",
      size: "small",
      options: { ...this.workflowDetails },
      onrefresh: (e) => {
        e.stopPropagation();
        notifyRecordUpdateAvailable([{ recordId: this.recordId }]);
        this.closeModal();
      }
    });
  }

  handleReject() {
    RejectModal.open({
      label: "Reject Modal",
      size: "small",
      options: { ...this.workflowDetails },
      onrefresh: (e) => {
        e.stopPropagation();
        notifyRecordUpdateAvailable([{ recordId: this.recordId }]);
        this.closeModal();
      }
    });
  }

  closeModal() {
    this.dispatchEvent(
      new CustomEvent("closeparentmodel", {
        detail: {
          message: "closeModel"
        }
      })
    );
  }
}
