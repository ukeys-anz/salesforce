import { LightningElement, api, wire } from "lwc";
import { getRecord } from "lightning/uiRecordApi";
import { publish, MessageContext } from "lightning/messageService";
import chatHistoryChannel from "@salesforce/messageChannel/ViewChatTopicHistory__c";
import { ShowToastEvent } from "lightning/platformShowToastEvent";

// Util methods
import { handleErrorShowToast } from "c/utils";

const fields = [
  "Interaction.Chat_or_Call_SID__c",
  "Interaction.Account.OCV_ID__c"
];

export default class ViewTranscriptForInteraction extends LightningElement {
  _recordId;
  chatOrCallSid;
  isExecuting = false;

  @api invoke() {
    if (this.chatOrCallSid && this.isExecuting) {
      const message = { channelSID: this.chatOrCallSid };
      this.publishLightningMessage(
        chatHistoryChannel,
        message,
        "Error occurred while displaying related Chat History"
      );
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

  @wire(MessageContext)
  messageContext;

  /**
   * Wire Method To Fetch ChatOr
   */
  @wire(getRecord, { recordId: "$_recordId", fields })
  interactionRecord({ data, error }) {
    if (data) {
      if (data.fields && data.fields.Chat_or_Call_SID__c.value) {
        this.chatOrCallSid = data.fields.Chat_or_Call_SID__c.value;
        this.isExecuting = true;
      }
    } else {
      console.error(
        "Error in Fetching ChatOrCallSid -> " + JSON.stringify(error)
      );
    }
  }

  publishLightningMessage(msgChannel, message, errorText) {
    let boolIsError = false;
    try {
      publish(this.messageContext, msgChannel, message);
    } catch (error) {
      boolIsError = true;
      let errorMessage = errorText;
      if (error.body && error.body.message) {
        errorMessage = error.body.message;
      }

      handleErrorShowToast(this, errorText, error, errorMessage, "pester");
    } finally {
      if (!boolIsError) {
        this.showToast("Success", "View Transcript Ran Successfully");
      }
      this.isExecuting = false;
    }
  }

  showToast(title, message) {
    const event = new ShowToastEvent({
      title: title,
      message: message,
      variant: "success"
    });
    this.dispatchEvent(event);
  }
}
