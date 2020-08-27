import { LightningElement, api, wire } from "lwc";

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

  @wire(MessageContext)
  messageContext;

  connectedCallback() {
    const accountList = {
      accountList: [
        {
          accountNumber: "8983238",
          bsb: "013268",
          name: "Peter Charalambous",
          balance: {
            currency: "AUD",
            value: "3200.00"
          },
          currentBalance: {
            currency: "AUD",
            value: "3200.00"
          },
          balanceValidAsOf: "2020-07-14T03:53:44.079935132Z",
          openDate: "2020-07-28",
          accountType: "Transaction"
        },
        {
          accountNumber: "1234123",
          bsb: "013268",
          name: "Peter Charalambous",
          balance: {
            currency: "AUD",
            value: "1200.00"
          },
          currentBalance: {
            currency: "AUD",
            value: "1200.00"
          },
          balanceValidAsOf: "2020-07-14T03:53:44.079935132Z",
          openDate: "2020-07-28",
          accountType: "Transaction"
        },
        {
          accountNumber: "1313431",
          bsb: "013268",
          name: "Peter C",
          balance: {
            currency: "AUD",
            value: "5000.00"
          },
          currentBalance: {
            currency: "AUD",
            value: "5000.00"
          },
          balanceValidAsOf: "2020-07-14T03:53:44.079932308Z",
          openDate: "2020-07-14",
          accountType: "Savings",
          goal: {
            name: "Sister Wedding Dress",
            iconId: "👗",
            startDate: "2020-07-14",
            themeId: "d50f1984-edba-430b-9588-c8b6595a3423",
            themeColour: "#007DBA",
            targetDate: "2020-09-09",
            targetAmount: {
              currency: "AUD",
              value: "8000"
            }
          }
        },
        {
          accountNumber: "1800873",
          bsb: "013268",
          name: "Peter Charalambous",
          balance: {
            currency: "AUD",
            value: "6266.567"
          },
          currentBalance: {
            currency: "AUD",
            value: "6266.567"
          },
          balanceValidAsOf: "2020-07-14T03:53:44.079932308Z",
          openDate: "2020-07-14",
          accountType: "Savings",
          goal: {
            name: "Engagement Ring",
            iconId: "💍",
            startDate: "2020-07-14",
            themeId: "d50f1984-edba-430b-9588-c8b6595a3423",
            themeColour: "#007DBA",
            targetDate: "2021-08-14",
            targetAmount: {
              currency: "AUD",
              value: "9600"
            }
          }
        },
        {
          accountNumber: "1803276",
          bsb: "013268",
          name: "Peter Charalambous",
          balance: {
            currency: "AUD",
            value: "4000"
          },
          currentBalance: {
            currency: "AUD",
            value: "4000"
          },
          balanceValidAsOf: "2020-07-14T03:53:44.079932308Z",
          openDate: "2020-07-14",
          accountType: "Savings",
          goal: {
            name: "Birthday Trip",
            iconId: "🎂",
            startDate: "2020-07-14",
            themeId: "d50f1984-edba-430b-9588-c8b6595a3423",
            themeColour: "#007DBA",
            targetDate: "2020-08-14",
            targetAmount: {
              currency: "AUD",
              value: "6000"
            }
          }
        }
      ]
    };

    accountList.accountList.forEach((account) => {
      this.accountNumbers.push(account.accountNumber);
      let accountInformation = {
        Name: account.name,
        FinServ__FinancialAccountNumber__c: account.accountNumber,
        FinServ__Balance__c: account.balance.value,
        FinServ__CurrentPostedBalance__c: account.currentBalance.value
      };

      this.accountDetails.push(accountInformation);
      if (account.accountType === "Savings") {
        this.goalAccountNumbers.push(account.accountNumber);
        let goalInformation = {
          Name: account.goal.name,
          Financial_Account_Number__c: account.accountNumber,
          FinServ__TargetValue__c: account.goal.targetAmount.value,
          FinServ__ActualValue__c: account.currentBalance.value,
          Start_Date__c: account.goal.startDate,
          FinServ__TargetDate__c: account.goal.targetDate,
          Icon__c: account.goal.iconId
        };
        this.goalDetails.push(goalInformation);
      }
    });
  }

  update() {
    const payload = { update: true };
    publish(this.messageContext, TriggerLoading, payload);
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
}
