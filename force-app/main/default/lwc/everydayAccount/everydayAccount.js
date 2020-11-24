import { LightningElement, api, track, wire } from "lwc";

import getFinancialAccounts from "@salesforce/apex/EverydayAccountController.getFinancialAccounts";

import { ShowToastEvent } from "lightning/platformShowToastEvent";

import { publish, subscribe, MessageContext } from "lightning/messageService";
import UpdateAccountsAndGoals from "@salesforce/messageChannel/FinancialAccountsGoalsUpdate__c";
import UpdateAccountsGoalsTimed from "@salesforce/messageChannel/FinancialAccountGoalsTimedUpdate__c";
import TriggerLoading from "@salesforce/messageChannel/FinancialAccountsTriggerLoading__c";
import { NavigationMixin } from "lightning/navigation";

export default class EverydayAccount extends NavigationMixin(LightningElement) {
  @api recordId;
  financialAccounts = [];
  @track viewAll;
  @track timestamp;
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
          this.financialAccounts = [];
          this.timestamp = "";
          this.getAccounts();

          if (this.financialAccounts) {
            this.loading = false;
          }
        } else {
          this.error = message.message;
          this.getAccounts();
          this.showToast("Financial Account Load Failed", this.error);
        }
      }
    );

    if (!this.subscription || Object.keys(this.subscription).length === 0) {
      this.getAccounts();
    }
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

    //If it has been more than 15 min since last update,
    //call API for latest data
    const today = new Date();
    if (today - lastUpdated > 15 * 60 * 1000) {
      const payload = { update: true };
      publish(this.messageContext, UpdateAccountsGoalsTimed, payload);
    }
  }

  showToast(theTitle, theMessage) {
    const event = new ShowToastEvent({
      title: theTitle,
      message: theMessage
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
            //Only set timestamp once instead of each time in the loop
            if (!this.timestamp) {
              this.setTimestamp(finAccount.LastModifiedDate);
            }
            //Set the badge class based on the status
            if (finAccount.FinServ__Status__c === "Open") {
              finAccount.badgeClass = "slds-badge slds-theme_success";
            } else {
              finAccount.badgeClass = "slds-badge slds-theme_error";
            }

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
        if (error.body && error.body.message) {
          this.error = error.body.message;
        }
        this.hasError = true;
      });
  }

  navigateToRecordViewPage(event) {
    this[NavigationMixin.Navigate]({
      type: "standard__recordPage",
      attributes: {
        recordId: event.currentTarget.dataset.id,
        actionName: "view"
      }
    });
  }
}
