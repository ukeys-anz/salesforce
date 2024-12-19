import { LightningElement, track, wire, api } from "lwc";
import { CloseActionScreenEvent } from "lightning/actions";
const fields = ["Case.Account.OCV_ID__c", "Case.AccountId"];
import { getPicklistValues } from "lightning/uiObjectInfoApi";
import CLOSURE_REASON from "@salesforce/schema/Case.Closure_Reason__c";
import { getRecord } from "lightning/uiRecordApi";
/* IMPORT APEX METHODS */
import getFilteredFinancialAccounts from "@salesforce/apex/AccountClosureWizardController.getFilteredFinancialAccounts";
import getFinancialAccountDB from "@salesforce/apex/FinancialAccountController.getFinancialAccountDB";
import createCasesForAccounts from "@salesforce/apex/AccountClosureWizardController.createCasesForAccounts";
import { handleErrorShowToast, isS2Account, isS2Enabled } from "c/utils";
import {
  CHECKING_ACCOUNT_RT_APINAME,
  SAVINGS_ACCOUNT_RT_APINAME
} from "c/financialAccountParent";

const columns = [
  { label: "Product Name", fieldName: "productName" },
  { label: "Account Number", fieldName: "accountNumber" },
  { label: "Account Type", fieldName: "finAccountType" },
  { label: "Balance", fieldName: "balance", type: "currency" }
];

const caseColumns = [
  { label: "Product", fieldName: "product" },
  { label: "Account Number", fieldName: "accountNumber" },
  { label: "Account Type", fieldName: "accountType" },
  {
    label: "Child Case Number",
    fieldName: "childCaseNumberUrl",
    type: "url",
    typeAttributes: { label: { fieldName: "childCaseNumber" } }
  }
];

export default class AccountClosureWizard extends LightningElement {
  @api recordId;
  customerOcvId;
  accountId;
  columns = columns;
  caseColumns = caseColumns;
  showCheckbox = false;
  copyToAll = false;
  loading = false;
  isCasesCreated = false;
  @track selectedRows = [];
  @track casesData = [];
  accountData = {
    checking: [],
    savings: [],
    savingss2: []
  };
  accountDetails = [];
  closureReasonOptions = []; // To store picklist options

  @wire(getRecord, { recordId: "$recordId", fields })
  wiredData({ data }) {
    if (data) {
      this.customerOcvId =
        data.fields?.Account?.value?.fields?.OCV_ID__c?.value;
      this.accountId = data.fields?.AccountId?.value;
    }
  }

  // Get Closure Reason Options
  @wire(getPicklistValues, {
    recordTypeId: "0122P0000004SC2QAM",
    fieldApiName: CLOSURE_REASON
  })
  wiredPicklist({ data }) {
    if (data) {
      const picklistValues = data.values.map((object) => {
        return { label: object.label, value: object.value };
      });
      this.closureReasonOptions = picklistValues;
    }
  }
  get closureResonValues() {
    return [
      { label: "--None--", value: "--None--" },
      ...this.closureReasonOptions
    ];
  }

  connectedCallback() {
    this.getFinancialAccount(); // Function call needs to be discuss with VK
  }

  handleRowSelection(event) {
    const selectedAccounts = event.detail.selectedRows;
    // Update the checkbox visibility based on selected row count
    this.showCheckbox = selectedAccounts.length > 1;
    // Create a map for fast lookups of previously selected rows
    const selectedRowsMap = new Map(
      this.selectedRows.map((row) => [row.id, row])
    );
    // Merge the selected rows with existing rows based on id
    this.selectedRows = selectedAccounts.map((row) => {
      const existingRow = selectedRowsMap.get(row.id);
      // Merge selected row with existing data, preserving known fields
      return {
        ...row,
        ...(existingRow && this.mergeRowData(existingRow))
      };
    });
  }

