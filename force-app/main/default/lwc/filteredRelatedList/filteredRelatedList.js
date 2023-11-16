import { LightningElement, api, track } from "lwc";
import { NavigationMixin } from "lightning/navigation";

export default class FilteredRelatedList extends NavigationMixin(
  LightningElement
) {
  @api iconName;
  @api records;
  @api relatedListTitle;
  @track recordsToShow;

  endIndex = 3;
  startIndex = 0;

  viewNextVisible = false;
  viewPrevVisible = false;
  showRecords = false;
  footerVisible = false;

  renderedCallback() {
    this.footerVisible = this.viewNextVisible || this.viewPrevVisible;
  }

  connectedCallback() {
    this.prepareInitialRecords();
  }

  prepareInitialRecords() {
    if (!this.records) return;
    if (this.records.length > 3) {
      this.recordsToShow = this.records.slice(0, 3);
      this.viewNextVisible = true;
    } else {
      this.recordsToShow = this.records;
    }
    if (this.recordsToShow) {
      this.showRecords = true;
    }
  }

  handleNext() {
    this.startIndex = this.endIndex;
    this.showRecords = false;

    if (this.records.length - this.endIndex > 3) {
      this.endIndex += 3;
    } else {
      this.endIndex = this.records.length;
      this.viewNextVisible = false;
    }

    this.recordsToShow = this.records.slice(this.startIndex, this.endIndex);
    this.showRecords = true;
    this.viewPrevVisible = true;
  }

  handlePrevious() {
    this.showRecords = false;

    if (this.startIndex >= 3) {
      this.endIndex = this.startIndex;
      this.startIndex = this.startIndex - 3;
    }

    if (this.startIndex < 3) this.viewPrevVisible = false;

    this.recordsToShow = this.records.slice(this.startIndex, this.endIndex);
    this.showRecords = true;
    this.viewNextVisible = true;
  }

  navigateToRecord(event) {
    const urlLink = event.target.dataset.url;
    event.preventDefault();
    this[NavigationMixin.Navigate]({
      type: "standard__webPage",
      attributes: {
        url: window.location.origin + urlLink
      }
    });
  }
}
