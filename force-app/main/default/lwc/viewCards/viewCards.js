import { LightningElement, wire, api } from "lwc";
import { getRecord } from "lightning/uiRecordApi";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { subscribe, MessageContext } from "lightning/messageService";
import { CurrentPageReference } from "lightning/navigation";
import { mapCardDetailsHandler } from "./helper/helper-cards";
import { errorHandler } from "./helper/helper-errors";
import { cardImageHandler } from "./helper/helper-cardImages";
import {
  CARD_IMAGES as cardImages,
  USER_PERMISSION as userPermission
} from "./helper/import-sf-const";
import CloseModal from "@salesforce/messageChannel/CloseModal__c";
import Id from "@salesforce/user/Id";
import UserNameField from "@salesforce/schema/User.Name";
import ViewCardNumber from "c/viewFullCardNumber";
//Added as part of ANZX-128123
import CardsAccountTypeForSorting from "@salesforce/label/c.CardsAccountTypeForSorting";

export default class ViewCards extends LightningElement {
  @api cardsFromParent;
  @api recordId;
  @api
  get isActiveCardSection() {
    return this._isActiveCardSection === "true" ? true : false;
  }

  set isActiveCardSection(value) {
    this._isActiveCardSection = value;
  }

  cards;
  _isActiveCardSection;
  _showViewCardNumber = false;
  cardsLeftToView;
  currentUserName;
  cardFraudLockStatus = "";
  errorMsg = "";
  last4Digits = "";
  buttonClicked = "";
  tokenizedCardNumber = "";
  cardHolder = "";
  accountType = "";
  subscription = null;
  onLoadCardDisplayCount = 6;
  replaceLockUnavailable = true;
  replaceLostUnavailable = true;
  replaceStolenUnavailable = true;
  replaceDamagedUnavailable = true;
  showViewAllButton = false;
  loading = false;
  showLock = false;
  showFraudLock = false;
  showReplace = false;
  showDetails = false;
  viewAllCards = false;
  initialCardsDetails = [];
  cardDetails = [];
  defaultImage = cardImageHandler(cardImages);

  get showViewCardNumber() {
    return this._showViewCardNumber;
  }
  set showViewCardNumber(value) {
    this._showViewCardNumber = value;
    if (value) {
      this.openViewCardNumberModal();
    }
  }

  //Get the current logged-in user details
  @wire(getRecord, { recordId: Id, fields: [UserNameField] })
  currentUserInfo({ data, error }) {
    if (data) {
      this.currentUserName = data.fields.Name.value;
    } else if (error) {
      this.error = error;
    }
  }

  @wire(MessageContext)
  messageContext;

  @wire(CurrentPageReference)
  pageRef;

  connectedCallback() {
    //The data is being received proxied, so we stringify it
    //and parse it to unproxy it
    this.cards = JSON.parse(JSON.stringify(this.cardsFromParent));
    this.processCardDetails();
    this.subscriptionHandler();
  }

  subscriptionHandler() {
    this.subscription = subscribe(this.messageContext, CloseModal, (data) => {
      switch (data.name) {
        case "replace":
          this.showReplace = data.show;
          break;
        case "lock":
          this.showLock = data.show;
          break;
        default:
          this.showFraudLock = data.show;
          break;
      }
      if (data.message) {
        if (data.success) {
          //Clear card details and refetch
          this.cardDetails = [];
          this.initialCardsDetails = [];
          //Refetch card details to get latest statuses
          this.pushRefreshCardDetailsEvent();
        }
        this.showToast("subscription", data);
      }
    });
  }

  processCardDetails() {
    if (this.cards?.length > 0) {
      this.initialCardsDetails = this.sortCardDetails(
        this.mapCardDetails(this.cards)
      );
      //Added this in order to handle the expansion of card details if load more is already clicked
      this.cardDetails = this.fetchInitialCardsToShow();
      this.cardsLeftToView = this.pendingCardsTobeViewed();
      this.showViewAllButtonHandler();
      this.showDetails = true;
    }
  }

  fetchInitialCardsToShow() {
    return this.initialCardsDetails.slice(0, this.onLoadCardDisplayCount);
  }

  pendingCardsTobeViewed() {
    return this.initialCardsDetails.length > this.onLoadCardDisplayCount
      ? this.initialCardsDetails.length - this.onLoadCardDisplayCount
      : 0;
  }

  showViewAllButtonHandler() {
    if (
      this.initialCardsDetails.length > this.onLoadCardDisplayCount &&
      !this.viewAllCards
    ) {
      this.showViewAllButton = true;
    }
  }

  showToast = (toastFor, msg) => {
    this.dispatchEvent(new ShowToastEvent(errorHandler[toastFor](msg)));
  };

  handleViewAll() {
    this.viewAllCards = !this.viewAllCards;
    this.showViewAllButton = !this.showViewAllButton;
    this.cardDetails = this.initialCardsDetails;
  }

  handleActionAccordingClickedButton = (event) => {
    const label = event.target.label;
    const cardNumber = event.target.dataset.cardNumber;
    const card = this.initialCardsDetails.find(
      (theCard) => theCard.tokenized_card_number === cardNumber
    );
    const inputObject = {
      card,
      label,
      showLock: this.showLock,
      showFraudLock: this.showFraudLock,
      showViewCardNumber: this.showViewCardNumber,
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
    let mappedCards = mapCardDetailsHandler(
      cards,
      userPermission,
      this.isActiveCardSection
    );
    mappedCards.forEach((c) => (c.image = cardImageHandler(cardImages, c)));
    return mappedCards;
  };

  //Sorting the order of cards based on type of accountType - Added as part of ANZX-128123
  sortCardDetails(arrOfCards) {
    return arrOfCards.sort((firstCard, otherCard) => {
      const accountTypeOrder = CardsAccountTypeForSorting.split(",");
      let sortValue = 0;
      if (firstCard.accountType !== otherCard.accountType) {
        sortValue =
          accountTypeOrder.indexOf(firstCard.accountType) -
          accountTypeOrder.indexOf(otherCard.accountType);
      }
      return sortValue;
    });
  }

  //Dispatch an event to refresh the data if any button got clicked
  pushRefreshCardDetailsEvent() {
    this.dispatchEvent(
      new CustomEvent("refreshcarddetails", {
        detail: true
      })
    );
  }

  async openViewCardNumberModal() {
    await ViewCardNumber.open({
      size: "small",
      cardNumber: this.tokenizedCardNumber,
      cardHolder: this.cardHolder,
      accountType: this.accountType,
      ocvId: this.pageRef.state.c__ocvId
    });
  }
}
