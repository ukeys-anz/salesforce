import { LightningElement, api, track, wire } from "lwc";
import ApprovalModal from "c/manageOpsWorkflowApproval";
import RejectModal from "c/manageOpsWorkflowReject";
import {
  getRecord,
  getFieldValue,
  notifyRecordUpdateAvailable
} from "lightning/uiRecordApi";
import { SimpleToast } from "c/utils";
import { RefreshEvent } from "lightning/refresh";
import hasPermission from "@salesforce/customPermission/AccessAegisFeatures";

// Case Fields
import FIELD_DAON_CHECK_ID from "@salesforce/schema/Case.Daon_Check_Id__c";
import FIELD_DAON_USER_ID from "@salesforce/schema/Case.Daon_User_Id__c";
import FIELD_UUID from "@salesforce/schema/Case.Person_Digital_Identity__c";
import FIELD_DOCUMENT_ID from "@salesforce/schema/Case.Daon_Document_Id__c";
import FIELD_AUTH_REQUEST_ID from "@salesforce/schema/Case.Daon_Auth_Request_Id__c";
import FIELD_REG_CHALLENGE_ID from "@salesforce/schema/Case.Daon_Reg_Challenge_Id__c";
import FIELD_AEGIS_WORKFLOW_ID from "@salesforce/schema/Case.Aegis_Workflow_Id__c";
import FIELD_PIN_HISTORY_CHECK from "@salesforce/schema/Case.Pin_History_Check_Failed__c";
import FIELD_IS_CLOSED from "@salesforce/schema/Case.IsClosed";
import FIELD_DAON_CHALLENGE_TYPE from "@salesforce/schema/Case.Daon_Challenge_Type__c";
import FIELD_CASE_ID from "@salesforce/schema/Case.Id";
import USER_ID from "@salesforce/user/Id";
import USER_ROLE_NAME_FIELD from "@salesforce/schema/User.UserRole.DeveloperName";

const FILES_TYPE = [
  {
    fileType: "DAON_FILE_TYPE_FRONT_PROCESSED",
    title: "Processed Document Front"
  },
  {
    fileType: "DAON_FILE_TYPE_FRONT_UNPROCESSED",
    title: "Unprocessed Document Front"
  },
  {
    fileType: "DAON_FILE_TYPE_SELFIE_ENROLLED",
    title: "Enrolled Selfie"
  },
  {
    fileType: "DAON_FILE_TYPE_SELFIE_TO_BE_VERIFIED",
    title: "Selfie to be Verified"
  }
];

const CHALLENGE_TYPE = {
  AUTH_REQUEST: "SELFIE_RECOVERY_CHALLENGE_TYPE_AUTH_REQUEST",
  REG_CHALLENGE: "SELFIE_RECOVERY_CHALLENGE_TYPE_REG_CHALLENGE"
};

const FIELDS = [
  "Case.Status",
  "Case.Daon_Check_Id__c",
  "Case.Daon_User_Id__c",
  "Case.Person_Digital_Identity__c",
  "Case.Daon_Document_Id__c",
  "Case.Daon_Auth_Request_Id__c",
  "Case.Daon_Reg_Challenge_Id__c",
  "Case.Aegis_Workflow_Id__c",
  "Case.Pin_History_Check_Failed__c",
  "Case.IsClosed",
  "Case.CaseNumber",
  "Case.Daon_Challenge_Type__c",
  "Case.Id"
];

export default class PinAndSelfieWorkflow extends LightningElement {
  @api recordId;
  componentSpinner = false;
  errorOccurred = false;
  @track caseDetails;
  toast = new SimpleToast(this);
  noAccess = !hasPermission;
  userId = USER_ID;

  @wire(getRecord, {
    recordId: "$userId",
    fields: [USER_ROLE_NAME_FIELD]
  })
  user;
  get userRole() {
    return getFieldValue(this.user.data, USER_ROLE_NAME_FIELD);
  }
  @wire(getRecord, {
    recordId: "$recordId",
    fields: FIELDS
  })
  wiredRecord({ error, data }) {
    if (error) {
      this.toast.error("Error loading case details", error);
    } else if (data) {
      this.caseDetails = data;
    }
  }

  get layout() {
    if (!this.caseDetails) {
      return null;
    }
    return [
      {
        title: "User Documents",
        size: 6,
        files: FILES_TYPE
      }
    ];
  }

  isPinWorkFlow() {
    return this.caseDetails.recordTypeInfo.name === "PIN Recovery";
  }

