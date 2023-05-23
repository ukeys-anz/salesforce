import { LightningElement, api } from "lwc";
import { NavigationMixin } from "lightning/navigation";

export default class CreateCaseButton extends NavigationMixin(
  LightningElement
) {
  isExecuting = false;
  @api invoke() {
    if (this.isExecuting) {
      return;
    }
    this.isExecuting = true;
    this[NavigationMixin.Navigate]({
      type: "standard__objectPage",
      attributes: {
        objectApiName: "Case",
        actionName: "new"
      }
    });
    this.isExecuting = false;
  }
}
