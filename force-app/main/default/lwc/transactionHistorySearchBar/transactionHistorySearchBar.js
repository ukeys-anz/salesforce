import { LightningElement, track, api } from "lwc";

export default class TransactionHistorySearchBar extends LightningElement {
  @track showAddFilter = false;
  @track relatedField = "Status";
  @track value = "AddFilter";
  @track filterList = [];
  @api savedFilterList;
  @api savedMaxIndex;
  maxIndex = 0;

  get fieldList() {
    return [
      { label: "Add Filter", value: "AddFilter" },
      { label: "Name", value: "Name" },
      { label: "TransactionDate", value: "TransactionDate" },
      { label: "Amount", value: "Amount" },
      { label: "Location", value: "Location" },
      { label: "Message/Narrative", value: "Message" }
    ];
  }

  connectedCallback() {
    this.filterList = [...this.savedFilterList]; //clone array
    if (this.maxIndex < this.savedMaxIndex) {
      this.maxIndex = this.savedMaxIndex;
    }
  }

  handleAddFilter(event) {
    this.relatedField = event.detail.value;
    if (event.detail.value !== "AddFilter") {
      this.showAddFilter = true;
    } else {
      this.showAddFilter = false;
    }
  }

  handleCancelAdd() {
    this.showAddFilter = false;
  }

  handleApplyAdd(event) {
    let newFilter = {};
    newFilter = event.detail;
    newFilter.index = this.maxIndex;
    this.maxIndex++;

    this.filterList.push(newFilter);

    this.value = "AddFilter";
    this.showAddFilter = false;
  }

  handleCloseItem(event) {
    let index = event.detail;
    for (let i = 0; i < this.filterList.length; i++) {
      if (this.filterList[i].index === index) {
        this.filterList.splice(i, 1);
        break;
      }
    }
  }

  handleCancelFilterPanel() {
    const event = new CustomEvent("cancelfilter");
    this.dispatchEvent(event);
  }

  handleSaveFilterPanel() {
    let eventDetail = {
      detail: this.filterList,
      maxIndex: this.maxIndex
    };
    const event = new CustomEvent("savefilter", {
      detail: eventDetail
    });
    this.dispatchEvent(event);
  }
}
