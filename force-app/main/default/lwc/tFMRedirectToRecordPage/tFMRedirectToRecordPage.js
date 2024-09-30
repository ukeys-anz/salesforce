import { LightningElement, api } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import { getFocusedTabInfo, refreshTab } from "lightning/platformWorkspaceApi";
import pubsub from "omnistudio/pubsub";

export default class TFMRedirectToRecordPage extends NavigationMixin(
  LightningElement
) {
  @api recordId;

  connectedCallback() {
    this.navigateToPersonIdentityPage();
    this.refreshTab();
    /* ANZX-179785 - The double refresh here is needed because of an issue where the criteria based Quick Actions on PersonDigitalIdentity were not getting rendedred
    correctly with a single sub-tab refresh. As a workaround, we are doing the secod refresh with a 5s timeout.
    */
    // eslint-disable-next-line @lwc/lwc/no-async-operation
    setTimeout(() => {
      this.refreshTab();
    }, 5000);
    pubsub.fire("DeviceDetailsCard", "reloadDeviceDetails");
  }

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

  async refreshTab() {
    const { tabId } = await getFocusedTabInfo();
    await refreshTab(tabId, {
      includeAllSubtabs: true
    });
  }
}
