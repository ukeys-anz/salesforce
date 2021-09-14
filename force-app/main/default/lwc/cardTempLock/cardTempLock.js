import { LightningElement, wire, api } from "lwc";

import { publish, MessageContext } from "lightning/messageService";
import CloseModal from "@salesforce/messageChannel/CloseModal__c";

import { getRecord } from "lightning/uiRecordApi";

import OCV_ID_FIELD from "@salesforce/schema/Account.OCV_ID__c";
import lockCard from "@salesforce/apex/CardTempLockController.lockCard";

import hasLockCardsPermission from "@salesforce/customPermission/ANZx_Temp_Lock_Card";

export default class CardTempLock extends LightningElement {
  @api recordId;
  @api showModal;
  @api cardNumber;
  ocvId;

  @wire(MessageContext)
  messageContext;

  //Get the OCVID to send to the API
  @wire(getRecord, {
    recordId: "$recordId",
    fields: [OCV_ID_FIELD]
  })
  wiredProject({ data }) {
    if (data) {
      this.ocvId = data.fields.OCV_ID__c.value;
    }
  }

  closeAction() {
    publish(this.messageContext, CloseModal, {
      name: "lock",
      show: !this.showModal
    });
  }

  handleLock() {
    if (hasLockCardsPermission) {
      lockCard({ cardNumber: this.cardNumber, ocvId: this.ocvId })
        .then((result) => {
          if (result) {
            publish(this.messageContext, CloseModal, {
              name: "lock",
              show: !this.showModal,
              message: "Card successfully locked.",
              success: true
            });
          }
        })
        .catch((error) => {
          let errorMessage =
            "Oh no! There was an issue locking this card. Please refresh and try again. Raise a fault through TechAssist if the problem persists.";
          if (error.body && error.body.message) {
            errorMessage = error.body.message;
          }
          publish(this.messageContext, CloseModal, {
            name: "lock",
            show: !this.showModal,
            message: errorMessage,
            success: false
          });
        });
    }
  }
}
