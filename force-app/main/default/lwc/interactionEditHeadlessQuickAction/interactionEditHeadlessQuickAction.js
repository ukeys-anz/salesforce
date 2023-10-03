import { LightningElement, api, wire } from "lwc";
import { CloseActionScreenEvent } from "lightning/actions";
import { getRecord } from "lightning/uiRecordApi";

const fields = ["Interaction.Record_Type__c"];

export default class InteractionEditHeadlessQuickAction extends LightningElement {
  booledit = false;
  boolEditStore = false;
  boolEditCall = false;
  boolEditChat = false;
  recordTypeName;
  _recordId;

  @api set recordId(recordId) {
    if (recordId !== this._recordId) {
      this._recordId = recordId;
      if (this._recordId) {
        this.booledit = true;
      }
    }
  }

  get recordId() {
    return this._recordId;
  }

  /**
   * Wire Method To Fetch RecordTypeName
   */

  @wire(getRecord, { recordId: "$_recordId", fields })
  interactionRecord({ data, error }) {
    if (data) {
      if (data.fields && data.fields.Record_Type__c.value) {
        this.recordTypeName = data.fields.Record_Type__c.value;
        if (this.recordTypeName === "In Person") {
          this.boolEditStore = true;
        }
        if (this.recordTypeName === "Call") {
          this.boolEditCall = true;
        }
        if (this.recordTypeName === "Message") {
          this.boolEditChat = true;
        }
      }
    } else {
      console.error(
        "Error in Fetching RecordTypeName -> " + JSON.stringify(error)
      );
    }
  }

  /**
   * Register to omniscript actions to listen to cancel and navigate actions.
   */
  connectedCallback() {
    window.addEventListener("message", this.handleEventObject, false);
  }

  /**
   * handler for listener from post message
   */
  handleEventObject = this.onMessage.bind(this);

  /**
   * processor for Omni Event Change
   */
  onMessage(event) {
    try {
      if (event.data && event.data["OmniScript-Messaging"]) {
        let elementNameFromOmni =
          event.data["OmniScript-Messaging"].ElementName;
        if (elementNameFromOmni === "NavigateActionOnEdit") {
          this.updateRecordView();
        }
        if (elementNameFromOmni === "cancelForEdit") {
          this.closeModal();
        }
      }
    } catch (error) {
      console.error(
        "Interaction Edit Headless Action " + JSON.stringify(error)
      );
    }
  }

  /**
   * This method fires close modal.
   * @param {*} event
   */
  closeModal(event) {
    if (event) {
      event.preventDefault();
    }
    this.booledit = false;
    this.dispatchEvent(new CloseActionScreenEvent());
  }

  /**
   * Fire Workspace API's internal event for the console tab refresh
   */
  updateRecordView() {
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
            this.closeModal();
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

  /**
   * Disconnect the listener
   */
  disconnectedCallback() {
    window.removeEventListener("message", this.handleEventObject, false);
  }
}
