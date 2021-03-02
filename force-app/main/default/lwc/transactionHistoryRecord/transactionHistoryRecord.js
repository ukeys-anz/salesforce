import { LightningElement, track, api, wire } from "lwc";

import { subscribe, MessageContext } from "lightning/messageService";
import ExpandCollapseAll from "@salesforce/messageChannel/ListCollapseExpandAll__c";

export default class TransactionHistoryRecord extends LightningElement {
  @api transactionRecord;
  @api expandAll;
  @track showTransactionDetails;
  zoomLevel = 15;
  @wire(MessageContext)
  messageContext;
  subscription = null;

  connectedCallback() {
    this.subscription = subscribe(
      this.messageContext,
      ExpandCollapseAll,
      (message) => {
        if (message.expand) {
          this.showTransactionDetails = true;
        } else if (!message.expand) {
          this.showTransactionDetails = false;
        }
      }
    );

    if (this.expandAll) {
      this.showTransactionDetails = true;
    }
  }

  get merchantPhoneNumber() {
    let merPhoneNumber;
    if (
      this.transactionRecord.merchant &&
      this.transactionRecord.merchant.phone_number
    ) {
      merPhoneNumber = this.transactionRecord.merchant.phone_number.value;
    } else {
      merPhoneNumber = "Unknown";
    }
    return merPhoneNumber;
  }

  get merchantWebsiteUrl() {
    let merWebsiteUrl;
    if (
      this.transactionRecord.merchant &&
      this.transactionRecord.merchant.website_url
    ) {
      merWebsiteUrl = this.transactionRecord.merchant.website_url.value;
    } else {
      merWebsiteUrl = "Unknown";
    }
    return merWebsiteUrl;
  }

  get amountConvertedValue() {
    let amountConValue;
    if (
      this.transactionRecord.amount &&
      this.transactionRecord.amount.converted
    ) {
      amountConValue = this.transactionRecord.amount.converted.value;
    } else {
      amountConValue = "Unknown";
    }
    return amountConValue;
  }

  get amountConvertedCurrency() {
    let amountConCurrency;
    if (
      this.transactionRecord.amount &&
      this.transactionRecord.amount.converted
    ) {
      amountConCurrency = this.transactionRecord.amount.converted.currency;
    } else {
      amountConCurrency = "Unknown";
    }
    return amountConCurrency;
  }

  get amountExchangeRateValue() {
    let amountExchangeRate;
    if (
      this.transactionRecord.amount &&
      this.transactionRecord.amount.exchangeRate
    ) {
      amountExchangeRate = this.transactionRecord.amount.exchangeRate.value;
    } else {
      amountExchangeRate = "Unknown";
    }
    return amountExchangeRate;
  }

  get amountNumber() {
    let relatedAmount = this.transactionRecord.amount.charged.value;
    if (relatedAmount < 0) {
      relatedAmount = -relatedAmount;
    }
    return relatedAmount;
  }

  get positiveAmount() {
    return this.transactionRecord.amount.charged.value >= 0;
  }

  get negativeAmount() {
    return this.transactionRecord.amount.charged.value < 0;
  }

  get transactionDate() {
    let recordDate = new Date(this.transactionRecord.TransactionDate);
    let dateStr = "";
    let today = new Date();
    let yesterday = new Date();
    yesterday.setDate(yesterday.getDate() - 1);

    if (recordDate.toDateString() === today.toDateString()) {
      dateStr = "Today";
    } else if (recordDate.toDateString() === yesterday.toDateString()) {
      dateStr = "Yesterday";
    } else {
      dateStr =
        recordDate.toLocaleString("en-AU", {
          weekday: "long"
        }) +
        ", " +
        recordDate.getDate() +
        " " +
        recordDate.toLocaleString("en-AU", {
          month: "long"
        }) +
        " " +
        recordDate.getFullYear();
    }

    return dateStr;
  }

  handleDetailsToggle() {
    this.showTransactionDetails = !this.showTransactionDetails;
  }
}
