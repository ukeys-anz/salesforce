import { LightningElement, api, wire } from "lwc";
import validateAbnAcnForCallout from "@salesforce/apex/validateABNACNController.validateAbnAcnForCallout";
import { CloseActionScreenEvent } from "lightning/actions";
import { NavigationMixin } from "lightning/navigation";

export default class ValidateABNACN extends NavigationMixin(LightningElement) {
  @api recordId;
  isLoading = true;

  @wire(validateAbnAcnForCallout, { leadId: "$recordId" })
  validateAbnAcnForCallout() {
    this.isLoading = false;
    this.dispatchEvent(new CloseActionScreenEvent());
  }

  disconnectedCallback() {
    window.location.reload();
  }

  refreshPage() {
    // Reloads the current page by navigating to it again
    this[NavigationMixin.Navigate]({
      type: "standard__recordPage",
      attributes: {
        recordId: this.recordId, // Record ID of the current page
        objectApiName: "Lead", // Object name of the current record
        actionName: "view" // Action to perform (view)
      }
    });
  }
}
