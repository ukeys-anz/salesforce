/* LWC IMPORTS */
import { LightningElement, api, wire } from "lwc";
import { getRecord } from "lightning/uiRecordApi";
import { handleErrorShowToast } from "c/utils";
import { handleGoalThemes } from "c/accountsGoalsUtils";
import {
  groupGoalsByAccountNumber,
  addFinAccountAndMetaDataToGoals
} from "./helper/helper-goalsDetails";
import { updateProductName } from "./helper/helper-accountDetails";

/* IMPORT APEX METHODS */
import getFinancialAccountFabric from "@salesforce/apex/FinancialAccountController.getFinancialAccountFabric";
import getFinancialAccountDB from "@salesforce/apex/FinancialAccountController.getFinancialAccountDB";
import getOffsetHomeLoanAccount from "@salesforce/apex/HomeLoanController.getListOffset";
import getAccountBuckets from "@salesforce/apex/AccountBucketsController.getAccountBuckets";

/* IMPORT PERMISSIONS */
import hasAccountsGoalsPermission from "@salesforce/customPermission/ANZx_Accounts_and_Goals";
import hasHomeLoanPermission from "@salesforce/customPermission/ANZx_Home_Loan";

/* IMPORT SCHEMA FIELDS */
import ACCOUNT_OCV_ID_FIELD from "@salesforce/schema/Account.OCV_ID__c";

export default class PersonAccountFinancialDetails extends LightningElement {
  @api recordId;
  @api objectApiName;
  goalDetails = [];
  ocvId;
  loading;
  goalError;
  totalBalanceError;
  loanData;
  offsetData = {};
  accountToOwnership = new Map();
  isS2AccountExist = false;
  fetchedAccounts;
  processedAccounts = {};
  savingAccountExist = false;

  connectedCallback() {
    window.addEventListener(
      "refreshFinances_" + this.recordId,
      this.handleRefreshFinances.bind(this)
    );
  }

  get accountData() {
    return this.processedAccounts;
  }

  get isSavingAccountExist() {
    return this.savingAccountExist;
  }

  get hasHomeLoan() {
    return (
      Array.isArray(this.processedAccounts.groupedAccounts) &&
      this.processedAccounts.groupedAccounts.some((group) => group.isHomeLoan)
    );
  }

  get homeLoanAccounts() {
    return this.processedAccounts.groupedAccounts
      .filter((group) => group.isHomeLoan)
      .flatMap((group) => group.accounts);
  }

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
      if (this.handleGoalApiCallout()) {
        this.savingAccountExist = true;
        await this.getGoals();
      }
    }
    if (this.ocvId && hasHomeLoanPermission) {
      const offsetResponse = await this.getOffsetHomeLoanResponse();
      this.offsetData = offsetResponse;
    }
    this.loading = false;
  }

  async getFinancialAccount() {
    try {
      this.fetchedAccounts = await getFinancialAccountFabric({
        ocvId: this.ocvId,
        accountNumbers: []
      });
      this.processedAccounts = structuredClone(this.fetchedAccounts);
      this.processedAccounts = updateProductName(this.processedAccounts);
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
      this.fetchedAccounts = await getFinancialAccountDB({
        ocvId: this.ocvId,
        ownerId: this.recordId
      });
      this.processedAccounts = structuredClone(this.fetchedAccounts);
      this.processedAccounts = updateProductName(this.processedAccounts);
    } finally {
      //Raise this event to call initiate fetching of total balance
      window.dispatchEvent(
        new CustomEvent("refreshFinances_" + this.recordId, {
          detail: "FetchBalance"
        })
      );
    }
  }

  async getOffsetHomeLoanResponse() {
    try {
      //Filter to only get offset account we are viewing
      let response = await getOffsetHomeLoanAccount({
        ocvId: this.ocvId,
        loanAccNumber: "",
        recordId: this.recordId
      });
      return response;
    } catch (error) {
      handleErrorShowToast(
        this,
        "Failed To Retrieve offset Details.",
        error,
        "Failed To Retrieve offset Details. Please refresh and try again. If issue persists please contact your System Administrator",
        "pester"
      );
    }
    return null;
  }

  get displayContent() {
    return hasAccountsGoalsPermission;
  }

  async getGoals() {
    this.goalDetails = [];
    try {
      let goalData = await getAccountBuckets({
        ocvId: this.ocvId,
        pageSize: 100,
        nextPageToken: "",
        accountNumber: ""
      });

      //Add additional financial account and meta data details to goals
      const goalCopy = addFinAccountAndMetaDataToGoals(
        this.processedAccounts,
        goalData
      );

      goalData = handleGoalThemes(goalCopy);

      //Remove savings jar as its not displayed on goals component
      const goalDetailsToShow = goalCopy.account_buckets.filter((obj) => {
        return !obj.is_default;
      });

      this.goalDetails = groupGoalsByAccountNumber(goalDetailsToShow);
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

  handleRefreshFinances(event) {
    if (event?.detail === "Refresh") {
      this.refreshData();
    }
  }

  async refreshData() {
    this.loading = true;
    await this.getFinancialAccount();
    await this.getGoals();
    this.loading = false;
  }

  disconnectedCallback() {
    window.removeEventListener(
      "refreshFinances_" + this.recordId,
      this.handleRefreshFinances.bind(this)
    );
  }

  handleGoalApiCallout() {
    return (
      Array.isArray(this.processedAccounts.groupedAccounts) &&
      this.processedAccounts.groupedAccounts.some((group) => group.isSaving)
    );
  }
}
