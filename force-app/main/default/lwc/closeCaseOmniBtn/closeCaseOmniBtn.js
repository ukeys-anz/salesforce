import { LightningElement, api } from "lwc";
import { getFocusedTabInfo, refreshTab } from "lightning/platformWorkspaceApi";
import { CloseActionScreenEvent } from "lightning/actions";

export default class CloseCaseOmniBtn extends LightningElement {
  @api recordId;

  connectedCallback() {
    this.template.addEventListener(
      "closeModalAndRefreshTab",
      this.handleRefreshTabCloseModal
    );
  }

  disconnectedCallback() {
    this.template.removeEventListener(
      "closeModalAndRefreshTab",
      this.handleRefreshTabCloseModal
    );
  }

  handleRefreshTabCloseModal = (evt) => {
    if (evt?.detail?.caseRecId && evt.detail.caseRecId === this.recordId) {
      getFocusedTabInfo().then((tabInfo) => {
        const { tabId } = tabInfo;
        refreshTab(tabId, false);
      });
      this.dispatchEvent(new CloseActionScreenEvent());
    }
  };
}
