import { LightningElement, track, api } from "lwc";

export default class TransactionHistoryRecord extends LightningElement {
  @track showTransactionDetails = false;
  @api transactionRecord;

  get amountNumber() {
    let relatedAmount = this.transactionRecord.Amount;
    if (relatedAmount < 0) {
      relatedAmount = -relatedAmount;
    }
    return relatedAmount;
  }

  get positiveAmount() {
    return this.transactionRecord.Amount >= 0;
  }

  get negativeAmount() {
    return this.transactionRecord.Amount < 0;
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
        recordDate.toLocaleString("en-AU", { weekday: "long" }) +
        ", " +
        recordDate.getDate() +
        " " +
        recordDate.toLocaleString("en-AU", { month: "long" }) +
        " " +
        recordDate.getFullYear();
    }

    return dateStr;
  }

  handleDetailsToggle() {
    this.showTransactionDetails = !this.showTransactionDetails;
  }
}
