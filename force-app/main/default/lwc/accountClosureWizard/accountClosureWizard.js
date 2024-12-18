import { LightningElement, track, wire, api } from "lwc";
import { CloseActionScreenEvent } from "lightning/actions";
const fields = ["Case.Account.OCV_ID__c", "Case.AccountId"];
import { getPicklistValues } from "lightning/uiObjectInfoApi";
import CLOSURE_REASON from "@salesforce/schema/Case.Closure_Reason__c";
import { getRecord } from "lightning/uiRecordApi";
import { NavigationMixin } from "lightning/navigation";
/* IMPORT APEX METHODS */
import getFilteredFinancialAccounts from "@salesforce/apex/AccountClosureWizardController.getFilteredFinancialAccounts";
import getFinancialAccountDB from "@salesforce/apex/FinancialAccountController.getFinancialAccountDB";
import FinancialAccountStatusForSorting from "@salesforce/label/c.FinancialAccountStatusForSorting";
import FinancialAccountOwnershipForSorting from "@salesforce/label/c.FinancialAccountOwnershipForSorting";
import createCasesForAccounts from "@salesforce/apex/AccountClosureWizardController.createCasesForAccounts";
import { handleErrorShowToast, isS2Account, isS2Enabled } from "c/utils";
import {
  CHECKING_ACCOUNT_RT_APINAME,
  SAVINGS_ACCOUNT_RT_APINAME
} from "c/financialAccountParent";

const columns = [
  { label: "Product Name", fieldName: "productName" },
  { label: "Account Number", fieldName: "accountNumber" },
  { label: "Account Type", fieldName: "accountType" },
  { label: "Balance", fieldName: "balance", type: "currency" }
];

const caseColumns = [
  { label: "Product", fieldName: "product" },
  { label: "Account Number", fieldName: "accountNumber" },
  { label: "Account Type", fieldName: "accountType" },
  { label: "Case Record Id", fieldName: "caseRecordId" },
  {
    label: "Child Case Number",
    fieldName: "childCaseNumber",
    type: "button",
    typeAttributes: {
      label: { fieldName: "childCaseNumber" },
      variant: "base", // Styling for the button
      name: "view_case", // Action name to handle clicks
      disabled: false
    }
  }
];

export default class AccountClosureWizard extends LightningElement {
  @api recordId;
  customerOcvId;
  accountId;
  data = [];
  columns = columns;
  caseColumns = caseColumns;
  showCheckbox = false;
  @track selectedRows = [];
  @track casesData = [];
  @track isCasesCreated = false;
  @track copyToAll = false;
  accountData = {
    checking: [],
    savings: [],
    savingss2: []
  };
  accountDetails = [];
  closureReasonOptions = []; // To store picklist options
  accountDetailsFromDb = false;

  @wire(getRecord, { recordId: "$recordId", fields })
  wiredData({ data, error }) {
    if (data) {
      this.customerOcvId =
        data.fields?.Account?.value?.fields?.OCV_ID__c?.value;
      this.accountId = data.fields?.AccountId?.value;
    } else if (error) {
      console.error("Error in Fetching OCVId -> " + JSON.stringify(error));
    }
  }

