import { LightningElement, wire, api } from "lwc";
import { getRecord, getRecordNotifyChange } from "lightning/uiRecordApi";
import { getPicklistValues } from "lightning/uiObjectInfoApi";
import { handleErrors, showToast } from "c/utils";
import PERSONA_ID_FIELD from "@salesforce/schema/Case.PersonaId__c";
import STATUS_FIELD from "@salesforce/schema/Case.Status";
import ONBOARDING_VERIFICATION_FAILED_REASON_FIELD from "@salesforce/schema/Case.OnboardingVerificationFailedReason__c";
import STATUS_UPDATE_ERROR from "@salesforce/schema/Case.Status_Update_Error__c";
import RECORD_TYPE_FIELD from "@salesforce/schema/Case.RecordTypeId";
import PARENT_ID_FIELD from "@salesforce/schema/Case.ParentId";
import updateStatus from "@salesforce/apex/COBCaseStatusPathController.updateStatus";

const FAILED_OK = "Failed";
const CONFIRMED_FRAUD = "Confirmed Fraud";

const CASE_STATUS_UPDATE_ERROR =
  "Case update failed. Please check Status Update Error field for details";
const SAME_CASE_STATUS_WARNING =
  "Case can't be updated with the same status. Please select a different status";

export default class CobCaseStatusPath extends LightningElement {
  @api recordId;
  recordTypeInfo;
  personaId;
  statusOptions;
  currentStatus;
  _newStatus;
  failedReasonFieldInfo;
  failedReasonOptions;
  currentFailedReason;
  _newFailedReason;
  pathSteps;
  isLoaded;
  showModal;
  isModalLoaded;
  isModalButtonDisable = false;
  error;
  statusUpdateError;
  parentId;

  confirmedFraudMessage =
    "By confirming, you are marking this onboarding case as Fraud. Done to continue, Cancel to go back.";

  @wire(getRecord, {
    recordId: "$recordId",
    fields: [
      RECORD_TYPE_FIELD,
      PERSONA_ID_FIELD,
      STATUS_FIELD,
      ONBOARDING_VERIFICATION_FAILED_REASON_FIELD,
      STATUS_UPDATE_ERROR,
      PARENT_ID_FIELD
    ]
  })
  wiredCaseFields({ data }) {
    this.isLoaded = false;

    if (data) {
      this.recordTypeInfo = data.recordTypeInfo;
      this.personaId = data.fields.PersonaId__c.value;
      this.currentStatus = data.fields.Status.value;
      this._newStatus = this.currentStatus;
      this.currentFailedReason =
        data.fields.OnboardingVerificationFailedReason__c.value;
      this._newFailedReason = this.currentFailedReason;
      this.statusUpdateError = data.fields.Status_Update_Error__c.value;
      this.parentId = data.fields.ParentId.value;
    }
  }

  @wire(getPicklistValues, {
    recordTypeId: "$recordTypeInfo.recordTypeId",
    fieldApiName: STATUS_FIELD
  })
  wiredStatusFieldInfo({ data }) {
    this.isLoaded = false;

    if (data) {
      this.statusOptions = data.values;

      this.pathSteps = data.values.map(({ label, value }) => ({
        label,
        value
      }));
    }

    this.isLoaded = true;
  }

  @wire(getPicklistValues, {
    recordTypeId: "$recordTypeInfo.recordTypeId",
    fieldApiName: ONBOARDING_VERIFICATION_FAILED_REASON_FIELD
  })
  wiredFailedReasonFieldInfo({ data }) {
    if (data) {
      this.failedReasonFieldInfo = data;
    }
  }

  get currentStep() {
    return this.currentStatus;
  }

  get isFailedOKSelected() {
    return this._newStatus === FAILED_OK;
  }

  get isConfirmedFraudSelected() {
    return this._newStatus === CONFIRMED_FRAUD;
  }

  get isFailedReasonDisabled() {
    return !this.failedReasonOptions || this.failedReasonOptions.length === 0;
  }

  handleHideModal() {
    this.showModal = false;
  }

  handleClickUpdate() {
    this.calculateFailedReasonOptions(this.currentStatus);
    this._newStatus = this.currentStatus;
    this._newFailedReason = this.currentFailedReason;
    this.showModal = true;
    this.isModalLoaded = true;
  }

  handleStatusChange(event) {
    this.calculateFailedReasonOptions(event.target.value);

    this._newStatus = event.detail.value;
    this._newFailedReason =
      this._newStatus !== FAILED_OK ? undefined : this.currentFailedReason;

    event.target.blur();
  }

  handleFailedReasonChange(event) {
    this._newFailedReason = event.detail.value;
    event.target.reportValidity();
    event.target.blur();
  }

  async handleUpdateStatus() {
    const isValid = this.isSelectionValid();

    if (isValid) {
      this.isModalButtonDisable = true;
      this.isModalLoaded = false;

      if (this.currentStatus === this._newStatus) {
        this.isModalLoaded = true;
        this.isModalButtonDisable = false;

        showToast(this, "Warning", SAME_CASE_STATUS_WARNING, "", "warning", "");
      } else {
        try {
          const cobCase = {
            RecordTypeId: this.recordTypeInfo.recordTypeId,
            Id: this.recordId,
            PersonaId__c: this.personaId,
            Status: this._newStatus,
            Status_Update_Error__c: this.statusUpdateError,
            OnboardingVerificationFailedReason__c:
              this._newStatus !== FAILED_OK ? undefined : this._newFailedReason,
            ParentId: this.parentId
          };
          let isCaseUpdated = await updateStatus({
            currentStatus: this.currentStatus,
            cobCase: cobCase
          });
          if (isCaseUpdated) {
            this.error = undefined;
            showToast(
              this,
              "Success!",
              "Successfully updated status.",
              "",
              "success",
              ""
            );
          } else {
            showToast(
              this,
              "Error!",
              CASE_STATUS_UPDATE_ERROR,
              "",
              "error",
              ""
            );
          }
          this.isModalLoaded = true;
          this.isModalButtonDisable = false;
          this.handleHideModal();
          getRecordNotifyChange([{ recordId: this.recordId }]);
        } catch (error) {
          this.error = error;
          this.isModalLoaded = true;
          this.isModalButtonDisable = false;

          showToast(this, "Error!", handleErrors(error), "", "error", "");
        }
      }
    }
  }

  calculateFailedReasonOptions(controllerValue) {
    const key = this.failedReasonFieldInfo?.controllerValues[controllerValue];
    this.failedReasonOptions = this.failedReasonFieldInfo?.values.filter(
      (opt) => opt.validFor.includes(key)
    );
  }

  isSelectionValid() {
    let isValid = false;

    isValid = this.template.querySelector(".status").reportValidity();

    if (this.template.querySelector(".failedReason")) {
      isValid = this.template.querySelector(".failedReason").reportValidity();
    }

    return isValid;
  }
}
