import { LightningElement, track, wire, api } from "lwc";
import { CloseActionScreenEvent } from "lightning/actions";
const fields = ["Case.Account.OCV_ID__c", "Case.AccountId"];
import { getPicklistValues } from "lightning/uiObjectInfoApi";
import CLOSURE_REASON from "@salesforce/schema/Case.Closure_Reason__c";
import { getRecord } from "lightning/uiRecordApi";
/* IMPORT APEX METHODS */
import getFinancialAccountFabric from "@salesforce/apex/FinancialAccountController.getFinancialAccountFabric";
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
  { label: "Child Case Number", fieldName: "childCaseNumber" }
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
      this.accountDetails = await getFinancialAccountFabric({
        ocvId: this.customerOcvId,
        accountNumbers: []
      });
      this.handleAccountInformation(this.accountDetails);
      this.data = this.generateData(this.accountDetails);
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
    }
  }

  handleAccountInformation(finAccounts) {
    if (finAccounts) {
      finAccounts.forEach((account) => {
        //Determine the type of financial account
        if (account.FinServ__Status__c !== "Closed") {
          if (
            account.RecordType.DeveloperName === CHECKING_ACCOUNT_RT_APINAME
          ) {
            this.accountData.checking.push(account);
          } else if (
            account.RecordType.DeveloperName === SAVINGS_ACCOUNT_RT_APINAME
          ) {
            if (isS2Enabled() && isS2Account(account.Marketing_Code__c)) {
              this.accountData.savingss2.push(account);
              this.isS2AccountExist = true;
            } else if (!isS2Account(account.Marketing_Code__c)) {
              this.accountData.savings.push(account);
            }
          }
        } else if (isS2Account(account.Marketing_Code__c) && isS2Enabled()) {
          this.isS2AccountExist = true;
        }
      });
      this.sortFinancialAccounts(this.accountData.checking);
      this.sortFinancialAccounts(this.accountData.savings);
      this.sortFinancialAccounts(this.accountData.savingss2);
    }
    return finAccounts;
  }

  //Sorting the order of accounts based on account status and then based on opendate for similar account statuses.
  sortFinancialAccounts(arrOfAccounts) {
    return arrOfAccounts.sort((firstAccount, otherAccount) => {
      const statusOrder = FinancialAccountStatusForSorting.split(",");
      const ownershipOrder = FinancialAccountOwnershipForSorting.split(",");

      // Sort by status first
      if (firstAccount.FinServ__Status__c !== otherAccount.FinServ__Status__c) {
        return (
          statusOrder.indexOf(firstAccount.FinServ__Status__c) -
          statusOrder.indexOf(otherAccount.FinServ__Status__c)
        );
      }

      //Sort by Ownership keeping single party account at top to multi-party By Shivam, Oct'23
      if (
        firstAccount.FinServ__Status__c === otherAccount.FinServ__Status__c &&
        firstAccount.FinServ__Ownership__c !==
          otherAccount.FinServ__Ownership__c
      ) {
        return (
          ownershipOrder.indexOf(firstAccount.FinServ__Ownership__c) -
          ownershipOrder.indexOf(otherAccount.FinServ__Ownership__c)
        );
      }

      // Handle null openDate values
      if (
        firstAccount.FinServ__OpenDate__c === null &&
        otherAccount.FinServ__OpenDate__c !== null
      )
        return 1;
      if (
        otherAccount.FinServ__OpenDate__c === null &&
        firstAccount.FinServ__OpenDate__c !== null
      )
        return -1;

      // Sort by date next if status is same
      return (
        new Date(otherAccount.FinServ__OpenDate__c) -
        new Date(firstAccount.FinServ__OpenDate__c)
      );
    });
  }

  generateData(records) {
    return records.map((record) => {
      return {
        id: record.Id,
        productName:
          record.Marketing_Code__c === "SAVING01"
            ? "ANZ Save"
            : record.Marketing_Code__c === "TRANSACT01"
              ? "ANZ Plus"
              : "ANZ Flex Saver", // Will be using Product by querying FA
        accountNumber: record.FinServ__FinancialAccountNumber__c,
        accountType:
          record.FinServ__Ownership__c === "Single" ? "Sole" : "Joint", // Keeping the account type as 'Sole'
        balance: record.FinServ__Balance__c,
        finiancialAccountId: record.Id
      };
    });
  }

  handleCreateChildCases() {
    // Validate selected rows and mark invalid fields
    const { validRows, hasError } = this.validateRows(this.selectedRows);

    // If any validation error exists, stop the process
    if (hasError) {
      this.selectedRows = validRows;
      return;
    }
    // Call Apex method to create cases for valid rows
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
    console.log("validRows: " + JSON.stringify(validRows));
    const soleToIndividualMap = new Map();
    soleToIndividualMap.set("Sole", "Individual"); // Note to discuss with VK:  Added this becuase the default value is 'Sole' and it is causing an issue as accountType is restricted picklist
    // Map the valid rows to the format expected by the Apex method (CaseData format)
    const caseDataList = validRows.map((row) => ({
      status: "Open",
      intendedAccountName: row.intendedAccountName,
      intendedAccountBsb: row.intendedAccountBsb,
      intendedAccountNumber: row.intendedAccountNumber,
      closureReason: row.closureReason,
      accountType: soleToIndividualMap.get(row.accountType),
      productName: row.productName,
      accountId: this.accountId,
      finiancialAccountId: row.finiancialAccountId
    }));

    // Call the Apex method to create cases
    createCasesForAccounts({
      parentCaseId: this.recordId,
      caseDataFromLwc: caseDataList
    })
      .then((result) => {
        this.isCasesCreated = true;
        this.casesData = result.map((row) => ({
          childCaseNumber: row.CaseNumber,
          product: row.Account_Product__c,
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
