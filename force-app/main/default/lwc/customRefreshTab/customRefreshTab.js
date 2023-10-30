import { LightningElement } from "lwc";

export default class CustomRefreshTab extends LightningElement {
  connectedCallback() {
    window.addEventListener("customRefreshTab", this.tabRefresh, false);
  }

  /**
   * Disconnect the listener
   */
  disconnectedCallback() {
    window.removeEventListener("customRefreshTab", this.tabRefresh, false);
  }

  tabRefresh = this.tabRefreshEvent.bind(this);

  tabRefreshEvent() {
    this.invokeWorkspaceAPI("getFocusedTabInfo").then((focusedTab) => {
      this.invokeWorkspaceAPI("refreshTab", {
        tabId: focusedTab.tabId
      });
    });
  }

  invokeWorkspaceAPI(methodName, methodArgs) {
    return new Promise((resolve, reject) => {
      const apiEvent = new CustomEvent("internalapievent", {
        bubbles: true,
        composed: true,
        cancelable: false,
        detail: {
          category: "workspaceAPI",
          methodName: methodName,
          methodArgs: methodArgs,
          callback: (err, response) => {
            if (err) {
              return reject(err);
            }
            return resolve(response);
          }
        }
      });
      window.dispatchEvent(apiEvent);
      this.dispatchEvent(apiEvent);
    });
  }
}
