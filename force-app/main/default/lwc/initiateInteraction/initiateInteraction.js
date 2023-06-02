import { LightningElement, wire, api } from "lwc";
import { getRecord } from "lightning/uiRecordApi";
import { publish, MessageContext } from "lightning/messageService";
import createInteraction from "@salesforce/apex/InitiateInteractionController.createInteraction";
import getPhoneNumber from "@salesforce/apex/InitiateInteractionController.getPhoneNumber";
import initiateChat from "@salesforce/apex/InitiateInteractionController.initiateChat";
import reinitiateChat from "@salesforce/apex/InitiateInteractionController.reinitiateChat";
import voiceChannel from "@salesforce/messageChannel/InitiateOutboundCall__c";
import hasOutboundChatPermission from "@salesforce/customPermission/ANZx_Outbound_Chat";
import hasOutboundDialPermission from "@salesforce/customPermission/ANZx_Outbound_Dialling";

import { handleErrorShowToast } from "c/utils";

// import fields
import ACC_PMP from "@salesforce/schema/Account.PersonMobilePhone";
import APPT_ACC from "@salesforce/schema/Interaction.AccountId";
import CASE_ACC from "@salesforce/schema/Case.AccountId";
import CS_ACC from "@salesforce/schema/Coaching_Summary__c.Account__c";
import CS_LEAD from "@salesforce/schema/Coaching_Summary__c.Lead__c";
import LEAD_MP from "@salesforce/schema/Lead.MobilePhone";

const NORMAL_TAB = "slds-tabs_scoped__item";
const ACTIVE_TAB = "slds-tabs_scoped__item slds-is-active";

export default class InitiateInteraction extends LightningElement {
  showContactTab;
  showDialTab = true;
  showChatWindow;
  contactTab = NORMAL_TAB;
  dialTab = ACTIVE_TAB;
  phoneNumber = "";
  messageToSend;
  numberToDial;
  callPhoneNumber;
  newInteraction;
  invalidMessage = true;
  invalidNumber = true;
  showMessageDialog = true;
  showMessageToast = false;
  showSuccessMessage = true;
  showErrorMessage = false;
  isLoadingCase = false;
  remainingCharStyle = "slds-text-color_default slds-float_right";
  errMsg = "Something went wrong. Please try again";
  remainingCharMsg = "1000 characters remaining";
  outboundError =
    "Uh-oh, there was an error and we couldn't automatically create the interaction. Please manually create a call interaction";
  contactCustomer = false;
  fields = {
    recordType: "General",
    direction: "Outbound"
  };
  objectFields = [];
  @api recordId;
  @api objectApiName;
  conversationSid; //Populated as part of the initiate chat response
  executionSid; //Populated as part of the reinitiate chat response
  showMessageCustomer = false;

  get displayOutboundChat() {
    return hasOutboundChatPermission;
  }

  get displayOutboundDial() {
    return hasOutboundDialPermission;
  }

  @wire(MessageContext)
  messageContext;
  @wire(getRecord, {
    recordId: "$recordId",
    fields: "$objectFields"
  })
  async wireRecord({ data }) {
    this.isLoaded = false;
    if (data) {
      switch (this.objectApiName) {
        case "Account":
          this.fields.accountId = this.recordId;
          this.fields.reason = "Customer";
          //Show contact tab as default on account
          this.contactCustomer = true;
          this.showMessageCustomer = true;
          this.handleShowContactTab();
          break;
        case "Case":
          this.fields.accountId = data.fields.AccountId.value;
          this.fields.caseId = this.recordId;
          this.fields.reason = "Customer";
          //If we have a number, set to true and show contact tab
          if (this.callPhoneNumber) {
            this.contactCustomer = true;
            this.handleShowContactTab();
          }
          break;
        case "Coaching_Summary__c":
          this.fields.accountId = data.fields.Account__c.value;
          this.fields.leadId = data.fields.Lead__c.value;
          this.fields.coachingSummaryId = this.recordId;
          this.fields.reason = "Customer";
          break;
        case "Interaction":
          this.fields.appointmentId = this.recordId;
          this.fields.accountId = data.fields.AccountId.value;
          this.fields.reason = "Customer";
          break;
        case "Lead":
          this.fields.leadId = this.recordId;
          this.fields.reason = "Non-Customer";
          break;
        default:
      }
    } else {
      this.showChatWindow = false;
    }
    this.isLoaded = true;
  }

  connectedCallback() {
    switch (this.objectApiName) {
      case "Account":
        this.objectFields = [ACC_PMP];
        break;
      case "Case":
        this.objectFields = [CASE_ACC];
        break;
      case "Coaching_Summary__c":
        this.objectFields = [CS_ACC, CS_LEAD];
        break;
      case "Interaction":
        this.objectFields = [APPT_ACC];
        break;
      case "Lead":
        this.objectFields = [LEAD_MP];
        break;
      default:
    }
    getPhoneNumber({
      sId: this.recordId
    }).then((result) => {
      if (result != null) {
        this.phoneNumber = result;
        this.callPhoneNumber = "Call " + this.phoneNumber;
      } else {
        //If we dont need to show Message Customer
        //and we dont have a number, hide the tab all together
        if (!this.showMessageCustomer) {
          this.contactCustomer = false;
          this.handleShowDialTab();
        }
      }
    });
  }

