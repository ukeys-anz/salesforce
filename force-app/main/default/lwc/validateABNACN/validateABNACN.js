import { LightningElement, api } from "lwc";
import validateAbnAcnForCallout from "@salesforce/apex/ValidateABNACNController.validateAbnAcnForCallout";
import { CloseActionScreenEvent } from "lightning/actions";
import { getFocusedTabInfo, refreshTab } from "lightning/platformWorkspaceApi";
import { NavigationMixin } from "lightning/navigation";
import { ShowToastEvent } from "lightning/platformShowToastEvent";

export default class ValidateABNACN extends NavigationMixin(LightningElement) {
  message = "ABN and ACN validation has been initiated.";
  @api
  set recordId(value) {
    this._recordId = value;
    this.validateABNACN();
  }

  get recordId() {
    return this._recordId;
  }

  validateABNACN() {
    validateAbnAcnForCallout({ leadId: this._recordId });
    // eslint-disable-next-line @lwc/lwc/no-async-operation
    setTimeout(() => {
      this.dispatchEvent(
        new ShowToastEvent({
          title: "Success",
          message: this.message,
          variant: "success"
        })
      );
      this.refreshConsoleTab();
      this.dispatchEvent(new CloseActionScreenEvent());
    }, 5000);
  }

  async refreshConsoleTab() {
    const { tabId } = await getFocusedTabInfo();
    await refreshTab(tabId, {
      includeAllSubtabs: false
    });
  }
}
