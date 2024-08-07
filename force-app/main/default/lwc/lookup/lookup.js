import { LightningElement, api } from "lwc";

const DELAY = 500; // delay apex callout timing in miliseconds

export default class Lookup extends LightningElement {
  @api label;
  @api placeholder;
  @api set searchResults(values) {
    this._searchResults = values || [];
    this.hasRecords = this._searchResults.length > 0;
    this.isSearchLoading = false;
  }

  get searchResults() {
    return this._searchResults;
  }

  _searchResults = [];
  hasRecords = false;
  searchKey = "";
  isSearchLoading = false;
  delayTimeout;
  selectedRecord = {};

  // update searchKey property on input field change
  handleKeyChange(event) {
    // Debouncing this method: Do not update the reactive property as long as this function is
    // being called within a delay of DELAY. This is to avoid a very large number of Apex method calls.
    this.isSearchLoading = true;
    clearTimeout(this.delayTimeout);
    const searchKey = event.target.value;
    this.isSearchLoading = true;
    // eslint-disable-next-line @lwc/lwc/no-async-operation
    this.delayTimeout = setTimeout(() => {
      this.searchKey = searchKey;
      const searchEvent = new CustomEvent("search", {
        detail: { searchKey: searchKey }
      });
      this.dispatchEvent(searchEvent);
    }, DELAY);
  }

  // method to toggle lookup result section on UI
  toggleResult(event) {
    const lookupInputContainer = this.template.querySelector(
      ".lookupInputContainer"
    );
    const clsList = lookupInputContainer.classList;
    const whichEvent = event.target.getAttribute("data-source");
    switch (whichEvent) {
      case "searchInputField":
        clsList.add("slds-is-open");
        break;
      case "lookupContainer":
        clsList.remove("slds-is-open");
        break;
      default:
    }
  }

  // method to clear selected lookup record
  handleRemove(event) {
    event.preventDefault();
    this.searchKey = "";
    this.selectedRecord = {};
    this.lookupUpdateHandler(undefined); // update value on parent component as well from helper function

    // remove selected pill and display input field again
    const searchBoxWrapper = this.template.querySelector(".searchBoxWrapper");
    searchBoxWrapper.classList.remove("slds-hide");
    searchBoxWrapper.classList.add("slds-show");

    const pillDiv = this.template.querySelector(".pillDiv");
    pillDiv.classList.remove("slds-show");
    pillDiv.classList.add("slds-hide");
  }

  // method to update selected record from search result
  handleSelectedRecord(event) {
    var objId = event.target.dataset.recid;
    this.selectedRecord = this.searchResults.find(
      (data) => data.uniqueId === objId
    );
    this.lookupUpdateHandler(this.selectedRecord); // update value on parent component as well from helper function
    this.handleSelectRecordHelper(); // helper function to show/hide lookup result container on UI
  }

  handleSelectRecordHelper() {
    this.template
      .querySelector(".lookupInputContainer")
      .classList.remove("slds-is-open");

    const searchBoxWrapper = this.template.querySelector(".searchBoxWrapper");
    searchBoxWrapper.classList.remove("slds-show");
    searchBoxWrapper.classList.add("slds-hide");

    const pillDiv = this.template.querySelector(".pillDiv");
    pillDiv.classList.remove("slds-hide");
    pillDiv.classList.add("slds-show");
  }

  // send selected lookup record to parent component using custom event
  lookupUpdateHandler(value) {
    const selectedValue = new CustomEvent("select", {
      detail: { selected: value }
    });
    this.dispatchEvent(selectedValue);
  }
}
