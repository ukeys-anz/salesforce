import { LightningElement, api, wire } from "lwc";
import { getRecord } from "lightning/uiRecordApi";
import { handleErrorShowToast } from "c/utils";

import getFinancialAccountFabric from "@salesforce/apex/FinancialAccountController.getFinancialAccountFabric";
import getFinancialAccountDB from "@salesforce/apex/FinancialAccountController.getFinancialAccountDB";
import getAccountBuckets from "@salesforce/apex/AccountBucketsController.getAccountBuckets";
import getTransactionHistoryAura from "@salesforce/apex/CoachBankingAPIRepository.getTransactionHistoryAura";
import hasAccountsGoalsPermission from "@salesforce/customPermission/ANZx_Accounts_and_Goals";

import FIN_ACCOUNT_NUMBER from "@salesforce/schema/FinServ__FinancialAccount__c.FinServ__FinancialAccountNumber__c";
import FIN_ACCOUNT_OCV_ID from "@salesforce/schema/FinServ__FinancialAccount__c.OCV_ID__c";
import FIN_ACCOUNT_TYPE from "@salesforce/schema/FinServ__FinancialAccount__c.FinServ__FinancialAccountType__c";
import FIN_ACCOUNT_INTEREST from "@salesforce/schema/FinServ__FinancialAccount__c.Interest_Accrued__c";
import { TRANSACTION_HISTORY_RETRIEVE_ERROR } from "c/transactionHistoryService";

import {
  getEmojiMap,
  getGoalMap,
  getImageMap,
  handleGoalsParent,
  handleTransactionGoals,
  handleComponentTitle
} from "./helpers/utils";
import { CurrentPageReference } from "lightning/navigation";

export default class FinancialAccountParent extends LightningElement {
  @api recordId;
  accountData = [];
  accountError;
  accountNumber;
  accountType;
  componentTitle;
  fullGoalData;
  goalData = { goalList: [], nextToken: null };
  goalError;
  goalLookup;
  goalMap;
  hasTransactionError = false;
  emojiMap;
  imageMap;
  isSavings;
  loading;
  ocvId;
  transactionData;
  transactionError;
  savingsJar;
  preselectedGoal;
  transactionStartDate;
  transactionEndDate;
  transactionBucketIds = [];
  //Triggers the whole transaction lwc to load
  transactionLoading = false;
  //Triggers the bottom of transactions to load for
  //appending new transactions
  transactionLoadMore = false;
  //triggers the transactions to clear, used for
  //goal filtering
  clearTransactions = false;

  @wire(CurrentPageReference)
  pageRef;

  @wire(getRecord, {
    recordId: "$recordId",
    fields: [
      FIN_ACCOUNT_NUMBER,
      FIN_ACCOUNT_OCV_ID,
      FIN_ACCOUNT_TYPE,
      FIN_ACCOUNT_INTEREST
    ]
  })
  async wiredRecord({ data }) {
    this.loading = true;
    if (data) {
      this.ocvId = data.fields.OCV_ID__c.value;
      this.accountNumber = data.fields.FinServ__FinancialAccountNumber__c.value;
      const accType = data.fields.FinServ__FinancialAccountType__c.value;
      if (accType === "Savings") {
        this.isSavings = true;
        this.accountType = "savings";
      } else if (accType === "Checking") {
        this.isSavings = false;
        this.accountType = "checking";
      }
      await this.getFinancialData();
      await this.getGoalData();
      await this.getTransactionData();
    }
    this.loading = false;
  }

  connectedCallback() {
    //get url param here for goal filtering
    if (this.pageRef?.state?.c__goalId) {
      this.preselectedGoal = this.pageRef.state.c__goalId;
      this.transactionBucketIds.push(this.preselectedGoal);
    }
  }

  get displayContent() {
    return hasAccountsGoalsPermission;
  }

  async getFinancialData() {
    this.accountData = [];
    try {
      let accountDetails = await getFinancialAccountFabric({
        ocvId: this.ocvId,
        accountNumbers: [this.accountNumber]
      });
      this.accountData = this.handleAccountInformation(accountDetails);
    } catch (error) {
      this.accountError =
        "Failed to retrieve latest account details. Please refresh and try again. If issue persists please contact your System Administrator";
      handleErrorShowToast(
        this,
        "Failed To Retrieve Account Details",
        error,
        this.accountError,
        "pester"
      );
      // If the API callout fails to fetch latest data, use this as a fallback to fetch
      // the records stored in Salesforce
      let accountDetails = await getFinancialAccountDB({
        ownerId: this.recordId,
        type: [this.accountType]
      });
      this.accountData = this.handleAccountInformation(accountDetails);
    }
  }

