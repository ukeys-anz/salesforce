import { LightningElement, wire, api } from "lwc";

import { publish, MessageContext } from "lightning/messageService";
import CloseModal from "@salesforce/messageChannel/CloseModal__c";

import { getRecord } from "lightning/uiRecordApi";

import CARD_OCV_ID_FIELD from "@salesforce/schema/FinServ__Card__c.OCV_ID__c";
import blockCard from "@salesforce/apex/CardTempBlockController.blockCard";

export default class CardTempBlock extends LightningElement {
  @api recordId;
  @api showModal;
  @api cardNumber;
  ocvId;

  @wire(MessageContext)
  messageContext;

  //Get the OCVID to send to the API
  @wire(getRecord, {
    recordId: "$recordId",
    fields: [CARD_OCV_ID_FIELD]
  })
  wiredProject({ data }) {
    if (data) {
      this.ocvId = data.fields.OCV_ID__c.value;
    }
  }

  closeAction() {
    publish(this.messageContext, CloseModal, { show: !this.showModal });
  }

  handleBlock() {
    blockCard({ cardNumber: this.cardNumber, ocvId: this.ocvId })
      .then((result) => {
        if (result && JSON.parse(result).status) {
          publish(this.messageContext, CloseModal, {
            show: !this.showModal,
            message: "Card temporarily blocked",
            success: true
          });
        }
      })
      .catch((error) => {
        let errorMessage = "Failed to retrieve card details";
        if (error.body && error.body.message) {
          errorMessage = error.body.message;
        }
        publish(this.messageContext, CloseModal, {
          show: !this.showModal,
          message: errorMessage,
          success: false
        });
      });
  }
}
