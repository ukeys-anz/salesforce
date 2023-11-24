import { LightningElement } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import pubsub from "omnistudio/pubsub";

export default class ToastEventListener extends LightningElement {
  message = "Sample Message";
  variant = "success";
  timeoutId;
  connectedCallback() {
    window.addEventListener(
      "CustomToastEvent",
      this.handleToastMessage.bind(this)
    );
  }

  handleToastMessage(event) {
    if (event && event.detail) {
      const evt = new ShowToastEvent({
        message: event.detail.message,
        variant: event.detail.variant
      });
      this.dispatchEvent(evt);
      clearTimeout(this.timeoutId);
      if (event.detail.variant === "success") {
        // eslint-disable-next-line @lwc/lwc/no-async-operation
        this.timeoutId = setTimeout(this.sendEventToFlexcard.bind(this), 3000);
      }
    }
  }

  sendEventToFlexcard() {
    pubsub.fire("ReloadChannel", "ReloadEvent", {});
  }

  disconnectedCallback() {
    window.removeEventListener(
      "CustomToastEvent",
      this.handleToastMessage.bind(this)
    );
  }
}
