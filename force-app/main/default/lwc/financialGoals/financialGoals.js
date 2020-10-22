import { LightningElement, api, track, wire } from "lwc";

import getFinancialGoals from "@salesforce/apex/FinancialGoalsComponentController.getFinancialGoals";

import { ShowToastEvent } from "lightning/platformShowToastEvent";

import { publish, subscribe, MessageContext } from "lightning/messageService";
import UpdateAccountsAndGoals from "@salesforce/messageChannel/FinancialAccountsGoalsUpdate__c";
import UpdateAccountsGoalsTimed from "@salesforce/messageChannel/FinancialAccountGoalsTimedUpdate__c";
import TriggerLoading from "@salesforce/messageChannel/FinancialAccountsTriggerLoading__c";
import { NavigationMixin } from "lightning/navigation";

export default class FinancialGoals extends NavigationMixin(LightningElement) {
  @api recordId;
  inProgressGoals = [];
  completedGoals = [];
  @track timestamp;
  @track viewAllInProgress = false;
  @track viewAllCompleted = false;
  @track loading = true;
  @track cardSizeClass;
  @track ringClass;
  @track paddingClass;
  @track gridClass;

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
          this.inProgressGoals = [];
          this.completedGoals = [];
          this.timestamp = "";
          this.getInProgressGoals();
          this.getCompletedGoals();

          if (this.inProgressGoals || this.completedGoals) {
            this.loading = false;
          }
        }
      }
    );

    if (!this.subscription || Object.keys(this.subscription).length === 0) {
      this.getInProgressGoals();
      this.getCompletedGoals();
    }

    this.loading = false;
  }

  setTimestamp(lastModifiedDate) {
    //Create timestamp
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

  getInProgressGoals() {
    getFinancialGoals({
      ownerId: this.recordId,
      status: "In Progress",
      recordLimit: 4
    })
      .then((result) => {
        if (result) {
          //If we get more than 3 records, set view all to true and get first 3 records
          if (result.length > 3) {
            this.viewAllInProgress = true;
            result = result.slice(0, 3);
          }

          //Change the card size and classes based on amount of results returned
          this.cardSizeClass = `slds-p-horizontal_small slds-size_1-of-1 slds-medium-size_1-of-${result.length}`;
          this.ringClass = `ring__${result.length}`;
          this.fieldPaddingClass = `field-padding__${result.length}`;
          this.gridClass = `grid-content__${result.length}`;

          result.forEach((finGoal) => {
            //Only set timestamp once instead of each time in the loop
            if (!this.timestamp) {
              this.setTimestamp(finGoal.LastModifiedDate);
            }

            //Work out percentage for fill
            finGoal.fillPercent = Math.floor(
              (finGoal.FinServ__ActualValue__c /
                finGoal.FinServ__TargetValue__c) *
                100
            );

            //Dont let overfill 100%
            finGoal.fillPercent =
              finGoal.fillPercent >= 100 ? 100 : finGoal.fillPercent;

            // Override potential null values with generic values
            if (finGoal.FinServ__TargetDate__c) {
              const targetDate = new Date(finGoal.FinServ__TargetDate__c);
              finGoal.FinServ__TargetDate__c =
                targetDate.getDate() +
                " " +
                targetDate.toLocaleString("en-AU", {
                  month: "long"
                }) +
                " " +
                targetDate.getFullYear();
            } else {
              finGoal.FinServ__TargetDate__c = "N/A";
            }

            //Format balances
            finGoal.FinServ__TargetValue__c = new Intl.NumberFormat("en-AU", {
              style: "currency",
              currency: "AUD"
            }).format(finGoal.FinServ__TargetValue__c);

            finGoal.FinServ__ActualValue__c = new Intl.NumberFormat("en-AU", {
              style: "currency",
              currency: "AUD"
            }).format(finGoal.FinServ__ActualValue__c);

            finGoal.Recommended_Savings_Amount__c =
              finGoal.Recommended_Savings_Amount__c !== "Unspecified"
                ? new Intl.NumberFormat("en-AU", {
                    style: "currency",
                    currency: "AUD"
                  }).format(finGoal.Recommended_Savings_Amount__c)
                : finGoal.Recommended_Savings_Amount__c;
          });
        }

        this.inProgressGoals = result;
      })
      .catch((error) => {
        let errorMessage = "Failed to load in progress financial goals";
        if (error.body && error.body.message) {
          errorMessage = error.body.message;
        }
        this.showToast("Financial Goals Load Failed", errorMessage, error);
      });
  }

  getCompletedGoals() {
    getFinancialGoals({
      ownerId: this.recordId,
      status: "Completed",
      recordLimit: 4
    })
      .then((result) => {
        if (result) {
          //If we get more than 3 records, set view all to true and get first 3 records
          if (result.length > 3) {
            this.viewAllCompleted = true;
            result = result.slice(0, 3);
          }

          result.forEach((finGoal) => {
            //Only set timestamp once instead of each time in the loop
            if (!this.timestamp) {
              this.setTimestamp(finGoal.LastModifiedDate);
            }

            //Format balances
            finGoal.FinServ__TargetValue__c = new Intl.NumberFormat("en-AU", {
              style: "currency",
              currency: "AUD"
            }).format(finGoal.FinServ__TargetValue__c);

            finGoal.FinServ__ActualValue__c = new Intl.NumberFormat("en-AU", {
              style: "currency",
              currency: "AUD"
            }).format(finGoal.FinServ__ActualValue__c);

            // Override potential null values with generic values
            if (finGoal.FinServ__TargetDate__c) {
              const targetDate = new Date(finGoal.FinServ__TargetDate__c);
              finGoal.FinServ__TargetDate__c =
                targetDate.getDate() +
                " " +
                targetDate.toLocaleString("en-AU", {
                  month: "long"
                }) +
                " " +
                targetDate.getFullYear();
            } else {
              finGoal.FinServ__TargetDate__c = "N/A";
            }

            if (finGoal.FinServ__CompletionDate__c) {
              const completionDate = new Date(
                finGoal.FinServ__CompletionDate__c
              );
              finGoal.FinServ__CompletionDate__c =
                completionDate.getDate() +
                " " +
                completionDate.toLocaleString("en-AU", {
                  month: "long"
                }) +
                " " +
                completionDate.getFullYear();
            } else {
              finGoal.FinServ__CompletionDate__c = "Unspecified";
            }
          });
        }
        this.completedGoals = result;
      })
      .catch((error) => {
        let errorMessage = "Failed to load completed financial goals";
        if (error.body && error.body.message) {
          errorMessage = error.body.message;
        }
        this.showToast("Financial Goals Load Failed", errorMessage, error);
      });
  }

  showToast(theTitle, theMessage, theVariant) {
    this.loading = false;
    const event = new ShowToastEvent({
      title: theTitle,
      message: theMessage,
      variant: theVariant
    });
    this.dispatchEvent(event);
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
