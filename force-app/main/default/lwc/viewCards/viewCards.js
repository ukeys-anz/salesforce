import { LightningElement, wire, api, track } from "lwc";

import { getRecord } from "lightning/uiRecordApi";
import ACCOUNT_OCV_ID_FIELD from "@salesforce/schema/Account.OCV_ID__c";
import card_images from "@salesforce/resourceUrl/card_images";

import hasViewCardsPermission from "@salesforce/customPermission/ANZx_View_Cards";

//Mock data until API is up and running
let response = {
  cards: [
    {
      name: "Bruce Willis",
      tokenizedCardNumber: "1234567890",
      last4Digits: "4123",
      status: "Closed",
      expiryTime: "2020-09-24T00:00:00Z",
      accountNumber: "",
      eligibilities: [
        "ELIGIBILITY_APPLE_PAY",
        "ELIGIBILITY_GOOGLE_PAY",
        "ELIGIBILITY_SAMSUNG_PAY",
        "ELIGIBILITY_SET_PIN",
        "ELIGIBILITY_CHANGE_PIN",
        "ELIGIBILITY_CARD_REPLACEMENT_LOST",
        "ELIGIBILITY_CARD_REPLACEMENT_STOLEN",
        "ELIGIBILITY_CARD_REPLACEMENT_DAMAGED",
        "ELIGIBILITY_CARD_CONTROLS",
        "ELIGIBILITY_BLOCK"
      ]
    },
    {
      name: "Peter Charalambous",
      tokenizedCardNumber: "1234567890",
      last4Digits: "9876",
      status: "Issued",
      expiryTime: "2023-02-19T00:00:00Z",
      accountNumber: "",
      eligibilities: [
        "ELIGIBILITY_APPLE_PAY",
        "ELIGIBILITY_GOOGLE_PAY",
        "ELIGIBILITY_SAMSUNG_PAY",
        "ELIGIBILITY_SET_PIN",
        "ELIGIBILITY_CHANGE_PIN",
        "ELIGIBILITY_CARD_REPLACEMENT_LOST",
        "ELIGIBILITY_CARD_REPLACEMENT_STOLEN",
        "ELIGIBILITY_CARD_REPLACEMENT_DAMAGED",
        "ELIGIBILITY_CARD_CONTROLS",
        "ELIGIBILITY_BLOCK"
      ]
    },
    {
      name: "Bernie Sanders",
      tokenizedCardNumber: "1234567890",
      last4Digits: "1111",
      status: "Temporary Block",
      expiryTime: "2020-12-21T00:00:00Z",
      accountNumber: "",
      eligibilities: [
        "ELIGIBILITY_APPLE_PAY",
        "ELIGIBILITY_GOOGLE_PAY",
        "ELIGIBILITY_SAMSUNG_PAY",
        "ELIGIBILITY_SET_PIN",
        "ELIGIBILITY_CHANGE_PIN",
        "ELIGIBILITY_CARD_REPLACEMENT_LOST",
        "ELIGIBILITY_CARD_REPLACEMENT_STOLEN",
        "ELIGIBILITY_CARD_REPLACEMENT_DAMAGED",
        "ELIGIBILITY_CARD_CONTROLS",
        "ELIGIBILITY_BLOCK"
      ]
    }
  ]
};

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
  hasPermission = hasViewCardsPermission ? false : true;
  error;
  noCards = false;
  showFetch = true;

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
      if (response.cards) {
        this.cardDetails = [...response.cards];
        if (this.cardDetails.length > 1) {
          this.showViewAllButton = true;
        }
        //sort card details so issued card is always first
        //if no issued card we just display in any order
        this.cardDetails.sort((card) => (card.status === "Issued" ? -1 : 1));
        this.cardDetails.forEach((card) => {
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

          //format date from ISO
          card.expiryTime = new Date(card.expiryTime).toLocaleDateString(
            "en-AU"
          );
        });

        //remove the first card in array and assign
        //to the initial card
        this.initialCardDetails = this.cardDetails.shift();

        this.showDetails = true;
      } else {
        this.noCards = true;
      }
      this.loading = false;
    }
  }

  handleViewAll() {
    this.viewAllCards = !this.viewAllCards;
    this.showViewAllButton = !this.showViewAllButton;
  }
}
