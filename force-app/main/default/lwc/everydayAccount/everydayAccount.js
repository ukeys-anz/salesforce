import { LightningElement, api, track, wire } from "lwc";

import getFinancialAccounts from "@salesforce/apex/FinancialAccountController.getFinancialAccounts";

import { ShowToastEvent } from "lightning/platformShowToastEvent";

import { subscribe, MessageContext } from "lightning/messageService";
import UpdateAccounts from "@salesforce/messageChannel/FinancialAccountsUpdate__c";
import TriggerLoading from "@salesforce/messageChannel/FinancialAccountsTriggerLoading__c";
import { NavigationMixin } from "lightning/navigation";

import hasAccountsGoalsPermission from "@salesforce/customPermission/ANZx_Accounts_and_Goals";

const ACCOUNT_TYPES = {
  checking: "Everyday - ANZ Plus Account",
  savings: "Savings - ANZ Save Account"
};

export default class EverydayAccount extends NavigationMixin(LightningElement) {
  @api recordId;
  @api accountType;
  financialAccounts = [];
  @track viewAll;
  @track timestamp;
  @track loading = true;
  hasError = false;
  error;
  componentTitle;
  balanceTitle;
  showInfoModal = false;
  productTitle;

  @wire(MessageContext)
  messageContext;
  subscription = null;
  loadingSubscription = null;

  get displayContent() {
    return hasAccountsGoalsPermission;
  }

  connectedCallback() {
    this.componentTitle = ACCOUNT_TYPES[this.accountType.toLowerCase()];
    if (this.accountType.toLowerCase() === "checking") {
      this.balanceTitle = "Everyday Funds";
      this.productTitle = "ANZ Plus";
    } else {
      this.balanceTitle = "Total Saved";
      this.productTitle = "ANZ Save";
    }

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
    } else {
      this.loading = false;
    }
  }

  setTimestamp(date) {
    //Create timestamp for last updated
    let updated = new Date(date);

    let lastUpdate =
      updated.getDate() +
      " " +
      updated.toLocaleString("en-AU", {
        month: "long"
      }) +
      " " +
      updated.getFullYear() +
      " | " +
      updated.toLocaleString("en-AU", {
        hour: "numeric",
        minute: "numeric",
        hour12: true
      });

    return lastUpdate;
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
      recordLimit: 4,
      type: this.accountType
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
            //Set last updated
            finAccount.lastUpdated = this.setTimestamp(
              finAccount.LastModifiedDate
            );

            //Set the badge class based on the status
            if (finAccount.FinServ__Status__c === "Active") {
              finAccount.badgeClass = "slds-badge slds-theme_success";
            } else {
              finAccount.badgeClass = "slds-badge slds-theme_error";
            }

            //Format balances
            finAccount.FinServ__Balance__c = new Intl.NumberFormat("en-AU", {
              style: "currency",
              currency: "AUD"
            }).format(finAccount.FinServ__Balance__c);
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

  handleInfoModal() {
    this.showInfoModal = !this.showInfoModal;
  }
}
