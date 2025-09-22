/**
 * @description Handles quick action for resetting Multi-Factor Authentication (MFA) of a broker.
 */
import { LightningElement, api } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import doMFAResetAction from "@salesforce/apex/BrokerMFAResetController.doMFAResetAction";
import { CloseActionScreenEvent } from "lightning/actions";
import userFriendlyServiceErrorMsg from "@salesforce/label/c.Forge_MFA_Reset_Error_Message";

const LABELS = {
  defaultErrorMessage: userFriendlyServiceErrorMsg,
  defaultSuccessMessage: "The MFA token has been reset for the broker"
};

export default class ContactRecordAction extends LightningElement {
  _recordId;
  @api get recordId() {
    return this._recordId;
  }
  set recordId(value) {
    this._recordId = value;
  }

  isLoading = true; // show spinner when loding

  connectedCallback() {
    this.isLoading = false;
  }

  handleCancel() {
    this.closeModal();
  }
  async doMfaReset() {
    try {
      this.isLoading = true;
      let result = await doMFAResetAction({ brokerContactId: this.recordId });
      if (result === false) {
        throw LABELS.defaultFailMessage;
      }
      this.showToast(null, LABELS.defaultSuccessMessage, "success");
    } catch (error) {
      if (typeof error === "string") {
        this.showToast(null, error.body.message, "error");
      } else if (typeof error.message === "string") {
        this.showToast(null, error.message, "error");
      } else if (error.body && typeof error.body.message === "string") {
        this.showToast(null, error.body.message, "error");
      }
    } finally {
      this.isLoading = false;
      this.closeModal();
    }
  }

  // Utilities
  closeModal() {
    this.dispatchEvent(new CloseActionScreenEvent());
  }
  showToast(title, message, variant) {
    this.dispatchEvent(
      new ShowToastEvent({
        title: title,
        message: message,
        variant: variant
      })
    );
  }
}
