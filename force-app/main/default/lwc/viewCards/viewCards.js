import { LightningElement, wire, api, track } from "lwc";
import { getRecord } from "lightning/uiRecordApi";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { createButtonsFromArray } from "./helper/helper-button-class";

import { errorHanlder } from "./helper/helper-errors";
import { cardImageHandler } from "./helper/helper-cardImages";
import ACCOUNT_OCV_ID_FIELD from "@salesforce/schema/Account.OCV_ID__c";
import getCardList from "@salesforce/apex/CoachBankingAPIRepository.getCardListAura";
import { subscribe, MessageContext } from "lightning/messageService";
import CloseModal from "@salesforce/messageChannel/CloseModal__c";
import {
  CARD_IMAGES as cardImages,
  USER_PERMISSION as userPermission
} from "./helper/import-sf-const";

export default class ViewCards extends LightningElement {
  @api recordId;
  @track viewAllCards = false;
  @track cardFraudLockStatus = "";
  @track showViewAllButton = false;

  ocvId;
  subscription = null;
  errorMsg = "";
  last4Digits = "";
  cardDetails = [];
  buttonClicked = "";
  initialCardsDetails = [];
  tokenizedCardNumber = "";
  collapseExpandText = "Expand List";
  replaceLockUnavailable = true;
  replaceLostUnavailable = true;
  replaceStolenUnavailable = true;
  replaceDamagedUnavailable = true;

  loading = false;
  noCards = false;
  showFetch = true;
  showLock = false;
  showFraudLock = false;
  showReplace = false;
  showDetails = false;
  showExpandCollapse = false;

  hasPermissionIssue = userPermission.hasViewPermission ? false : true;
  defaultImage = cardImageHandler(cardImages);
  hasError = userPermission.hasViewPermission ? false : true;

  @wire(getRecord, { recordId: "$recordId", fields: [ACCOUNT_OCV_ID_FIELD] })
  wiredProject({ data }) {
    if (data) {
      this.ocvId = data.fields.OCV_ID__c.value;
    }
  }

  @wire(MessageContext)
  messageContext;

  connectedCallback() {
    this.subscriptionHandler();
  }

  subscriptionHandler = () => {
    this.subscription = subscribe(
      this.messageContext,
      CloseModal,
      (message) => {
        if (message.name === "replace") {
          this.showReplace = message.show;
        } else if (message.name === "lock") {
          this.showLock = message.show;
        } else {
          this.showFraudLock = message.show;
        }
        if (message.message) {
          if (message.success) {
            //Clear card details and refetch
            this.cardDetails = [];
            this.initialCardsDetails = [];

            //Refetch card details to get latest statuses
            this.getCardDetails();
          }
          this.showToast("subscription", message);
        }
      }
    );
  };
  getCardDetails = () => {
    if (userPermission.hasViewPermission) {
      this.showFetch = false;
      this.loading = true;

      getCardList({ ocvId: this.ocvId })
        .then((result) => {
          if (result.cards) {
            this.initialCardsDetails = this.mapCardDetails(result.cards);
            this.cardDetails = [this.initialCardsDetails[0]];
            this.showViewAllButtonHandler();
            this.isInvalidCardHandler();

            this.showDetails = true;
          } else {
            this.noCards = true;
          }
          this.loading = false;
        })
        .catch((error) => {
          this.hasError = true;
          this.loading = false;
          this.showToast("cardDetailsError", error.body);
        });
    }
  };

  showViewAllButtonHandler = () => {
    if (this.initialCardsDetails.length > 1) {
      this.showExpandCollapse = true;
      // Have this check to ensure button doesnt show
      // if all cards already in view
      if (!this.viewAllCards) {
        this.showViewAllButton = true;
      }
    }
  };

  // check if all the cards are valid
  isInvalidCardHandler = () => {
    let invalidCard = this.initialCardsDetails.find(
      (curCard) => !curCard.isValid
    );
    if (invalidCard) {
      this.hasError = true;
      this.errorMsg = errorHanlder.invalidCard;
    }
  };

  showToast = (toastFor, msg) => {
    this.dispatchEvent(new ShowToastEvent(errorHanlder[toastFor](msg)));
  };

  handleViewAll() {
    this.viewAllCards = !this.viewAllCards;
    this.showViewAllButton = !this.showViewAllButton;
    this.cardDetails = this.viewAllCards
      ? this.initialCardsDetails
      : [this.initialCardsDetails[0]];
    if (this.collapseExpandText === "Expand List") {
      this.collapseExpandText = "Collapse List";
    } else {
      this.collapseExpandText = "Expand List";
    }
  }

  handleActionAccordingClickedButton = (event) => {
    const label = event.target.label;
    const cardNumber = event.target.dataset.cardNumber;
    const card = this.initialCardsDetails.find(
      (theCard) => theCard.tokenizedCardNumber === cardNumber
    );
    const inputObject = {
      card,
      label,
      showLock: this.showLock,
      showFraudLock: this.showFraudLock,
      showReplace: this.showReplace,
      replaceDamagedUnavailable: this.replaceDamagedUnavailable,
      replaceLockUnavailable: this.replaceLockUnavailable,
      replaceLostUnavailable: this.replaceLostUnavailable,
      replaceStolenUnavailable: this.replaceStolenUnavailable
    };
    const buttonClicked = card.buttons.find((btn) => btn.label === label);
    const returnObject = buttonClicked.actionFunction(inputObject);
    for (let key in returnObject) {
      if (typeof this[key] !== "undefined") {
        this[key] = returnObject[key];
      }
    }
  };

  mapCardDetails = (cards) => {
    let mappedCards = createButtonsFromArray(cards, userPermission);
    mappedCards.forEach(
      (c) => (c.image = cardImageHandler(cardImages, c.status))
    );
    return mappedCards;
  };
}
