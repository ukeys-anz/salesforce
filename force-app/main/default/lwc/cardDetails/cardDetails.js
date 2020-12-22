import { LightningElement, api } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import getCardDetails from "@salesforce/apex/CardDetailsController.getCardDetails";

export default class Cards extends LightningElement {
  @api recordId;
  activeSections = ["Primary", "Additional"];
  cardDetails = [];
  hasError = false;

  connectedCallback() {
    getCardDetails({ recordId: this.recordId })
      .then((result) => {
        if (result) {
          this.cardDetails = result[0];

          //Mask card number except last 4
          //This should already be encrypted when stored, but just an
          //extra layer of security to be certain
          this.cardDetails.Card_Number__c = this.cardDetails.Card_Number__c.replace(
            /(\w| )(?=(\w| ){4})/g,
            "*"
          );

          //Add spaces every 4 characters
          this.cardDetails.Card_Number__c = this.cardDetails.Card_Number__c.replace(
            /(.{4})/g,
            "$1 "
          );

          this.cardDetails.AccountHolder = this.cardDetails.FinServ__AccountHolder__r.Name;
        } else {
          this.hasError = true;
        }
      })
      .catch((error) => {
        let errorMessage = "Failed to retrieve card details";
        this.hasError = true;
        if (error.body && error.body.message) {
          errorMessage = error.body.message;
        }
        this.showToast("Card Detail Load Failed", errorMessage, error);
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

  formatDate(date) {
    //Format date to match AU formatting
    if (date) {
      return new Date(date).toLocaleDateString("en-AU");
    }
    return "";
  }
}
