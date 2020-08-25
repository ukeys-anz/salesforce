import { LightningElement, api, track, wire } from "lwc";

import getTotalBalance from "@salesforce/apex/TotalBalanceController.getTotalBalance";

import { ShowToastEvent } from "lightning/platformShowToastEvent";

import { subscribe, MessageContext } from "lightning/messageService";
import UpdateAccountsAndGoals from "@salesforce/messageChannel/FinancialAccountsGoalsUpdate__c";
import TriggerLoading from "@salesforce/messageChannel/FinancialAccountsTriggerLoading__c";

export default class TotalBalance extends LightningElement {
  @api recordId;
  acc;
  @track totalBalance;
  @track timestamp;
  @track loading = true;

  @wire(MessageContext)
  messageContext;
  subscription = null;
  loadingSubscription = null;

  connectedCallback() {
    this.loadingSubscription = subscribe(
      this.messageContext,
      TriggerLoading,
      (message) => {
        if (message.update) {
          this.loading = true;
        }
      }
    );

    this.subscription = subscribe(
      this.messageContext,
      UpdateAccountsAndGoals,
      (message) => {
        if (message.update) {
          this.acc = null;
          this.getTotal();
          this.setTimestamp();

          if (this.acc) {
            this.loading = false;
          }
        }
      }
    );

    if (!this.subscription || Object.keys(this.subscription).length === 0) {
      this.getTotal();
      this.setTimestamp();
    }
  }

  setTimestamp() {
    //Create timestamp for last updated
    const today = new Date();
    this.timestamp =
      today.getDate() +
      " " +
      today.toLocaleString("en-AU", {
        month: "long"
      }) +
      " " +
      today.getFullYear() +
      " | " +
      today.toLocaleString("en-AU", {
        hour: "numeric",
        minute: "numeric",
        hour12: true
      });
  }

  showToast(theTitle, theMessage, theVariant) {
    const event = new ShowToastEvent({
      title: theTitle,
      message: theMessage,
      variant: theVariant
    });
    this.dispatchEvent(event);
  }

  getTotal() {
    getTotalBalance({
      ownerId: this.recordId
    })
      .then((result) => {
        this.acc = result;
        this.totalBalance = new Intl.NumberFormat("en-AU", {
          style: "currency",
          currency: "AUD"
        }).format(this.acc.FinServ__TotalFinAcctsPrimaryOwner__c);
        this.loading = false;
      })
      .catch((error) => {
        this.loading = false;
        let errorMessage = "Failed to load total balance";
        if (error.body && error.body.message) {
          errorMessage = error.body.message;
        }
        this.showToast("Total Balance Load Failed", errorMessage, error);
      });
  }
}
