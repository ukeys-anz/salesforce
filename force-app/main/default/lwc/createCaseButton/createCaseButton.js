import { LightningElement, api } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import { navigate } from "c/utils";

export default class CreateCaseButton extends NavigationMixin(
  LightningElement
) {
  isExecuting = false;
  @api invoke() {
    if (this.isExecuting) {
      return;
    }
    this.isExecuting = true;
    // Navigate to a Case Creation
    const attributes = {
      objectApiName: "Case",
      actionName: "new"
    };
    navigate(this, "standard__objectPage", attributes);

    this.isExecuting = false;
  }
}
