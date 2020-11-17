import { LightningElement } from "lwc";
import getSessionIdToken from "@salesforce/apex/AuthTokenCacheUtil.getSessionIdToken";

export default class PageBackgroundModal extends LightningElement {
  showModal = false;
  connectedCallback() {
    getSessionIdToken()
      .then()
      .catch((error) => {
        this.loadModal("Notification", error.body.message);
      });
  }

  loadModal(header, message) {
    this.modalHeader = header;
    this.modalMessage = message;
    this.showModal = true;
  }

  closeModal() {
    this.showModal = false;
  }
}
