import { LightningElement, api, wire } from "lwc";
import { getRecord } from "lightning/uiRecordApi";
import reinitiateChat from "@salesforce/apex/InitiateInteractionController.reinitiateChat";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { RefreshEvent } from "lightning/refresh";

// Util methods
import { handleErrorShowToast } from "c/utils";

const fields = ["Interaction.Chat_or_Call_SID__c", "Interaction.AccountId"];

export default class ReplyToCustomerForInteraction extends LightningElement {
  _recordId;
  chatOrCallSid;
  accountId;
  isExecuting = false;

  @api invoke() {
    if (this.chatOrCallSid && this.accountId && this.isExecuting) {
      this.reinitiateChat();
    }
    this.isExecuting = true;
  }

  @api set recordId(recordId) {
    if (recordId !== this._recordId) {
      this._recordId = recordId;
    }
  }

  get recordId() {
    return this._recordId;
  }

  @wire(getRecord, { recordId: "$_recordId", fields })
  interactionRecord({ data, error }) {
    if (data) {
      if (
        data.fields &&
        data.fields.Chat_or_Call_SID__c.value &&
        data.fields.AccountId.value
      ) {
        this.chatOrCallSid = data.fields.Chat_or_Call_SID__c.value;
        this.accountId = data.fields.AccountId.value;
        this.isExecuting = true;
      }
    } else {
      console.error(
        "Error in Fetching ChatOrCallSid -> " + JSON.stringify(error)
      );
    }
  }

  reinitiateChat() {
    let errorMessage =
      "Failed to reinitiate chat. Please refresh and try again. Raise a fault through TechAssist if the problem persists.";
    reinitiateChat({
      accountId: this.accountId,
      conversationSid: this.chatOrCallSid
    })
      .then((result) => {
        if (result) {
          this.isExecuting = false;
          this.showToast("Success", "Reinitiate Chat Completed Successfully");
          this.beginRefresh();
        }
      })
      .catch((error) => {
        console.error("Error in reinitiating chat -> " + JSON.stringify(error));
        handleErrorShowToast(
          this,
          "Failed to re-initiate Chat",
          errorMessage,
          errorMessage,
          "pester"
        );
      });
  }

  showToast(title, message) {
    const event = new ShowToastEvent({
      title: title,
      message: message,
      variant: "success"
    });
    this.dispatchEvent(event);
  }

  beginRefresh() {
    this.dispatchEvent(new RefreshEvent());
  }
}
