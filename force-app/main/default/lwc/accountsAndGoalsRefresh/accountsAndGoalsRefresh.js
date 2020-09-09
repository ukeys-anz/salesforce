import { LightningElement, api, wire } from "lwc";

import { getRecord } from "lightning/uiRecordApi";
import OCV_ID_FIELD from "@salesforce/schema/Account.OCV_ID__c";
import FABRIC_ID_FIELD from "@salesforce/schema/Account.Fabric_ID__c";

import getAccounts from "@salesforce/apex/GetAccountsAndGoals.getAccounts";
import updateAccounts from "@salesforce/apex/UpdateAccountsAndGoals.updateAccounts";
import updateGoals from "@salesforce/apex/UpdateAccountsAndGoals.updateGoals";

// Import message service features required for publishing and the message channel
import { publish, MessageContext } from "lightning/messageService";
import UpdateAccountsAndGoals from "@salesforce/messageChannel/FinancialAccountsGoalsUpdate__c";
import TriggerLoading from "@salesforce/messageChannel/FinancialAccountsTriggerLoading__c";

export default class AccountsAndGoals extends LightningElement {
  @api recordId;
  accountDetails = [];
  goalDetails = [];
  accountNumbers = [];
  goalAccountNumbers = [];
  ocvId;
  fabricId;
  @wire(MessageContext)
  messageContext;

  @wire(getRecord, {
    recordId: "$recordId",
    fields: [OCV_ID_FIELD, FABRIC_ID_FIELD]
  })
  wiredProject({ data }) {
    if (data) {
      this.ocvId = data.fields.OCV_ID__c.value;
      this.fabricId = data.fields.Fabric_ID__c.value;
    }
  }

  update() {
    const payload = { update: true };
    publish(this.messageContext, TriggerLoading, payload);
    getAccounts({
      ocvId: this.ocvId,
      fabricId: this.fabricId
    }).then((result) => {
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
          ownerId: this.recordId,
          accountNumbers: this.accountNumbers,
          accountData: this.accountDetails
        }).then(() => {
          publish(this.messageContext, UpdateAccountsAndGoals, payload);
        });

        //Update goals
        updateGoals({
          ownerId: this.recordId,
          accountNumbers: this.goalAccountNumbers,
          goalData: this.goalDetails
        }).then(() => {
          publish(this.messageContext, UpdateAccountsAndGoals, payload);
        });
      }
    });
  }
}
