import { LightningElement, api } from "lwc";
import { NavigationMixin } from "lightning/navigation";

export default class TFMRedirectToRecordPage extends NavigationMixin(
  LightningElement
) {
  @api recordId;
  navigateToPersonIdentityPage() {
    this[NavigationMixin.Navigate]({
      type: "standard__recordPage",
      attributes: {
        objectApiName: "PersonDigitalIdentity__x",
        actionName: "view",
        recordId: this.recordId
      }
    });
  }

  connectedCallback() {
    this.navigateToPersonIdentityPage();
    window.location.reload();
  }
}
