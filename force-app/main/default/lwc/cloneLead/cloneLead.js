import { LightningElement, api } from "lwc";
import { CloseActionScreenEvent } from "lightning/actions";
import { NavigationMixin } from "lightning/navigation";
import cloneLeadRecord from "@salesforce/apex/CloneLeadController.cloneLeadRecord";

// Utility imports
import { SimpleToast, handleErrorShowToast } from "c/utils";

export default class CloneLead extends NavigationMixin(LightningElement) {
  _recordId;
  hasCloned = false;
  isLoading = false;

  toast = new SimpleToast(this);

  @api
  set recordId(value) {
    if (value && !this.hasCloned) {
      this._recordId = value;
      this.hasCloned = true;
      this.cloneLead();
    }
  }

  get recordId() {
    return this._recordId;
  }

  cloneLead() {
    this.isLoading = true;

    cloneLeadRecord({ leadId: this.recordId })
      .then((newLeadId) => {
        if (newLeadId) {
          this.toast.success("Lead cloned successfully.");
          // Navigate to the cloned Lead using NavigationMixin
          this[NavigationMixin.Navigate]({
            type: "standard__recordPage",
            attributes: {
              recordId: newLeadId,
              objectApiName: "Lead",
              actionName: "view"
            }
          });
        } else {
          this.toast.info(
            "Cloning initiated. Please refresh after a few seconds."
          );
        }
      })
      .catch((error) => {
        handleErrorShowToast(
          this,
          "Clone Failed",
          error,
          "Unable to clone the lead.",
          "dismissable"
        );
      })
      .finally(() => {
        this.isLoading = false;
        this.dispatchEvent(new CloseActionScreenEvent());
      });
  }
}
