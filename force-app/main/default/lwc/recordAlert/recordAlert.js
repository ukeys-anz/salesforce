import { LightningElement, api, wire } from "lwc";
import {
  subscribe,
  unsubscribe,
  onError,
  isEmpEnabled
} from "lightning/empApi";
import userInfoId from "@salesforce/user/Id";

import {
  subscribe as lmsSubscribe,
  unsubscribe as lmsUnsubscribe,
  APPLICATION_SCOPE,
  MessageContext
} from "lightning/messageService";
import ConsoleTabFocus from "@salesforce/messageChannel/ConsoleTabFocus__c";

import { showToast } from "c/utils";
import { getRecord } from "lightning/uiRecordApi";

const CHANNEL_NAME = "/event/Record_Monitoring__e";

export default class RecordAlert extends LightningElement {
  @api recordId;
  @api objectApiName;

  @api toastTitle;
  @api toastMessage;
  @api toastFields;

  subscription = {};
  referenceId;
  hasExecuted = false;

  lmsSubscription = null;

  @wire(MessageContext)
  messageContext;

  @wire(getRecord, {
    recordId: "$recordId",
    fields: "$fields"
  })
  wiredProject({ data, error }) {
    if (data) {
      //add different objects as needed
      switch (this.objectApiName) {
        case "Case":
          this.referenceId =
            data.fields[[this.toastFields][0]?.split(".")[1]]?.value;
          break;
        default:
          break;
      }
      if (this.hasExecuted === false) {
        this.executeEmpSubscription();
        this.hasExecuted = true;
      }
    } else if (error) {
      console.log("getRecords error : ", error);
    }
  }
  get fields() {
    //getRecords used by case for now
    if (this.objectApiName === "Case") {
      return this.toastFields;
    }
    return undefined;
  }

  connectedCallback() {
    //when getRecords isn't invoked
    if (this.hasExecuted === false) {
      this.executeEmpSubscription();
      this.subscribeToMessageChannel();
      this.hasExecuted = true;
    }
  }

  disconnectedCallback() {
    this.unsubscribeEmp(this);
    this.unsubscribeToMessageChannel(this);
  }

  /** LMS functions **/
  subscribeToMessageChannel() {
    if (!this.lmsSubscription) {
      this.lmsSubscription = lmsSubscribe(
        this.messageContext,
        ConsoleTabFocus,
        (message) => this.handleLMSMessage(message),
        { scope: APPLICATION_SCOPE }
      );
    }
  }

  unsubscribeToMessageChannel() {
    lmsUnsubscribe(this.lmsSubscription);
    this.lmsSubscription = null;
  }

  // Handler for message received by component
  handleLMSMessage(message) {
    if (message.tabInfo.recordId !== this.recordId) {
      this.unsubscribeEmp(this);
      this.hasExecuted = false;
      return;
    }
    if (this.hasExecuted === false) {
      this.executeEmpSubscription();
      this.hasExecuted = true;
    }
  }

  /** EMP API Functions **/
  handleSubscribe() {
    const self = this;
    const messageCallback = function (response) {
      const eventMessage = JSON.parse(response.data.payload.Message__c);

      switch (self.objectApiName) {
        //case toast only if related RLA is updated
        case "Case":
          if (
            eventMessage.Origin === "ResidentialLoanApplication" &&
            eventMessage.Ids?.includes(self.referenceId)
          ) {
            showToast(
              self,
              eventMessage.Toast.title,
              eventMessage.Toast.message,
              "",
              "success",
              "dismissible"
            );
            return;
          }
          break;
        default:
          //no toast for current user who fired event for every other sobject
          if (userInfoId === eventMessage.User) {
            return;
          }
          break;
      }

      //toast for everyone else
      if (eventMessage.Ids?.includes(self.recordId)) {
        showToast(
          self,
          self.toastTitle,
          self.toastMessage,
          "",
          "success",
          "dismissible"
        );
      }
    };

    subscribe(CHANNEL_NAME, -1, messageCallback).then((response) => {
      this.subscription = response;
    });
  }

  registerErrorListener() {
    onError((error) => {
      console.log("Received error from server: ", JSON.stringify(error));
    });
  }

  checkEmpApi() {
    isEmpEnabled().then((isEnabled) => {
      if (!isEnabled) {
        showToast(
          this,
          "Error on EMP API",
          `EMP API is not enabled is this environment. Streaming app will not work.`,
          "",
          "error",
          "dismissible"
        );
      }
    });
  }

  executeEmpSubscription() {
    this.checkEmpApi();
    this.registerErrorListener();
    this.handleSubscribe();
  }

  unsubscribeEmp(instance) {
    unsubscribe(instance.subscription, (response) => {
      console.log("unsubscribe() successful", response);
    });
  }
}
