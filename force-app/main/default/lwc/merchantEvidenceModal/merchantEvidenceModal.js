import { api, wire } from "lwc";
import { SimpleToast } from "c/utils";
import LightningModal from "lightning/modal";
import getTaskRecord from "@salesforce/apex/MerchantEvidenceModalController.getTaskRecord";
import updateTaskStatus from "@salesforce/apex/MerchantEvidenceModalController.updateTaskStatus";
import CASE_COMMENT_FIELD from "@salesforce/schema/Case.Comments";
import CASEID_FIELD from "@salesforce/schema/Case.Id";
import USER_ID from "@salesforce/user/Id";
import USER_NAME_FIELD from "@salesforce/schema/User.Name";
import { updateRecord, getRecord } from "lightning/uiRecordApi";
import { CloseActionScreenEvent } from "lightning/actions";

export default class MerchantEvidenceModal extends LightningModal {
  @api isFromPopup = false;
  showSpinner = false;
  _recordId;
  recordIdSet = false;
  caseRecordId;
  @api set recordId(value) {
    this._recordId = value;
    if (value && !this.recordIdSet) {
      this.recordIdSet = true;
      this.handleRecordIdAvailable(value);
    }
  }

  get recordId() {
    return this._recordId;
  }

  taskRecords = [];
  showMerchantEvidenceModal = false;
  selectedStatusValue;
  userId = USER_ID;
  currentUserName;
  error;
  value = "";
  updatedStatus;

  toast = new SimpleToast(this);
  taskStatusToChatterCommentMap = new Map([
    [
      "Pending",
      " has confirmed that the evidence provided by the merchant will be reviewed for redaction later."
    ],
    [
      "No Review Required",
      " has confirmed that the evidence provided by the merchant is not required to be redacted or will not be sent to the customer."
    ],
    [
      "Reviewed",
      " has confirmed that the evidence provided by the merchant has been reviewed and redacted."
    ]
  ]);

  get radioOptions() {
    return [
      { label: "Evidence review to be done later", value: "Pending" },
      {
        label:
          "Evidence not required to be redacted or not being sent to customer",
        value: "No Review Required"
      },
      { label: "Evidence has been reviewed and redacted", value: "Reviewed" }
    ];
  }

  handleRecordIdAvailable(id) {
    this.caseRecordId = id;
    this.showSpinner = true;
    this.getTaskRecords();
    this.showSpinner = false;
  }

  @wire(getRecord, { recordId: "$userId", fields: [USER_NAME_FIELD] })
  userDetails({ error, data }) {
    if (data) {
      this.currentUserName = data.fields.Name.value;
    } else if (error) {
      this.error = error;
    }
  }

  handleChange(event) {
    this.selectedStatusValue = event.target.value;
  }

  get disableConfirmButton() {
    return !this.selectedStatusValue ? true : false;
  }

  getTaskRecords() {
    if (!this.caseRecordId) {
      return;
    }
    getTaskRecord({ caseId: this.caseRecordId })
      .then((result) => {
        if (
          !this.isFromPopup &&
          (result.Status === "No Review Required" ||
            result.Status === "Reviewed")
        ) {
          this.toast.warning("The task associated is already completed.");
          this.handleCloseModal();
          return;
        }

        this.taskRecord = result;
        this.showEvidenceModal();
      })
      .catch(() => {
        this.showSpinner = false;
        if (!this.isFromPopup) {
          this.toast.warning("The task is not created for this case.");
        }
        this.handleCloseModal();
      });
  }

  showEvidenceModal() {
    if (
      this.taskRecord &&
      this.taskRecord.Subject === "Card - Merchant Evident Received" &&
      (this.taskRecord.Status === "Not Started" ||
        this.taskRecord.Status === "Pending")
    ) {
      this.showMerchantEvidenceModal = true;
    } else {
      this.handleCloseModal();
    }
  }

  handleUpdateTaskStatus() {
    this.showSpinner = true;

    const task = {};
    task.Id = this.taskRecord.Id;
    task.WhatId = this.taskRecord.WhatId;
    task.Status = this.selectedStatusValue;
    updateTaskStatus({
      taskObj: task
    })
      .then(() => {
        this.createChatterPostForCase();
        this.toast.success("Task status updated successfully.");
      })
      .catch(() => {
        this.toast.error("Error occurred while updating task status.");
      })
      .finally(() => {
        this.showSpinner = false;
        this.handleCloseModal();
      });
  }

  createChatterPostForCase() {
    let commentBody =
      this.currentUserName +
      this.taskStatusToChatterCommentMap.get(this.selectedStatusValue);
    const fields = {};
    fields[CASE_COMMENT_FIELD.fieldApiName] = commentBody;
    fields[CASEID_FIELD.fieldApiName] = this.caseRecordId;

    const recordInput = { fields };
    updateRecord(recordInput)
      .then(() => {
        //CHATTER POST CREATED SUCCESSFULLY
      })
      .catch(() => {
        this.toast.error("Error occurred while creating chatter post.");
      });
  }

  handleCloseModal() {
    this.close("canceled");
    this.dispatchEvent(new CloseActionScreenEvent());
  }
}
