/* LWC IMPORTS */
import { LightningElement, api, wire } from "lwc";
import { getRecord } from "lightning/uiRecordApi";
import { handleErrorShowToast } from "c/utils";
import { updateProductName } from "./helper/helper-accountDetails";

/* IMPORT APEX METHODS */
import getFinancialAccountFabric from "@salesforce/apex/FinancialAccountController.getFinancialAccountFabric";
import getFinancialAccountDB from "@salesforce/apex/FinancialAccountController.getFinancialAccountDB";
import getOffsetHomeLoanAccount from "@salesforce/apex/HomeLoanController.getListOffset";

/* IMPORT PERMISSIONS */
import hasAccountsGoalsPermission from "@salesforce/customPermission/ANZx_Accounts_and_Goals";
import hasHomeLoanPermission from "@salesforce/customPermission/ANZx_Home_Loan";

/* IMPORT SCHEMA FIELDS */
import ACCOUNT_OCV_ID_FIELD from "@salesforce/schema/Account.OCV_ID__c";

export default class PersonAccountFinancialDetails extends LightningElement {
  @api recordId;
  @api objectApiName;
  ocvId;
  loading;
  totalBalanceError;
  loanData;
  offsetData = {};
  accountToOwnership = new Map();
  fetchedAccounts;
  processedAccounts = [];
  hasOffsetError = false;

  connectedCallback() {
    window.addEventListener(
      "refreshFinances_" + this.recordId,
      this.handleRefreshFinances.bind(this)
    );
  }

  get hasHomeLoan() {
    return (
      Array.isArray(this.processedAccounts) &&
      this.processedAccounts.some((group) => group.isHomeLoan)
    );
  }

  get homeLoanAccounts() {
    return JSON.stringify(
      this.processedAccounts
        .filter((group) => group.isHomeLoan)
        .flatMap((group) => group.accounts)
    );
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
      this.processedAccounts = this.fetchedAccounts;
      this.processedAccounts.sort(
        (firstGroup, secondGroup) =>
          firstGroup.sortOrder - secondGroup.sortOrder
      );
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
      this.processedAccounts = this.fetchedAccounts.filter(
        (group) => !group.isHomeLoan
      );
      this.processedAccounts.sort(
        (firstGroup, secondGroup) =>
          firstGroup.sortOrder - secondGroup.sortOrder
      );
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
      this.hasOffsetError = true;
    }
    return null;
  }

  get displayContent() {
    return hasAccountsGoalsPermission;
  }

  handleRefreshFinances(event) {
    if (event?.detail === "Refresh") {
      this.refreshData();
    }
  }

  async refreshData() {
    this.loading = true;
    await this.getFinancialAccount();
    this.loading = false;
  }

  disconnectedCallback() {
    window.removeEventListener(
      "refreshFinances_" + this.recordId,
      this.handleRefreshFinances.bind(this)
    );
  }
}
