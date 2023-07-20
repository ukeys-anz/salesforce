import { LightningElement, api } from "lwc";
import { NavigationMixin } from "lightning/navigation";

export default class ViewAllGeneric extends NavigationMixin(LightningElement) {
  @api anyRecordId;
  @api lightningPageName;
  @api recordTypeDeveloperName;

  openSubTabForListView(event) {
    event.preventDefault();
    this[NavigationMixin.Navigate]({
      type: "standard__component",
      attributes: {
        componentName: "c__interactionListView"
      },
      state: {
        c__anyRecordId: this.anyRecordId,
        c__recordTypeDeveloperName: this.recordTypeDeveloperName
      }
    });
  }
}
