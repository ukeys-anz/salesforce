import { LightningElement, wire, api } from "lwc";
import { publish, MessageContext } from "lightning/messageService";
import CloseModal from "@salesforce/messageChannel/CloseModal__c";
import { getRecord } from "lightning/uiRecordApi";

import hasReplaceCardsPermission from "@salesforce/customPermission/ANZx_Replace_Card";
import replaceCard from "@salesforce/apex/CardReplaceController.replaceCard";

const RECORD_FIELDS = [
  "Account.OCV_ID__c",
  "Account.BillingStreet",
  "Account.BillingCity",
  "Account.BillingState",
  "Account.BillingPostalCode",
  "Account.BillingCountry"
];

export default class ReplaceCard extends LightningElement {
  @api recordId;
  @api showModal;
  @api cardNumber;
  @api replaceLostUnavailable;
  @api replaceStolenUnavailable;
  @api replaceDamagedUnavailable;
  @api replaceLockUnavailable;
  ocvId;
  showSelectionMenu = true;
  showLostMenu = false;
  showStolenMenu = false;
  showDamagedMenu = false;
  billingStreet;
  billingCity;
  billingState;
  billingPostalCode;
  billingCountry;
  replaceOption;
  @wire(MessageContext)
  messageContext;
  loading;

  //Get the OCVID to send to the API
  @wire(getRecord, {
    recordId: "$recordId",
    fields: RECORD_FIELDS
  })
  wiredProject({ data }) {
    if (data) {
      this.ocvId = data.fields.OCV_ID__c.value;
      this.billingStreet = data.fields.BillingStreet.value;
      this.billingCity = data.fields.BillingCity.value;
      this.billingState = data.fields.BillingState.value;
      this.billingPostalCode = data.fields.BillingPostalCode.value;
      this.billingCountry = data.fields.BillingCountry.value;
    }
  }

  closeAction() {
    //reset the order for the menus
    this.showSelectionMenu = true;
    this.showLostMenu = false;
    publish(this.messageContext, CloseModal, {
      name: "replace",
      show: !this.showModal
    });
  }

  handleLostMenu() {
    this.showSelectionMenu = false;
    this.showLostMenu = true;
  }

  handleReplaceMenu(event) {
    //set the replace path we want to use
    this.replaceOption = event.target.dataset.id;
    this.showSelectionMenu = false;
    this.showLostMenu = false;
    this.showReplaceMenu = true;
  }

  handleLockMenu() {
    // close the replace modal
    this.closeAction();

    // open the lock modal
    publish(this.messageContext, CloseModal, {
      name: "lock",
      show: true
    });
  }

  handleReplaceCard() {
    if (hasReplaceCardsPermission) {
      this.loading = true;
      replaceCard({
        cardNumber: this.cardNumber,
        ocvId: this.ocvId,
        reason: this.replaceOption.toUpperCase()
      })
        .then((result) => {
          if (result) {
            publish(this.messageContext, CloseModal, {
              name: "replace",
              show: !this.showModal,
              message: "A replacement card has successfully been ordered.",
              success: true
            });
          }
          this.loading = false;
        })
        .catch((error) => {
          this.loading = false;
          let errorMessage =
            "Oh no! There was an issue replacing this card. Please refresh and try again. Raise a fault through TechAssist if the problem persists.";
          if (error.body && error.body.message) {
            errorMessage = error.body.message;
          }
          publish(this.messageContext, CloseModal, {
            name: "replace",
            show: !this.showModal,
            message: errorMessage,
            success: false
          });
        });
    }
  }
}
