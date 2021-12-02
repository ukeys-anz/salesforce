import { LightningElement, wire, track } from "lwc";
import getAllKnownIssues from "@salesforce/apex/IDRExpressComplaintController.getAllKnownIssues";
export default class IdrExpressComplaint extends LightningElement {
  @track
  allKnownIssues;
  @track
  knownIssueItems = [];
  @track
  knownIssueValue;
  @track
  selectedKnownIssue;
  showKnownOutageSelect;

  @wire(getAllKnownIssues)
  wiredKnownIssues({ error, data }) {
    if (data) {
      this.allKnownIssues = data;
      for (var i = 0; i < data.length; i++) {
        this.knownIssueItems = [
          ...this.knownIssueItems,
          { value: data[i].Name, label: data[i].Name }
        ];
      }
    }
    if (error) {
      console.error(error);
    }
  }

  get knownIssueOptions() {
    return this.knownIssueItems;
  }

  handleKnownIssueChange(event) {
    for (let knownIssue of this.allKnownIssues) {
      if (
        JSON.stringify(knownIssue.Name) == JSON.stringify(event.detail.value)
      ) {
        this.selectedKnownIssue = knownIssue;
      }
    }
    const selectedEvent = new CustomEvent("selected", {
      detail: this.selectedKnownIssue
    });
    this.dispatchEvent(selectedEvent);
  }

  handleExpressCaseToggle(event) {
    this.showKnownOutageSelect = event.detail.checked;
    if (event.detail.checked) {
      const toggleEvent = new CustomEvent("togglechecked", {
        detail: true
      });
      this.dispatchEvent(toggleEvent);
    }
  }
}
