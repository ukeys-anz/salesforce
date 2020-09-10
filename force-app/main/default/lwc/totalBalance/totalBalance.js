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
        }
      }
    );

    if (!this.subscription || Object.keys(this.subscription).length === 0) {
      this.getTotal();
    }
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
        let errorMessage = "Failed to load total balance";
        if (error.body && error.body.message) {
          errorMessage = error.body.message;
        }
        this.showToast("Total Balance Load Failed", errorMessage, error);
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
        let errorMessage = "Failed to load total saved";
        if (error.body && error.body.message) {
          errorMessage = error.body.message;
        }
        this.showToast("Total Balance Load Failed", errorMessage, error);
      });
  }
}
