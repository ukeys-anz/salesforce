import { LightningElement, track, wire, api } from "lwc";
import getTransactions from "@salesforce/apex/TransactionHistoryController.getTransactions";

import { getRecord } from "lightning/uiRecordApi";
import { ShowToastEvent } from "lightning/platformShowToastEvent";

import FIN_ACCOUNT_OCV_ID_FIELD from "@salesforce/schema/FinServ__FinancialAccount__c.OCV_ID__c";
import FIN_ACCOUNT_ACCOUNT_NUMBER_FIELD from "@salesforce/schema/FinServ__FinancialAccount__c.FinServ__FinancialAccountNumber__c";

import { publish, MessageContext } from "lightning/messageService";
import ExpandCollapseAll from "@salesforce/messageChannel/ListCollapseExpandAll__c";

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
  TRANSACTION_TYPE_BSB_ACC_NUM: "BSB",
  TRANSACTION_TYPE_BPAY: "BPAY",
  TRANSACTION_TYPE_OTHER: "Other"
};

export default class TransactionHistoryBoard extends LightningElement {
  @api recordId;
  fullTransactionList = [];
  currentLimit = 10;
  @track transactionList;
  @track showSearchBar = false;
  @track filterList = [];
  @track savedMaxIndex = 0;
  expandAll = false;
  ocvId;
  accountNumber;
  hasError = false;
  errorMessage;

  @wire(MessageContext)
  messageContext;

  //Get the OCVID and Account Number to send to
  //the API and get the transactions
  @wire(getRecord, {
    recordId: "$recordId",
    fields: [FIN_ACCOUNT_OCV_ID_FIELD, FIN_ACCOUNT_ACCOUNT_NUMBER_FIELD]
  })
  wiredProject({ data }) {
    if (data) {
      this.ocvId = data.fields.OCV_ID__c.value;
      this.accountNumber = data.fields.FinServ__FinancialAccountNumber__c.value;
      this.fetchTransactions();
    }
  }

  get showLoadMore() {
    return this.fullTransactionList.length > this.currentLimit;
  }

  fetchTransactions() {
    getTransactions({ ocvId: this.ocvId, accountNumber: this.accountNumber })
      .then((result) => {
        if (result) {
          this.fullTransactionList = JSON.parse(result).transactions;
          let updatedFullList = [];
          for (let i = 0; i < this.fullTransactionList.length; i++) {
            let currentTransaction = this.fullTransactionList[i];

            //Remove $ from value and convert to int
            currentTransaction.amount.charged.value = parseInt(
              currentTransaction.amount.charged.value.replace("$", ""),
              10
            );

            //Remap type and status
            currentTransaction.type =
              transactionTypeMapping[currentTransaction.type];
            currentTransaction.status =
              transactionStatusMapping[currentTransaction.status];

            currentTransaction.TransactionDate = currentTransaction.date.slice(
              0,
              10
            );
            currentTransaction.TransactionTime = currentTransaction.date.match(
              /\d\d:\d\d/
            );

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

            if (currentTransaction.tags) {
              currentTransaction.tagList = [];
              //loop through tags
              currentTransaction.tags.forEach((tag) => {
                //Truncate tag name
                if (tag.name.length > 15) {
                  tag.name = tag.name.substring(0, 14) + "...";
                }
                currentTransaction.tagList.push(tag.name);
              });
            }

            //Handle merchant details
            if (currentTransaction.merchant) {
              currentTransaction.merchantDetails = true;
              currentTransaction.name = currentTransaction.merchant.chain_name
                ? currentTransaction.merchant.chain_name.value
                : currentTransaction.merchant.name;

              currentTransaction.merchantLocation = `${currentTransaction.merchant.address.line_one.value}, ${currentTransaction.merchant.address.suburb.value} ${currentTransaction.merchant.address.state.value} ${currentTransaction.merchant.address.postcode.value}`;

              currentTransaction.logo =
                currentTransaction.merchant.image_details.light_url.value;

              currentTransaction.merchant.email = currentTransaction.merchant
                .email
                ? currentTransaction.merchant.email.value
                : "";
              if (currentTransaction.merchant.address.coordinates) {
                //Set the map markers for the map
                currentTransaction.mapMarkers = [
                  {
                    location: {
                      Latitude:
                        currentTransaction.merchant.address.coordinates
                          .latitude,
                      Longitude:
                        currentTransaction.merchant.address.coordinates
                          .longitude
                    }
                  }
                ];
              }
            }

            //Check if international transaction
            if (
              currentTransaction.amount.type === "EXCHANGE_TYPE_INTERNATIONAL"
            ) {
              currentTransaction.internationalDetails = true;
            }

            currentTransaction.error = currentTransaction.error
              ? currentTransaction.error
              : "N/A";

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
        }
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
        this.showToast(
          "Transaction History Load Failed",
          this.errorMessage,
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
