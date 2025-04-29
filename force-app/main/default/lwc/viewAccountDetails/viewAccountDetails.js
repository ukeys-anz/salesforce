import { LightningElement, api } from "lwc";
import getExternalRecordId from "@salesforce/apex/FinAccountController.getExternalRecordId";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { NavigationMixin } from "lightning/navigation";

export default class ViewAccountDetails extends NavigationMixin(
  LightningElement
) {
  @api
  recordId;

  @api
  async invoke() {
    this.fetchExternalRecord();
  }

  fetchExternalRecord() {
    getExternalRecordId({ recordId: this.recordId })
      .then((externalRecordId) => {
        if (this.recordId) {
          this[NavigationMixin.Navigate]({
            type: "standard__recordPage",
            attributes: {
              recordId: externalRecordId,
              actionName: "view"
            }
          });
        } else {
          this.showToast("Error", "No external record found", "error");
        }
      })
      .catch((error) => this.showToast("Error", error.body.message, "error"));
  }

  showToast(title, message, variant) {
    this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
  }
}
