import { LightningElement, api } from "lwc";
import escalateCase from "@salesforce/apex/CreditReferralCaseController.escalateCase";
import { CloseActionScreenEvent } from "lightning/actions";
import { notifyRecordUpdateAvailable } from "lightning/uiRecordApi";
import { getFocusedTabInfo, refreshTab } from "lightning/platformWorkspaceApi";
import { handleErrorShowToast } from "c/utils";

const ERROR_MESSAGE =
  "An error has occurred. Please refresh and try again. If the problem persists, please contact your System Administrator.";

export default class EscalateCase extends LightningElement {
  @api recordId;
  comments = "";
  escalateTo;
  componentSpinner = false;

  get escalateToOptions() {
    return [
      { label: "CAD", value: "CAD" },
      { label: "FRAUD", value: "FRAUD" }
    ];
  }

  get disabledSaveButton() {
    return (
      this.escalateTo == null ||
      (this.showCommentsField && this.comments === "")
    );
  }

  get showCommentsField() {
    return this.escalateTo === "FRAUD";
  }

  handleCommentChange(event) {
    this.comments = event.target.value;
  }

  handleEscalateToChange(event) {
    this.escalateTo = event.target.value;
  }

  handleSave() {
    this.componentSpinner = true;
    escalateCase({
      caseId: this.recordId,
      comments: this.comments,
      escalateTo: this.escalateTo
    })
      .then(() => {
        this.handleClose();
        notifyRecordUpdateAvailable([{ recordId: this.recordId }]);
        this.refreshTab();
      })
      .catch(() => {
        handleErrorShowToast(this, "", null, ERROR_MESSAGE, "pester");
      })
      .finally(() => {
        this.componentSpinner = false;
      });
  }

  handleClose() {
    this.dispatchEvent(new CloseActionScreenEvent());
  }

  /* To show comment added by user while Escalation without manual refresh */
  async refreshTab() {
    const { tabId } = await getFocusedTabInfo();
    await refreshTab(tabId, {
      includeAllSubtabs: false
    });
  }
}