  // Get Closure Reason Options
  // The following recordTypeId is a "Master Record Picklist ID" and can be hardcoded for all orgs
  @wire(getPicklistValues, {
    recordTypeId: "0122P0000004SC2QAM",
    fieldApiName: CLOSURE_REASON
  })
  wiredPicklist({ data, error }) {
    if (data) {
      const picklistValues = data.values.map((object) => {
        return { label: object.label, value: object.value };
      });
      this.closureReasonOptions = picklistValues;
    } else if (error) {
      console.log(
        "Error in Fetching Picklist Values -> " + JSON.stringify(error)
      );
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

    // Update the checkbox visibility based on selected row count.
    this.showCheckbox = selectedAccounts.length > 1;

    // Update the selectedRows array with merged data, preserving user-entered values.
    this.selectedRows = selectedAccounts.map((row) => {
      const existingRow = this.selectedRows.find((r) => r.id === row.id);
      // Merge and preserve any previous user-entered data (closureReason, intendedAccountName, etc.).
      return {
        ...row,
        ...(existingRow && {
          closureReason: existingRow.closureReason,
          intendedAccountName: existingRow.intendedAccountName,
          intendedAccountBsb: existingRow.intendedAccountBsb,
          intendedAccountNumber: existingRow.intendedAccountNumber,
          isClosureReasonInvalid: existingRow.isClosureReasonInvalid,
          isAccountNameInvalid: existingRow.isAccountNameInvalid,
          isaccountBsbInvalid: existingRow.isaccountBsbInvalid,
          isAccountNumberInvalid: existingRow.isAccountNumberInvalid
        })
      };
    });
  }

  // Handle the button click event (case record navigation)   TO DO: THIS NEEDS TO BE FIX
  handleCaseRowAction(event) {
    // this.dispatchEvent(new CloseActionScreenEvent());
    const actionName = event.detail.action.name;
    const row = event.detail.row;
    console.log("actionName " + actionName);
    // Check if the clicked action is 'view_case'
    if (actionName === "view_case") {
      // Use the NavigationMixin to open the case record
      console.log("Case Record Id " + row.caseRecordId);
      this.navigateToCaseRecord(row.caseRecordId);
    }
  }

  // Method to navigate to a specific case record
  navigateToCaseRecord(caseRecordId) {
    // Navigation to the case record page in Salesforce

    this[NavigationMixin.Navigate]({
      type: "standard__recordPage",
      attributes: {
        recordId: caseRecordId,
        objectApiName: "Case",
        actionName: "view"
      }
    });
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
      this.accountDetails = await getFilteredFinancialAccounts({
        ocvId: this.customerOcvId,
        accountNumbers: []
      });
      this.handleAccountInformation(this.accountDetails);
      this.data = this.accountDetails.map((record) => ({
        id: record.id,
        productName: record.productName,
        accountNumber: record.accountNumber,
        accountType: record.ownership,
        balance: record.balance,
        productId: record.productId
      }));
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
      this.accountDetailsFromDb = true;
      this.accountDetails = await getFinancialAccountDB({
        ownerId: this.customerOcvId,
        recordTypeDeveloperNames: [
          CHECKING_ACCOUNT_RT_APINAME,
          SAVINGS_ACCOUNT_RT_APINAME
        ]
      });
      this.handleAccountInformation(this.accountDetails);
      this.data = this.accountDetails.map((record) => {
        return {
          id: record.Id,
          productName: record.FinServ__ProductName__r.Name,
          accountNumber: record.FinServ__FinancialAccountNumber__c,
          accountType: record.Ownership__c,
          balance: record.FinServ__Balance__c,
          finiancialAccountId: record.Id,
          productId: record.FinServ__ProductName__c
        };
      });
      console.log("financial account data " + JSON.stringify(this.data));
    }
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
  createCasesInApex(validRows) {
    // Map the valid rows to the format expected by the Apex method (CaseData format)
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
    // Call the Apex method to create cases
    createCasesForAccounts({
      parentCaseId: this.recordId,
      caseDataFromLwc: caseDataList
    })
      .then((result) => {
        this.isCasesCreated = true;
        this.casesData = result.map((row) => ({
          caseRecordId: row.Id,
          childCaseNumber: row.CaseNumber,
          // product: row.Product__r.Name,
          accountNumber:
            row.FinServ__FinancialAccount__r.FinServ__FinancialAccountNumber__c,
          accountType: row.Account_Type__c
        }));
      })
      .catch((error) => {
        console.error("Error creating cases:", JSON.stringify(error));
      });
  }

  handleCancel() {
    this.dispatchEvent(new CloseActionScreenEvent());
  }

  capitalize(string) {
    return string.charAt(0).toUpperCase() + string.slice(1);
  }
}
