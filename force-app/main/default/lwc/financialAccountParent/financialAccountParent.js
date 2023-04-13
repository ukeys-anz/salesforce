import { LightningElement, api, wire } from "lwc";
import { getRecord } from "lightning/uiRecordApi";
import { handleErrorShowToast } from "c/utils";

import getFinancialAccountFabric from "@salesforce/apex/FinancialAccountController.getFinancialAccountFabric";
import getFinancialAccountDB from "@salesforce/apex/FinancialAccountController.getFinancialAccountDB";
import getAccountBuckets from "@salesforce/apex/AccountBucketsController.getAccountBuckets";
import getTransactionHistoryAura from "@salesforce/apex/CoachBankingAPIRepository.getTransactionHistoryAura";

import FIN_ACCOUNT_NUMBER from "@salesforce/schema/FinServ__FinancialAccount__c.FinServ__FinancialAccountNumber__c";
import FIN_ACCOUNT_OCV_ID from "@salesforce/schema/FinServ__FinancialAccount__c.OCV_ID__c";
import FIN_ACCOUNT_TYPE from "@salesforce/schema/FinServ__FinancialAccount__c.FinServ__FinancialAccountType__c";
import FIN_ACCOUNT_RECORD_TYPE from "@salesforce/schema/FinServ__FinancialAccount__c.FinServ__RecordTypeName__c";
import FIN_ACCOUNT_PRIMARY_OWNER from "@salesforce/schema/FinServ__FinancialAccount__c.FinServ__PrimaryOwner__c";

import FIN_ACCOUNT_INTEREST from "@salesforce/schema/FinServ__FinancialAccount__c.Interest_Accrued__c";
import { TRANSACTION_HISTORY_RETRIEVE_ERROR } from "c/transactionHistoryService";

import getHomeLoanAccount from "@salesforce/apex/HomeLoanController.getHomeLoanAccount";
/* IMPORT PERMISSIONS */
import hasHomeLoanPermission from "@salesforce/customPermission/ANZx_Home_Loan";
import hasAccountsGoalsPermission from "@salesforce/customPermission/ANZx_Accounts_and_Goals";

import {
  getEmojiMap,
  getGoalMap,
  getImageMap,
  handleGoalData,
  handleTransactionGoals,
  handleComponentTitle
} from "./helpers/utils";
import { CurrentPageReference } from "lightning/navigation";
import getDisputeRecordTypeMap from "@salesforce/apex/TransactionHistoryController.getDisputeRecordTypeMap";
import { DISPUTE_RECORD_TYPES_RETRIEVE_ERROR } from "c/transactionHistoryService";
export default class FinancialAccountParent extends LightningElement {
  @api recordId;
  @api objectApiName;
  accountData = [];
  accountError;
  accountNumber;
  accountType;
  accRecordType;
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
  isHomeLoan;
  loanData;
  loading;
  ocvId;
  transactionData;
  transactionError;
  savingsJar;
  preselectedGoal;
  primaryOwner;
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
  //Triggers the bottom of goals to load for
  //appending new goals
  goalsLoading = false;
  showRaiseDispute;
  transactionTypeDisputeIdMap = {};
  disputeRecordTypes = [];
  filterGoal = false;

  @wire(CurrentPageReference)
  pageRef;