  handleShowContactTab() {
    this.showContactTab = true;
    this.showDialTab = false;
    this.showChatWindow = false;
    this.contactTab = ACTIVE_TAB;
    this.dialTab = NORMAL_TAB;
    this.remainingCharMsg = "1000 characters remaining";
  }

  handleShowDialTab() {
    this.showContactTab = false;
    this.showDialTab = true;
    this.showChatWindow = false;
    this.contactTab = NORMAL_TAB;
    this.dialTab = ACTIVE_TAB;
  }

  handleShowChatWindow() {
    this.showContactTab = false;
    this.showChatWindow = true;
    this.showMessageDialog = true;
    this.showMessageToast = false;
  }

  async handleCallCustomer() {
    this.fields.interactionType = "Call";
    this.fields.contactNumber = this.phoneNumber;
    try {
      let fields = this.fields;
      this.newInteraction = await createInteraction({
        fields
      });
    } catch (error) {
      let errorText = this.outboundError;
      let errorMessage = errorText;
      if (error.body && error.body.message) {
        errorMessage = error.body.message;
      }
      handleErrorShowToast(this, errorText, error, errorMessage, "pester");
    } finally {
      const message = {
        recordId: this.newInteraction.Id,
        externalId: this.newInteraction.Interaction_External_Id__c,
        number: this.phoneNumber
      };
      this.publishLightningMessage(
        voiceChannel,
        message,
        "Oops, we couldn't connect your call. Please try again."
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

  async handleMessageCustomer() {
    this.isLoadingCase = true;
    try {
      let response = await initiateChat({
        accountId: this.fields.accountId,
        messageContent: this.messageToSend
      });

      if (response?.conversationSid) {
        this.conversationSid = response.conversationSid;
      }

      this.showMessageDialog = false;
      this.showMessageToast = true;
    } catch (error) {
      handleErrorShowToast(
        this,
        "Initiate Chat failed",
        error,
        "Failed to send outbound chat message. Please try sending it again. Raise a fault through TechAssist if the problem persists.",
        "pester"
      );
    }
    this.isLoadingCase = false;
  }

  async handleReinitiate() {
    this.isLoadingCase = true;
    let errorMessage =
      "Failed to reinitiate chat. Please refresh and try again. Raise a fault through TechAssist if the problem persists.";
    if (this.conversationSid) {
      try {
        let response = await reinitiateChat({
          accountId: this.fields.accountId,
          conversationSid: this.conversationSid
        });
        if (response?.executionSid) {
          this.executionSid = response.executionSid;
          this.handleShowContactTab();
        }
      } catch (error) {
        handleErrorShowToast(
          this,
          "Reinitiate Chat failed",
          error,
          errorMessage,
          "pester"
        );
      }
    } else {
      handleErrorShowToast(
        this,
        "Reinitiate Chat failed",
        errorMessage,
        errorMessage,
        "pester"
      );
    }
    this.isLoadingCase = false;
  }

  handlePhoneChange(event) {
    let regex = "[a-zA-Z]+";
    if (
      event.target.value.length < 3 ||
      event.target.value.length > 15 ||
      event.detail.value.match(regex)
    ) {
      this.invalidNumber = true;
    } else {
      this.numberToDial = event.detail.value;
      this.invalidNumber = false;
    }
  }

  handleMessageChange(event) {
    let txtAreaMessage = event.detail.value;
    if (txtAreaMessage.trim().length < 4 || txtAreaMessage.length > 1000) {
      this.invalidMessage = true;
    } else {
      this.messageToSend = txtAreaMessage;
      this.invalidMessage = false;
    }

    this.remainingCharMsg =
      1000 - txtAreaMessage.length + " characters remaining";
    if (txtAreaMessage.length >= 1000) {
      this.remainingCharStyle = "slds-text-color_error slds-float_right";
    } else {
      this.remainingCharStyle = "slds-text-color_default slds-float_right";
    }
  }

  async handleCallNow() {
    this.fields.interactionType = "Call";
    this.fields.contactNumber = this.numberToDial;
    try {
      let fields = this.fields;
      this.newInteraction = await createInteraction({
        fields
      });
    } catch (error) {
      let errorText = this.outboundError;
      let errorMessage = errorText;
      if (error.body && error.body.message) {
        errorMessage = error.body.message;
      }
      handleErrorShowToast(this, errorText, error, errorMessage, "pester");
    } finally {
      const message = {
        recordId: this.newInteraction.Id,
        externalId: this.newInteraction.Interaction_External_Id__c,
        number: this.numberToDial
      };
      this.publishLightningMessage(
        voiceChannel,
        message,
        "Oops, we couldn't connect your call. Please try again."
      );
    }
  }
}
