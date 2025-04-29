import { LightningElement, api } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import { ShowToastEvent } from "lightning/platformShowToastEvent";

/* IMPORT APEX METHODS */
import fetchJWETokenFromFrig from "@salesforce/apex/CoachCollaborationController.fetchJWETokenFromFrig";

export default class CoachCollaboration extends NavigationMixin(
  LightningElement
) {
  @api recordId;
  @api objectApiName;

  @api invoke() {
    let objectApiName = this.objectApiName;
    let recordId = this.recordId;
    fetchJWETokenFromFrig({ objectApiName, recordId })
      .then((url) => {
        if (url) {
          this[NavigationMixin.Navigate]({
            type: "standard__webPage",
            attributes: {
              url: url
            }
          });
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
