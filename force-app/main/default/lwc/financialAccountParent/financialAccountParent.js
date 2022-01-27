import { LightningElement, api, wire } from "lwc";
import { getRecord } from "lightning/uiRecordApi";
import { handleErrorShowToast, showToast } from "c/utils";

import getFinancialAccountFabric from "@salesforce/apex/FinancialAccountController.getFinancialAccountFabric";
import getFinancialAccountDB from "@salesforce/apex/FinancialAccountController.getFinancialAccountDB";
import getAccountBuckets from "@salesforce/apex/AccountBucketsController.getAccountBuckets";
import getTransactionHistoryAura from "@salesforce/apex/CoachBankingAPIRepository.getTransactionHistoryAura";
import hasAccountsGoalsPermission from "@salesforce/customPermission/ANZx_Accounts_and_Goals";

import FIN_ACCOUNT_NUMBER from "@salesforce/schema/FinServ__FinancialAccount__c.FinServ__FinancialAccountNumber__c";
import FIN_ACCOUNT_OCV_ID from "@salesforce/schema/FinServ__FinancialAccount__c.OCV_ID__c";
import FIN_ACCOUNT_TYPE from "@salesforce/schema/FinServ__FinancialAccount__c.FinServ__FinancialAccountType__c";
import TRANSACTION_HISTORY_RETRIEVE_ERROR from "c/transactionHistoryService";

import { handleGoalData } from "./helpers/utils";
import { CurrentPageReference } from "lightning/navigation";

export default class FinancialAccountParent extends LightningElement {
  @api recordId;
  financialAccountData = [];
  financialAccountError;
  financialAccountNumber;
  financialAccountType;
  goalData = { goalList: [], nextToken: null };
  goalError;
  hasError = false;
  isSavings;
  loading;
  ocvId;
  transactionData;
  transactionError;
  savingsJar;
  preselectedGoal;

  @wire(CurrentPageReference)
  pageRef;

  @wire(getRecord, {
    recordId: "$recordId",
    fields: [FIN_ACCOUNT_NUMBER, FIN_ACCOUNT_OCV_ID, FIN_ACCOUNT_TYPE]
  })
  async wiredRecord({ data }) {
    this.loading = true;
    if (data) {
      this.ocvId = data.fields.OCV_ID__c.value;
      this.financialAccountNumber =
        data.fields.FinServ__FinancialAccountNumber__c.value;
      if (data.fields.FinServ__FinancialAccountType__c.value === "Savings") {
        this.isSavings = true;
        this.financialAccountType = "savings";
      } else if (
        data.fields.FinServ__FinancialAccountType__c.value === "Checking"
      ) {
        this.isSavings = false;
        this.financialAccountType = "checking";
      }
      await this.getFinancialData();
      await this.getGoalData();
      this.getTransactionData();
    }
    this.loading = false;
  }
  connectedCallback() {
    //get url param here for goal filtering
    if (this.pageRef?.state?.c__goalId) {
      this.preselectedGoal = this.pageRef.state.c__goalId;
    }
  }
  get displayContent() {
    return hasAccountsGoalsPermission;
  }

  async getFinancialData() {
    this.financialAccountData = [];
    try {
      let financialAccountDetails = await getFinancialAccountFabric({
        ocvId: this.ocvId,
        accountNumbers: [this.financialAccountNumber]
      });
      this.financialAccountData = this.handleAccountInformation(
        financialAccountDetails
      );
    } catch (error) {
      this.financialAccountError =
        "Failed to retrieve latest account details. Please refresh and try again. If issue persists please contact your System Administrator";
      handleErrorShowToast(
        this,
        "Failed To Retrieve Account Details",
        error,
        this.financialAccountError,
        "pester"
      );
      // If the API callout fails to fetch latest data, use this as a fallback to fetch
      // the records stored in Salesforce
      let financialAccountDetails = await getFinancialAccountDB({
        ownerId: this.recordId,
        type: [this.financialAccountType]
      });
      this.financialAccountData = this.handleAccountInformation(
        financialAccountDetails
      );
    }
  }

  async getGoalData() {
    this.goalData = [];
    this.savingsJar = null;
    if (this.isSavings) {
      try {
        let goalDetails = await getAccountBuckets({ ocvId: this.ocvId });
        goalDetails = handleGoalData(goalDetails);
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

  async getTransactionData(
    paramUrl = "",
    startDateString = "",
    endDateString = ""
  ) {
    try {
      this.transactionData = await getTransactionHistoryAura({
        ocvId: this.ocvId,
        accountNumber: this.financialAccountNumber,
        startDate: startDateString,
        endDate: endDateString,
        paramUrl: paramUrl
      });
    } catch (error) {
      this.transactionError = TRANSACTION_HISTORY_RETRIEVE_ERROR;
      if (error.body && error.body.message) {
        let message = this.handleError(error.body.message);
        //Catch any system error messages (most readable errors wont be a single word)
        if (message && message.split(" ").length > 1) {
          this.transactionError = message;
        }
      }
      this.hasError = true;
      showToast("Transaction History Load Failed", this.errorMessage, error);
    }
  }

  handleAccountInformation(finAccounts) {
    finAccounts.forEach((finAccount) => {
      finAccount.badgeClass =
        finAccount.FinServ__Status__c === "Active"
          ? "slds-badge slds-theme_success"
          : "slds-badge slds-theme_error";
    });

    return finAccounts;
  }
  //This function is required as some errors are returned
  //as stringified json
  handleError(error) {
    try {
      JSON.parse(error);
    } catch (e) {
      return error;
    }
    return JSON.parse(error).message;
  }

  handleLoadMore(event) {
    this.getTransactionData(event.detail);
  }

  handleSearchDates(event) {
    this.getTransactionData(
      "",
      event.detail.startDateString,
      event.detail.endDateString
    );
  }

  //   handleTransactionGoals(transactions){
  //     //if (transactions){
  //       //loop through transactions to check for bucket_id
  //       transactions.embedded.transactions.transfer.destination_account.bucket_id;
  //       transactions.embedded.transactions.transfer.source_account.bucket_id;
  //       //map id from ths.goalData and append image to transaction dataset }
  //       //ensure getTransactionData is refactored to be run after getGoalData
  //   }
  // }

  //Pagination for buckets not built yet. When merged,
  //this will be updated to handle it
  // handleLoadMoreGoals(event) {
  // }

  handleGoalFilters(event) {
    if (event?.detail?.goalFilters?.length > 0) {
      //Call transactions with filter - to be done in ANZX-30884
    }
  }
}
