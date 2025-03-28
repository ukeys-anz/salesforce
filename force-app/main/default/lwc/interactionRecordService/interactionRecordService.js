import { LightningElement, wire, api } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import { getRecord } from "lightning/uiRecordApi";
import { publish, MessageContext } from "lightning/messageService";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import chatHistoryChannel from "@salesforce/messageChannel/ViewChatTopicHistory__c";
import reinitiateChat from "@salesforce/apex/InitiateInteractionController.reinitiateChat";
import hasOutboundChatPermission from "@salesforce/customPermission/ANZx_Outbound_Chat";
import getInteractionRecord from "@salesforce/apex/InteractionRecordServiceController.getInteractionRecord";
import USER_ID from "@salesforce/user/Id";
import USER_ROLE from "@salesforce/schema/User.UserRole.DeveloperName";

// Util methods
import { handleErrorShowToast } from "c/utils";

export default class InteractionRecordService extends NavigationMixin(
  LightningElement
) {
  @api strParentId;
  @api strRecordTypeName;
  @api maxNumber;
  @api lightningPageName;
  @api messageRecord;
  @api generalRecord;
  @api storeRecord;
  @api appointmentRecord;
  @api showOpenMessageOnly;
  rolesToShowViewTranscriptOnCop = [
    "Quality_Analyst",
    "Join_Lead",
    "Quality_Capability_Lead"
  ];
  chatOrCallSid;
  showInteractionRecords = false;
  totalInteractionRecords = 0;
  interactionrecords = {
    data: undefined,
    error: undefined
  };
  userRole;

  get displayReinitiateChat() {
    return hasOutboundChatPermission;
  }

  get showMessage() {
    return this.strRecordTypeName === this.messageRecord;
  }

  get showCall() {
    return this.strRecordTypeName === this.generalRecord;
  }

  get showStore() {
    return this.strRecordTypeName === this.storeRecord;
  }

  get showAppointment() {
    return this.strRecordTypeName === this.appointmentRecord;
  }

  @wire(getRecord, { recordId: USER_ID, fields: [USER_ROLE] })
  user({ error, data }) {
    if (data) {
      this.userRole = data.fields.UserRole?.value?.fields?.DeveloperName?.value;
    } else if (error) {
      console.error("Error retrieving user record", error);
    }
  }

  @wire(MessageContext)
  messageContext;
  //This method will get the interactions associated to the parent record example Account, case, lead, coaching summary
  @wire(getInteractionRecord, {
    strParentId: "$strParentId",
    strRecordTypeName: "$strRecordTypeName",
    maxRecords: "$maxNumber",
    activeInteractionsOnly: "$showOpenMessageOnly"
  })
  wiredData(response) {
    const { error, data } = response;
    if (data) {
      this.interactionrecords.error = undefined;
      if (data.length > 0) {
        let interactionRecords = structuredClone(data);
        this.interactionrecords.data = this.calculateInteractionRecords(
          this.addViewTranscriptButtonVisibility(interactionRecords)
        );
        this.totalInteractionRecords = interactionRecords.length;
        this.showInteractionRecords = true;
      }
      this.showViewAll();
    } else if (error) {
      this.interactionrecords.data = undefined;
      this.interactionrecords.error = error.message;
    }
  }

  calculateInteractionRecords(data) {
    if (data.length > this.maxNumber) {
      return data.slice(0, this.maxNumber);
    }
    return data;
  }

  //This is called when view all link is clicked on appointment tab and show all list of interactions.
  handleViewRecord(evt) {
    evt.preventDefault();
    evt.stopPropagation();

    let rId = evt.currentTarget.dataset.id;

    this[NavigationMixin.Navigate]({
      type: "standard__recordPage",
      attributes: {
        recordId: rId,
        objectApiName: "Interaction",
        actionName: "view"
      }
    });
  }

  // This method controls the visibility of view all link on message, call, store tab
  showViewAll() {
    this.dispatchEvent(
      new CustomEvent("showviewall", {
        detail: {
          showViewAll: this.totalInteractionRecords > 0,
          totalInteractionCount: this.getTotalInteractionCount()
        }
      })
    );
  }

  getTotalInteractionCount() {
    if (this.totalInteractionRecords <= this.maxNumber) {
      return this.totalInteractionRecords;
    }
    return this.maxNumber + "+";
  }

  handleOnselect(event) {
    this.chatOrCallSid = event.target.dataset.id;
  }

  // this method will perform the action based on selection of View transcript and Reply to customers button
  handleActionSelect(event) {
    let accountId = event.target.dataset.id;
    let selectedAction = event.target.value;
    // Publish a message on 'ReinitiateChatTopic' channel which triggers Twilio to re-initiate this Chat Topic
    if (selectedAction === "re_initiate") {
      let errorMessage =
        "Failed to reinitiate chat. Please refresh and try again. Raise a fault through TechAssist if the problem persists.";
      reinitiateChat({
        accountId: accountId,
        conversationSid: this.chatOrCallSid,
        sObjectId: ""
      })
        .then((result) => {
          if (result) {
            this.showToast("Success", "Reinitiate Chat Completed Successfully");
          }
        })
        .catch((error) => {
          console.error(
            "Error in reinitiating chat -> " + JSON.stringify(error)
          );
          handleErrorShowToast(
            this,
            "Failed to re-initiate Chat",
            errorMessage,
            errorMessage,
            "pester"
          );
        });
    }

    // Show Chat History related to the selected Chat Topic
    if (selectedAction === "chat_history") {
      const message = { channelSID: this.chatOrCallSid };
      this.publishLightningMessage(
        chatHistoryChannel,
        message,
        "Error occurred while displaying related Chat History"
      );
    }
  }

  publishLightningMessage(msgChannel, message, errorText) {
    let boolIsError = false;
    try {
      publish(this.messageContext, msgChannel, message);
    } catch (error) {
      boolIsError = true;
      let errorMessage = errorText;
      if (error.body && error.body.message) {
        errorMessage = error.body.message;
      }

      handleErrorShowToast(this, errorText, error, errorMessage, "pester");
    } finally {
      if (!boolIsError) {
        this.showToast("Success", "View Transcript Ran Successfully");
      }
    }
  }

  showToast(title, message) {
    const event = new ShowToastEvent({
      title: title,
      message: message,
      variant: "success"
    });
    this.dispatchEvent(event);
  }

  addViewTranscriptButtonVisibility(interactionRecords) {
    interactionRecords.forEach((record) => {
      if (
        !record?.actualTopic?.includes("Confirmation of Payee") ||
        rolesToShowViewTranscriptOnCop.includes(this.userRole)
      ) {
        record.enableViewTranscript = true;
      } else {
        record.enableViewTranscript = false;
      }
    });

    return interactionRecords;
  }
}
