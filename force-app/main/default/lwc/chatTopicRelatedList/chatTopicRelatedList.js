import { LightningElement, api, track, wire } from "lwc";
import getChatTopicsFromAccount from "@salesforce/apex/ChatTopicRelatedListController.getChatTopicsFromAccount";
import getChatTopicFromCase from "@salesforce/apex/ChatTopicRelatedListController.getChatTopicFromCase";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { publish, MessageContext } from "lightning/messageService";
import chatReChannel from "@salesforce/messageChannel/ReinitiateChatTopic__c";
import chatHistoryChannel from "@salesforce/messageChannel/ViewChatTopicHistory__c";

export default class RetrieveChatTopics extends LightningElement {
  @api recordId;
  @api objectName;
  @track data = []; //data to be displayed in the table
  @track totalRecordCount = 0; //total record count received from all retrieved records
  @track loading = true;

  @wire(MessageContext)
  messageContext;

  connectedCallback() {
    if (this.objectName === "Account") {
      this.fetchChatTopicsFromAccount();
    }
    if (this.objectName === "Case") {
      this.fetchChatTopicsFromCase();
    }
  }

  fetchChatTopicsFromAccount() {
    getChatTopicsFromAccount({
      accountId: this.recordId
    })
      .then((result) => {
        if (result) {
          let currentData = [];

          result.forEach((row) => {
            let rowData = {};
            rowData.Name = row.Name;
            rowData.Status__c = row.Status__c;
            rowData.LastModifiedDate = row.LastModifiedDate;
            if (rowData.Status__c === "On Hold") {
              rowData.enableReinitiate = true;
            } else {
              rowData.enableReinitiate = false;
            }
            rowData.ChannelSID = row.Twilio_Channel_SID__c;
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

  fetchChatTopicsFromCase() {
    getChatTopicFromCase({
      caseId: this.recordId
    })
      .then((result) => {
        if (result) {
          let currentData = [];

          result.forEach((row) => {
            let rowData = {};
            rowData.Name = row.Chat_Topic__r.Name;
            rowData.Status__c = row.Chat_Topic__r.Status__c;
            rowData.LastModifiedDate = row.Chat_Topic__r.LastModifiedDate;
            if (rowData.Status__c === "On Hold") {
              rowData.enableReinitiate = true;
            } else {
              rowData.enableReinitiate = false;
            }
            rowData.ChannelSID = row.Chat_Topic__r.Twilio_Channel_SID__c;
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

    // Show Chat History related to the selected Chat Topic
    if (selectedAction == "chat_history") {
      const message = { channelSID: selectedChannelSID };
      try {
        publish(this.messageContext, chatHistoryChannel, message);
      } catch (error) {
        let errorMessage =
          "Error occured while displaying related Chat History";
        if (error.body && error.body.message) {
          errorMessage = error.body.message;
        }
        this.showToast(
          "Error occured while displaying related Chat History",
          errorMessage,
          error
        );
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
