import { LightningElement, wire } from "lwc";
import { CurrentPageReference, NavigationMixin } from "lightning/navigation";
import { getFocusedTabInfo } from "lightning/platformWorkspaceApi";

export default class TFMRedirectTOParentOS extends NavigationMixin(
  LightningElement
) {
  @wire(CurrentPageReference)
  getStateParameters(currentPageReference) {
    if (currentPageReference) {
      this.showToast = currentPageReference.state?.c__showToast;
      this.tabName = currentPageReference.state?.c__tabName;
      this.recordId = currentPageReference.state?.c__recordId;
      this.parentTab = currentPageReference.state?.c__parentTab;

      if (this.showToast != null) {
        getFocusedTabInfo()
          .then((tabInfo) => {
            this.replaceTab(tabInfo.tabId);
          })
          .catch((error) => {
            console.log(error);
          });
      }
    }
  }

  replaceTab(tabId) {
    const pageRef = {
      type: "standard__navItemPage",
      attributes: {
        apiName: "TFMManageOpenBankingPage"
      },
      state: {
        c__recordId: this.recordId,
        c__showToast: null,
        c__tabName: this.tabName,
        c__parentTab: this.parentTab
      }
    };
    this[NavigationMixin.Navigate](pageRef, {
      isOverride: true,
      overrideTabId: tabId
    });
  }
}