  checkAuthVSChallengeId() {
    return (
      getFieldValue(this.caseDetails, FIELD_AUTH_REQUEST_ID) ??
      getFieldValue(this.caseDetails, FIELD_REG_CHALLENGE_ID)
    );
  }

  get metadata() {
    if (!this.caseDetails) {
      return null;
    }
    if (
      !getFieldValue(this.caseDetails, FIELD_DAON_CHALLENGE_TYPE) &&
      this.isPinWorkFlow()
    ) {
      return {
        idxDocumentId: getFieldValue(this.caseDetails, FIELD_DOCUMENT_ID),
        idxIdCheckId: getFieldValue(this.caseDetails, FIELD_DAON_CHECK_ID),
        idxUserId: getFieldValue(this.caseDetails, FIELD_DAON_USER_ID),
        workflowId: getFieldValue(this.caseDetails, FIELD_AEGIS_WORKFLOW_ID),
        relatedRecordId: this.recordId,
        ...this.customerToken,
        challengeId: getFieldValue(this.caseDetails, FIELD_REG_CHALLENGE_ID)
      };
    }
    return {
      idxDocumentId: getFieldValue(this.caseDetails, FIELD_DOCUMENT_ID),
      idxIdCheckId: getFieldValue(this.caseDetails, FIELD_DAON_CHECK_ID),
      idxUserId: getFieldValue(this.caseDetails, FIELD_DAON_USER_ID),
      workflowId: getFieldValue(this.caseDetails, FIELD_AEGIS_WORKFLOW_ID),
      relatedRecordId: this.recordId,
      ...this.customerToken,
      challengeId: this.checkAuthVSChallengeId(),
      challengeType:
        CHALLENGE_TYPE[
          getFieldValue(this.caseDetails, FIELD_DAON_CHALLENGE_TYPE)
        ]
    };
  }

  isJoinOperationReader() {
    return this.userRole === "Join_Operations_Reader";
  }

  openApprovalModal() {
    let caseId = getFieldValue(this.caseDetails, FIELD_CASE_ID);
    let parentComponent = "PinAndSelfie";
    let IdValue = getFieldValue(this.caseDetails, FIELD_UUID);
    let workflowId = getFieldValue(this.caseDetails, FIELD_AEGIS_WORKFLOW_ID);
    let isPinWorkFlow = this.isPinWorkFlow();
    let isPinHistoryCheck = getFieldValue(
      this.caseDetails,
      FIELD_PIN_HISTORY_CHECK
    );

    ApprovalModal.open({
      label: "Approval Modal",
      size: "small",
      options: {
        caseId,
        parentComponent,
        IdValue,
        workflowId,
        isPinHistoryCheck,
        isPinWorkFlow
      },
      onrefresh: (e) => {
        e.stopPropagation();
        notifyRecordUpdateAvailable([{ recordId: this.recordId }]);
        this.dispatchEvent(new RefreshEvent());
      }
    });
  }

  openRejectModal() {
    let caseId = getFieldValue(this.caseDetails, FIELD_CASE_ID);
    let parentComponent = "PinAndSelfie";
    let IdValue = getFieldValue(this.caseDetails, FIELD_UUID);
    let workflowId = getFieldValue(this.caseDetails, FIELD_AEGIS_WORKFLOW_ID);
    let isPinHistoryCheck = getFieldValue(
      this.caseDetails,
      FIELD_PIN_HISTORY_CHECK
    );
    let isPinWorkFlow = this.isPinWorkFlow();
    RejectModal.open({
      label: "Reject Modal",
      size: "small",
      options: {
        caseId,
        parentComponent,
        IdValue,
        workflowId,
        isPinHistoryCheck,
        isPinWorkFlow
      },
      onrefresh: (e) => {
        e.stopPropagation();
        notifyRecordUpdateAvailable([{ recordId: this.recordId }]);
        this.dispatchEvent(new RefreshEvent());
      }
    });
  }

  get isApprovButtonDisable() {
    return (
      getFieldValue(this.caseDetails, FIELD_PIN_HISTORY_CHECK) ||
      getFieldValue(this.caseDetails, FIELD_IS_CLOSED) ||
      this.isJoinOperationReader()
    );
  }

  get isRejectButtonDisable() {
    return (
      getFieldValue(this.caseDetails, FIELD_IS_CLOSED) ||
      this.isJoinOperationReader()
    );
  }

  get customerToken() {
    return {
      customerId: getFieldValue(this.caseDetails, FIELD_UUID),
      customerIdType: "UUID"
    };
  }
}
