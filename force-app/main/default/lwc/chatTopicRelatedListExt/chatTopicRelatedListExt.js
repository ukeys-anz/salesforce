import { LightningElement, api, track, wire } from "lwc";
import getChatTopics from "@salesforce/apex/ChatTopicRelatedListExternal.getChatTopics";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { publish, MessageContext } from "lightning/messageService";
import chatReChannel from "@salesforce/messageChannel/ReinitiateChatTopic__c";
import { getRecord } from "lightning/uiRecordApi";
import CHANNEL_SID from "@salesforce/schema/Case.Channel_SID__c";
import MEMBER_ID from "@salesforce/schema/Account.MemberId__c";

export default class RetrieveChatTopics extends LightningElement {
  @api recordId;
  @api objectName;
  @track data = []; //data to be displayed in the table
  @track totalRecordCount = 0; //total record count received from all retrieved records
  @track loading = true;
  objectFields = [CHANNEL_SID];
  fieldValue;

  @wire(MessageContext)
  messageContext;

  @wire(getRecord, { recordId: "$recordId", fields: "$objectFields" })
  wiredProject({ data }) {
    if (data) {
      if (this.objectName === "Account") {
        this.fieldValue = data.fields.MemberId__c.value;
        if (this.fieldValue) {
          this.fetchChatTopics();
        } else {
          this.loading = false;
        }
      }
      if (this.objectName === "Case") {
        this.fieldValue = data.fields.Channel_SID__c.value;
        if (this.fieldValue) {
          this.fetchChatTopics();
        } else {
          this.loading = false;
        }
      }
    }
  }

  connectedCallback() {
    if (this.objectName === "Account") {
      this.objectFields = [MEMBER_ID];
    }
    if (this.objectName === "Case") {
      this.objectFields = [CHANNEL_SID];
    }
  }

  fetchChatTopics() {
    getChatTopics({
      objectName: this.objectName,
      fieldValue: this.fieldValue
    })
      .then((result) => {
        if (result) {
          let currentData = [];

          result.forEach((row) => {
            let rowData = {};
            rowData.Name = row.Name__c;
            rowData.Status__c = row.Status__c;
            rowData.LastModifiedDate = row.UpdatedDate__c;
            if (rowData.Status__c === "On Hold") {
              rowData.enableReinitiate = true;
            } else {
              rowData.enableReinitiate = false;
            }
            rowData.ChannelSID = row.ExternalId;
            currentData.push(rowData);
          });
          this.data = currentData;
          this.totalRecordCount = result.length;
        }
        this.loading = false;
      })
      .catch((error) => {
        this.loading = false;
        let errorMessage = "Failed to load chat records";
        if (error.body && error.body.message) {
          errorMessage = error.body.message;
        }
        this.showToast("Chat Topic Load Failed", errorMessage, error);
      });
  }

  handleOnselect(event) {
    let selectedChannelSID = event.target.dataset.id;
    let selectedAction = event.detail.value;

    // Publish a message on 'ReinitiateChatTopic' channel which triggers Twilio to re-initiate this Chat Topic
    if (selectedAction == "re_initiate") {
      const message = { channelSID: selectedChannelSID };

      try {
        publish(this.messageContext, chatReChannel, message);
      } catch (error) {
        let errorMessage = "Failed to re-initiate Chat Topic";
        if (error.body && error.body.message) {
          errorMessage = error.body.message;
        }
        this.showToast("Failed to re-initiate Chat Topic", errorMessage, error);
      }
    }
  }

  showToast(theTitle, theMessage, theVariant) {
    const event = new ShowToastEvent({
      title: theTitle,
      message: theMessage,
      variant: theVariant
    });
    this.dispatchEvent(event);
  }
}
