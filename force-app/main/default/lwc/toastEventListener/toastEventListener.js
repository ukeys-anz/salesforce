import { LightningElement } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";

export default class ToastEventListener extends LightningElement {
  message = "Sample Message";
  variant = "success";

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
      /* eslint-disable no-eval */
      eval("$A.get('e.force:refreshView').fire();");
    }
  }

  disconnectedCallback() {
    window.removeEventListener(
      "CustomToastEvent",
      this.handleToastMessage.bind(this)
    );
  }
}
