import { LightningElement, track, wire } from "lwc";
import getJsonResponse from "@salesforce/apex/TransactionHistoryController.getJsonResponse";
import { ShowToastEvent } from "lightning/platformShowToastEvent";

import { publish, MessageContext } from "lightning/messageService";
import ExpandCollapseAll from "@salesforce/messageChannel/ListCollapseExpandAll__c";

//Declare the keys for each specific section we can check
//if response returns them and dynamically show them on the component
const merchantKeys = [
  "MerchantName",
  "MerchantLocation",
  "MerchantPhone",
  "MerchantWebsite",
  "MerchantEmail",
  "IsSensitive"
];

const internationalKeys = [
  "ConvertedAmount",
  "ConvertedCurrencyCode",
  "ExchangeRate"
];

const cardKeys = ["CardScheme", "CardLastFour"];

export default class TransactionHistoryBoard extends LightningElement {
  fullTransactionList = [];
  currentLimit = 10;
  @track transactionList;
  @track showSearchBar = false;
  @track filterList = [];
  @track savedMaxIndex = 0;
  expandAll = false;

  @wire(MessageContext)
  messageContext;

  get showLoadMore() {
    return this.fullTransactionList.length > this.currentLimit;
  }

  connectedCallback() {
    getJsonResponse()
      .then((result) => {
        this.fullTransactionList = JSON.parse(result).body;
        let updatedFullList = [];
        for (let i = 0; i < this.fullTransactionList.length; i++) {
          let currentTransaction = this.fullTransactionList[i];

          //Check to see if we have the details required to show
          //the dynamic sections of our transactions
          let transactionKeys = Object.keys(currentTransaction);
          transactionKeys.forEach((key) => {
            if (merchantKeys.includes(key)) {
              currentTransaction.merchantDetails = true;
            } else if (internationalKeys.includes(key)) {
              currentTransaction.internationalDetails = true;
            } else if (cardKeys.includes(key)) {
              currentTransaction.cardDetails = true;
            }
          });

          if (i === 0) {
            currentTransaction.showDateTitle = true;
          } else if (
            currentTransaction.TransactionDate !==
            this.fullTransactionList[i - 1].TransactionDate
          ) {
            currentTransaction.showDateTitle = true;
          } else {
            currentTransaction.showDateTitle = false;
          }

          //Apply odd or even for each item to determine background
          currentTransaction.rowColour =
            "slds-card slds-m-bottom_small transaction-item ";
          currentTransaction.rowColour += i % 2 === 0 ? "even" : "odd";

          //Split the tags into an array
          if (currentTransaction.Tags) {
            currentTransaction.tagList = currentTransaction.Tags.split(";");
          }

          currentTransaction.Error = currentTransaction.Error
            ? currentTransaction.Error
            : "N/A";

          if (currentTransaction.Latitude && currentTransaction.Longitude) {
            //Set the map markers for the map
            currentTransaction.mapMarkers = [
              {
                location: {
                  Latitude: currentTransaction.Latitude,
                  Longitude: currentTransaction.Longitude
                }
              }
            ];
          }

          updatedFullList.push(currentTransaction);
        }

        if (this.currentLimit >= updatedFullList.length) {
          this.transactionList = updatedFullList;
        } else {
          this.transactionList = [];
          for (let i = 0; i < this.currentLimit; i++) {
            this.transactionList.push(updatedFullList[i]);
          }
        }
      })
      .catch((error) => {
        let errorMessage = "Get transaction history failed. Please retry.";
        if (error.body.message) {
          errorMessage = error.body.message;
        }
        this.showToast(
          "Transaction history service Failed",
          errorMessage,
          error
        );
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

  handleLoadMore() {
    this.currentLimit += 10;
    if (this.currentLimit >= this.fullTransactionList.length) {
      this.transactionList = this.fullTransactionList;
    } else {
      this.transactionList = [];
      for (let i = 0; i < this.currentLimit; i++) {
        this.transactionList.push(this.fullTransactionList[i]);
      }
    }
  }

  handleSearchFilterToggle() {
    this.showSearchBar = !this.showSearchBar;
  }

  handleCancelFilter() {
    this.showSearchBar = false;
  }

  handleSaveFilter(event) {
    this.filterList = event.detail.detail;
    this.savedMaxIndex = event.detail.maxIndex;
    this.showSearchBar = false;
  }

  handleExpandAll() {
    this.expandAll = !this.expandAll;
    const payload = { expand: this.expandAll };
    publish(this.messageContext, ExpandCollapseAll, payload);
  }
}
