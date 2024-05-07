/* LWC IMPORTS */
import { LightningElement, api, wire } from "lwc";
import { getRecord } from "lightning/uiRecordApi";
import { handleErrorShowToast } from "c/utils";
import { handleGoalThemes } from "c/accountsGoalsUtils";

/* IMPORT APEX METHODS */
import getTotalBalance from "@salesforce/apex/TotalBalanceController.getTotalBalance";
import getTotalSaved from "@salesforce/apex/TotalBalanceController.getTotalSaved";
import getFinancialAccountFabric from "@salesforce/apex/FinancialAccountController.getFinancialAccountFabric";
import getFinancialAccountDB from "@salesforce/apex/FinancialAccountController.getFinancialAccountDB";
//import getLoans from "@salesforce/resourceUrl/mock_homeloanaccounts";
import getHomeLoanAccount from "@salesforce/apex/HomeLoanController.getHomeLoanAccount";
import getAccountBuckets from "@salesforce/apex/AccountBucketsController.getAccountBuckets";

/* IMPORT PERMISSIONS */
import hasAccountsGoalsPermission from "@salesforce/customPermission/ANZx_Accounts_and_Goals";
import hasHomeLoanPermission from "@salesforce/customPermission/ANZx_Home_Loan";

/* IMPORT SCHEMA FIELDS */
import ACCOUNT_OCV_ID_FIELD from "@salesforce/schema/Account.OCV_ID__c";
import FinancialAccountStatusForSorting from "@salesforce/label/c.FinancialAccountStatusForSorting";
import FinancialAccountOwnershipForSorting from "@salesforce/label/c.FinancialAccountOwnershipForSorting";

import {
  CHECKING_ACCOUNT_RT_APINAME,
  SAVINGS_ACCOUNT_RT_APINAME
} from "c/financialAccountParent";

import { MULTI_PARTY, JOINT } from "c/transactionHistoryService";

export default class PersonAccountFinancialDetails extends LightningElement {
  @api recordId;
  @api objectApiName;
  goalDetails = [];
  ocvId;
  loading;
  goalError;
  totalBalanceError;
  accountData = {
    checking: [],
    savings: []
  };
  savingsJar = [];
  loanData;
  //Pass this to the goals lwc so we can navigate to the
  //savings financial account
  savingsId;
  accountToOwnership = new Map();

  @wire(getRecord, {
    recordId: "$recordId",
    fields: [ACCOUNT_OCV_ID_FIELD]
  })
  async wiredRecord({ data }) {
    this.loading = true;
    if (data) {
      this.ocvId = data.fields.OCV_ID__c.value;
    }
    if (this.ocvId && hasAccountsGoalsPermission) {
      await this.getFinancialAccount();
      await this.getGoals();
    }
    if (this.ocvId && hasHomeLoanPermission) {
      await this.getHomeLoanResponse();
    }
    this.loading = false;
  }
  async getHomeLoanResponse() {
    try {
      //No need to filter by accounts as we want all H1s
      //No need for record id, only used in fin account record call
      let response = await getHomeLoanAccount({
        ocvId: this.ocvId,
        accountNumbers: [],
        recordId: ""
      });
      //Need to stringify and send as the array consists of many objects and SF proxies it
      //https://developer.salesforce.com/docs/platform/lwc/guide/security-array-proxy.html
      this.loanData = JSON.stringify(response.accounts);
    } catch (error) {
      handleErrorShowToast(
        this,
        "Failed To Retrieve Home Loan Details.",
        error,
        "Failed To Retrieve Home Loan Details. Please refresh and try again. If issue persists please contact your System Administrator",
        "pester"
      );
    }
  }
  get displayContent() {
    return hasAccountsGoalsPermission;
  }

  async getFinancialAccount() {
    this.accountData = {
      checking: [],
      savings: []
    };
    try {
      //Attempt to get the latest account details from fabric
      let accountDetails = await getFinancialAccountFabric({
        ocvId: this.ocvId,
        accountNumbers: []
      });
      this.handleAccountInformation(accountDetails);
    } catch (error) {
      handleErrorShowToast(
        this,
        "Failed To Retrieve Account Details",
        error,
        "Failed to retrieve latest account details. Please refresh and try again. If issue persists please contact your System Administrator",
        "pester"
      );

      //If the API callout fails to fetch latest data, use this as a fallback to fetch
      //the records stored in Salesforce
      let accountDetails = await getFinancialAccountDB({
        ownerId: this.recordId,
        recordTypeDeveloperNames: [
          CHECKING_ACCOUNT_RT_APINAME,
          SAVINGS_ACCOUNT_RT_APINAME
        ]
      });
      this.handleAccountInformation(accountDetails);
    } finally {
      try {
        let { totalBalance } = await getTotalBalance({
          ownerId: this.recordId
        });
        this.totalBalance = totalBalance;

        let { totalSaved } = await getTotalSaved({
          ownerId: this.recordId
        });
        this.totalSaved = totalSaved;
      } catch (error) {
        this.totalBalanceError =
          "Failed to retrieve total balance details. Please refresh and try again. If issue persists please contact your System Administrator";
        handleErrorShowToast(
          this,
          "Failed To Retrieve Total Balance Details",
          error,
          this.totalBalanceError,
          "pester"
        );
      }
    }
  }

