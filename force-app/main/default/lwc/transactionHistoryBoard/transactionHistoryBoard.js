import { LightningElement, track, wire, api } from "lwc";
import getTransactions from "@salesforce/apex/TransactionHistoryController.getTransactions";

import { getRecord } from "lightning/uiRecordApi";
import { ShowToastEvent } from "lightning/platformShowToastEvent";

import FIN_ACCOUNT_OCV_ID_FIELD from "@salesforce/schema/FinServ__FinancialAccount__c.OCV_ID__c";
import FIN_ACCOUNT_ACCOUNT_NUMBER_FIELD from "@salesforce/schema/FinServ__FinancialAccount__c.FinServ__FinancialAccountNumber__c";

import { publish, MessageContext } from "lightning/messageService";
import ExpandCollapseAll from "@salesforce/messageChannel/ListCollapseExpandAll__c";

import hasAccountsGoalsPermission from "@salesforce/customPermission/ANZx_Accounts_and_Goals";

//Remapping the status and types returned from the API so they
//are more readable on the UI
const transactionStatusMapping = {
  TRANSACTION_STATUS_UNSPECIFIED: "Unknown",
  TRANSACTION_STATUS_PENDING: "Pending",
  TRANSACTION_STATUS_POSTED: "Posted"
};

const transactionTypeMapping = {
  TRANSACTION_TYPE_UNSPECIFIED: "Unknown",
  TRANSACTION_TYPE_CARD: "Card",
  TRANSACTION_TYPE_DIRECT_DEBIT: "Direct Debit",
  TRANSACTION_TYPE_FEE: "Fee",
  TRANSACTION_TYPE_INTEREST: "Interest",
  TRANSACTION_TYPE_DEPOSIT_WITHDRAWAL: "Deposit Withdrawal",
  TRANSACTION_TYPE_TRANSFER: "Transfer",
  TRANSACTION_TYPE_PAYID: "PAYID",
  TRANSACTION_TYPE_BSB_ACC_NUM: "BSB/ACC",
  TRANSACTION_TYPE_BPAY: "BPAY",
  TRANSACTION_TYPE_OTHER: "Other"
};

const cardMapping = {
  CARD_SCHEME_UNSPECIFIED: "Unknown",
  CARD_SCHEME_VISA: "Visa",
  CARD_SCHEME_MASTERCARD: "MasterCard",
  CARD_SCHEME_EFTPOS: "EFTPOS",
  CARD_SCHEME_AMERICAN_EXPRESS: "American Express"
};

export default class TransactionHistoryBoard extends LightningElement {
  @api recordId;
  fullTransactionList = [];
  @track transactionList = [];
  @track showSearchBar = false;
  @track filterList = [];
  @track savedMaxIndex = 0;
  expandAll = false;
  startDate;
  endDate = new Date().toISOString().slice(0, 10);
  todayDate = new Date().toISOString().slice(0, 10);
  disableSearch = true;
  ocvId;
  accountNumber;
  hasError = false;
  errorMessage;
  totalTransactions;
  links;
  loading = true;

  @wire(MessageContext)
  messageContext;

  //Get the OCVID and Account Number to send to
  //the API and get the transactions
  @wire(getRecord, {
    recordId: "$recordId",
    fields: [FIN_ACCOUNT_OCV_ID_FIELD, FIN_ACCOUNT_ACCOUNT_NUMBER_FIELD]
  })
  wiredProject({ data }) {
    if (data && hasAccountsGoalsPermission) {
      this.ocvId = data.fields.OCV_ID__c.value;
      this.accountNumber = data.fields.FinServ__FinancialAccountNumber__c.value;
      this.fetchTransactions();
    }
  }

  get displayContent() {
    return hasAccountsGoalsPermission;
  }

  get showLoadMore() {
    return this.links && this.links.next && this.links.next.href ? true : false;
  }

