import { LightningElement } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import getSessionIdToken from "@salesforce/apex/AuthTokenCacheUtil.getSessionIdToken";

export default class PageBackgroundModal extends NavigationMixin(
  LightningElement
) {
  showModal = false;
  connectedCallback() {
    getSessionIdToken()
      .then()
      .catch((error) => {
        this.loadModal("Connectivity Error", error.body.message);
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

  logout() {
    this[NavigationMixin.Navigate]({
      type: "standard__webPage",
      attributes: {
        url: window.location.origin + "/secur/logout.jsp"
      }
    });
  }
}
