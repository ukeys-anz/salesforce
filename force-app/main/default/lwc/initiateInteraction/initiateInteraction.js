import { LightningElement, wire, api } from "lwc";
import { getRecord } from "lightning/uiRecordApi";
import { publish, MessageContext } from "lightning/messageService";
import createInteraction from "@salesforce/apex/InitiateInteractionController.createInteraction";
import getPhoneNumber from "@salesforce/apex/InitiateInteractionController.getPhoneNumber";
import voiceChannel from "@salesforce/messageChannel/InitiateOutboundCall__c";

import { handleErrorShowToast } from "c/utils";

// import fields
import ACC_PMP from "@salesforce/schema/Account.PersonMobilePhone";
import APPT_ACC from "@salesforce/schema/Interaction.AccountId";
import CASE_ACC from "@salesforce/schema/Case.AccountId";
import CS_ACC from "@salesforce/schema/Coaching_Summary__c.Account__c";
import CS_LEAD from "@salesforce/schema/Coaching_Summary__c.Lead__c";
import LEAD_MP from "@salesforce/schema/Lead.MobilePhone";

const NORMAL_TAB = "slds-tabs_default__item";
const ACTIVE_TAB = "slds-tabs_default__item slds-is-active";

export default class InitiateInteraction extends LightningElement {
  showContactTab;
  showDialTab;
  contactTab;
  dialTab;
  enableChat = false;
  phoneNumber = "";
  numberToDial;
  callPhoneNumber;
  newInteraction;
  outboundError =
    "Uh-oh, there was an error and we couldn't automatically create the interaction. Please manually create a call interaction";
  contactCustomer;
  fields = {
    recordType: "General",
    direction: "Outbound"
  };
  objectFields = [];
  @api recordId;
  @api objectApiName;

  @wire(MessageContext)
  messageContext;
  @wire(getRecord, {
    recordId: "$recordId",
    fields: "$objectFields"
  })
  async wireRecord({ data }) {
    this.loading = true;
    if (data) {
      switch (this.objectApiName) {
        case "Account":
          this.fields.accountId = this.recordId;
          this.fields.reason = "Customer";
          break;
        case "Case":
          this.fields.accountId = data.fields.AccountId.value;
          this.fields.caseId = this.recordId;
          this.fields.reason = "Customer";
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
      this.contactCustomer = false;
      this.showContactTab = false;
      this.showDialTab = true;
      this.dialTab = ACTIVE_TAB;
      this.contactTab = NORMAL_TAB;
    }
    this.loading = false;
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
        this.callPhoneNumber = "Call " + result;
        this.contactCustomer = true;
        this.showContactTab = true;
        this.showDialTab = false;
        this.contactTab = ACTIVE_TAB;
        this.dialTab = NORMAL_TAB;
      }
    });
  }

  handleShowContactTab() {
    this.showContactTab = true;
    this.showDialTab = false;
    this.contactTab = ACTIVE_TAB;
    this.dialTab = NORMAL_TAB;
  }

  handleShowDialTab() {
    this.showContactTab = false;
    this.showDialTab = true;
    this.contactTab = NORMAL_TAB;
    this.dialTab = ACTIVE_TAB;
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
    this.fields.interactionType = "Chat";
  }

  handleInputChange(event) {
    this.numberToDial = event.detail.value;
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
