import { LightningElement, wire, track } from "lwc";
import getReleases from "@salesforce/apex/ReleaseLogServerController.getReleases";
import { ShowToastEvent } from "lightning/platformShowToastEvent";

export default class ReleaseLog extends LightningElement {
  @track releases;

  connectedCallback() {
    getReleases()
      .then(result => {
        this.releases = result;
        console.log(result);
      })
      .catch(error => {
        let errorMessage = "Failed to load release log";
        if (error.body && error.body.message) {
          errorMessage = error.body.message;
        }
        this.showToast("Release Log Load Failed", errorMessage, error);
      });
  }

  showToast(theTitle, theMessage, theVariant) {
    const event = new ShowToastEvent({
      title: theTitle,
      message: theMessage,
      variant: theVariant
    });
    this.dispatchEvent(event);
  }
}
