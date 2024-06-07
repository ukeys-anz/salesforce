import { LightningElement, wire, api } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";

import { messageHandler } from "./helper/helper-message";
import {
  fraudLockOptionsSchema,
  showFraudLockOptions,
  teamToContactOptionsSchema
} from "./helper/helper-fraud-lock";
import {
  primaryButtonChatterMessage,
  fraudChatterMessage
} from "./helper/helper-chatter-message";
import { toastSuccessObjectSchema } from "./helper/helper-confirm-toast-handler";
import { firstMessageForFraudOption } from "./helper/helper-message";
import {
  fraudLockToastErrorObjectSchema,
  noTeamToContactChosenErrorToastSchema
} from "./helper/helper-error-toast-handler";
import {
  cardActionReason,
  primaryButtonToCardStatus
} from "./helper/helper-card-action";

import fraudLock from "@salesforce/apex/FraudCardStatusController.setFraudCardStatus";

import { publish, MessageContext } from "lightning/messageService";
import CloseModal from "@salesforce/messageChannel/CloseModal__c";

import { getRecord } from "lightning/uiRecordApi";
import OCV_ID_FIELD from "@salesforce/schema/Account.OCV_ID__c";

export default class cardFraudLock extends LightningElement {
  @api recordId;
  @api showModal;
  @api cardNumber;
  @api buttonClicked;
  @api cardStatus;
  @api last4Digits;
  @api currentUserName;

  ocvId;
  fraudLockOptions = [];
  teamToContactOptions = [];
  displayFraudOptions;
  displayTeamToContact;
  newCardStatus = "";
  newTeamToContact = "";
  message = {};
  chatterMessage = "";
  reason = "";
  confirmButtonTriggered = false;

  connectedCallback() {
    this.displayTeamToContact = showFraudLockOptions(this.buttonClicked);
    this.message = messageHandler(this.buttonClicked);
    this.reason = cardActionReason(this.buttonClicked);

    if (this.displayTeamToContact) {
      this.teamToContactOptions = teamToContactOptionsSchema(
        this.newTeamToContact
      );
    } else {
      this.chatterMessage = primaryButtonChatterMessage(
        this.buttonClicked,
        this.last4Digits,
        this.currentUserName
      );
      this.newCardStatus = primaryButtonToCardStatus(this.buttonClicked);
    }
  }

  @wire(MessageContext)
  messageContext;

  //Get the OCVID to send to the API
  @wire(getRecord, { recordId: "$recordId", fields: [OCV_ID_FIELD] })
  wiredProject({ data }) {
    if (data) {
      this.ocvId = data.fields.OCV_ID__c.value;
    }
  }

  closeAction() {
    publish(this.messageContext, CloseModal, {
      name: "showFraudLock",
      show: !this.showModal
    });
  }

  fraudLockStatusSelectHandler = (e) => {
    this.newCardStatus = e.target.dataset.status;
    this.fraudLockOptions = fraudLockOptionsSchema(this.newCardStatus);
  };

  teamToContactSelectHandler = (e) => {
    this.newTeamToContact = e.target.dataset.label;
    this.teamToContactOptions = teamToContactOptionsSchema(
      this.newTeamToContact
    );
  };

  handleTeamToContact = () => {
    if (!this.newTeamToContact) {
      this.showErrorToastTeamToContact();
      return;
    }

    this.displayTeamToContact = false;
    this.displayFraudOptions = true;
    this.fraudLockOptions = fraudLockOptionsSchema(this.cardStatus);
  };

  handleFraudLock = () => {
    if (this.newCardStatus && this.newCardStatus !== this.cardStatus) {
      this.message = firstMessageForFraudOption(
        this.newCardStatus,
        this.message
      );
      this.displayFraudOptions = false;
      this.chatterMessage = fraudChatterMessage(
        this.newCardStatus,
        this.last4Digits,
        this.newTeamToContact
      );
    } else {
      this.showErrorToastFraudLock();
    }
  };

  submitHandler = () => {
    let fraudLockObject = {
      chatterInformation: {
        recordId: this.recordId,
        currentUserName: this.currentUserName,
        chatterMessage: this.chatterMessage
      },
      fraudLockInformation: {
        cardNumber: this.cardNumber,
        ocvId: this.ocvId,
        status: this.newCardStatus,
        reason: this.reason
      }
    };

    fraudLock({
      fraudLockObject
    })
      .then((result) => {
        if (result) {
          this.showSuccessToast();
          this.closeAction();
        }
      })
      .catch(() => {
        let errorMessage = `Oh no! There was an issue ${
          this.buttonClicked === "Cancel Card" ? "cancelling" : "locking"
        } this card. Please refresh and try again. Raise a fault through TechAssist if the problem persists.`;

        publish(this.messageContext, CloseModal, {
          name: "showFraudLock",
          show: !this.showModal,
          message: errorMessage,
          success: false
        });
        this.closeAction();
      });
    this.confirmButtonTriggered = true;
  };

  showSuccessToast() {
    const toastObject = toastSuccessObjectSchema(this.buttonClicked);
    const event = new ShowToastEvent(toastObject);
    this.dispatchEvent(event);
  }

  showErrorToastFraudLock() {
    const toastObject = fraudLockToastErrorObjectSchema(
      this.newCardStatus,
      this.cardStatus
    );
    const event = new ShowToastEvent(toastObject);
    this.dispatchEvent(event);
  }

  showErrorToastTeamToContact() {
    const toastObject = noTeamToContactChosenErrorToastSchema;
    const event = new ShowToastEvent(toastObject);
    this.dispatchEvent(event);
  }
}
