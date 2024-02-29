import { LightningElement, api } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";

export default class ShowToastInFlexCard extends LightningElement {
  @api toastTitle;
  @api toastMessage;
  @api toastVariant;
  @api toastMode;

  renderedCallback() {
    this.showToast();
  }

  showToast() {
    const event = new ShowToastEvent({
      title: this.toastTitle,
      message: this.toastMessage,
      variant: this.toastVariant,
      mode: this.toastMode
    });
    this.dispatchEvent(event);
  }
}
