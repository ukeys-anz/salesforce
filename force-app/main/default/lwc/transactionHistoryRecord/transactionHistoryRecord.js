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
