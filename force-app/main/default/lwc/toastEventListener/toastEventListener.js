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
    pubsub.register("omniscript_action", {
      data: this.handleOmniAction.bind(this)
    });
  }

  handleOmniAction(data) {
    switch (data.name) {
      case "closeModal": {
        this.showToastRefresh(data.message, data.toast);
        break;
      }
      default:
        break;
    }
  }

  handleToastMessage(event) {
    if (event && event.detail) {
      this.showToastRefresh(event.detail.message, event.detail.variant);
    }
  }

  showToastRefresh(toastMessage, toastVariant) {
    const evt = new ShowToastEvent({
      message: toastMessage,
      variant: toastVariant
    });
    this.dispatchEvent(evt);
    clearTimeout(this.timeoutId);
    if (toastVariant === "success") {
      // eslint-disable-next-line @lwc/lwc/no-async-operation
      this.timeoutId = setTimeout(this.sendEventToFlexcard.bind(this), 3000);
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
