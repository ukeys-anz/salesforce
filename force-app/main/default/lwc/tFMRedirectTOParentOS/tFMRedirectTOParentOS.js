import { LightningElement, wire } from "lwc";
import { CurrentPageReference, NavigationMixin } from "lightning/navigation";
import { getFocusedTabInfo, closeTab } from "lightning/platformWorkspaceApi";

export default class TFMRedirectTOParentOS extends NavigationMixin(
  LightningElement
) {
  @wire(CurrentPageReference)
  getStateParameters(currentPageReference) {
    if (currentPageReference) {
      this.showToast = currentPageReference.state?.c__showToast;
      this.tabName = currentPageReference.state?.c__tabName;
      this.recordId = currentPageReference.state?.c__recordId;
      if (this.showToast != null) {
        getFocusedTabInfo()
          .then((tabInfo) => {
            closeTab(tabInfo.tabId);
          })
          .catch(function (error) {
            console.log(error);
          });
        this.redirectToParentOS();
      }
    }
  }

  redirectToParentOS() {
    const pageRef = {
      type: "standard__navItemPage",
      attributes: {
        apiName: "TFMManageOpenBankingPage"
      },
      state: {
        c__recordId: this.recordId,
        c__showToast: null,
        c__tabName: this.tabName
      }
    };
    this[NavigationMixin.Navigate](pageRef);
  }
}
