import { LightningElement, api, wire } from "lwc";
import { getFocusedTabInfo, refreshTab } from "lightning/platformWorkspaceApi";
import { CloseActionScreenEvent } from "lightning/actions";
import { getRecord, getFieldValue } from "lightning/uiRecordApi";
import IS_THIS_A_COMPLAINT_ABOUT_A_COMPLAINT from "@salesforce/schema/Case.Is_this_a_complaint_about_a_complaint__c";
import { showToast } from "c/utils";

export default class CloseCaseOmniBtn extends LightningElement {
  @api recordId;
  isComplaintAboutComplaint;

  @wire(getRecord, {
    recordId: "$recordId",
    fields: [IS_THIS_A_COMPLAINT_ABOUT_A_COMPLAINT]
  })
  caseData({ data }) {
    if (data) {
      this.isComplaintAboutComplaint = getFieldValue(
        data,
        IS_THIS_A_COMPLAINT_ABOUT_A_COMPLAINT
      );
      if ([null, "Yes"].includes(this.isComplaintAboutComplaint)) {
        return;
      }
      this.dispatchEvent(new CloseActionScreenEvent());
      let errorMsg =
        "Review the following fields: Resolution Information Section: Is this a complaint about a complaint? CAC Sub Category, Review Outcome of Original Complaint. These fields can only be completed when the Subsequent Issue Type 1, 2 or 3 is 'Failure to properly respond to complaint'.";
      showToast(this, "Error Closing Case", errorMsg, "", "error");
    }
  }

  get showOmni() {
    return this.isComplaintAboutComplaint !== "No";
  }

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
