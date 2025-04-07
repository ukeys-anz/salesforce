import { LightningElement, track, wire, api } from "lwc";
import { getPicklistValues } from "lightning/uiObjectInfoApi";
import { getRecord } from "lightning/uiRecordApi";
import COP_REASON from "@salesforce/schema/Case.Opt_Out_Reason__c";
import CLOSURE_REASON from "@salesforce/schema/Case.Closure_Reason__c";
import createCasesForAccounts from "@salesforce/apex/CaseGroupController.createChildCasesForFinAccounts";
import confirmationOfPayeeDOM from "./confirmationOfPayeeDOM.html";
import accountClosureDOM from "./accountClosureDOM.html";

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

const fields = ["Case.RecordTypeId"];

const ISSUE_TYPE_ACCOUNT_CLOSURE = "Account Closure";
const ISSUE_TYPE_CONFIRMATION_OF_PAYEE_OPT_IN = "Confirmation of Payee Opt-In";
const ISSUE_TYPE_CONFIRMATION_OF_PAYEE_OPT_OUT =
  "Confirmation of Payee Opt-Out";

export default class AccountClosureWizardChild extends LightningElement {
  @api recordId;
  @api accountId;
  @api showCheckbox;
  @api issueType;
  errorMessageForValidAccountName;
  errorMessageForValidBsb;
  errorMessageForValidAccountNumber;
  errorMessageForValidClosureReason;
  @track _selectedRows = [];
  @api
  set selectedRows(value) {
    if (value) {
      this.handleRowMerge(value);
    }
  }
  get selectedRows() {
    return this._selectedRows || [];
  }

  get isOptOut() {
    return this.issueType === "Confirmation of Payee Opt-Out" ? true : false;
  }

  @track caseData = [];
  @track closureReasonOptions = [];
  @track copReasonOptions = [];
  caseColumns = caseColumns;
  copyToAll = false;
  loading = false;
  isCasesCreated = false;
  hasError = false;
  errorMsg;
  recordTypeId;

  templateMap = {
    [ISSUE_TYPE_ACCOUNT_CLOSURE]: accountClosureDOM,
    [ISSUE_TYPE_CONFIRMATION_OF_PAYEE_OPT_IN]: confirmationOfPayeeDOM,
    [ISSUE_TYPE_CONFIRMATION_OF_PAYEE_OPT_OUT]: confirmationOfPayeeDOM
  };

  render() {
    return this.templateMap[this.issueType];
  }

  @wire(getRecord, {
    recordId: "$recordId",
    fields
  })
  copCaseRecord({ data }) {
    if (data) {
      this.recordTypeId = data.recordTypeId;
    }
  }

  // Get Closure Reason Options
  @wire(getPicklistValues, {
    recordTypeId: "0122P0000004SC2QAM",
    fieldApiName: CLOSURE_REASON
  })
  wiredPicklistClosure({ data }) {
    if (data) {
      const picklistValues = data.values.map((object) => {
        return { label: object.label, value: object.value };
      });
      this.closureReasonOptions = picklistValues;
    }
  }

  // Get Closure Reason Options
  @wire(getPicklistValues, {
    recordTypeId: "$recordTypeId",
    fieldApiName: COP_REASON
  })
  wiredPicklistCOP({ data }) {
    if (data) {
      const picklistValues = data.values.map((object) => {
        return { label: object.label, value: object.value };
      });
      this.copReasonOptions = picklistValues;
    }
  }

  get closureResonValues() {
    return this.closureReasonOptions.length === 0
      ? [{ label: "--None--", value: "--None--" }]
      : [...this.closureReasonOptions];
  }

  get copResonValues() {
    return this.copReasonOptions.length === 0
      ? [{ label: "--None--", value: "--None--" }]
      : [...this.copReasonOptions];
  }

  mergeRowData(existingRow) {
    return {
      closureReason: existingRow.closureReason,
      intendedAccountName: existingRow.intendedAccountName,
      intendedAccountBsb: existingRow.intendedAccountBsb,
      intendedAccountNumber: existingRow.intendedAccountNumber,
      isClosureReasonInvalid: existingRow.isClosureReasonInvalid,
      isAccountNameInvalid: existingRow.isAccountNameInvalid,
      isaccountBsbInvalid: existingRow.isaccountBsbInvalid,
      isAccountNumberInvalid: existingRow.isAccountNumberInvalid,
      copReason: existingRow.copReason,
      copStatus: existingRow.accountStatusCOP,
      updateAccountStatusCOP: existingRow.updateAccountStatusCOP
    };
  }

  handleRowMerge(newRows) {
    const selectedRowsMap = new Map(
      this.selectedRows?.map((row) => [row.id, row])
    );

    this._selectedRows = newRows.map((row) => {
      const existingRow = selectedRowsMap.get(row.id);
      const mergedRow = {
        ...row,
        ...(existingRow && this.mergeRowData(existingRow))
      };
      return mergedRow;
    });
  }

  handleFieldChange(event) {
    const { rowId, name, value } = event.detail;

    // Update the row data based on the field change
    this._selectedRows = this._selectedRows.map((row) => {
      if (row.id === rowId) {
        row[name] = value; // Update the field value
        row[`is${this.capitalize(name)}Invalid`] = false; // Reset validation flag
      }
      return row;
    });

    if (this.copyToAll) {
      this.realTimeFieldsUpdate();
    }
  }

