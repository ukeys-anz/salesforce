import { LightningElement, api } from "lwc";
import { CloseActionScreenEvent } from "lightning/actions";
import pubsub from "omnistudio/pubsub";

export default class InteractionEditHeadlessQuickAction extends LightningElement {
  interactionDetail;
  booledit = false;
  _recordId;

  @api set recordId(recordId) {
    if (recordId !== this._recordId) {
      console.log("recordId -> " + recordId);
      this._recordId = recordId;
      if (this._recordId) {
        this.booledit = true;
        this.interactionDetail =
          '{"interactionRecordId":"' + this._recordId + '"}';
      }
    }
  }

  get recordId() {
    return this._recordId;
  }

  /**
   * handler for listener from pubsub
   */
  handleEventObject = {
    data: this.handleOmniAction.bind(this)
  };

  /**
   * Register to omniscript actions to listen to cancel and navigate actions.
   */
  connectedCallback() {
    pubsub.register("omniscript_action", this.handleEventObject);
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

  handleOmniAction(data) {
    if (data && data.name) {
      if (data.name === "cancelForEdit") {
        this.closeModal();
      }
      if (data.name === "NavigateActionOnEdit") {
        this.updateRecordView();
      }
    }
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
    pubsub.unregister("omniscript_action", this.handleEventObject);
  }
}
