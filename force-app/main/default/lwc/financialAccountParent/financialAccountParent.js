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

export default class FinancialAccountParent extends LightningElement {
  @api recordId;
  financialAccountData = [];
  financialAccountError;
  financialAccountNumber;
  financialAccountType;
  goalDetails = [];
  goalError;
  isSavings;
  loading;
  ocvId;
  transactionDetails = [];
  transactionError;

  @wire(getRecord, {
    recordId: "$recordId",
    fields: [FIN_ACCOUNT_NUMBER, FIN_ACCOUNT_OCV_ID, FIN_ACCOUNT_TYPE]
  })
  wiredRecord({ data }) {
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
      this.getFinancialData();
      // will be part of #5557 & #5559
      // this.getGoalData();
      // this.getTransactionData();
    }
    this.loading = false;
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

  getGoalData() {
    this.goalDetails = [];
    if (this.isSavings)
      try {
        this.goalDetails = getAccountBuckets({
          ocvId: this.ocvId
        });
      } catch (error) {
        this.goalError =
          "Failed to retrieve goal details. Please refresh and try again. If issue persists please contact your System Administrator";
        handleErrorShowToast(
          this,
          "Failed To Retrieve Goal Details",
          error,
          this.goalError,
          "pester"
        );
      }
  }

  getTransactionData() {
    this.transactionDetails = [];
    try {
      this.transactionDetails = getTransactionHistoryAura({
        ocvId: this.ocvId,
        accountNumber: this.financialAccountNumber,
        startDate: startDateString,
        endDate: endDateString,
        paramUrl: paramUrl
      });
    } catch (error) {
      this.transactionError =
        "Failed to retrieve transaction details. Please refresh and try again. If issue persists please contact your System Administrator";
      handleErrorShowToast(
        this,
        "Failed To Retrieve Transaction Details",
        error,
        this.transactionError,
        "pester"
      );
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
}