  @wire(getRecord, {
    recordId: "$recordId",
    fields: [
      FIN_ACCOUNT_NUMBER,
      FIN_ACCOUNT_OCV_ID,
      FIN_ACCOUNT_TYPE,
      FIN_ACCOUNT_RECORD_TYPE,
      FIN_ACCOUNT_PRIMARY_OWNER,
      FIN_ACCOUNT_INTEREST
    ]
  })
  async wiredRecord({ data }) {
    this.loading = true;
    if (data) {
      this.ocvId = data.fields.OCV_ID__c.value;
      this.accountNumber = data.fields.FinServ__FinancialAccountNumber__c.value;
      this.primaryOwner = data.fields.FinServ__PrimaryOwner__c.value;
      this.accRecordType = data.fields.FinServ__RecordTypeName__c.value;
      const accType = data.fields.FinServ__FinancialAccountType__c.value;
      if (
        this.ocvId &&
        this.accRecordType === "Bank Account" &&
        hasHomeLoanPermission
      ) {
        this.isHomeLoan = true;
        this.showRaiseDispute = false;
        await this.getHomeLoanResponse();
      } else {
        this.showRaiseDispute = true;
        if (accType === "Savings") {
          this.isSavings = true;
          this.accountType = "savings";
        } else if (accType === "Checking") {
          this.isSavings = false;
          this.accountType = "checking";
        }
        if (this.disputeRecordTypes.length === 0) {
          await this.handleGetDisputeRecordTypeDetails();
        }
        await this.getFinancialData();
        await this.getGoalData();
      }

      if (!this.transactionData) {
        await this.getTransactionData();
      }
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

  get displayNotLoan() {
    return hasAccountsGoalsPermission && this.accRecordType !== "Bank Account";
  }

  get displayLoan() {
    return hasHomeLoanPermission && this.accRecordType === "Bank Account";
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

  async getGoalData(paramUrl = "") {
    if (this.isSavings) {
      try {
        this.goalData = [];
        this.goalData = await getAccountBuckets({
          ocvId: this.ocvId,
          pageSize: 7,
          nextPageToken: paramUrl
        });

        this.goalData = handleGoalData(this.goalData);
        this.emojiMap = getEmojiMap(this.goalData);
        this.imageMap = getImageMap(this.goalData);
        this.goalMap = getGoalMap(this.goalData);

        //Savings jar will always be default, so retrieve it
        //to pass through to other components that need it
        //Wrap if check so we dont overwrite the value when loading next
        //set of data
        if (!paramUrl) {
          this.savingsJar = this.goalData.account_buckets.filter((obj) => {
            return obj.is_default;
          })[0];
        }
        //Remove savings jar as its not displayed on goals component
        this.goalData.goalList = this.goalData.account_buckets.filter((obj) => {
          return !obj.is_default;
        });
        this.goalData.nextPageToken = this.goalData.next_page_token
          ? this.goalData.next_page_token
          : "";
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
      } finally {
        this.goalsLoading = false;
      }
    }
  }

  async getTransactionData(paramUrl = "") {
    //If we arent loading in new transactions to append,
    //trigger the whole lwc to load
    if (!this.transactionLoadMore) {
      this.transactionLoading = true;
    }

    if (this.filterGoal) {
      this.clearTransactions = true;
    } else {
      this.clearTransactions = false;
    }
    //Set default component title here to ensure theres always a title
    //even if the try catch fails
    if (this.isHomeLoan) {
      this.componentTitle = "Transaction History";
    } else {
      this.componentTitle = this.isSavings
        ? "All Savings Transaction History"
        : "All Everyday Transaction History";
    }
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
      this.filterGoal = false;
      this.transactionLoading = false;
      this.transactionLoadMore = false;
    }
  }

  async getHomeLoanResponse() {
    try {
      let response = await getHomeLoanAccount({ ocvId: this.ocvId });
      this.loanData = response.accounts[0];
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

  handleLoadMoreGoals(event) {
    this.goalsLoading = true;
    this.getGoalData(event.detail.nextPageToken);
  }

  handleGoalFilters(event) {
    this.transactionBucketIds = event.detail.goalFilters;
    //Remove preselected goal if we are clearing filters
    if (this.transactionBucketIds.length === 0) {
      this.preselectedGoal = null;
    }
    this.filterGoal = true;
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

  // Construct a map of transaction type and its corresponding case record type
  async handleGetDisputeRecordTypeDetails() {
    let result = await getDisputeRecordTypeMap();
    if (result) {
      try {
        const returnedMap = JSON.parse(result);
        // Construct a list of dispute record type's label and Id to send to transaction record to construct the modal
        for (const [key, value] of Object.entries(returnedMap)) {
          this.transactionTypeDisputeIdMap[key] = value.Id; // This map is used in getRecordTypeId() below to determine which page layout the user should be directed to
          let recordTypeItem = {};
          recordTypeItem.developerName = key;
          recordTypeItem.label = value.Name;
          recordTypeItem.value = value.Id;
          this.disputeRecordTypes.push(recordTypeItem);
        }
      } catch (error) {
        handleErrorShowToast(
          this,
          "Failed To Retrieve Dispute Record Types",
          error,
          DISPUTE_RECORD_TYPES_RETRIEVE_ERROR,
          "pester"
        );
      }
    }
  }
}
