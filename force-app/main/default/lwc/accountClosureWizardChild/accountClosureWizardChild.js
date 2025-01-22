import { LightningElement, track, wire, api } from "lwc";
import { getPicklistValues } from "lightning/uiObjectInfoApi";
import CLOSURE_REASON from "@salesforce/schema/Case.Closure_Reason__c";
import createCasesForAccounts from "@salesforce/apex/AccountClosureWizardController.createCasesForAccounts";

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

export default class AccountClosureWizardChild extends LightningElement {
  @api recordId;
  @api accountId;
  @api showCheckbox;
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

  @track caseData = [];
  @track closureReasonOptions = [];
  caseColumns = caseColumns;
  copyToAll = false;
  loading = false;
  isCasesCreated = false;
  hasError = false;
  errorMsg;

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
    // Only add "--None--" option if no picklist values are available
    return this.closureReasonOptions.length === 0
      ? [{ label: "--None--", value: "--None--" }]
      : [...this.closureReasonOptions];
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
      isAccountNumberInvalid: existingRow.isAccountNumberInvalid
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

  handleInputChange(event) {
    const { name, value } = event.target;
    const rowId = event.target.dataset.id;

    // Update the corresponding field for the selected row.
    this._selectedRows = this._selectedRows.map((row) => {
      if (row.id === rowId) {
        row[name] = value; // Update the field value.
        row[`is${this.capitalize(name)}Invalid`] = false; // Reset validation flag.

        // If the user selected 'copy to all', update other rows.
        if (this.copyToAll && this._selectedRows[0].id === rowId) {
          this.cascadeFields(name, value);
        }
      }
      return row;
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
        "intendedAccountNumber"
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
      "Child cases could not be created. Please enter forwarding account details for all accounts";
    const { validRows, isFieldIsBlank } = this.validateRows(this._selectedRows);
    this._selectedRows = validRows;
    this.setErrorVisibility(isFieldIsBlank, this.errorMsg);

    if (!isFieldIsBlank) {
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
    let isFieldIsBlank = false;
    const validRows = rows.map((row) => {
      const invalidFields = this.validateRowFields(row);
      if (Object.values(invalidFields).includes(true)) {
        isFieldIsBlank = true;
      }
      return { ...row, ...invalidFields };
    });
    return { validRows, isFieldIsBlank };
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
          product: row.Product__c,
          accountNumber:
            row.FinServ__FinancialAccount__r.FinServ__FinancialAccountNumber__c,
          accountType:
            row.Account_Type__c === "Individual" ? "Sole" : row.Account_Type__c
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
