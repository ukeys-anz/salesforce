import { LightningElement } from "lwc";
import { closeTab, getFocusedTabInfo } from "lightning/platformWorkspaceApi";
import { ShowToastEvent } from "lightning/platformShowToastEvent";

export default class CloseCurrentTab extends LightningElement {
  connectedCallback() {
    this.showToast();
    this.closeTab();
  }

  async closeTab() {
    const { tabId } = await getFocusedTabInfo();
    await closeTab(tabId);
  }

  showToast() {
    const event = new ShowToastEvent({
      message: "The record was deleted.",
      variant: "success"
    });
    this.dispatchEvent(event);
  }
}
