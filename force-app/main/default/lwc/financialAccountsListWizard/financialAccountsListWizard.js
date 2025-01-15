import { LightningElement, track, api, wire } from "lwc";
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
  { label: "Product Name", fieldName: "productName" },
  { label: "Account Number", fieldName: "accountNumber" },
  { label: "Account Type", fieldName: "finAccountType" },
  { label: "Signing Authority", fieldName: "signingAuthority" },
  { label: "Balance", fieldName: "balance", type: "currency" }
];

export default class FinancialAccountsListWizard extends LightningElement {
  @api recordId;
  @track finAccData = [];
  @track selectedRows = [];
  loading = false;
  customerOcvId;
  accountId;
  accountDetails = [];
  hasFetchedAccounts = false;
  columns = columns;
  showCheckbox = false;
  isCasesCreated = false;
  hasError = false;
  ownershipMap = {
    Single: { displayValue: "Sole", apiValue: "Individual" },
    "Multi-party": { displayValue: "Joint", apiValue: "Joint" }
  };

  @wire(getRecord, { recordId: "$recordId", fields })
  wiredData({ data }) {
    if (data && !this.hasFetchedAccounts) {
      this.customerOcvId =
        data.fields?.Account?.value?.fields?.OCV_ID__c?.value;
      this.accountId = data.fields?.AccountId?.value;
      if (this.customerOcvId) {
        this.hasFetchedAccounts = true;
        this.getFinancialAccount();
      }
    }
  }

  async getFinancialAccount() {
    this.loading = true;
    try {
      // Attempt to get the latest account details from fabric
      this.accountDetails = await getFilteredFinancialAccounts({
        ocvId: this.customerOcvId,
        accountNumbers: []
      });

      // Map account details to financial account data
      if (this.accountDetails) {
        this.finAccData = this.mapAccountDetailsToFinAccData(
          this.accountDetails
        );
      }
    } catch (error) {
      this.hasError = true;
      handleErrorShowToast(
        this,
        "Failed To Retrieve Account Details",
        error,
        "Failed to retrieve latest account details. Please refresh and try again. If the issue persists, please contact your System Administrator",
        "pester"
      );
      // Fallback to database retrieval if API call fails
      // Attempt to fetch from the database
      this.accountDetails = await getFinancialAccountDB({
        ownerId: this.accountId,
        recordTypeDeveloperNames: [
          CHECKING_ACCOUNT_RT_APINAME,
          SAVINGS_ACCOUNT_RT_APINAME
        ]
      });
      // Map account details to financial account data
      if (this.accountDetails) {
        this.finAccData = this.mapAccountDetailsToFinAccData(
          this.accountDetails
        );
      }
    } finally {
      this.loading = false;
    }
  }

  /**
   * Helper method to map account details to financial account data.
   */
  mapAccountDetailsToFinAccData(accountDetails) {
    return accountDetails.map((record) => {
      const { displayValue, apiValue } = this.mapOwnership(record.ownership);
      return {
        id: record.id,
        productName: record.productName,
        accountNumber: record.accountNumber,
        finAccountType: displayValue,
        signingAuthority:
          record.ownership === "Multi-party" ? record.signingAuthority : "",
        balance: record.balance,
        productId: record.productId,
        apiFinAccountType: apiValue
      };
    });
  }

  mapOwnership(ownership) {
    return this.ownershipMap[ownership] || { displayValue: "", apiValue: "" }; // Default to empty if not found
  }

  handleRowSelection(event) {
    const selectedAccounts = event.detail.selectedRows;

    this.showCheckbox = selectedAccounts.length > 1;

    this.selectedRows = [...selectedAccounts];
  }

  handleCasesCreated() {
    this.isCasesCreated = true;
  }
  handleErrorVisibilty() {
    this.hasError = false;
  }
  handleCancelAction() {
    this.dispatchEvent(new CloseActionScreenEvent());
  }
}
