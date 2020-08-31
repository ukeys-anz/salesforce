import { LightningElement, api } from "lwc";

export default class TransactionHistorySearchItem extends LightningElement {
  @api filterItem;
  operatorLabel;

  connectedCallback() {
    this.operatorLabel = this.filterItem.operator;
    if (this.operatorLabel === "notEqual") {
      this.operatorLabel = "not equal to";
    } else if (this.operatorLabel === "lessThan") {
      this.operatorLabel = "less than";
    } else if (this.operatorLabel === "greaterThan") {
      this.operatorLabel = "greater than";
    }
  }

  get normalValue() {
    return this.filterItem.field !== "Amount";
  }

  get amountValue() {
    return this.filterItem.field === "Amount";
  }

  handleCloseItem() {
    const event = new CustomEvent("closefilteritem", {
      detail: this.filterItem.index
    });
    this.dispatchEvent(event);
  }
}
