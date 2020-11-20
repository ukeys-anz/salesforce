import { LightningElement, api, track, wire } from "lwc";

import getTotalBalance from "@salesforce/apex/TotalBalanceController.getTotalBalance";
import getTotalSaved from "@salesforce/apex/TotalBalanceController.getTotalSaved";

import { ShowToastEvent } from "lightning/platformShowToastEvent";

import { subscribe, MessageContext } from "lightning/messageService";
import UpdateAccountsAndGoals from "@salesforce/messageChannel/FinancialAccountsGoalsUpdate__c";
import TriggerLoading from "@salesforce/messageChannel/FinancialAccountsTriggerLoading__c";

export default class TotalBalance extends LightningElement {
  @api recordId;
  @track totalBalance;
  @track totalSaved;
  @track loading = true;
  hasError = false;
  error;

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
          this.totalSaved = null;
          this.totalBalance = null;
          this.getTotal();

          if (this.totalBalance || this.totalSaved) {
            this.loading = false;
          }
        } else {
          this.error = message.message;
          this.getTotal();
          this.showToast("Total Balance Load Failed", this.error);
        }
      }
    );

    if (!this.subscription || Object.keys(this.subscription).length === 0) {
      this.getTotal();
    }
  }

  showToast(theTitle, theMessage) {
    const event = new ShowToastEvent({
      title: theTitle,
      message: theMessage
    });
    this.dispatchEvent(event);
  }

  getTotal() {
    getTotalBalance({
      ownerId: this.recordId
    })
      .then((result) => {
        this.totalBalance = result.totalBalance
          ? new Intl.NumberFormat("en-AU", {
              style: "currency",
              currency: "AUD"
            }).format(result.totalBalance)
          : "N/A";

        this.loading = false;
      })
      .catch((error) => {
        this.loading = false;
        if (error.body && error.body.message) {
          this.error = error.body.message;
        }
        this.hasError = true;
      });

    getTotalSaved({
      ownerId: this.recordId
    })
      .then((result) => {
        this.totalSaved = result.totalSaved
          ? new Intl.NumberFormat("en-AU", {
              style: "currency",
              currency: "AUD"
            }).format(result.totalSaved)
          : "N/A";

        this.loading = false;
      })
      .catch((error) => {
        this.loading = false;
        if (error.body && error.body.message) {
          this.error = error.body.message;
        }
        this.hasError = true;
      });
  }
}
