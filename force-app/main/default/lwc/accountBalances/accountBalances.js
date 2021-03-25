import { LightningElement, api, track, wire } from "lwc";

import getBalances from "@salesforce/apex/AccountBalancesController.getBalances";
import { ShowToastEvent } from "lightning/platformShowToastEvent";

import { subscribe, MessageContext } from "lightning/messageService";
import UpdateAccounts from "@salesforce/messageChannel/FinancialAccountsUpdate__c";
import TriggerLoading from "@salesforce/messageChannel/FinancialAccountsTriggerLoading__c";

import hasAccountsGoalsPermission from "@salesforce/customPermission/ANZx_Accounts_and_Goals";

export default class AccountBalances extends LightningElement {
  @api recordId;
  loading = true;
  currentBalance;
  availableBalance;
  @track timestamp;
  @track loading = true;
  hasError = false;
  error;

  @wire(MessageContext)
  messageContext;
  subscription = null;
  loadingSubscription = null;

  connectedCallback() {
    if (hasAccountsGoalsPermission) {
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
        UpdateAccounts,
        (message) => {
          if (message.update) {
            this.timestamp = "";
            this.fetchBalances();

            if (this.availableBalance && this.currentBalance) {
              this.loading = false;
            }
          } else {
            this.error = message.message;
            this.fetchBalances();
            this.showToast("Financial Account Load Failed", this.error);
          }
        }
      );

      if (!this.subscription || Object.keys(this.subscription).length === 0) {
        this.fetchBalances();
      }
    }
  }

  get displayContent() {
    return hasAccountsGoalsPermission;
  }

  fetchBalances() {
    getBalances({
      recordId: this.recordId
    })
      .then((result) => {
        if (result) {
          result.forEach((finAccount) => {
            //Only set timestamp once instead of each time in the loop
            if (!this.timestamp) {
              this.setTimestamp(finAccount.LastModifiedDate);
            }
            //Format balances
            this.availableBalance = new Intl.NumberFormat("en-AU", {
              style: "currency",
              currency: "AUD"
            }).format(finAccount.FinServ__Balance__c);

            this.currentBalance = new Intl.NumberFormat("en-AU", {
              style: "currency",
              currency: "AUD"
            }).format(finAccount.FinServ__CurrentPostedBalance__c);
          });
        }
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

  setTimestamp(lastModifiedDate) {
    //Create timestamp for last updated
    const lastUpdated = new Date(lastModifiedDate);
    this.timestamp =
      lastUpdated.getDate() +
      " " +
      lastUpdated.toLocaleString("en-AU", {
        month: "long"
      }) +
      " " +
      lastUpdated.getFullYear() +
      " | " +
      lastUpdated.toLocaleString("en-AU", {
        hour: "numeric",
        minute: "numeric",
        hour12: true
      });
  }

  showToast(theTitle, theMessage) {
    const event = new ShowToastEvent({
      title: theTitle,
      message: theMessage
    });
    this.dispatchEvent(event);
  }
}
