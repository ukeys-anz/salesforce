import { LightningElement, wire, api, track } from "lwc";

import { getRecord } from "lightning/uiRecordApi";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import ACCOUNT_OCV_ID_FIELD from "@salesforce/schema/Account.OCV_ID__c";
import card_images from "@salesforce/resourceUrl/card_images";

import hasViewCardsPermission from "@salesforce/customPermission/ANZx_View_Cards";
import hasLockCardsPermission from "@salesforce/customPermission/ANZx_Temp_Lock_Card";
import hasReplaceCardsPermission from "@salesforce/customPermission/ANZx_Replace_Card";

import getCardList from "@salesforce/apex/CoachBankingAPIRepository.getCardListAura";

import { subscribe, MessageContext } from "lightning/messageService";
import CloseModal from "@salesforce/messageChannel/CloseModal__c";

const REPLACE_ELIGIBILITIES = [
  "ELIGIBILITY_CARD_REPLACEMENT_LOST",
  "ELIGIBILITY_CARD_REPLACEMENT_STOLEN",
  "ELIGIBILITY_CARD_REPLACEMENT_DAMAGED"
];

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
  showLock = false;
  subscription = null;
  tokenizedCardNumber = "";
  allCards = [];
  showReplace = false;
  replaceLostUnavailable;
  replaceStolenUnavailable;
  replaceDamagedUnavailable;
  replaceLockUnavailable;

  @wire(getRecord, {
    recordId: "$recordId",
    fields: [ACCOUNT_OCV_ID_FIELD]
  })
  wiredProject({ data }) {
    if (data) {
      this.ocvId = data.fields.OCV_ID__c.value;
    }
  }

  @wire(MessageContext)
  messageContext;

  connectedCallback() {
    this.subscription = subscribe(
      this.messageContext,
      CloseModal,
      (message) => {
        switch (message.name) {
          case "lock":
            this.showLock = message.show;
            break;
          case "replace":
            this.showReplace = message.show;
            break;
          default:
            break;
        }
        if (message.message) {
          if (message.success) {
            //Clear card details and refetch
            this.cardDetails = [];
            this.initialCardDetails = [];
            this.allCards = [];

            //Refetch card details to get latest statuses
            this.getCardDetails();
          }

          this.showToast(
            "Card Management",
            message.message,
            message.success ? "success" : "error"
          );
        }
      }
    );
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
              //Have this check to ensure button doesnt show
              //if all cards already in view
              if (!this.viewAllCards) {
                this.showViewAllButton = true;
              }
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
            this.cardDetails.forEach((card, index) => {
              card.cardId = index;
              card.expiryDate = this.handleDateFormat(card.expiryDate);
              //Map the relevant image to the statuses
              switch (card.status) {
                case "Issued":
                  card.image = `${card_images}/card_active.png`;
                  break;
                case "Temporary Block":
                  card.image = `${card_images}/card_locked.png`;
                  //reword status to match correct terms
                  card.status = "Temporary Lock";
                  card.isLocked = true;
                  break;
                default:
                  card.image = `${card_images}/card_disabled.png`;
                  card.hideTempLock = true;
                  card.hideReplaceCard = true;
                  break;
              }

              if (hasLockCardsPermission) {
                card.preventLock = card.eligibilities.includes(
                  "ELIGIBILITY_BLOCK"
                )
                  ? false
                  : true;
              } else {
                card.hideTempLock = true;
              }

              if (hasReplaceCardsPermission) {
                card.preventReplace = REPLACE_ELIGIBILITIES.some((el) =>
                  card.eligibilities.includes(el)
                )
                  ? false
                  : true;
              } else {
                card.hideReplaceCard = true;
              }

              this.allCards.push(card);
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

  handleShowLock(event) {
    //Get the card based on the target id
    let card = this.allCards.find(
      (chosenCard) =>
        chosenCard.cardId === parseInt(event.target.dataset.id, 10)
    );
    this.tokenizedCardNumber = card.tokenizedCardNumber;
    this.showLock = !this.showLock;
  }

  handleShowReplace(event) {
    //Get the card based on the target id
    let card = this.allCards.find(
      (chosenCard) =>
        chosenCard.cardId === parseInt(event.target.dataset.id, 10)
    );
    this.tokenizedCardNumber = card.tokenizedCardNumber;

    //Determine eligibilities available for the replace steps
    //Note: We cant pass the whole eligibilities array as it is proxied when passed to child component
    //(https://developer.salesforce.com/docs/component-library/documentation/en/lwc/lwc.security_array_proxy)
    this.replaceLostUnavailable = !card.eligibilities.includes(
      "ELIGIBILITY_CARD_REPLACEMENT_LOST"
    );
    this.replaceStolenUnavailable = !card.eligibilities.includes(
      "ELIGIBILITY_CARD_REPLACEMENT_STOLEN"
    );
    this.replaceDamagedUnavailable = !card.eligibilities.includes(
      "ELIGIBILITY_CARD_REPLACEMENT_DAMAGED"
    );
    this.replaceLockUnavailable = !card.eligibilities.includes(
      "ELIGIBILITY_BLOCK"
    );
    this.showReplace = !this.showReplace;
  }
}
