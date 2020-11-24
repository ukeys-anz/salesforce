import { LightningElement, api, wire } from "lwc";

import { getRecord } from "lightning/uiRecordApi";
import ACCOUNT_OCV_ID_FIELD from "@salesforce/schema/Account.OCV_ID__c";
import FIN_ACCOUNT_OCV_ID_FIELD from "@salesforce/schema/FinServ__FinancialAccount__c.OCV_ID__c";
import FIN_ACCOUNT_PRIMARY_OWNER_FIELD from "@salesforce/schema/FinServ__FinancialAccount__c.FinServ__PrimaryOwner__c";

import getAccounts from "@salesforce/apex/GetAccountsAndGoals.getAccounts";
import updateAccounts from "@salesforce/apex/UpdateAccountsAndGoals.updateAccounts";
import updateGoals from "@salesforce/apex/UpdateAccountsAndGoals.updateGoals";

// Import message service features required for publishing and the message channel
import { publish, MessageContext, subscribe } from "lightning/messageService";
import UpdateAccountsAndGoals from "@salesforce/messageChannel/FinancialAccountsGoalsUpdate__c";
import TriggerLoading from "@salesforce/messageChannel/FinancialAccountsTriggerLoading__c";
import UpdateAccountsGoalsTimed from "@salesforce/messageChannel/FinancialAccountGoalsTimedUpdate__c";

export default class AccountsAndGoals extends LightningElement {
  @api recordId;
  @api objectName;
  accountDetails = [];
  goalDetails = [];
  accountNumbers = [];
  goalAccountNumbers = [];
  ocvId;
  objectFields = [];
  ownerId;

  @wire(MessageContext)
  messageContext;
  subscription = null;
  triggerUpdate;

  @wire(getRecord, {
    recordId: "$recordId",
    fields: "$objectFields"
  })
  wiredProject({ data }) {
    if (data) {
      this.ownerId = this.recordId;
      this.ocvId = data.fields.OCV_ID__c.value;
      if (data.fields.FinServ__PrimaryOwner__c) {
        this.ownerId = data.fields.FinServ__PrimaryOwner__c.value;
      }
      if (this.subscription && this.triggerUpdate) {
        this.update();
      }
    }
  }

  connectedCallback() {
    this.subscription = subscribe(
      this.messageContext,
      UpdateAccountsGoalsTimed,
      (message) => {
        if (message.update) {
          this.triggerUpdate = true;
          this.update();
        }
      }
    );

    if (this.objectName === "Account") {
      this.objectFields = [ACCOUNT_OCV_ID_FIELD];
    } else {
      this.objectFields = [
        FIN_ACCOUNT_OCV_ID_FIELD,
        FIN_ACCOUNT_PRIMARY_OWNER_FIELD
      ];
    }
  }

  update() {
    const payload = {
      update: true
    };
    publish(this.messageContext, TriggerLoading, payload);
    getAccounts({
      ocvId: this.ocvId
    })
      .then((result) => {
        if (result) {
          result = JSON.parse(result);
          result.accountList.forEach((account) => {
            this.accountNumbers.push(account.accountNumber);
            let accountInformation = {
              Name: account.name,
              FinServ__FinancialAccountNumber__c: account.accountNumber,
              FinServ__Balance__c: account.balance.value.replace("$", ""),
              FinServ__CurrentPostedBalance__c: account.currentBalance.value.replace(
                "$",
                ""
              )
            };

            this.accountDetails.push(accountInformation);
            if (account.accountType === "Savings") {
              this.goalAccountNumbers.push(account.accountNumber);
              let goalInformation = {
                Name: account.goal.name,
                Financial_Account_Number__c: account.accountNumber,
                FinServ__TargetValue__c: account.goal.targetAmount.value.replace(
                  "$",
                  ""
                ),
                FinServ__ActualValue__c: account.currentBalance.value.replace(
                  "$",
                  ""
                ),
                Start_Date__c: account.goal.startDate,
                FinServ__TargetDate__c: account.goal.targetDate,
                Icon__c: account.goal.iconId
              };
              this.goalDetails.push(goalInformation);
            }
          });

          //Update accounts
          updateAccounts({
            ownerId: this.ownerId,
            accountNumbers: this.accountNumbers,
            accountData: this.accountDetails
          })
            .then(() => {
              publish(this.messageContext, UpdateAccountsAndGoals, payload);
            })
            .catch((error) => {
              let errorMessage =
                "Failed to update account details. Please refresh and try again. If the problem persists, please contact your System Administrator.";
              if (error.body && error.body.message) {
                let message = this.handleError(error.body.message);
                //Catch any system error messages (most readable errors wont be a single word)
                if (message.split(" ").length > 1) {
                  errorMessage = message;
                }
              }

              publish(this.messageContext, UpdateAccountsAndGoals, {
                update: false,
                message: errorMessage
              });
            });

          //Update goals
          updateGoals({
            ownerId: this.ownerId,
            accountNumbers: this.goalAccountNumbers,
            goalData: this.goalDetails
          })
            .then(() => {
              publish(this.messageContext, UpdateAccountsAndGoals, payload);
            })
            .catch((error) => {
              let errorMessage =
                "Failed to update goal details. Please refresh and try again. If the problem persists, please contact your System Administrator.";
              if (error.body && error.body.message) {
                let message = this.handleError(error.body.message);
                //Catch any system error messages (most readable errors wont be a single word)
                if (message.split(" ").length > 1) {
                  errorMessage = message;
                }
              }

              publish(this.messageContext, UpdateAccountsAndGoals, {
                update: false,
                message: errorMessage
              });
            });
        } else {
          let errorMessage =
            "No new data returned. Please refresh and try again. If the problem persists, please contact your System Administrator.";

          publish(this.messageContext, UpdateAccountsAndGoals, {
            update: false,
            message: errorMessage
          });
        }
      })
      .catch((error) => {
        let errorMessage =
          "Failed to retrieve updated account details. Please refresh and try again. If the problem persists, please contact your System Administrator.";
        if (error.body && error.body.message) {
          let message = this.handleError(error.body.message);
          //Catch any system error messages (most readable errors wont be a single word)
          if (message.split(" ").length > 1) {
            errorMessage = message;
          }
        }

        publish(this.messageContext, UpdateAccountsAndGoals, {
          update: false,
          message: errorMessage
        });
      });
  }

  //This function is required as some errors are returned
  //as stringified json
  handleError(error) {
    try {
      JSON.parse(error);
    } catch (e) {
      return error;
    }
    return JSON.parse(error).error;
  }
}
