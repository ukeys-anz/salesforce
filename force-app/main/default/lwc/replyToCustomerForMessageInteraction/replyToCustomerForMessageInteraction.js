import { LightningElement, api, wire } from "lwc";
import { getRecord } from "lightning/uiRecordApi";
import reinitiateChat from "@salesforce/apex/InitiateInteractionController.reinitiateChat";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { RefreshEvent } from "lightning/refresh";

// Util methods
import { handleErrorShowToast } from "c/utils";

const fields = [
  "Interaction.Chat_or_Call_SID__c",
  "Interaction.AccountId",
  "Interaction.TwilioDetailsID__r.Chat_or_Call_SID__c"
];

export default class ReplyToCustomerForInteraction extends LightningElement {
  _recordId;
  chatOrCallSid;
  accountId;
  isExecuting = false;

  @api invoke() {
    this.isExecuting = true;

    // It has been observed that in some org, the wire method gets called when we click
    // quick action, but in some org it never gets called. Hence a workaround to call this method
    // from invoke to.
    this.reinitiateChat();
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
      this.chatOrCallSid = this.extractChatOrCallSidFromRecord(data);
      this.accountId = data.fields?.AccountId?.value;
      if (this.isExecuting) {
        this.reinitiateChat();
      }
    } else if (error) {
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
      conversationSid: this.chatOrCallSid,
      sObjectId: ""
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

  //This method extract chatOrCallSid from Data fields of Interaction or Related Twilio Details record
  extractChatOrCallSidFromRecord(data) {
    let chatOrCallSidFromInteraction = data.fields?.Chat_or_Call_SID__c?.value;
    let chatOrCallSidFromRelatedTwilioDetail =
      data.fields?.TwilioDetailsID__r?.value?.fields?.Chat_or_Call_SID__c
        ?.value;

    return chatOrCallSidFromInteraction || chatOrCallSidFromRelatedTwilioDetail;
  }
}
