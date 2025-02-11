import { LightningElement, api, wire } from "lwc";
import { CloseActionScreenEvent } from "lightning/actions";
import { getRecord } from "lightning/uiRecordApi";
import { getFocusedTabInfo, refreshTab } from "lightning/platformWorkspaceApi";
import getFilteredFinancialAccounts from "@salesforce/apex/AccountClosureWizardController.getFilteredFinancialAccounts";
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
  hasError = false;
  isFinAccountsAvailable = false;
  showFinDataTable = true;
  _showNoDataMessage = false;
  customerOcvId;
  accountId;
  errorMsg;

  ownershipMap = {
    Single: { displayValue: "Sole", apiValue: "Individual" },
    "Multi-party": { displayValue: "Joint", apiValue: "Joint" }
  };

  get showNoDataMessage() {
    return this._showNoDataMessage;
  }

  set showNoDataMessage(value) {
    this._showNoDataMessage = value.length === 0;
  }

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
      this.accountDetails = await getFilteredFinancialAccounts({
        ocvId: this.customerOcvId
      });
      this.showNoDataMessage = this.accountDetails;
      // Map account details to financial account data
      this.finAccData = this.mapAccountDetailsToFinAccData(this.accountDetails);
    } catch (error) {
      this.handleError(error);
      this.showNoDataMessage = this.accountDetails;
      handleErrorShowToast(
        this,
        "Failed To Retrieve Account Details",
        error,
        "Failed to retrieve latest account details. Please refresh and try again. If the issue persists, please contact your System Administrator",
        "pester"
      );
    } finally {
      this.loading = false;
    }
  }

  /**
   * Helper method to map account details to financial account data.
   */
  mapAccountDetailsToFinAccData(accountDetails) {
    return accountDetails.map((record) => {
      const ownershipInfo = this.ownershipMap[record.Ownership__c] || {};
      return {
        id: record.Id,
        productId: record?.FinServ__ProductName__c || null,
        productName: record?.FinServ__ProductName__r?.Name || null,
        accountNumber: record?.FinServ__FinancialAccountNumber__c || null,
        finAccountType: ownershipInfo.displayValue || "",
        signingAuthority:
          record.Ownership__c === "Multi-party" &&
          record.Number_Of_Signatures__c === "All to sign"
            ? record.Number_Of_Signatures__c
            : "",
        balance: record?.FinServ__Balance__c,
        apiFinAccountType: ownershipInfo.apiValue || ""
      };
    });
  }

  handleRowSelection(event) {
    this.selectedRows = event.detail.selectedRows;
  }

  handleCasesCreated() {
    this.showFinDataTable = false;
    this.refreshTab();
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

  async refreshTab() {
    const { tabId } = await getFocusedTabInfo();
    await refreshTab(tabId, {
      includeAllSubtabs: false
    });
  }
}
