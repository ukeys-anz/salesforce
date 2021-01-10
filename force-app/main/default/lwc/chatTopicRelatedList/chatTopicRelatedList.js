import { LightningElement, api, track, wire } from "lwc";
import getChatTopicsOnAccount from "@salesforce/apex/ChatTopicRelatedListController.getChatTopicsOnAccount";
import getChatTopicInfoOnCase from "@salesforce/apex/ChatTopicRelatedListController.getChatTopicInfoOnCase";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { publish, MessageContext } from "lightning/messageService";
import chatReChannel from "@salesforce/messageChannel/ReinitiateChatTopic__c";
import chatHistoryChannel from "@salesforce/messageChannel/ViewChatTopicHistory__c";

// Twilio Channel Status values
const STATUS_ACTIVE = "active";
const STATUS_INACTIVE = "inactive";
const STATUS_CLOSED = "closed";
const CHAT_FLOW_STATUS_NEW = "NEW";
const CHAT_FLOW_STATUS_ACCEPTED = "ACCEPTED";
const CHAT_FLOW_STATUS_RESOLVED = "RESOLVED";
const CHAT_FLOW_STATUS_ONHOLD = "ON_HOLD";
const CHAT_FLOW_STATUS_OPEN = "OPEN";
const ONHOLD_REASON_CUSTOMER = "WAITING_ON_CUSTOMER";
const ONHOLD_REASON_COACH = "WAITING_ON_COACH";

// Chat Topic statuses to be displayed for Coaches
const TOPIC_STATUS_NEW = "New";
const TOPIC_STATUS_ACTIVE = "Active";
const TOPIC_STATUS_RESOLVED = "Resolved";
const TOPIC_STATUS_ONHOLD_CUSTOMER = "On Hold (customer)";
const TOPIC_STATUS_ONHOLD_COACH = "On Hold (coach)";
const TOPIC_STATUS_OPEN = "Open";
const TOPIC_STATUS_CLOSED = "Closed & Archived";
const TOPIC_STATUS_UNDEFINED = "Undefined";

export default class RetrieveChatTopics extends LightningElement {
  @api recordId;
  @api objectName;
  @track data = []; //data to be displayed in the table
  @track totalRecordCount = 0; //total record count received from all retrieved records
  @track loading = true;

  links;

  @wire(MessageContext)
  messageContext;

  connectedCallback() {
    if (this.objectName === "Account") {
      this.fetchChatTopicsOnAccount();
    }
    if (this.objectName === "Case") {
      this.fetchChatTopicInfoOnCase();
    }
  }

  fetchChatTopicsOnAccount(nextUrl = "") {
    getChatTopicsOnAccount({
      accountId: this.recordId,
      nextURL: nextUrl
    })
      .then((result) => {
        console.log(result);

        if (result) {
          let respObj = JSON.parse(result);

          // To heck if there were more records that what was retrieved against the same Customer
          this.links = respObj._links._links;

          // TODO: More error handling

          respObj.channels.forEach((row) => {
            let rowData = {};

            console.log(row);

            rowData.Name = row.name;
            rowData.Status = this.resolveStatuses(row);
            rowData.LastModifiedDate = row.lastModified;
            rowData.ChannelSID = row.id;
            if (
              row.status &&
              row.status != STATUS_CLOSED &&
              row.chatFlowStatus === CHAT_FLOW_STATUS_ONHOLD
            ) {
              rowData.enableReinitiate = true;
            } else {
              rowData.enableReinitiate = false;
            }
            this.data.push(rowData);
          });
          this.totalRecordCount = this.data.length;
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

  fetchChatTopicInfoOnCase() {
    getChatTopicInfoOnCase({
      caseId: this.recordId
    })
      .then((result) => {
        if (result) {
          console.log(result);

          let respObj = JSON.parse(result);

          console.log(respObj);
          // TODO: More error handling

          let rowData = {};
          rowData.Name = respObj.name;
          rowData.Status = this.resolveStatuses(respObj);
          rowData.LastModifiedDate = respObj.lastModified;
          rowData.ChannelSID = respObj.id;

          if (
            respObj.status &&
            respObj.status != STATUS_CLOSED &&
            respObj.chatFlowStatus === CHAT_FLOW_STATUS_ONHOLD
          ) {
            rowData.enableReinitiate = true;
          } else {
            rowData.enableReinitiate = false;
          }
          this.data.push(rowData);

          this.totalRecordCount = this.data.length;
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

  resolveStatuses(row) {
    let topicStatus;

    if (row.status) {
      if (row.chatFlowStatus) {
        // IF row status is 'active'
        if (row.status == STATUS_ACTIVE) {
          if (row.chatFlowStatus == CHAT_FLOW_STATUS_NEW) {
            topicStatus = TOPIC_STATUS_NEW;
          }
          if (row.chatFlowStatus == CHAT_FLOW_STATUS_ACCEPTED) {
            topicStatus = TOPIC_STATUS_ACTIVE;
          }
          if (row.chatFlowStatus == CHAT_FLOW_STATUS_OPEN) {
            topicStatus = TOPIC_STATUS_OPEN;
          }
        }

        // IF row status is 'inactive'
        if (row.status == STATUS_INACTIVE) {
          if (row.chatFlowStatus == CHAT_FLOW_STATUS_RESOLVED) {
            topicStatus = TOPIC_STATUS_RESOLVED;
          }

          if (
            row.chatFlowStatus == CHAT_FLOW_STATUS_ONHOLD &&
            row.onHoldReason
          ) {
            if (row.onHoldReason == ONHOLD_REASON_CUSTOMER) {
              topicStatus = TOPIC_STATUS_ONHOLD_CUSTOMER;
            }
            if (row.onHoldReason == ONHOLD_REASON_COACH) {
              topicStatus = TOPIC_STATUS_ONHOLD_COACH;
            }
          }
        }
      }

      // IF row status is 'closed'
      if (row.status == STATUS_CLOSED) {
        topicStatus = TOPIC_STATUS_CLOSED;
      }
    }

    // Incase if no conditions were matched
    if (!topicStatus) {
      topicStatus = TOPIC_STATUS_UNDEFINED;
    }

    return topicStatus;
  }

  get showLoadMore() {
    return this.links && this.links.next ? true : false;
  }

  handleLoadMore() {
    // Read the URL substring related to next offset (if there is a next) from the response,
    // and pass it in the next API call
    let nextSubstring = `?${this.links.next.substring(
      this.links.next.indexOf("?") + 1
    )}`;

    this.fetchChatTopicsOnAccount(nextSubstring);
  }
}
