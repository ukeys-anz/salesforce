import { LightningElement, wire } from "lwc";
import getAllEventChannels from "@salesforce/apex/StreamingMonitorController.getAllEventChannels";
import publishEvent from "@salesforce/apex/StreamingMonitorController.publishEvent";
import { publish, MessageContext } from "lightning/messageService";
import MESSAGE_CHANNEL from "@salesforce/messageChannel/Streaming_app_message_service__c";
import { ShowToastEvent } from "lightning/platformShowToastEvent";

const eventTypes = [
  { label: "PushTopic event", value: "PushTopicEvent" },
  { label: "Generic event", value: "GenericEvent" },
  { label: "Platform event", value: "PlatformEvent" },
  { label: "CDC event", value: "ChangeDataCaptureEvent" }
];
const replayOption = [
  { label: "No replay", value: "-1" },
  { label: "Replay past events", value: "-2" }
];
export default class StreamingAction extends LightningElement {
  isLoading = true;
  channels;

  eventTypeOptions = eventTypes;
  replayOption = replayOption;

  subEventType;
  subEventName;
  subEventOptions;
  subChannel;
  subReplay = "1";

  pubEventType;
  pubEventName;
  pubEventOptions;
  pubChannel;
  pubEventPayload;

  regEventType;

  get disableSubEventName() {
    return !this.subEventType;
  }
  get disableSubscribe() {
    return !this.subEventType || !this.subEventName;
  }
  get disablePublish() {
    return !this.pubEventType || !this.pubEventName;
  }

  get publishGenericOrPlatformEvent() {
    return (
      this.pubEventType === "GenericEvent" ||
      this.pubEventType === "PlatformEvent"
    );
  }
  get publishPushTopicOrCDC() {
    return (
      this.pubEventType === "PushTopicEvent" ||
      this.pubEventType === "ChangeDataCaptureEvent"
    );
  }

  get isRegEventTypePusTopic() {
    return this.regEventType === "PushTopicEvent";
  }

  get isRegEventTypeGenericEvent() {
    return this.regEventType === "GenericEvent";
  }

  get isRegEventTypePlatformEvent() {
    return this.regEventType === "PlatformEvent";
  }

  get isRegEventTypeCDC() {
    return this.regEventType === "ChangeDataCaptureEvent";
  }

  @wire(getAllEventChannels)
  wiredEventChannels({ error, data }) {
    if (data) {
      this.channels = data;
      this.isLoading = false;
    } else if (error) {
      this.channels = undefined;
      this.isLoading = false;
    }
  }
  @wire(MessageContext)
  messageContext;

  handleFieldChange(event) {
    let fld = event.target.name;
    this[fld] = event.target.value;

    try {
      switch (fld) {
        case "subEventType":
          this.loadEvents("sub");
          break;
        case "subEventName":
          this.updateChannel("sub");
          break;
        case "pubEventType":
          this.loadEvents("pub");
          break;
        case "pubEventName":
          this.updateChannel("pub");
          break;
      }
    } catch (e) {
      console.error(e);
    }
  }

  getChannelPrefix(eventType) {
    switch (eventType) {
      case "PushTopicEvent":
        return "/topic/";
      case "GenericEvent":
        return "/u/";
      case "PlatformEvent":
        return "/event/";
      case "ChangeDataCaptureEvent":
        return "/data/";
    }
  }

  onSubscribe() {
    const channel = this.subChannel;
    const replayId = this.subReplay;
    this.fireEvent("subscribeRequest", { channel, replayId });
    this.subEventName = "";
    this.subChannel = "";
  }

  onPublish() {
    this.isLoading = true;
    publishEvent({
      eventType: this.pubEventType,
      eventName: this.pubEventName,
      eventPayload: this.pubEventPayload
    })
      .then(() => {
        this.showToast(
          "Event published successful",
          "success",
          `Published event ${this.pubEventName} successfully`
        );
      })
      .catch(() => {
        this.showToast(
          "Error in publising event",
          "error",
          `Failed to publish event ${this.pubEventName}`
        );
      })
      .finally(() => {
        this.isLoading = false;
      });
  }

  updateChannel(pubSubPrefix) {
    const eventType = this[`${pubSubPrefix}EventType`];
    const eventName = this[`${pubSubPrefix}EventName`];
    const channelPrefix = this.getChannelPrefix(eventType);

    this[`${pubSubPrefix}Channel`] =
      channelPrefix + (eventName ? eventName : "");
  }

  loadEvents(pubSubPrefix) {
    this[`${pubSubPrefix}EventName`] = "";
    this.updateChannel(pubSubPrefix);

    let eventType = this[`${pubSubPrefix}EventType`];
    let channelDirectory = JSON.parse(JSON.stringify(this.channels));
    if (pubSubPrefix === "sub" && eventType === "ChangeDataCaptureEvent") {
      channelDirectory[eventType].unshift({
        label: "All Change Events",
        value: "ChangeEvents"
      });
    }
    this[`${pubSubPrefix}EventOptions`] = channelDirectory[eventType];
  }

  fireEvent(messageName, data) {
    let payload = { messageName, data };
    publish(this.messageContext, MESSAGE_CHANNEL, payload);
  }
  showToast(title, variant, message) {
    const event = new ShowToastEvent({ title, variant, message });
    this.dispatchEvent(event);
  }
}
