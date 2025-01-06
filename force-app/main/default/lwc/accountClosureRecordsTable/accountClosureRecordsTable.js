import { LightningElement, api, wire } from "lwc";
import { NavigationMixin } from "lightning/navigation";
export default class AccountClosureRecordsTable extends NavigationMixin(
  LightningElement
) {
  @api records;

  handleCaseClick(event) {
    event.preventDefault();

    const caseId = event.target.getAttribute("data-case-record-id");

    this[NavigationMixin.Navigate]({
      type: "standard__recordPage",
      attributes: {
        recordId: caseId,
        objectApiName: "Case",
        actionName: "view"
      }
    });
  }
}
