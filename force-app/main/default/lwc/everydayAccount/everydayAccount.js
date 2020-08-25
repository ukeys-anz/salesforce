import { LightningElement, api, track, wire } from "lwc";

import getFinancialAccounts from "@salesforce/apex/EverydayAccountController.getFinancialAccounts";

import { ShowToastEvent } from "lightning/platformShowToastEvent";

import { subscribe, MessageContext } from "lightning/messageService";
import UpdateAccountsAndGoals from "@salesforce/messageChannel/FinancialAccountsGoalsUpdate__c";
import TriggerLoading from "@salesforce/messageChannel/FinancialAccountsTriggerLoading__c";

export default class EverydayAccount extends LightningElement {
  @api recordId;
  financialAccounts = [];
  @track viewAll;
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
          this.financialAccounts = [];
          this.getAccounts();
          this.setTimestamp();

          if (this.financialAccounts) {
            this.loading = false;
          }
        }
      }
    );

    if (!this.subscription || Object.keys(this.subscription).length === 0) {
      this.getAccounts();
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

  getAccounts() {
    getFinancialAccounts({
      ownerId: this.recordId,
      recordLimit: 4
    })
      .then((result) => {
        this.viewAll = false;
        if (result) {
          //If we get more than 3 records, set view all to true and get first 3 records
          if (result.length > 3) {
            this.viewAll = true;
            result = result.slice(0, 3);
          }
          result.forEach((finAccount) => {
            //Set the badge class based on the status
            if (finAccount.FinServ__Status__c === "Open") {
              finAccount.badgeClass = "slds-badge slds-theme_success";
            } else {
              finAccount.badgeClass = "slds-badge slds-theme_error";
            }

            //Set URL for record
            finAccount.url = `/lightning/r/FinServ__FinancialAccount__c/${finAccount.Id}/view`;

            //Format balances
            finAccount.FinServ__Balance__c = new Intl.NumberFormat("en-AU", {
              style: "currency",
              currency: "AUD"
            }).format(finAccount.FinServ__Balance__c);
            finAccount.FinServ__CurrentPostedBalance__c = new Intl.NumberFormat(
              "en-AU",
              {
                style: "currency",
                currency: "AUD"
              }
            ).format(finAccount.FinServ__CurrentPostedBalance__c);
          });
        }
        this.financialAccounts = result;
        this.loading = false;
      })
      .catch((error) => {
        this.loading = false;
        let errorMessage = "Failed to load financial accounts";
        if (error.body && error.body.message) {
          errorMessage = error.body.message;
        }
        this.showToast("Financial Account Load Failed", errorMessage, error);
      });
  }
}
