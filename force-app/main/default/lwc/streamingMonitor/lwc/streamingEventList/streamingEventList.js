import { wire, LightningElement } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import {
  publish,
  subscribe,
  unsubscribe,
  MessageContext
} from "lightning/messageService";
import {
  subscribe as empSubscribe,
  unsubscribe as empUnsubscribe,
  onError,
  isEmpEnabled
} from "lightning/empApi";
import MESSAGE_CHANNEL from "@salesforce/messageChannel/Streaming_app_message_service__c";
import displayModal from "c/streamingMonitorModal";
import LOCALE from "@salesforce/i18n/locale";

const columns = [
  {
    label: "Time",
    fieldName: "time",
    type: "text",
    sortable: true,
    initialWidth: 180
  },
  {
    label: "Channel",
    fieldName: "channel",
    type: "text",
    sortable: true,
    initialWidth: 200
  },
  {
    label: "Replay Id",
    fieldName: "replayId",
    type: "number",
    sortable: true,
    initialWidth: 100
  },
  { label: "Payload", fieldName: "payload", type: "text" },
  {
    label: " ",
    type: "button-icon",
    initialWidth: 50,
    typeAttributes: {
      iconName: "utility:zoomin",
      name: "view",
      title: "Click to View Details"
    }
  }
];
const dateOption = {
  year: "numeric",
  month: "numeric",
  day: "numeric",
  hour: "numeric",
  minute: "numeric",
  second: "numeric",
  hour12: false
};
export default class StreamingEventList extends LightningElement {
  receivedEvents = [];
  columns = columns;

  @wire(MessageContext)
  messageContext;

  connectedCallback() {
    this.checkEmpApiEnabled();
    this.subscribeToMessageChannel();
  }

  disconnectedCallback() {
    this.unsubscribeToMessageChannel();

    for (let sub of this.empSubscriptionList) {
      this.handleUnsubscribeRequest(sub, false);
    }
    this.empSubscriptionList = [];
  }

  checkEmpApiEnabled() {
    onError((error) => {
      this.showToast(
        "Error on EMP API",
        "error",
        `Received error from server: ${JSON.stringify(error)}`
      );
      // Error contains the server-side error
    });
    isEmpEnabled().then((isEnabled) => {
      if (!isEnabled) {
        this.showToast(
          "Error on EMP API",
          "error",
          `EMP API is not enabled is this environment. Streaming app will not work.`
        );
      }
    });
  }

  lmssubscription = null;
  subscribeToMessageChannel() {
    this.lmssubscription = subscribe(
      this.messageContext,
      MESSAGE_CHANNEL,
      (message) => this.handleMessage(message)
    );
  }

  unsubscribeToMessageChannel() {
    unsubscribe(this.lmssubscription);
    this.lmssubscription = null;
  }

  handleMessage(message) {
    if (message.messageName == "subscribeRequest") {
      this.handleSubscribeRequest(message.data);
    } else if (message.messageName == "unsubscribeRequest") {
      this.handleUnsubscribeRequest(message.data, true);
    }
  }

  empSubscriptionList = [];
  handleSubscribeRequest(data) {
    //check If Subscription Exist for the same event
    if (this.checkIfSubscriptionExist(data)) {
      return;
    }

    var lwcThisContext = this;
    const messageCallback = function (response) {
      lwcThisContext.showToast(
        "New message received",
        "success",
        `Received event from : ${response.channel}`
      );
      // Response contains the payload of the new message received
      lwcThisContext.saveEventData(response.channel, response.data);
    };
    empSubscribe(data.channel, data.replayId, messageCallback).then(
      (response) => {
        // Response contains the subscription information on subscribe call
        this.showToast(
          "Subscription successful",
          "success",
          `Subscribed to channel : ${response.channel}`
        );
        let payload = {
          messageName: "subscribeConfirm",
          data: response
        };
        publish(this.messageContext, MESSAGE_CHANNEL, payload);
        let currentSubscriptions = this.empSubscriptionList;
        currentSubscriptions.push(response);
        this.empSubscriptionList = currentSubscriptions;
      }
    );
  }

  checkIfSubscriptionExist(data) {
    let subscriptionExist = this.empSubscriptionList?.some(
      (x) => x.channel === data.channel
    );

    if (subscriptionExist) {
      this.showToast(
        "Subscription unsuccessful",
        "error",
        `Subscription already exist for this channel : ${data.channel}`
      );
    }
    return subscriptionExist;
  }

  saveEventData(channel, data) {
    // Build id for datatable // Generic event does not support schema Id
    let id =
      (typeof data.schema !== "undefined" ? data.schema : channel) +
      data.event.replayId;

    // Extract time from event
    let time = null;
    if (typeof data.event.createdDate !== "undefined") {
      // Generic event and PushTopic
      time = new Date(data.event.createdDate);
    } else if (typeof data.payload.ChangeEventHeader !== "undefined") {
      // CDC
      time = new Date(data.payload.ChangeEventHeader.commitTimestamp);
    } else if (typeof data.payload.CreatedDate !== "undefined") {
      // Platform Event
      time = new Date(data.payload.CreatedDate);
    }
    // Assemble payload
    let payload = null;
    if (typeof data.payload !== "undefined") {
      payload = data.payload;
    } else if (typeof data.sobject !== "undefined") {
      // PushTopic
      payload = data.sobject;
    }
    // Build event row
    let eventRow = {
      id,
      time: new Intl.DateTimeFormat(LOCALE, dateOption).format(time), // fix the timeformat
      channel: channel,
      replayId: data.event.replayId,
      payload: JSON.stringify(payload, null, 4),
      rawPayload: JSON.stringify({ data, channel }, null, 4)
    };
    // Append row to table
    let tmpData = this.receivedEvents;
    tmpData.unshift(eventRow);
    this.receivedEvents = JSON.parse(JSON.stringify(tmpData));
  }

  handleUnsubscribeRequest(data, updateSubscriptionList) {
    var lwcThisContext = this;
    empUnsubscribe(data, () => {
      lwcThisContext.showToast(
        "Unsubscription successful!",
        "success",
        `Unsuscribed from event successfully`
      );
    });

    if (updateSubscriptionList) {
      let updatedSubscriptions = this.empSubscriptionList.filter(
        (sub) => sub.channel !== data.channel
      );
      this.subscriptions = updatedSubscriptions;
    }
  }

  clearReceivedEvents() {
    this.receivedEvents = [];
  }

  handleEventTableRowAction(event) {
    const action = event.detail.action;
    let row = event.detail.row;
    switch (action.name) {
      case "view":
        this.handleClick(row);
        break;
    }
  }
  async handleClick(eventData) {
    const result = await displayModal.open({
      size: "large",
      description: "Display event data",
      eventData: eventData
    });
  }
  showToast(title, variant, message) {
    const event = new ShowToastEvent({ title, variant, message });
    this.dispatchEvent(event);
  }
}