  // Capitalizes the field name for validation (e.g., "closureReason" -> "ClosureReason")
  capitalize(string) {
    return string.charAt(0).toUpperCase() + string.slice(1);
  }

  handleUseSameDetailsCheckbox(event) {
    this.copyToAll = event.target.checked;
    if (this.copyToAll) {
      this.realTimeFieldsUpdate();
    }
  }

  realTimeFieldsUpdate() {
    const firstRow = this._selectedRows[0];
    if (firstRow) {
      [
        "closureReason",
        "intendedAccountName",
        "intendedAccountBsb",
        "intendedAccountNumber",
        "copReason"
      ].forEach((field) => {
        this.cascadeFields(field, firstRow[field]);
      });
    }
  }

  cascadeFields(field, value) {
    this._selectedRows = this._selectedRows.map((row, index) => {
      if (index !== 0) {
        const updatedRow = { ...row, [field]: value };
        return updatedRow;
      }
      return row;
    });
  }

  handleCreateChildCases() {
    this.errorMsg =
      "Child case could not be created. Please complete all required fields and meet the specified criteria.";
    const { validRows, isFieldIsValid } = this.validateRows(this._selectedRows);
    this._selectedRows = validRows;
    this.setErrorVisibility(isFieldIsValid, this.errorMsg);
    if (!isFieldIsValid) {
      this.createChildCases(validRows);
    }
  }

  setErrorVisibility(showError, errorMessage) {
    this.dispatchEvent(
      new CustomEvent("errorvisibilty", {
        detail: { showError: showError, errorMessage: errorMessage }
      })
    );
  }

  // Method to validate all rows
  validateRows(rows) {
    let isFieldIsValid = false;
    const validRows = rows.map((row) => {
      const invalidFields = this.validateRowFields(row);
      if (Object.values(invalidFields).includes(true)) {
        isFieldIsValid = true;
      }
      if (invalidFields.isClosureReasonInvalid) {
        this.errorMessageForValidClosureReason = "This field is required.";
      }
      if (invalidFields.isAccountNameInvalid) {
        this.errorMessageForValidAccountName = row.intendedAccountName
          ? "Forwarding Account Name must be less than 255 characters long"
          : "This field is required.";
      }
      if (invalidFields.isaccountBsbInvalid) {
        this.errorMessageForValidBsb = row.intendedAccountBsb
          ? "Forwarding Account BSB must be 4-6 numerical characters long"
          : "This field is required.";
      }
      if (invalidFields.isAccountNumberInvalid) {
        this.errorMessageForValidAccountNumber = row.intendedAccountNumber
          ? "Forwarding Account Number must be between 6-23 numerical characters long"
          : "This field is required.";
      }

      return { ...row, ...invalidFields };
    });

    return { validRows, isFieldIsValid };
  }

  // Method to check the validity of each row's fields
  validateRowFields(row) {
    switch (this.issueType) {
      case ISSUE_TYPE_ACCOUNT_CLOSURE:
        return {
          isClosureReasonInvalid: !row.closureReason,
          isAccountNameInvalid:
            !row.intendedAccountName || row.intendedAccountName.length > 255,
          isaccountBsbInvalid:
            !row.intendedAccountBsb ||
            !/^\d{4,6}$/.test(row.intendedAccountBsb),
          isAccountNumberInvalid:
            !row.intendedAccountNumber ||
            !/^\d{6,23}$/.test(row.intendedAccountNumber)
        };

      case ISSUE_TYPE_CONFIRMATION_OF_PAYEE_OPT_OUT:
        return {
          iscopReasonInvalid: !row.copReason
        };

      default:
        return row;
    }
  }

  // Method to call Apex and create cases
  async createChildCases(validRows) {
    // Map the valid rows to the format expected by the Apex method (CaseData format)
    this.loading = true;
    const caseDataList = validRows.map((row) => ({
      intendedAccountName: row.intendedAccountName,
      intendedAccountBsb: row.intendedAccountBsb,
      intendedAccountNumber: row.intendedAccountNumber,
      closureReason: row.closureReason,
      accountNumber: row.accountNumber,
      accountId: this.accountId,
      accountType: row.apiFinAccountType,
      productName: row.productName,
      financialAccountId: row.id,
      productId: row.productId,
      copReason: row.copReason,
      issueType: this.issueType,
      parentCaseId: this.recordId,
      accountingSystem: row.accountingSystem,
      copStatus: row.accountStatusCOP
    }));
    try {
      let result = await createCasesForAccounts({
        parentCaseId: this.recordId,
        childCaseInputs: caseDataList
      });
      if (result.length > 0) {
        this.isCasesCreated = true;
        this.casesData = result.map((row) => ({
          childCaseNumberUrl: "/" + row.Id,
          childCaseNumber: "#" + row?.CaseNumber || null,
          product: row?.Product?.Name || null,
          accountNumber:
            row?.FinServ__FinancialAccount__r
              ?.FinServ__FinancialAccountNumber__c || null,
          accountType:
            row?.Account_Type__c === "Individual"
              ? "Sole"
              : row?.Account_Type__c
        }));
        this.dispatchEvent(new CustomEvent("casescreated"));
      }
    } catch (error) {
      this.handleError();
    } finally {
      this.loading = false;
    }
  }

  handleError() {
    this.hasError = true;
    this.errorMsg =
      "Please try again. Raise a fault through TechAssist if the problem persists.";
    this.setErrorVisibility(this.hasError, this.errorMsg);
  }

  handleCancel() {
    this.dispatchEvent(new CustomEvent("cancel"));
  }
}
