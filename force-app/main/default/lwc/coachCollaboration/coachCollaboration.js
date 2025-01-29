import { LightningElement, api } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";

/* IMPORT APEX METHODS */
import fetchJWETokenFromFrig from "@salesforce/apex/CoachCollaborationController.fetchJWETokenFromFrig";

export default class CoachCollaboration extends LightningElement {
  @api recordId;
  @api objectApiName;

  @api invoke() {
    let objectApiName = this.objectApiName;
    let recordId = this.recordId;
    fetchJWETokenFromFrig({ objectApiName, recordId })
      .then((url) => {
        if (url) {
          window.open(url, "_blank");
        } else {
          this.showNotification();
        }
      })
      .catch(() => {
        this.showNotification();
      });
  }

  showNotification() {
    const evt = new ShowToastEvent({
      title: "Error",
      message: "Some error occured. Please contact your System Administrator",
      variant: "error"
    });
    this.dispatchEvent(evt);
  }
}
