// import { LightningElement, api, wire } from "lwc";
import { LightningElement, api } from "lwc";

// import { getRecord } from "lightning/uiRecordApi";
// import ACCOUNT_OCV_ID_FIELD from "@salesforce/schema/Account.OCV_ID__c";
// import FIN_ACCOUNT_OCV_ID_FIELD from "@salesforce/schema/FinServ__FinancialAccount__c.OCV_ID__c";
// import FIN_ACCOUNT_PRIMARY_OWNER_FIELD from "@salesforce/schema/FinServ__FinancialAccount__c.FinServ__PrimaryOwner__c";

// import getAccounts from "@salesforce/apex/CoachBankingAPIRepository.getAccountsAura";
// import updateAccounts from "@salesforce/apex/UpdateFinancialAccounts.updateAccounts";

// Import message service features required for publishing and the message channel
// import { publish, MessageContext } from "lightning/messageService";
// import UpdateAccounts from "@salesforce/messageChannel/FinancialAccountsUpdate__c";
// import RetrieveGoals from "@salesforce/messageChannel/RetrieveFinancialGoals__c";
// import TriggerLoading from "@salesforce/messageChannel/FinancialAccountsTriggerLoading__c";
// import TriggerBalanceLoading from "@salesforce/messageChannel/FinancialAccountsBalanceTriggerLoading__c";

// import hasAccountsGoalsPermission from "@salesforce/customPermission/ANZx_Accounts_and_Goals";

export default class AccountsAndGoals extends LightningElement {
  @api recordId;
  @api objectName;
  // accountDetails = [];
  // goalDetails = [];
  // accountNumbers = [];
  // goalAccountNumbers = [];
  // ocvId;
  // objectFields = [];
  // ownerId;

  // @wire(MessageContext)
  // messageContext;
  // timedSubscription = null;
  // goalSubscription = null;
  // accountSubscription = null;
  // triggerUpdate;

  // @wire(getRecord, {
  //   recordId: "$recordId",
  //   fields: "$objectFields"
  // })
  // wiredProject({ data }) {
  //   if (data && hasAccountsGoalsPermission) {
  //     this.ownerId = this.recordId;
  //     this.ocvId = data.fields.OCV_ID__c.value;
  //     if (data.fields.FinServ__PrimaryOwner__c) {
  //       this.ownerId = data.fields.FinServ__PrimaryOwner__c.value;
  //     }
  //     if (this.ocvId) {
  //       this.update();
  //     }
  //   }
  // }

  // connectedCallback() {
  //   if (hasAccountsGoalsPermission) {
  //     if (this.objectName === "Account") {
  //       this.objectFields = [ACCOUNT_OCV_ID_FIELD];
  //     } else {
  //       this.objectFields = [
  //         FIN_ACCOUNT_OCV_ID_FIELD,
  //         FIN_ACCOUNT_PRIMARY_OWNER_FIELD
  //       ];
  //     }
  //   }
  // }

  // get displayContent() {
  //   return hasAccountsGoalsPermission;
  // }

  // update() {
  //   if (this.objectName === "Account") {
  //     publish(this.messageContext, TriggerLoading, {
  //       update: true
  //     });
  //   } else {
  //     publish(this.messageContext, TriggerBalanceLoading, {
  //       update: true
  //     });
  //   }
  //   //Reset values
  //   this.accountDetails = [];
  //   this.goalDetails = [];
  //   this.accountNumbers = [];
  //   this.goalAccountNumbers = [];

  //   const payload = {
  //     update: true
  //   };

  //   getAccounts({
  //     ocvId: this.ocvId
  //   })
  //     .then((result) => {
  //       if (result) {
  //         result.accountList.forEach((account) => {
  //           // check to drop or show an error message against a particular Fin Account record based on response
  //           if (account.isValid) {
  //             this.accountNumbers.push(account.accountNumber);
  //             let accountInformation = {
  //               Name: account.name,
  //               FinServ__FinancialAccountNumber__c: account.accountNumber,
  //               FinServ__Balance__c: account.balance.value,
  //               FinServ__CurrentPostedBalance__c: account.currentBalance.value,
  //               BSB__c: account.bsb.toString(),
  //               FinServ__OpenDate__c: account.openDate
  //             };
  //             this.accountDetails.push(accountInformation);
  //             if (account.accountType === "Savings") {
  //               this.goalAccountNumbers.push(account.accountNumber);
  //               let goalInformation = {
  //                 name: account.goal.name,
  //                 accountNumber: account.accountNumber,
  //                 targetAmount: account.goal.targetAmount
  //                   ? account.goal.targetAmount.value
  //                   : "",
  //                 currentBalance: account.currentBalance.value,
  //                 startDate: account.goal.startDate,
  //                 targetDate: account.goal.targetDate
  //                   ? account.goal.targetDate
  //                   : "",
  //                 icon: account.goal.iconId
  //               };
  //               this.goalDetails.push(goalInformation);
  //             }
  //           } else {
  //             let errorMessage =
  //               "One or more Financial Account records returned bad or missing data. Please refresh and try again. If the problem persists, please contact your System Administrator.";
  //             publish(this.messageContext, UpdateAccounts, {
  //               update: false,
  //               message: errorMessage
  //             });
  //           }
  //         });

  //         //Return goal data
  //         publish(this.messageContext, RetrieveGoals, this.goalDetails);

  //         //Update accounts
  //         updateAccounts({
  //           ownerId: this.ownerId,
  //           accountNumbers: this.accountNumbers,
  //           financialAccounts: this.accountDetails
  //         })
  //           .then(() => {
  //             publish(this.messageContext, UpdateAccounts, payload);
  //           })
  //           .catch((error) => {
  //             let errorMessage =
  //               "Failed to update account details. Please refresh and try again. If the problem persists, please contact your System Administrator.";
  //             if (error.body && error.body.message) {
  //               let message = this.handleError(error.body.message);
  //               //Catch any system error messages (most readable errors wont be a single word)
  //               if (message && message.split(" ").length > 1) {
  //                 errorMessage = message;
  //               }
  //             }

  //             publish(this.messageContext, UpdateAccounts, {
  //               update: false,
  //               message: errorMessage
  //             });
  //           });
  //       } else {
  //         let errorMessage =
  //           "No new data returned. Please refresh and try again. If the problem persists, please contact your System Administrator.";

  //         publish(this.messageContext, UpdateAccounts, {
  //           update: false,
  //           message: errorMessage
  //         });
  //       }
  //     })
  //     .catch((error) => {
  //       let errorMessage =
  //         "Failed to retrieve updated account details. Please refresh and try again. If the problem persists, please contact your System Administrator.";
  //       if (error.body && error.body.message) {
  //         let message = this.handleError(error.body.message);
  //         //Catch any system error messages (most readable errors wont be a single word)
  //         if (message && message.split(" ").length > 1) {
  //           errorMessage = message;
  //         }
  //       }

  //       publish(this.messageContext, UpdateAccounts, {
  //         update: false,
  //         message: errorMessage
  //       });

  //       publish(this.messageContext, RetrieveGoals, { error: errorMessage });
  //     });
  // }

  // //This function is required as some errors are returned
  // //as stringified json
  // handleError(error) {
  //   try {
  //     JSON.parse(error);
  //   } catch (e) {
  //     return error;
  //   }
  //   return JSON.parse(error).error;
  // }
}
