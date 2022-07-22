import { LightningElement, wire, api } from "lwc";

import { publish, MessageContext } from "lightning/messageService";
import CloseModal from "@salesforce/messageChannel/CloseModal__c";

import { getRecord } from "lightning/uiRecordApi";

import OCV_ID_FIELD from "@salesforce/schema/Account.OCV_ID__c";
import lockCard from "@salesforce/apex/CardTempLockController.lockCard";

import hasLockCardsPermission from "@salesforce/customPermission/ANZx_Temp_Lock_Card";

const LOCK_SUCCESS_MSG =
  "The physical card has been successfully locked. This means all physical transactions are blocked, including ATM and point of sale.";
const LOCK_FAILURE_MSG =
  "Oh no! There was an issue locking this card. Please refresh and try again. Raise a fault through TechAssist if the problem persists.";
export default class CardTempLock extends LightningElement {
  @api recordId;
  @api showModal;
  @api cardNumber;
  ocvId;
  loading;

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
      this.loading = true;
      lockCard({ cardNumber: this.cardNumber, ocvId: this.ocvId })
        .then((result) => {
          if (result) {
            publish(this.messageContext, CloseModal, {
              name: "lock",
              show: !this.showModal,
              message: LOCK_SUCCESS_MSG,
              success: true
            });
          }
          this.loading = false;
        })
        .catch((error) => {
          let errorMessage = LOCK_FAILURE_MSG;
          if (error.body && error.body.message) {
            errorMessage = error.body.message;
          }
          publish(this.messageContext, CloseModal, {
            name: "lock",
            show: !this.showModal,
            message: errorMessage,
            success: false
          });
          this.loading = false;
        });
    }
  }
}
