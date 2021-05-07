import { LightningElement, api, track, wire } from "lwc";

import getFinancialAccounts from "@salesforce/apex/FinancialAccountController.getFinancialAccounts";

import { subscribe, MessageContext } from "lightning/messageService";
import RetrieveGoals from "@salesforce/messageChannel/RetrieveFinancialGoals__c";
import TriggerLoading from "@salesforce/messageChannel/FinancialAccountsTriggerLoading__c";
import { NavigationMixin } from "lightning/navigation";

import hasAccountsGoalsPermission from "@salesforce/customPermission/ANZx_Accounts_and_Goals";

export default class FinancialGoals extends NavigationMixin(LightningElement) {
  @api recordId;
  goals = [];
  @track timestamp;
  @track viewAllGoals = false;
  @track loading = true;
  accountNumbers = [];
  hasError = false;
  error;

  @wire(MessageContext)
  messageContext;
  subscription = null;
  loadingSubscription = null;

  get displayContent() {
    return hasAccountsGoalsPermission;
  }

  connectedCallback() {
    if (hasAccountsGoalsPermission) {
      getFinancialAccounts({
        ownerId: this.recordId,
        recordLimit: 4,
        type: "Savings"
      })
        .then((result) => {
          if (result) {
            result.forEach((finAccount) => {
              //Set account number as key and ID as value to link goals to accounts later
              this.accountNumbers[
                finAccount.FinServ__FinancialAccountNumber__c
              ] = finAccount.Id;

              //Only set timestamp once instead of each time in the loop
              if (!this.timestamp) {
                this.setTimestamp();
              }
            });
          } else {
            //If no goals set goals to null as template condition checks
            //dont seem to mark as false if array empty
            this.goals = null;
          }
        })
        .catch((error) => {
          this.loading = false;
          if (error.body && error.body.message) {
            this.error = error.body.message;
          }
          this.hasError = true;
        });

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
        RetrieveGoals,
        (response) => {
          if (response.error) {
            this.error = response.error;
            this.loading = false;
            this.hasError = true;
          } else {
            this.timestamp = "";
            //Only need to handle goals if there is any
            if (response && response.length > 0) {
              this.goals = [];
              this.handleGoals(response);
            } else {
              this.goals = null;
              this.loading = false;
            }
          }
        }
      );
    } else {
      this.loading = false;
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

  handleGoals(response) {
    if (response) {
      //If we get more than 3 records, set view all to true and get first 3 records
      if (response.length > 3) {
        this.viewAllGoals = true;
        response = response.slice(0, 3);
      }

      for (let i = 0; i < response.length; i++) {
        let finGoal = { ...response[i] };
        //Only set timestamp once instead of each time in the loop
        if (!this.timestamp) {
          this.setTimestamp();
        }

        finGoal.targetAmount = finGoal.targetAmount
          ? parseFloat(finGoal.targetAmount)
          : "";
        finGoal.currentBalance = parseFloat(finGoal.currentBalance);

        finGoal.Id = this.accountNumbers[finGoal.accountNumber];

        if (finGoal.targetAmount) {
          //Work out percentage for fill
          finGoal.fillPercent = Math.floor(
            (finGoal.currentBalance / finGoal.targetAmount) * 100
          );

          //Dont let overfill 100%
          finGoal.fillPercent =
            finGoal.fillPercent >= 100 ? 100 : finGoal.fillPercent;

          finGoal.balanceRemaining =
            finGoal.targetAmount - finGoal.currentBalance;
        } else {
          finGoal.fillPercent = finGoal.currentBalance > 0 ? 100 : 0;
        }

        finGoal.daysRemaining = "Days remaining: ";
        // Override potential null values with generic values
        if (finGoal.targetDate) {
          const targetDate = new Date(finGoal.targetDate);
          const today = new Date();

          if (targetDate > today) {
            //Calculate time difference between two dates
            let timeDifference = targetDate.getTime() - today.getTime();

            //Calculate days remaining
            finGoal.daysRemaining += Math.round(
              timeDifference / (1000 * 3600 * 24)
            );

            finGoal.recommendedSavings = finGoal.balanceRemaining
              ? finGoal.balanceRemaining / finGoal.daysRemaining
              : "";
          }

          finGoal.targetDate =
            targetDate.getDate() +
            " " +
            targetDate.toLocaleString("en-AU", {
              month: "long"
            }) +
            " " +
            targetDate.getFullYear();
        } else {
          finGoal.targetDate = "N/A";
        }

        //Format balances
        finGoal.targetAmount = finGoal.targetAmount
          ? new Intl.NumberFormat("en-AU", {
              style: "currency",
              currency: "AUD"
            }).format(finGoal.targetAmount)
          : "N/A";

        finGoal.currentBalance = new Intl.NumberFormat("en-AU", {
          style: "currency",
          currency: "AUD"
        }).format(finGoal.currentBalance);

        finGoal.recommendedSavings = finGoal.recommendedSavings
          ? new Intl.NumberFormat("en-AU", {
              style: "currency",
              currency: "AUD"
            }).format(finGoal.recommendedSavings)
          : "Unspecified";
        this.goals.push(finGoal);
      }
    }
    this.loading = false;
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