  // Helper function to merge specific fields from an existing row
  mergeRowData(existingRow) {
    return {
      closureReason: existingRow.closureReason,
      intendedAccountName: existingRow.intendedAccountName,
      intendedAccountBsb: existingRow.intendedAccountBsb,
      intendedAccountNumber: existingRow.intendedAccountNumber,
      isClosureReasonInvalid: existingRow.isClosureReasonInvalid,
      isAccountNameInvalid: existingRow.isAccountNameInvalid,
      isaccountBsbInvalid: existingRow.isaccountBsbInvalid,
      isAccountNumberInvalid: existingRow.isAccountNumberInvalid
    };
  }

  handleInputChange(event) {
    const { name, value } = event.target;
    const rowId = event.target.dataset.id;

    // Update the corresponding field for the selected row.
    this.selectedRows = this.selectedRows.map((row) => {
      if (row.id === rowId) {
        row[name] = value; // Update the field value.
        row[`is${this.capitalize(name)}Invalid`] = false; // Reset validation flag.

        // If the user selected 'copy to all', update other rows.
        if (this.copyToAll && this.selectedRows[0].id === rowId) {
          this.cascadeFields(name, value);
        }
      }
      return row;
    });
  }

  handleFieldChange(event) {
    const { rowId, name, value } = event.detail;

    // Update the row data based on the field change
    this.selectedRows = this.selectedRows.map((row) => {
      if (row.id === rowId) {
        row[name] = value; // Update the field value
        row[`is${this.capitalize(name)}Invalid`] = false; // Reset validation flag
      }
      return row;
    });
  }

  // Capitalizes the field name for validation (e.g., "closureReason" -> "ClosureReason")
  capitalize(string) {
    return string.charAt(0).toUpperCase() + string.slice(1);
  }

  handleUseSameDetailsCheckbox(event) {
    this.copyToAll = event.target.checked;
    if (this.copyToAll) {
      const firstRow = this.selectedRows[0];
      if (firstRow) {
        [
          "closureReason",
          "intendedAccountName",
          "intendedAccountBsb",
          "intendedAccountNumber"
        ].forEach((field) => {
          this.cascadeFields(field, firstRow[field]);
        });
      }
    }
  }

  cascadeFields(field, value) {
    this.selectedRows = this.selectedRows.map((row, index) => {
      if (index !== 0) {
        row[field] = value;
      }
      return row;
    });
  }

  async getFinancialAccount() {
    try {
      //Attempt to get the latest account details from fabric
      // this.loading = true;
      this.accountDetails = await getFilteredFinancialAccounts({
        ocvId: this.customerOcvId,
        accountNumbers: []
      });
      if (this.accountDetails) {
        //this.handleAccountInformation(this.accountDetails);
        this.accountDetails.map((record) => ({
          id: record.id,
          productName: record.productName,
          accountNumber: record.accountNumber,
          finAccountType: record.ownership,
          balance: record.balance,
          productId: record.productId
        }));
      }
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
      this.accountDetails = await getFinancialAccountDB({
        ownerId: this.customerOcvId,
        recordTypeDeveloperNames: [
          CHECKING_ACCOUNT_RT_APINAME,
          SAVINGS_ACCOUNT_RT_APINAME
        ]
      });
      this.handleAccountInformation(this.accountDetails);
      this.accountDetails.map((record) => ({
        id: record.Id,
        productName: record.FinServ__ProductName__r.Name,
        accountNumber: record.FinServ__FinancialAccountNumber__c,
        finAccountType: record.FinServ__Ownership__c,
        balance: record.FinServ__Balance__c,
        finiancialAccountId: record.Id,
        productId: record.FinServ__ProductName__c
      }));
    }
    //this.loading = false;
  }