  fetchTransactions(paramUrl = "", isSearch = false) {
    getTransactions({
      ocvId: this.ocvId,
      accountNumber: this.accountNumber,
      paramUrl: paramUrl
    })
      .then((result) => {
        if (result) {
          const resultObj = JSON.parse(result);
          this.totalTransactions = resultObj.total;
          this.fullTransactionList = resultObj.transactions;
          this.links = resultObj.links;
          let updatedFullList = [];

          if (this.fullTransactionList) {
            for (let i = 0; i < this.fullTransactionList.length; i++) {
              let currentTransaction = { ...this.fullTransactionList[i] };

              //Remove $ from value and convert to int
              if (
                currentTransaction.amount &&
                currentTransaction.amount.charged &&
                currentTransaction.amount.charged.value
              ) {
                currentTransaction.amount.charged.value = parseFloat(
                  currentTransaction.amount.charged.value.replace("$", ""),
                  10
                ).toFixed(2);
              } else {
                currentTransaction.amount.charged.value = 0;
              }

              //Remap type and status
              currentTransaction.type = currentTransaction.type
                ? transactionTypeMapping[currentTransaction.type]
                : "Unknown";
              currentTransaction.status = currentTransaction.status
                ? transactionStatusMapping[currentTransaction.status]
                : "Unknown";

              //Slice the returned date time to get only the date
              currentTransaction.TransactionDate = currentTransaction.date
                ? currentTransaction.date.slice(0, 10)
                : "Unknown";

              //Return only the time from the date time
              currentTransaction.TransactionTime = currentTransaction.date
                ? currentTransaction.date.match(/\d\d:\d\d/)
                : "Unknown";

              if (i === 0) {
                currentTransaction.showDateTitle = true;
              } else if (
                currentTransaction.TransactionDate !==
                this.fullTransactionList[i - 1].date.slice(0, 10)
              ) {
                currentTransaction.showDateTitle = true;
              } else {
                currentTransaction.showDateTitle = false;
              }

              //Apply odd or even for each item to determine background
              currentTransaction.rowColour =
                "slds-card slds-m-bottom_small transaction-item ";
              currentTransaction.rowColour += i % 2 === 0 ? "even" : "odd";

              if (currentTransaction.tags) {
                currentTransaction.tagList = [];
                //loop through tags
                currentTransaction.tags.forEach((tag) => {
                  //Truncate tag name
                  if (tag.name && tag.name.length > 15) {
                    tag.name = tag.name.substring(0, 14) + "...";
                  }
                  currentTransaction.tagList.push(tag.name);
                });
              }

              //Handle merchant details
              if (currentTransaction.merchant) {
                currentTransaction = this.handleMerchantDetails(
                  currentTransaction
                );
              }

              //Remap card scheme to be user friendly
              if (currentTransaction.card) {
                currentTransaction.card.scheme = currentTransaction.card.scheme
                  ? cardMapping[currentTransaction.card.scheme]
                  : "Unknown";
              }

              //Check if international transaction
              if (
                currentTransaction.amount &&
                currentTransaction.amount.type === "EXCHANGE_TYPE_INTERNATIONAL"
              ) {
                currentTransaction.internationalDetails = true;
              }

              currentTransaction.error = currentTransaction.error
                ? currentTransaction.error
                : "N/A";

              updatedFullList.push(currentTransaction);
            }
          }

          //Clear transaction list to only display search results
          if (isSearch) {
            this.transactionList = [];
          }
          updatedFullList.forEach((e) => {
            this.transactionList.push(e);
          });
        }

        this.loading = false;
      })
      .catch((error) => {
        this.errorMessage =
          "Failed to retrieve transaction history. Please refresh and try again. If the problem persists, please contact your System Administrator.";
        if (error.body && error.body.message) {
          let message = this.handleError(error.body.message);
          //Catch any system error messages (most readable errors wont be a single word)
          if (message && message.split(" ").length > 1) {
            this.errorMessage = message;
          }
        }
        this.hasError = true;
        this.loading = false;
        this.showToast(
          "Transaction History Load Failed",
          this.errorMessage,
          error
        );
      });
  }

  handleMerchantDetails(transaction) {
    transaction.merchantDetails = true;
    transaction.name = transaction.merchant.chain_name
      ? transaction.merchant.chain_name.value
      : transaction.merchant.name;

    if (transaction.merchant.address) {
      if (
        transaction.merchant.address.line_one &&
        transaction.merchant.address.suburb &&
        transaction.merchant.address.state &&
        transaction.merchant.address.postcode
      ) {
        transaction.merchantLocation = `${transaction.merchant.address.line_one.value}, ${transaction.merchant.address.suburb.value} ${transaction.merchant.address.state.value} ${transaction.merchant.address.postcode.value}`;
      } else {
        transaction.merchantLocation = "Unknown";
      }

      if (transaction.merchant.address.coordinates) {
        //Set the map markers for the map
        transaction.mapMarkers = [
          {
            location: {
              Latitude: transaction.merchant.address.coordinates.latitude,
              Longitude: transaction.merchant.address.coordinates.longitude
            }
          }
        ];
      }
    }

    if (
      transaction.merchant.image_details &&
      transaction.merchant.image_details.light_url
    ) {
      transaction.logo = transaction.merchant.image_details.light_url.value;
    } else {
      transaction.logo = null;
    }

    transaction.merchant.email = transaction.merchant.email
      ? transaction.merchant.email.value
      : "Unknown";

    return transaction;
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
    //The provided URL doesn't go through MS, so we need
    //to retrieve the params and pass them to the Apex class
    //and append it to the request
    let nextSubstring = `&${this.links.next.href.substring(
      this.links.next.href.indexOf("?") + 1
    )}`;

    this.fetchTransactions(nextSubstring);
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

  handleSearch() {
    if (this.startDate && this.endDate) {
      this.loading = true;
      //Need to convert dates to ISO string for search params
      let urlParam = `&start_date=${new Date(
        this.startDate + " 00:00:00 UTC"
      ).toISOString()}&end_date=${new Date(
        this.endDate + " 23:59:59 UTC"
      ).toISOString()}`;

      this.fetchTransactions(urlParam, true);
    }
  }

  handleStartDateChange(e) {
    this.startDate = e.detail.value;
    if (this.startDate > this.endDate || this.startDate > this.todayDate) {
      this.disableSearch = true;
    } else if (this.startDate && this.endDate) {
      this.disableSearch = false;
    } else {
      this.disableSearch = true;
    }
  }

  handleEndDateChange(e) {
    this.endDate = e.detail.value;
    if (
      (this.startDate && this.endDate < this.startDate) ||
      this.endDate > this.todayDate
    ) {
      this.disableSearch = true;
    } else if (this.endDate && this.startDate) {
      this.disableSearch = false;
    } else {
      this.disableSearch = true;
    }
  }

  //This function is required as some errors are returned
  //as stringified json
  handleError(error) {
    try {
      JSON.parse(error);
    } catch (e) {
      return error;
    }
    return JSON.parse(error).message;
  }
}
