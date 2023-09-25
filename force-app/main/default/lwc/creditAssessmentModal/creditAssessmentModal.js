import { LightningElement, api } from "lwc";
import { OmniscriptActionCommonUtil } from "omnistudio/omniscriptActionUtils";
import pubsub from "omnistudio/pubsub";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
export default class CreditAssessmentModal extends LightningElement {
  @api reasonCode;
  @api assessmentCategory;
  @api reasonDescription;
  @api guidanceCode;
  @api createdBy;
  @api createTime;
  @api referralOutcomeCode;
  @api applicantId;
  optionList;
  selectedValue;
  saving = false;
  defaultSelection = true;
  disableSave = true;

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
        this.disableSave = false;
      }
    }
  }

  handleSelectedValue(e) {
    this.selectedValue = e.target.value;
    this.disableSave = false;
  }

  handleCancel() {
    pubsub.fire("CreditReferralReasons", "closeFlyout");
  }

  async handleSave() {
    //Applicant Id is optional, however it is required in certain instances,
    //so we ensure there is a value otherwise assign blank string to send
    let applicantId = null;
    if (
      this.applicantId &&
      this.applicantId !== "{applicantId}" &&
      this.applicantId !== "null"
    ) {
      applicantId = this.applicantId;
    }

    this.saving = true;
    this._actionUtilClass = new OmniscriptActionCommonUtil();
    const params = {
      input: {
        creditId: this.creditId,
        refOutcome: this.selectedValue,
        recordId: this.recordId,
        reasonCode: this.reasonCode,
        applicantId: applicantId
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
        this.showToast(
          "Credit Assessment",
          "Failed to update referral outcome.",
          "error"
        );
      }
    } catch (error) {
      this.showToast(
        "Credit Assessment",
        "Failed to update referral outcome.",
        "error"
      );
    } finally {
      this.saving = false;
    }
  }

  showToast(theTitle, theMessage, theVariant) {
    const event = new ShowToastEvent({
      title: theTitle,
      message: theMessage,
      variant: theVariant
    });
    this.dispatchEvent(event);
  }
}
