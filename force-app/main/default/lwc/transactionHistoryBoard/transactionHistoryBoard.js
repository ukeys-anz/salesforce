import { LightningElement, track } from "lwc";
import getJsonResponse from "@salesforce/apex/TransactionHistoryController.getJsonResponse";
import { ShowToastEvent } from "lightning/platformShowToastEvent";

export default class TransactionHistoryBoard extends LightningElement {
  fullTransactionList = [];
  currentLimit = 10;
  @track transactionList;
  @track showSearchBar = false;
  @track filterList = [];
  @track savedMaxIndex = 0;

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
}
