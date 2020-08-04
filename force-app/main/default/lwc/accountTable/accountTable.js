import { LightningElement, track } from "lwc";
import getAccInfo from "@salesforce/apex/accountTableServerController.getAccInfo";
import { ShowToastEvent } from "lightning/platformShowToastEvent";

export default class AccountTable extends LightningElement {
  @track accounts;

  connectedCallback() {
    getAccInfo()
      .then((result) => {
        this.accounts = result;
      })
      .catch((error) => {
        let errorMessage = "Call account service failed. Please retry.";
        if (error.body.message) {
          errorMessage = error.body.message;
        }
        this.showToast("Account Service Failed", errorMessage, error);
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