  async getGoalData() {
    this.goalData = [];
    this.savingsJar = null;
    if (this.isSavings) {
      try {
        let goalDetails = await getAccountBuckets({ ocvId: this.ocvId });
        goalDetails = handleGoalsParent(goalDetails);
        this.emojiMap = getEmojiMap(goalDetails);
        this.imageMap = getImageMap(goalDetails);
        this.goalMap = getGoalMap(goalDetails);
        //Savings jar will always be default, so retrieve it
        //to pass through to other components that need it
        this.savingsJar = goalDetails.account_buckets.filter((obj) => {
          return obj.is_default;
        })[0];
        //Remove savings jar as its not displayed on goals component
        this.goalData.goalList = goalDetails.account_buckets.filter((obj) => {
          return !obj.is_default;
        });
        //Check if we have any goals other than savings jar
        if (this.goalData.goalList.length > 0) {
          this.goalData.nextToken = goalDetails.next_page_token;
        } else {
          this.goalData = null;
        }
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
  }

  async getTransactionData(paramUrl = "") {
    //If we arent loading in new transactions to append,
    //trigger the whole lwc to load
    if (!this.transactionLoadMore) {
      this.transactionLoading = true;
    }
    //Set default component title here to ensure theres always a title
    //even if the try catch fails
    this.componentTitle = this.isSavings
      ? "All Savings Transaction History"
      : "All Everyday Transaction History";
    try {
      this.transactionData = await getTransactionHistoryAura({
        ocvId: this.ocvId,
        accountNumber: this.accountNumber,
        startDate: this.transactionStartDate,
        endDate: this.transactionEndDate,
        paramUrl: paramUrl,
        bucketIds: this.transactionBucketIds
      });

      if (
        this.isSavings &&
        this.transactionData?.embedded?.transactions &&
        this.emojiMap &&
        this.imageMap
      ) {
        this.transactionData = handleTransactionGoals(
          this.transactionData,
          this.imageMap,
          this.emojiMap
        );

        //If theres no goals filtered, reset transaction title
        //otherwise append filtered goals
        if (this.transactionBucketIds.length === 0) {
          this.componentTitle = "All Savings Transaction History";
        } else {
          this.componentTitle = handleComponentTitle(
            this.transactionBucketIds,
            this.goalMap
          );
        }
      }
    } catch (error) {
      this.hasTransactionError = true;
      this.transactionError = TRANSACTION_HISTORY_RETRIEVE_ERROR;
      handleErrorShowToast(
        this,
        "Failed To Retrieve Transaction History",
        error,
        this.transactionError,
        "pester"
      );
    } finally {
      //reset values
      this.clearTransactions = false;
      this.transactionLoading = false;
      this.transactionLoadMore = false;
    }
  }

  handleAccountInformation(finAccounts) {
    finAccounts.forEach((finAccount) => {
      finAccount.badgeClass =
        finAccount.FinServ__Status__c === "Active" ||
        finAccount.FinServ__Status__c === "Open"
          ? "slds-badge slds-theme_success"
          : "slds-badge slds-theme_error";
    });

    return finAccounts;
  }

  handleLoadMore(event) {
    this.transactionLoadMore = true;
    this.getTransactionData(event.detail);
  }

  handleSearchDates(event) {
    this.transactionStartDate = event.detail.startDateString;
    this.transactionEndDate = event.detail.endDateString;
    this.getTransactionData();
  }

  //Pagination for buckets not built yet. When merged,
  //this will be updated to handle it
  // handleLoadMoreGoals(event) {
  // }

  handleGoalFilters(event) {
    this.transactionBucketIds = event.detail.goalFilters;
    //Remove preselected goal if we are clearing filters
    if (this.transactionBucketIds.length === 0) {
      this.preselectedGoal = null;
    }
    this.clearTransactions = true;
    this.getTransactionData();
  }

  async refreshData() {
    this.loading = true;
    //Reset any preset goals and filters
    this.transactionBucketIds = [];
    if (this.pageRef?.state?.c__goalId) {
      this.preselectedGoal = this.pageRef.state.c__goalId;
      this.transactionBucketIds.push(this.preselectedGoal);
    }
    await this.getFinancialData();
    await this.getGoalData();
    await this.getTransactionData();
    this.loading = false;
  }
}
