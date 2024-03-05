import { LightningElement, wire, api } from "lwc";
import {
  IsConsoleNavigation,
  EnclosingTabId,
  getTabInfo,
  openSubtab
} from "lightning/platformWorkspaceApi";
import { getRecord, getFieldValue } from "lightning/uiRecordApi";

export default class ClickToAction extends LightningElement {
  @api title;
  @api buttonName;
  @api iconName;
  @api tabName;
  @api stateParams;

  @wire(EnclosingTabId) tabId;
  @wire(IsConsoleNavigation) isConsoleNavigation;

  @api recordId;
  fields = [];
  @wire(getRecord, { recordId: "$recordId", fields: "$fields" })
  wiredRecord;

  _state = [];
  connectedCallback() {
    if (this.stateParams) {
      this._state = JSON.parse(this.stateParams);
      this.fields = this._state.map((a) => a.field);
    }
  }

  async handleClick() {
    if (!this.tabId) {
      return;
    }

    const tabInfo = await getTabInfo(this.tabId);
    const primaryTabId = tabInfo.isSubtab ? tabInfo.parentTabId : tabInfo.tabId;

    // Open a record as a subtab of the current tab
    await openSubtab(primaryTabId, {
      pageReference: {
        type: "standard__navItemPage",
        attributes: {
          apiName: this.tabName
        },
        state: this.getState()
      },
      focus: true
    });
  }

  getState() {
    if (!this.stateParams) {
      return null;
    }
    let data = {};
    this._state.forEach((item) => {
      data[item.key] = item.value
        ? item.value
        : getFieldValue(this.wiredRecord.data, item.field);
    });
    return data;
  }
}
