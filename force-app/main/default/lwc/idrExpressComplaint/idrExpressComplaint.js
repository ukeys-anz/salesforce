import { LightningElement, wire, track } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
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
      for (let i = 0; i < data.length; i++) {
        this.knownIssueItems = [
          ...this.knownIssueItems,
          { value: data[i].Name, label: data[i].Name }
        ];
      }
    }
    if (error) {
      const toastEvent = new ShowToastEvent({
        title: "Error fetching known issues",
        message: error.body.message,
        variant: "error"
      });
      this.dispatchEvent(toastEvent);
    }
  }

  get knownIssueOptions() { 
    return this.knownIssueItems;
  }

  handleKnownIssueChange(event) {
    for (let knownIssue of this.allKnownIssues) {
      if (
        JSON.stringify(knownIssue.Name) === JSON.stringify(event.detail.value)
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
    const toggleEvent = new CustomEvent("togglechecked", {
      detail: {
        value: event.detail.checked
      }
    });
    this.dispatchEvent(toggleEvent);
  }
}
