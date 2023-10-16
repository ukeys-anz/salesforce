import { api } from "lwc";
import LightningModal from "lightning/modal";

export default class ConfirmationModal extends LightningModal {
  @api content;
  handleConfirm(event) {
    this.dispatchSelectEvent(event.target.dataset.name);
    this.close("true");
  }
  handleCancel() {
    this.close("true");
  }
  dispatchSelectEvent(event) {
    const selectEvent = new CustomEvent("select", {
      detail: event
    });
    this.dispatchEvent(selectEvent);
  }
}
