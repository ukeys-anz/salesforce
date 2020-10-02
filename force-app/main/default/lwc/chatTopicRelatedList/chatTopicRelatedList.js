import { LightningElement, api, track } from "lwc";
import getChatTopicsFromAccount from "@salesforce/apex/ChatTopicRelatedListController.getChatTopicsFromAccount";
import getChatTopicFromCase from "@salesforce/apex/ChatTopicRelatedListController.getChatTopicFromCase";
import { ShowToastEvent } from "lightning/platformShowToastEvent";

export default class RetrieveChatTopics extends LightningElement {
  @api recordId;
  @api objectName;
  @track data = []; //data to be displayed in the table
  @track totalRecordCount = 0; //total record count received from all retrieved records
  @track loading = true;

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

  handleOnselect() {
    //do nothing for now
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
