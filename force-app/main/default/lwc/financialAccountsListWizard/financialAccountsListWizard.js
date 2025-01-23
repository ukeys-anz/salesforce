import { LightningElement, api, wire } from "lwc";
import { CloseActionScreenEvent } from "lightning/actions";
import { getRecord } from "lightning/uiRecordApi";
import getFilteredFinancialAccounts from "@salesforce/apex/AccountClosureWizardController.getFilteredFinancialAccounts";
import getFinancialAccountDB from "@salesforce/apex/AccountClosureWizardController.getFilteredFinancialAccountsDb";
import {
  CHECKING_ACCOUNT_RT_APINAME,
  SAVINGS_ACCOUNT_RT_APINAME
} from "c/financialAccountParent";
import { handleErrorShowToast } from "c/utils";

const fields = ["Case.Account.OCV_ID__c", "Case.AccountId"];
const columns = [
  { label: "Product", fieldName: "productName" },
  { label: "Account Number", fieldName: "accountNumber" },
  { label: "Account Type", fieldName: "finAccountType" },
  { label: "Signing Authority", fieldName: "signingAuthority" },
  { label: "Available Balance", fieldName: "balance", type: "currency" }
];

const ERROR_MESSAGE =
  "Please try again. Raise a fault through TechAssist if the problem persists.";

export default class FinancialAccountsListWizard extends LightningElement {
  @api recordId;
  finAccData = [];
  selectedRowsData = [];
  accountDetails = [];
  loading = false;
  hasFetchedAccounts = false;
  columns = columns;
  showCheckbox = false;
  isCasesCreated = false;
  hasError = false;
  customerOcvId;
  accountId;
  errorMsg;

  ownershipMap = {
    Single: { displayValue: "Sole", apiValue: "Individual" },
    "Multi-party": { displayValue: "Joint", apiValue: "Joint" }
  };

  get selectedRows() {
    return this.selectedRowsData;
  }

  set selectedRows(value) {
    this.showCheckbox = value.length > 1;
    this.selectedRowsData = value;
  }

  @wire(getRecord, { recordId: "$recordId", fields })
  wiredData({ data }) {
    try {
      if (data && !this.hasFetchedAccounts) {
        this.customerOcvId =
          data.fields?.Account?.value?.fields?.OCV_ID__c?.value;
        this.accountId = data.fields?.AccountId?.value;
        if (this.customerOcvId) {
          this.hasFetchedAccounts = true;
          this.getFinancialAccount();
        }
      }
    } catch (error) {
      this.handleError(error);
    }
  }

  async getFinancialAccount() {
    this.loading = true;
    try {
      const accountDetailsFromApi = await this.fetchAccountDataFromApi();
      this.accountDetails = accountDetailsFromApi.length
        ? accountDetailsFromApi
        : await this.handleErrorFetchingAccounts();
      // Map account details to financial account data
      this.finAccData = this.mapAccountDetailsToFinAccData(this.accountDetails);
    } finally {
      this.loading = false;
    }
  }

  async fetchAccountDataFromApi() {
    try {
      return await getFilteredFinancialAccounts({
        ocvId: this.customerOcvId,
        accountNumbers: []
      });
    } catch {
      return [];
    }
  }

  async handleErrorFetchingAccounts() {
    this.hasError = true;
    handleErrorShowToast(
      this,
      "Failed To Retrieve Account Details",
      "error",
      "Failed to retrieve latest account information. Please refresh and try again. If the issue persists, contact your System Administrator.",
      "pester"
    );
    // Fallback to database retrieval if API call fails
    // Attempt to fetch from the database
    return await getFinancialAccountDB({
      ownerId: this.accountId,
      recordTypeDeveloperNames: [
        CHECKING_ACCOUNT_RT_APINAME,
        SAVINGS_ACCOUNT_RT_APINAME
      ]
    });
  }

  mapAccountDetailsToFinAccData(accountDetails) {
    return accountDetails.map((record) => {
      const ownershipInfo = this.ownershipMap[record.ownership] || {};
      return {
        id: record.id,
        productName: record.productName,
        accountNumber: record.accountNumber,
        finAccountType: ownershipInfo.displayValue || "",
        signingAuthority:
          record.ownership === "Multi-party" &&
          record.signingAuthority === "All to sign"
            ? record.signingAuthority
            : "",
        balance: record.balance,
        productId: record.productId,
        apiFinAccountType: ownershipInfo.apiValue || ""
      };
    });
  }

  handleRowSelection(event) {
    this.selectedRows = event.detail.selectedRows;
  }

  handleCasesCreated() {
    this.isCasesCreated = true;
  }

  handleErrorVisibilty(event) {
    this.hasError = event.detail.showError;
    this.errorMsg = event.detail.errorMessage;
  }

  handleCancelAction() {
    this.dispatchEvent(new CloseActionScreenEvent());
  }

  handleError() {
    this.hasError = true;
    this.errorMsg = ERROR_MESSAGE;
  }
}
