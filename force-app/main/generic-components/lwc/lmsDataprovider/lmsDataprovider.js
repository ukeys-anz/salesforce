import { LightningElement, wire } from "lwc";
import { subscribe, MessageContext, publish } from "lightning/messageService";
import dataProviderChannel from "@salesforce/messageChannel/lmsDataProviderChannel__c";
import getData from "@salesforce/apex/GenericController.getData";

export default class lmsDataprovider extends LightningElement {
  subscription = null;

  @wire(MessageContext)
  messageContext;

  connectedCallback() {
    this.subscribeToMessageChannel();
  }

  disconnectedCallback() {
    this.unsubscribeFromMessageChannel();
  }

  subscribeToMessageChannel() {
    if (!this.subscription) {
      this.subscription = subscribe(
        this.messageContext,
        dataProviderChannel,
        (message) => this.handleMessage(message)
      );
    }
  }

  unsubscribeFromMessageChannel() {
    if (this.subscription) {
      this.subscription = null;
    }
  }

  // ignore response message, process request message, broadcast message is no controller specified
  handleMessage(message) {
    if (message.isResponse) {
      return;
    }

    const { controllerClassName, parameters } = message;

    if (controllerClassName) {
      this.callApex(controllerClassName, parameters);
    } else {
      publishResponse(message, "broadcast", false);
    }
  }

  callApex(controllerClassName, parameters) {
    getData({ apexController: controllerClassName, param: parameters })
      .then((result) => {
        this.publishResponse(result, controllerClassName, true);
      })
      .catch((error) => {
        console.error(`Error calling ${controllerClassName}:`, error);
        this.publishResponse(
          {
            error: error.body?.message || "Unknown error"
          },
          controllerClassName
        );
      });
  }

  publishResponse(message, controllerClassName, isResponse) {
    const parsedMessage =
      typeof message === "string" ? JSON.parse(message) : message;
    publish(this.messageContext, dataProviderChannel, {
      isResponse: isResponse,
      controllerClassName: controllerClassName,
      message: parsedMessage
    });
  }
}
