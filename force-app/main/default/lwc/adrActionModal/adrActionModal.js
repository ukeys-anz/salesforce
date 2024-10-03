import { api } from "lwc";
import LightningModal from "lightning/modal";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import performADRAction from "@salesforce/apex/ADRController.performADRAction";

export default class AdrActionModal extends LightningModal {
  @api options;
  showSpinner = false;

  get ModalLabel() {
    return this.options?.nameBrandConcat;
  }

  get Modalcontent() {
    return (
      "Are you sure you want to " +
      this.options?.actionToPerform.toLowerCase() +
      " " +
      this.options?.nameBrandConcat
    );
  }

  get ModalButtonName() {
    return this.options?.actionToPerform;
  }

  get ModalButtonVariant() {
    return this.options?.buttonVariant;
  }

  handleClick() {
    this.performADRAction();
  }

  performADRAction() {
    this.showSpinner = true;
    performADRAction({
      rspId: this.options?.rspId,
      actionName: this.options?.actionToPerform
    })
      .then((result) => {
        this.showToast(result.status, result.responseMessage, result.status);
        this.fireRefreshEvent();
      })
      .catch(() => {
        this.showToast("Error", "Error occured while updating status", "error");
      })
      .finally(() => {
        this.showSpinner = false;
        this.close();
      });
  }

  showToast(title, message, variant) {
    const event = new ShowToastEvent({
      title: title,
      message: message,
      variant: variant,
      mode: "dismissable"
    });
    this.dispatchEvent(event);
  }

  fireRefreshEvent() {
    this.dispatchEvent(
      new CustomEvent("refresh", {
        detail: {
          message: "refresh"
        }
      })
    );
  }
}
