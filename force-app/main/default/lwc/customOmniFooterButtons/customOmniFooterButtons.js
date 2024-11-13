import { LightningElement, api, wire } from "lwc";
import { createRecord } from "lightning/uiRecordApi";
import { NavigationMixin } from "lightning/navigation";
import CASECOMMENT_OBJECT from "@salesforce/schema/CaseComment";
import BODY_FIELD from "@salesforce/schema/CaseComment.CommentBody";
import CASEID_FIELD from "@salesforce/schema/CaseComment.ParentId";
import { OmniscriptBaseMixin } from "omnistudio/omniscriptBaseMixin";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import {
  IsConsoleNavigation,
  getFocusedTabInfo,
  closeTab
} from "lightning/platformWorkspaceApi";

const NEXT = "Next";
const SAVE = "Save & Finish";
export default class CustomOmniFooterButtons extends OmniscriptBaseMixin(
  NavigationMixin(LightningElement)
) {
  @api checkIssueTypeSelection = false;
  @api label;
  _defaultValue;
  _isLastScreen;
  nextStepLabel = NEXT;
  showPrevious = true;
  showSaveAndExit = true;

  @wire(IsConsoleNavigation) isConsoleNavigation;

  // Close the subtab for omniscript when the save and exit button / finish is clicked
  async closeTab() {
    if (!this.isConsoleNavigation) {
      return;
    }
    const { tabId } = await getFocusedTabInfo();
    await closeTab(tabId);
  }

  @api set defaultValue(value) {
    this._defaultValue = value;
  }
  get defaultValue() {
    return this._defaultValue;
  }

  @api set isFirstScreen(value) {
    this.showPrevious = value ? false : true;
  }
  get isFirstScreen() {
    return this.showPrevious;
  }

  @api set isLastScreen(value) {
    this.showSaveAndExit = value ? false : true;
    this.nextStepLabel = value ? SAVE : NEXT;
    this._isLastScreen = value;
  }
  get isLastScreen() {
    return this._isLastScreen;
  }

  // Update the data json on change of Case comments field
  handleChange(event) {
    this._defaultValue = event.target.value;
    this.omniApplyCallResp({ rpCaseComments: this._defaultValue });
  }

  handleNext() {
    if (this._isLastScreen) {
      this.handleSaveAndExit();
      return;
    }
    if (
      (this.checkIssueTypeSelection &&
        this.omniJsonData.ChoosePathway?.IssueTypeButtons
          ?.selectedButtonName) ||
      !this.checkIssueTypeSelection
    ) {
      // If user has selected an issue type in ChoosePathway screen, then call next step OR by default call next step in other screens
      this.omniNextStep();
    } else if (
      this.checkIssueTypeSelection &&
      !this.omniJsonData.ChoosePathway?.IssueTypeButtons?.selectedButtonName
    ) {
      // Updates the data json with 'None' value to throw a warning on screen
      this.omniApplyCallResp({ issueType: "None" });
    }
  }

  handlePrevious() {
    this.omniPrevStep();
  }

  handleSaveAndExit() {
    this.handleCreate(this.omniJsonData);
    this.redirectToCaseDetail(this.omniJsonData.ContextId);
    this.closeTab();
  }

  async handleCreate(data) {
    if (!data.rpCaseComments) return;

    if (data.rpCaseComments.length > 4000) return;

    const fields = {};
    // Map the user input to the fields
    fields[BODY_FIELD.fieldApiName] = data?.rpCaseComments
      ? data.rpCaseComments
      : "";
    fields[CASEID_FIELD.fieldApiName] = data.ContextId;
    const recordInput = { apiName: CASECOMMENT_OBJECT.objectApiName, fields };
    try {
      await createRecord(recordInput);
    } catch (error) {
      // Handle error
      this.showToast("Error", error.body.message, "error");
    }
  }

  redirectToCaseDetail(recId) {
    this[NavigationMixin.Navigate]({
      type: "standard__recordPage",
      attributes: {
        recordId: recId,
        objectApiName: "Case",
        actionName: "view"
      }
    });
  }

  showToast(title, msg, variant) {
    const evt = new ShowToastEvent({
      title: title,
      message: msg,
      variant: variant
    });
    this.dispatchEvent(evt);
  }
}
