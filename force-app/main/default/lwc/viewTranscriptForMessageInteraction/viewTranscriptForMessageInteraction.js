import { LightningElement, api, wire } from "lwc";
import { getRecord } from "lightning/uiRecordApi";
import { publish, MessageContext } from "lightning/messageService";
import chatHistoryChannel from "@salesforce/messageChannel/ViewChatTopicHistory__c";
import { ShowToastEvent } from "lightning/platformShowToastEvent";

// Util methods
import { handleErrorShowToast } from "c/utils";

const fields = [
  "Interaction.Chat_or_Call_SID__c",
  "Interaction.Account.OCV_ID__c",
  "Interaction.TwilioDetailsID__r.Chat_or_Call_SID__c"
];

export default class ViewTranscriptForInteraction extends LightningElement {
  _recordId;
  chatOrCallSid;
  isExecuting = false;

  @api invoke() {
    this.isExecuting = true;

    // It has been observed that in some org, the wire method gets called when we click
    // quick action, but in some org it never gets called. Hence a workaround to call this method
    // from invoke to.
    const message = { channelSID: this.chatOrCallSid };
    this.publishLightningMessage(
      chatHistoryChannel,
      message,
      "Error occurred while displaying related Chat History"
    );
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
      this.chatOrCallSid = this.extractChatOrCallSidFromRecord(data);
      if (this.isExecuting) {
        const message = { channelSID: this.chatOrCallSid };
        this.publishLightningMessage(
          chatHistoryChannel,
          message,
          "Error occurred while displaying related Chat History"
        );
      }
    } else if (error) {
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

  //This method extract chatOrCallSid from Data fields of Interaction or Related Twilio Details record
  extractChatOrCallSidFromRecord(data) {
    let chatOrCallSidFromInteraction = data.fields?.Chat_or_Call_SID__c?.value;
    let chatOrCallSidFromRelatedTwilioDetail =
      data.fields?.TwilioDetailsID__r?.value?.fields?.Chat_or_Call_SID__c
        ?.value;

    return chatOrCallSidFromInteraction || chatOrCallSidFromRelatedTwilioDetail;
  }
}
