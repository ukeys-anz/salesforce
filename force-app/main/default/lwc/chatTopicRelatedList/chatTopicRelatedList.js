import { LightningElement, api, track, wire } from "lwc";
import getChatTopicsOnAccount from "@salesforce/apex/ChatTopicRelatedListController.getChatTopicsOnAccount";
import getChatTopicInfoOnCase from "@salesforce/apex/ChatTopicRelatedListController.getChatTopicInfoOnCase";
import { publish, MessageContext } from "lightning/messageService";
import chatReChannel from "@salesforce/messageChannel/ReinitiateChatTopic__c";
import chatHistoryChannel from "@salesforce/messageChannel/ViewChatTopicHistory__c";

// Util methods
import { handleErrorShowToast } from "c/utils";

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

export default class ChatTopicRelatedList extends LightningElement {
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
        if (result) {
          // To check if there were more records that what was retrieved against the same Customer
          this.links = result.links.links;

          // TODO: More error handling

          result.channels.forEach((row) => {
            this.data.push(this.generateRowData(row));
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

        handleErrorShowToast(
          this,
          "Chat Topic Load Failed",
          error,
          errorMessage,
          "pester"
        );
      });
  }

  fetchChatTopicInfoOnCase() {
    getChatTopicInfoOnCase({
      caseId: this.recordId
    })
      .then((result) => {
        if (result) {
          // TODO: More error handling

          this.data.push(this.generateRowData(result));
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

        handleErrorShowToast(
          this,
          "Chat Topic Load Failed",
          error,
          errorMessage,
          "pester"
        );
      });
  }

  generateRowData(row) {
    row.status = this.resolveStatuses(row);
    if (
      row.status &&
      row.status !== STATUS_CLOSED &&
      row.chatFlowStatus === CHAT_FLOW_STATUS_ONHOLD
    ) {
      row.enableReinitiate = true;
    } else {
      row.enableReinitiate = false;
    }

    return row;
  }

  handleOnselect(event) {
    let selectedChannelSID = event.target.dataset.id;
    let selectedAction = event.detail.value;

    // Publish a message on 'ReinitiateChatTopic' channel which triggers Twilio to re-initiate this Chat Topic
    if (selectedAction === "re_initiate") {
      const message = { channelSID: selectedChannelSID };
      this.publishLightningMessage(
        chatReChannel,
        message,
        "Failed to re-initiate Chat Topic"
      );
    }

    // Show Chat History related to the selected Chat Topic
    if (selectedAction === "chat_history") {
      const message = { channelSID: selectedChannelSID };
      this.publishLightningMessage(
        chatHistoryChannel,
        message,
        "Error occured while displaying related Chat History"
      );
    }
  }

  publishLightningMessage(msgChannel, message, errorText) {
    try {
      publish(this.messageContext, msgChannel, message);
    } catch (error) {
      let errorMessage = errorText;
      if (error.body && error.body.message) {
        errorMessage = error.body.message;
      }

      handleErrorShowToast(this, errorText, error, errorMessage, "pester");
    }
  }

  resolveStatuses(row) {
    let topicStatus;

    if (row.status) {
      if (row.chatFlowStatus) {
        // IF row status is 'active'
        if (row.status === STATUS_ACTIVE) {
          if (row.chatFlowStatus === CHAT_FLOW_STATUS_NEW) {
            topicStatus = TOPIC_STATUS_NEW;
          }
          if (row.chatFlowStatus === CHAT_FLOW_STATUS_ACCEPTED) {
            topicStatus = TOPIC_STATUS_ACTIVE;
          }
          if (row.chatFlowStatus === CHAT_FLOW_STATUS_OPEN) {
            topicStatus = TOPIC_STATUS_OPEN;
          }
        }

        // IF row status is 'inactive'
        if (row.status === STATUS_INACTIVE) {
          if (row.chatFlowStatus === CHAT_FLOW_STATUS_RESOLVED) {
            topicStatus = TOPIC_STATUS_RESOLVED;
          }

          if (
            row.chatFlowStatus === CHAT_FLOW_STATUS_ONHOLD &&
            row.onHoldReason
          ) {
            if (row.onHoldReason === ONHOLD_REASON_CUSTOMER) {
              topicStatus = TOPIC_STATUS_ONHOLD_CUSTOMER;
            }
            if (row.onHoldReason === ONHOLD_REASON_COACH) {
              topicStatus = TOPIC_STATUS_ONHOLD_COACH;
            }
          }
        }
      }

      // IF row status is 'closed'
      if (row.status === STATUS_CLOSED) {
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
