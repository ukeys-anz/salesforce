import { LightningElement, track, api } from "lwc";
import getCaseDurationTime from "@salesforce/apex/CaseDurationServerController.getCaseDurationTime";
import { ShowToastEvent } from "lightning/platformShowToastEvent";

export default class CaseDuration extends LightningElement {
  @track durationTime;
  @api recordId;

  connectedCallback() {
    getCaseDurationTime({ caseId: this.recordId })
      .then((result) => {
        this.durationTime = result;
      })
      .catch((error) => {
        let errorMessage = "Failed to load case duration";
        if (error.body && error.body.message) {
          errorMessage = error.body.message;
        }
        this.showToast("Case Duration Load Failed", errorMessage, error);
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
