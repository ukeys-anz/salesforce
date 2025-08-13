import { LightningElement, api } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import getData from "@salesforce/apex/GenericController.getData";

export default class GenericRecordLink extends NavigationMixin(
  LightningElement
) {
  @api objectName;
  @api fields; //Fields array to display in the popover and to query
  @api apexController; // Apex controller to use for data retrieval
  @api recordName; //field to display as the record name in the link
  @api params; //params (from api) to pass to the apex controller for query
  @api isStacked;
  showPopover = false;
  recordDetails;
  loading;

  get recordNameValue() {
    return this.recordDetails && this.recordName
      ? this.recordDetails[this.recordName]
      : null;
  }

  get recordDetailsId() {
    return this.recordDetails ? this.recordDetails.Id : null;
  }

  get _fieldCompCss() {
    return this.isStacked ? "fieldContentStacked" : "fieldContent";
  }

  async connectedCallback() {
    try {
      this.loading = true;
      this.recordDetails = await getData({
        apexController: this.apexController,
        param: JSON.stringify(this.params)
      });
    } catch (error) {
      console.error("Error fetching record:", error.message);
    } finally {
      this.loading = false;
    }
  }
  navigateToRecord() {
    this[NavigationMixin.Navigate]({
      type: "standard__recordPage",
      attributes: {
        recordId: this.recordDetailsId,
        objectApiName: this.objectName,
        actionName: "view"
      }
    });
  }

  handlePopover(e) {
    this.showPopover = !this.showPopover;
  }
}
