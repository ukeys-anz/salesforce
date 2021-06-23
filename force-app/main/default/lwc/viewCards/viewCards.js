import { LightningElement, wire, api, track } from "lwc";

import { getRecord } from "lightning/uiRecordApi";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import ACCOUNT_OCV_ID_FIELD from "@salesforce/schema/Account.OCV_ID__c";
import card_images from "@salesforce/resourceUrl/card_images";

import hasViewCardsPermission from "@salesforce/customPermission/ANZx_View_Cards";
import getCardList from "@salesforce/apex/CoachBankingAPIRepository.getCardListAura";

export default class ViewCards extends LightningElement {
  @api recordId;
  ocvId;
  showDetails = false;
  loading = false;
  cardDetails = [];
  //Set this as we want to show one card first
  //before showing others
  initialCardDetails = [];
  @track showViewAllButton = false;
  @track viewAllCards = false;
  hasError = hasViewCardsPermission ? false : true;
  hasPermissionIssue = hasViewCardsPermission ? false : true;
  errorMsg = "";
  noCards = false;
  showFetch = true;
  defaultImage = `${card_images}/card_active.png`;
  showExpandCollapse = false;
  collapseExpandText = "Expand List";

  @wire(getRecord, {
    recordId: "$recordId",
    fields: [ACCOUNT_OCV_ID_FIELD]
  })
  wiredProject({ data }) {
    if (data) {
      this.ocvId = data.fields.OCV_ID__c.value;
    }
  }

  getCardDetails() {
    if (hasViewCardsPermission) {
      this.showFetch = false;
      this.loading = true;
      getCardList({
        ocvId: this.ocvId
      })
        .then((result) => {
          if (result.cards) {
            this.cardDetails = [...result.cards];
            if (this.cardDetails.length > 1) {
              this.showExpandCollapse = true;
              this.showViewAllButton = true;
            }
            for (let curCard of result.cards) {
              if (!curCard.isValid) {
                this.hasError = true;
                this.errorMsg =
                  "Card Information is invalid. Please reach out to your system administrator.";
              }
            }
            //sort card details so issued card is always first
            //if no issued card we just display in any order
            this.cardDetails.sort((card) => {
              return card.status === "Issued" ? -1 : 1;
            });
            this.cardDetails.forEach((card) => {
              card.expiryDate = this.handleDateFormat(card.expiryDate);
              //Map the relevant image to the statuses
              switch (card.status) {
                case "Issued":
                  card.image = `${card_images}/card_active.png`;
                  break;
                case "Temporary Block":
                  card.image = `${card_images}/card_locked.png`;
                  break;
                default:
                  card.image = `${card_images}/card_disabled.png`;
                  break;
              }
            });

            //remove the first card in array and assign
            //to the initial card
            this.initialCardDetails = this.cardDetails.shift();

            this.showDetails = true;
          } else {
            this.noCards = true;
          }
          this.loading = false;
        })
        .catch((error) => {
          this.errorMsg =
            "Failed to retrieve card list. Please refresh and try again. If the problem persists, please contact your System Administrator.";
          if (error.body && error.body.message) {
            let message = this.handleError(error.body.message);
            //Catch any system error messages (most readable errors wont be a single word)
            if (message && message.split(" ").length > 1) {
              this.errorMsg = message;
            }
          }
          this.hasError = true;
          this.loading = false;
          this.showToast("Card List Load Failed", this.errorMsg, error);
        });
    }
  }

  handleDateFormat(expiryDate) {
    let splitDate = expiryDate.split("/");
    //Check if month is single digit
    if (splitDate[0].length === 1) {
      //Append 0 if month is single digit
      expiryDate = "0" + splitDate[0] + "/" + splitDate[1];
    }

    return expiryDate;
  }

  //This function is required as some errors are returned
  //as stringified json
  handleError(error) {
    try {
      JSON.parse(error);
    } catch (e) {
      return error;
    }
    return JSON.parse(error).error;
  }

  showToast(theTitle, theMessage, theVariant) {
    const event = new ShowToastEvent({
      title: theTitle,
      message: theMessage,
      variant: theVariant
    });
    this.dispatchEvent(event);
  }

  handleViewAll() {
    this.viewAllCards = !this.viewAllCards;
    this.showViewAllButton = !this.showViewAllButton;
    if (this.collapseExpandText === "Expand List") {
      this.collapseExpandText = "Collapse List";
    } else {
      this.collapseExpandText = "Expand List";
    }
  }
}
