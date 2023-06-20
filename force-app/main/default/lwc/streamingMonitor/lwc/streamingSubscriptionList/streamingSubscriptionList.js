import { LightningElement, wire } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import {
  publish,
  subscribe,
  unsubscribe,
  MessageContext
} from "lightning/messageService";
import MESSAGE_CHANNEL from "@salesforce/messageChannel/Streaming_app_message_service__c";

export default class StreamingSubscriptionList extends LightningElement {
  subscriptions = [];

  @wire(MessageContext)
  messageContext;

  connectedCallback() {
    this.subscribeToMessageChannel();
  }

  disconnectedCallback() {
    this.unsubscribeToMessageChannel();
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
    if (message.messageName === "subscribeConfirm") {
      this.saveSubscription(message.data);
    }
  }

  onUnsubscribe(event) {
    const channel = event.target.dataset.item;
    let currentSubscriptions = this.subscriptions;

    // Find subscription
    const thisSubscription = currentSubscriptions.filter(
      (sub) => sub.channel === channel
    );
    if (thisSubscription.length !== 1) {
      const event = new ShowToastEvent({
        title: "Error occured",
        variant: "error",
        message: `Failed to unsubscribe: unknown subscription to ${channel}`
      });
      this.dispatchEvent(event);
      return;
    }

    // Unsubscribe
    this.fireEvent("unsubscribeRequest", thisSubscription[0]);

    // Update UI
    let updatedSubscriptions = currentSubscriptions.filter(
      (sub) => sub.channel !== channel
    );
    this.subscriptions = updatedSubscriptions;
  }

  saveSubscription(data) {
    // Save and sort subscriptions
    let currentSubscriptions = this.subscriptions;
    currentSubscriptions.push(data);
    currentSubscriptions.sort((a, b) => {
      const channelA = a.channel.toUpperCase();
      const channelB = b.channel.toUpperCase();
      if (channelA < channelB) {
        return -1;
      }
      if (channelA > channelB) {
        return 1;
      }
      return 0;
    });
    this.subscriptions = JSON.parse(JSON.stringify(currentSubscriptions));
  }

  fireEvent(messageName, data) {
    let payload = { messageName, data };
    publish(this.messageContext, MESSAGE_CHANNEL, payload);
  }
}