  // TO DO: DISCUSS THIS WITH VK and KOPAL WHETHER THIS IS NEEDED OR NOT
  handleAccountInformation(finAccounts) {
    if (finAccounts) {
      finAccounts.forEach((account) => {
        //Determine the type of financial account
        if (account.status !== "Closed") {
          if (account.recodTypeName === CHECKING_ACCOUNT_RT_APINAME) {
            this.accountData.checking.push(account);
          } else if (account.recodTypeName === SAVINGS_ACCOUNT_RT_APINAME) {
            if (isS2Enabled() && isS2Account(account.marketingCode)) {
              this.accountData.savingss2.push(account);
              this.isS2AccountExist = true;
            } else if (!isS2Account(account.marketingCode)) {
              this.accountData.savings.push(account);
            }
          }
        } else if (isS2Account(account.marketingCode) && isS2Enabled()) {
          this.isS2AccountExist = true;
        }
      });
      // this.sortFinancialAccounts(this.accountData.checking);
      // this.sortFinancialAccounts(this.accountData.savings);
      // this.sortFinancialAccounts(this.accountData.savingss2);
    }
    return finAccounts;
  }

  // // TO DO: DISCUSS THIS WITH VK and KOPAL WHETHER THIS IS NEEDED OR NOT

  // //Sorting the order of accounts based on account status and then based on opendate for similar account statuses.
  // sortFinancialAccounts(arrOfAccounts) {
  //   return arrOfAccounts.sort((firstAccount, otherAccount) => {
  //     const statusOrder = FinancialAccountStatusForSorting.split(",");
  //     const ownershipOrder = FinancialAccountOwnershipForSorting.split(",");

  //     // Sort by status first
  //     if (firstAccount.status !== otherAccount.status) {
  //       return (
  //         statusOrder.indexOf(firstAccount.status) -
  //         statusOrder.indexOf(otherAccount.status)
  //       );
  //     }

  //     //Sort by Ownership keeping single party account at top to multi-party By Shivam, Oct'23
  //     if (
  //       firstAccount.status === otherAccount.status &&
  //       firstAccount.ownership !== otherAccount.ownership
  //     ) {
  //       return (
  //         ownershipOrder.indexOf(firstAccount.ownership) -
  //         ownershipOrder.indexOf(otherAccount.ownership)
  //       );
  //     }
  //   });
  // }

  handleCreateChildCases() {
    const { validRows, hasError } = this.validateRows(this.selectedRows);
    if (hasError) {
      this.selectedRows = validRows;
      return;
    }
    this.createCasesInApex(validRows);
  }

  // Method to validate all rows
  validateRows(rows) {
    let hasError = false;
    const validRows = rows.map((row) => {
      const invalidFields = this.validateRowFields(row);
      if (Object.values(invalidFields).includes(true)) {
        hasError = true;
      }
      return { ...row, ...invalidFields };
    });

    return { validRows, hasError };
  }

  // Method to check the validity of each row's fields
  validateRowFields(row) {
    return {
      isClosureReasonInvalid: !row.closureReason,
      isAccountNameInvalid: !row.intendedAccountName,
      isaccountBsbInvalid: !row.intendedAccountBsb,
      isAccountNumberInvalid: !row.intendedAccountNumber
    };
  }

  // Method to call Apex and create cases
  async createCasesInApex(validRows) {
    // Map the valid rows to the format expected by the Apex method (CaseData format)
    this.loading = true;
    const caseDataList = validRows.map((row) => ({
      intendedAccountName: row.intendedAccountName,
      intendedAccountBsb: row.intendedAccountBsb,
      intendedAccountNumber: row.intendedAccountNumber,
      closureReason: row.closureReason,
      accountNumber: row.accountNumber,
      accountId: this.accountId,
      accountType: row.accountType,
      productName: row.productName,
      finiancialAccountId: row.id,
      productId: row.productId
    }));
    try {
      let result = await createCasesForAccounts({
        parentCaseId: this.recordId,
        caseInputs: caseDataList
      });
      if (result) {
        this.isCasesCreated = true;
        this.casesData = result.map((row) => ({
          childCaseNumberUrl: "/" + row.Id,
          childCaseNumber: row.CaseNumber,
          // product: row.Product__r.Name,
          accountNumber:
            row.FinServ__FinancialAccount__r.FinServ__FinancialAccountNumber__c,
          accountType: row.Account_Type__c
        }));
      }
    } catch (error) {
      console.error("Error creating cases:", JSON.stringify(error));
    }
    this.loading = false;
  }

  handleCancel() {
    this.dispatchEvent(new CloseActionScreenEvent());
  }
}
