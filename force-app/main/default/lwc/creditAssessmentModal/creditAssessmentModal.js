import { LightningElement, api } from "lwc";
import { OmniscriptActionCommonUtil } from "omnistudio/omniscriptActionUtils";
import pubsub from "omnistudio/pubsub";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import LightningConfirm from "lightning/confirm";

const ERROR_MESSAGE =
  "Unfortunately there was an error saving the Referral Outcome. Please try again.";
export default class CreditAssessmentModal extends LightningElement {
  @api reasonCode;
  @api assessmentCategory;
  @api reasonDescription;
  @api guidanceCode;
  @api createdBy;
  @api createTime;
  @api referralOutcomeCode;
  @api applicantId;
  @api outcomeId;
  @api assessmentId;
  @api propertyId;

  optionList;
  selectedValue;
  saving = false;
  showError = false;
  defaultSelection = true;
  disableSave = true;
  hasOutcome = false;
  isClearBtnDisabled = true;
  errorMessage;
  //Only call getOptions when we have a reasonCodeId
  @api set reasonCodeId(value) {
    this._reasonCodeId = value;
    this.getOptions();
  }
  get reasonCodeId() {
    return this._reasonCodeId;
  }

  @api set recordId(value) {
    this._recordId = value;
  }
  get recordId() {
    return this._recordId;
  }

  @api set creditId(value) {
    this._creditId = value;
  }
  get creditId() {
    return this._creditId;
  }

  //Only show the modified details if both create time and created by have values
  get showModified() {
    //If the value is null, omni sends the attribute value as a string containing '{createdBy}'
    return (
      this.createdBy &&
      this.createdBy !== "{createdBy}" &&
      this.createTime &&
      this.createTime !== "{createTime}"
    );
  }

  get modifiedBy() {
    return `${this.createdBy} ${this.createTime}`;
  }

  async getOptions() {
    this._actionUtilClass = new OmniscriptActionCommonUtil();
    const params = {
      input: { reasonCodeId: this.reasonCodeId },
      sClassName: "CreditAssessmentController",
      sMethodName: "getSelectOptions",
      options: "{}"
    };

    let response = await this._actionUtilClass.executeAction(
      params,
      null,
      this,
      null,
      null
    );

    if (response?.result?.options) {
      this.optionList = response.result.options;

      //Get any default values to pre-populate selectbox
      let defaultValue = this.optionList.findIndex(
        (i) => i.value === this.referralOutcomeCode
      );

      //Anything not found will have index with negative value
      if (defaultValue >= 0) {
        this.optionList[defaultValue].selected = true;
        this.selectedValue = this.optionList[defaultValue];
        this.defaultSelection = false;
        this.hasOutcome = true;
        this.isClearBtnDisabled = false;
      }
    }
  }

  handleSelectedValue(e) {
    this.selectedValue = e.target.value;
    if (this.selectedValue === "None") {
      this.disableSave = true;
    } else {
      this.disableSave = false;
    }
  }

  handleCancel() {
    pubsub.fire("CreditReferralReasons", "closeFlyout");
  }

  async handleConfirmClick() {
    const result = await LightningConfirm.open({
      message:
        "Are you sure you have selected the correct referral outcome? Once saved this cannot be changed. Please click OK to confirm or cancel to review referral outcome.",
      label: "Please confirm referral outcome change",
      theme: "alt-inverse"
    });
    //If OK is clicked, result is true
    if (result) {
      this.handleSave();
    }
  }

  async handleSave() {
    //Applicant Id and Property Id is optional, however it is required in certain instances,
    //so we ensure there is a value otherwise assign blank string to send
    let applicantId = null;
    if (
      this.applicantId &&
      this.applicantId !== "{applicantId}" &&
      this.applicantId !== "null"
    ) {
      applicantId = this.applicantId;
    }

    let propertyId = null;
    if (
      this.propertyId &&
      this.propertyId !== "{propertyId}" &&
      this.propertyId !== "null"
    ) {
      propertyId = this.propertyId;
    }

    this.saving = true;
    this._actionUtilClass = new OmniscriptActionCommonUtil();
    const params = {
      input: {
        creditId: this.creditId,
        refOutcome: this.selectedValue,
        recordId: this.recordId,
        reasonCode: this.reasonCode,
        applicantId: applicantId,
        propertyId: propertyId
      },
      sClassName: "CreditAssessmentController",
      sMethodName: "saveReferralChange",
      options: "{}"
    };

    try {
      let response = await this._actionUtilClass.executeAction(
        params,
        null,
        this,
        null,
        null
      );
      if (!response?.error) {
        this.showToast(
          "Credit Assessment",
          "The Referral Outcome has been updated successfully.",
          "success"
        );
        pubsub.fire("CreditAssessmentParent", "closeFlyout");
      } else {
        this.showError = true;
        this.errorMessage = ERROR_MESSAGE;
      }
    } catch (error) {
      this.showError = true;
      this.errorMessage = ERROR_MESSAGE;
    } finally {
      this.saving = false;
    }
  }

  async handleDelete() {
    this.saving = true;
    this._actionUtilClass = new OmniscriptActionCommonUtil();
    const params = {
      input: {
        creditId: this.creditId,
        recordId: this.recordId,
        outcomeId: this.outcomeId,
        assessmentId: this.assessmentId
      },
      sClassName: "CreditAssessmentController",
      sMethodName: "deleteReferralOutcome",
      options: "{}"
    };

    this._actionUtilClass
      .executeAction(params, null, this, null, null)
      .then((response) => {
        if (!response?.error) {
          this.showToast(
            "Credit Assessment",
            "The referral outcome was successfully removed",
            "success"
          );

          this.hasOutcome = false;
          this.template.querySelector('[name="referralOutcome"]').value =
            "None";
          this.isClearBtnDisabled = true;
        } else {
          this.handleDeleteError();
        }
      })
      .catch(() => {
        this.handleDeleteError();
      });

    this.saving = false;
    this.disableSave = true;
  }

  handleDeleteError() {
    this.showToast(
      "Credit Assessment",
      "The referral outcome could not be deleted. Please try again.",
      "error"
    );
    this.isClearBtnDisabled = false;
    this.hasOutcome = true;
  }

  showToast(theTitle, theMessage, theVariant) {
    const event = new ShowToastEvent({
      title: theTitle,
      message: theMessage,
      variant: theVariant
    });
    this.dispatchEvent(event);
  }

  closeError() {
    this.showError = false;
    const closeErrorEvent = new CustomEvent("errorclosed", {
      detail: this.showError
    });
    this.dispatchEvent(closeErrorEvent);
  }
}
