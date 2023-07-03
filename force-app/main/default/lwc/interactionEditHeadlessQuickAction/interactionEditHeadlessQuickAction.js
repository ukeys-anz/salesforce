import { LightningElement, api } from "lwc";
import { CloseActionScreenEvent } from "lightning/actions";
import getRecordTypeDeveloperNameEdit from "@salesforce/apex/FetchRecordTypeName.getRecordTypeDeveloperNameEdit";

export default class InteractionEditHeadlessQuickAction extends LightningElement {
  interactionDetail;
  booledit = false;
  boolEditStore = false;
  boolEditCall = false;
  recordTypeName;
  _recordId;

  @api set recordId(recordId) {
    if (recordId !== this._recordId) {
      console.log("recordId -> " + recordId);
      this._recordId = recordId;
      if (this._recordId) {
        this.booledit = true;
        this.interactionDetail =
          '{"interactionRecordId":"' + this._recordId + '"}';
        this.getRecordTypeName();
      }
    }
  }

  get recordId() {
    return this._recordId;
  }

  /**
   * handler for recordTypeName of the record
   */
  getRecordTypeName() {
    getRecordTypeDeveloperNameEdit({
      recordId: this._recordId
    })
      .then((result) => {
        let mapOfDeveloperNameAndIds = JSON.parse(result);
        this.recordTypeName =
          mapOfDeveloperNameAndIds[this._recordId].RecordType.DeveloperName;
        if (this.recordTypeName) {
          if (this.recordTypeName === "Store") {
            this.boolEditStore = true;
          }
          if (this.recordTypeName === "General") {
            this.boolEditCall = true;
          }
        }
      })
      .catch((error) => {
        console.error(
          "Interaction Edit Headless Action For RecordType Fetch " +
            JSON.stringify(error)
        );
        this.recordTypeName = undefined;
      });
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
        console.log("Omni Json " + JSON.stringify(event.data));
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