  async getGoals() {
    this.goalDetails = [];
    this.savingsJar = null;
    try {
      let goalData = await getAccountBuckets({
        ocvId: this.ocvId,
        pageSize: 10,
        nextPageToken: ""
      });
      goalData = handleGoalThemes(goalData);
      const goalBucket = goalData.account_buckets.filter((eachGoalData) => {
        let ownership = "";
        if (this.accountToOwnership.has(eachGoalData.account_number)) {
          ownership = this.accountToOwnership.get(eachGoalData.account_number);
        }
        return ownership !== MULTI_PARTY;
      });
      goalData.account_buckets = goalBucket;

      //Savings jar will always be default, so retrieve it
      //to pass through to other components that need it
      this.savingsJar = goalData.account_buckets.filter((obj) => {
        return obj.is_default;
      })[0];
      //Remove savings jar as its not displayed on goals component
      this.goalDetails = goalData.account_buckets.filter((obj) => {
        return !obj.is_default;
      });
    } catch (error) {
      this.goalError =
        "Failed to retrieve latest goal details. Please refresh and try again. If issue persists please contact your System Administrator";
      handleErrorShowToast(
        this,
        "Failed To Retrieve Goal Details",
        error,
        this.goalError,
        "pester"
      );
    }
  }

  handleAccountInformation(finAccounts) {
    if (finAccounts) {
      finAccounts.forEach((account) => {
        // As per story ANZX-113310 Colour of status “Active”, “Dormant“, “Closed” is changed .Hence,changing the badge class
        account.badgeClass =
          account.FinServ__Status__c === "Active" ||
          account.FinServ__Status__c === "Open"
            ? "slds-badge slds-theme_success"
            : account.FinServ__Status__c === "Closed"
            ? "slds-badge closedBadgeClass"
            : account.FinServ__Status__c === "Dormant"
            ? "slds-badge dormantBadgeClass"
            : "slds-badge";

        // Only show Savings Jar when FinServ__Status__c is not "CLOSED"
        account.showSavingsJar = account.FinServ__Status__c !== "Closed";

        // Only show showMultipartyBadge badge when the ownership is multi-party - By Shivam, Oct'23
        if (account.FinServ__Ownership__c) {
          account = this.handleShowMultiPartyBadge(
            account,
            "FinServ__Ownership__c"
          );
        } else if (account.Ownership__c) {
          account = this.handleShowMultiPartyBadge(account, "Ownership__c");
          account.FinServ__Ownership__c = account.Ownership__c;
        }
        this.accountToOwnership.set(
          account.FinServ__FinancialAccountNumber__c,
          account.FinServ__Ownership__c
        );

        //Determine the type of financial account
        if (account.RecordType.DeveloperName === CHECKING_ACCOUNT_RT_APINAME) {
          this.accountData.checking.push(account);
        } else if (
          account.RecordType.DeveloperName === SAVINGS_ACCOUNT_RT_APINAME
        ) {
          this.accountData.savings.push(account);
          if (account.FinServ__Ownership__c !== MULTI_PARTY) {
            this.savingsId = account.Id;
          }
        }
      });
      this.sortFinancialAccounts(this.accountData.checking);
      this.sortFinancialAccounts(this.accountData.savings);
    }

    return finAccounts;
  }
  //Sorting the order of accounts based on account status and then based on opendate for similar account statuses.
  sortFinancialAccounts(arrOfAccounts) {
    return arrOfAccounts.sort((firstAccount, otherAccount) => {
      const statusOrder = FinancialAccountStatusForSorting.split(",");
      const ownershipOrder = FinancialAccountOwnershipForSorting.split(",");

      // Sort by status first
      if (firstAccount.FinServ__Status__c !== otherAccount.FinServ__Status__c) {
        return (
          statusOrder.indexOf(firstAccount.FinServ__Status__c) -
          statusOrder.indexOf(otherAccount.FinServ__Status__c)
        );
      }

      //Sort by Ownership keeping single party account at top to multi-party By Shivam, Oct'23
      if (
        firstAccount.FinServ__Status__c === otherAccount.FinServ__Status__c &&
        firstAccount.FinServ__Ownership__c !==
          otherAccount.FinServ__Ownership__c
      ) {
        return (
          ownershipOrder.indexOf(firstAccount.FinServ__Ownership__c) -
          ownershipOrder.indexOf(otherAccount.FinServ__Ownership__c)
        );
      }

      // Handle null openDate values
      if (
        firstAccount.FinServ__OpenDate__c === null &&
        otherAccount.FinServ__OpenDate__c !== null
      )
        return 1;
      if (
        otherAccount.FinServ__OpenDate__c === null &&
        firstAccount.FinServ__OpenDate__c !== null
      )
        return -1;

      // Sort by date next if status is same
      return (
        new Date(otherAccount.FinServ__OpenDate__c) -
        new Date(firstAccount.FinServ__OpenDate__c)
      );
    });
  }

  async refreshData() {
    this.loading = true;
    await this.getFinancialAccount();
    await this.getGoals();
    this.loading = false;
  }

  //Created this method to check whether the account have Multi-party or Single ownership type
  handleShowMultiPartyBadge(finAccount, finAccountOwner) {
    finAccount.showMultipartyBadge =
      finAccount[finAccountOwner] === MULTI_PARTY;
    finAccount.multiParty = finAccount.showMultipartyBadge
      ? JOINT
      : finAccount[finAccountOwner];
    return finAccount;
  }
}
