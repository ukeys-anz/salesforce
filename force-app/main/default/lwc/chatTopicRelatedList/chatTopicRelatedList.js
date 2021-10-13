import { LightningElement, api, track, wire } from "lwc";
import { getRecord } from "lightning/uiRecordApi";
import getChatTopicsOnAccount from "@salesforce/apex/ChatTopicRelatedListController.getChatTopicsOnAccount";
import getChatTopicInfoOnCase from "@salesforce/apex/ChatTopicRelatedListController.getChatTopicInfoOnCase";
import { publish, MessageContext } from "lightning/messageService";
import chatReChannel from "@salesforce/messageChannel/ReinitiateChatTopic__c";
import chatHistoryChannel from "@salesforce/messageChannel/ViewChatTopicHistory__c";
import UserId from "@salesforce/user/Id";
import USERROLE_FIELD from "@salesforce/schema/User.UserRole.DeveloperName";
import ACCOUNT_PPID_FIELD from "@salesforce/schema/Account.PPID__c";
import CASE_CHANNEL_SID_FIELD from "@salesforce/schema/Case.Twilio_Channel_SID__c";

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
  @track isPrivilegedRole = true; // show button by default
  links;
  objectFields = [];

  @wire(MessageContext)
  messageContext;
  // get current user and role field
  @wire(getRecord, { recordId: UserId, fields: [USERROLE_FIELD] })
  wireuser({ error, data }) {
    if (data && data.fields.UserRole) {
      if (
        // if the user role is QA
        data.fields.UserRole.value.fields.DeveloperName.value ===
        "Quality_Analyst"
      ) {
        // make this variable false
        this.isPrivilegedRole = false;
      } else if (error) {
        // error handling
        handleErrorShowToast(
          this,
          "Unable to resolve role privileges",
          error,
          error.body.message,
          "pester"
        );
      }
    }
  }

  @wire(getRecord, {
    recordId: "$recordId",
    fields: "$objectFields"
  })
  wiredProject({ data }) {
    if (data) {
      if (this.objectName === "Account") {
        //Check if there is PPID otherwise no chat topics
        if (data.fields && data.fields.PPID__c.value) {
          this.fetchChatTopicsOnAccount();
        }
      } else if (this.objectName === "Case") {
        //Check if there is channelSID otherwise no chat topics
        if (data.fields && data.fields.Twilio_Channel_SID__c.value) {
          this.fetchChatTopicInfoOnCase();
        }
      } else {
        this.loading = false;
      }
    } else {
      this.loading = false;
    }
  }

  connectedCallback() {
    this.objectFields =
      this.objectName === "Account"
        ? [ACCOUNT_PPID_FIELD]
        : [CASE_CHANNEL_SID_FIELD];
  }

  fetchChatTopicsOnAccount(nextUrl = "") {
    getChatTopicsOnAccount({
      accountId: this.recordId,
      nextURL: nextUrl
    })
      .then((result) => {
        if (result) {
          // To check if there were more records that what was retrieved against the same Customer
          // Check if links is not undefined before processing, avoid throwing error when user has the case tab open along with
          // the account tab which will call fetchChatTopicInfoOnCase() and return a single channel which might not have links
          this.links = result.links !== undefined ? result.links : "";

          // TODO: More error handling
          // Check if there are channels before processing, avoid throwing error when user has the case tab open along with
          // the account tab which will call fetchChatTopicInfoOnCase() and return a single channel instead of a list of channels
          if (result.channels) {
            result.channels.forEach((row) => {
              this.data.push(this.generateRowData(row));
            });
            this.totalRecordCount = this.data.length;
          }
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
        if (Object.keys(result).length !== 0) {
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
      this.isPrivilegedRole === true &&
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
        "Error occurred while displaying related Chat History"
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
