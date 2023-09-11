import { LightningElement, api } from "lwc";
import { showToast } from "c/utils";
import { CloseActionScreenEvent } from "lightning/actions";
import sendCommunication from "@salesforce/apex/CaseSendCommunicationController.sendCommunication";

const TOAST_MESSAGE_SUCCESS =
  "Request for email notification has been successfully sent.";
const TOAST_MESSAGE_ERROR =
  "Email notification request could not be sent. Please try again by clicking the 'Send Communication' button.";
const MODAL_MESSAGE_HEADER = "Email Notification Confirmation";
const MODAL_MESSAGE_BODY =
  "You are about to send an email to the customer. Are you sure you want to proceed?";

export default class CaseSendCommunication extends LightningElement {
  @api recordId;
  isLoading = false;
  disableButtons = false;

  messageHeader = MODAL_MESSAGE_HEADER;
  messageBody = MODAL_MESSAGE_BODY;

  handleClose() {
    this.disableButtons = true;
    this.dispatchEvent(new CloseActionScreenEvent());
  }

  handleConfirmSend() {
    this.isLoading = true;
    this.disableButtons = true;

    sendCommunication({ recordId: this.recordId })
      .then(() => {
        showToast(this, "Success!", TOAST_MESSAGE_SUCCESS, "", "success", "");
        this.updateRecordView();
      })
      .catch(() => {
        showToast(this, "Error!", TOAST_MESSAGE_ERROR, "", "error", "");
      })
      .finally(() => {
        this.dispatchEvent(new CloseActionScreenEvent());
      });
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
