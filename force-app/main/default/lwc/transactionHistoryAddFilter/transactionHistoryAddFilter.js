import { LightningElement, track, api } from "lwc";

export default class TransactionHistoryAddFilter extends LightningElement {
  @track operator = "equals";
  @api relatedField;
  @track filterValue = "";
  @track dateValue = new Date().toISOString().slice(0, 10);

  get operatorList() {
    let opList = [
      { label: "equals", value: "equals" },
      { label: "not equal to", value: "notEqual" }
    ];

    if (
      this.relatedField === "Amount" ||
      this.relatedField === "TransactionDate"
    ) {
      opList.push({ label: "less than", value: "lessThan" });
      opList.push({ label: "greater than", value: "greaterThan" });
    }

    return opList;
  }

  get isDate() {
    return this.relatedField === "TransactionDate";
  }

  get normalInput() {
    return !(this.relatedField === "TransactionDate");
  }

  handleOperatorChange(event) {
    this.operator = event.detail.value;
  }

  handleFilterValueChange(event) {
    this.filterValue = event.target.value;
  }

  handleDateChange(event) {
    this.dateValue = event.target.value;
  }

  handleCancelAdd() {
    const event = new CustomEvent("addfiltercancel");
    this.dispatchEvent(event);
  }

  handleApply() {
    let filterItem = {
      field: this.relatedField,
      operator: this.operator,
      filtervalue: this.filterValue
    };

    if (this.isDate === true) {
      filterItem.filtervalue = this.dateValue;
    }

    const event = new CustomEvent("applyaddfilter", {
      detail: filterItem
    });
    this.dispatchEvent(event);
  }
}
