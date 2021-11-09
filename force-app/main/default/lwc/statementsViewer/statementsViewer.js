import { LightningElement, api, track, wire } from "lwc";
import { getRecord } from "lightning/uiRecordApi";

import hasViewStatementsPermission from "@salesforce/customPermission/ANZx_View_Statements";
import getStatements from "@salesforce/apex/StatementAPIRepository.getStatementsAura";
import getStatementUrl from "@salesforce/apex/StatementAPIRepository.getStatementUrlAura";

import FINANCIAL_ACCOUNT_NUMBER_FIELD from "@salesforce/schema/FinServ__FinancialAccount__c.FinServ__FinancialAccountNumber__c";
import FINANCIAL_ACCOUNT_PRIMARY_OWNER_FIELD from "@salesforce/schema/FinServ__FinancialAccount__c.FinServ__PrimaryOwner__c";
import FINANCIAL_ACCOUNT_ID_FIELD from "@salesforce/schema/FinServ__FinancialAccount__c.Id";
import PRODUCT_NAME_FIELD from "@salesforce/schema/FinServ__FinancialAccount__c.Product_Name__c";
import OCV_ID_FIELD from "@salesforce/schema/FinServ__FinancialAccount__c.OCV_ID__c";

const FIELDS = [
  FINANCIAL_ACCOUNT_NUMBER_FIELD,
  FINANCIAL_ACCOUNT_PRIMARY_OWNER_FIELD,
  FINANCIAL_ACCOUNT_ID_FIELD,
  PRODUCT_NAME_FIELD,
  OCV_ID_FIELD
];

const columns = [
  {
    label: "Account",
    fieldName: "statementId",
    type: "button",
    typeAttributes: {
      label: { fieldName: "productName" },
      name: "view_statement",
      title: "View Statement",
      variant: "base"
    }
  },
  { label: "Start Date", fieldName: "startDate", sortable: true },
  { label: "End Date", fieldName: "endDate" }
];

const ERROR_UNKNOWN_TITLE = "An error has occurred.";

export default class StatementsViewer extends LightningElement {
  @api recordId;
  @track statements;

  accountId;
  financialAccountId;
  ocvId;
  productName;

  columns = columns;
  sortedBy;
  defaultSortDirection = "desc";
  sortDirection = "desc";
  isLoading = true;
  error;

  get hasPermissionIssue() {
    return !hasViewStatementsPermission;
  }

  get hasError() {
    return this.error !== undefined && this.error !== null;
  }

  @wire(getRecord, {
    recordId: "$recordId",
    fields: FIELDS
  })
  wiredFinancialAccount({ data, error }) {
    if (data) {
      const accountNumber =
        data.fields.FinServ__FinancialAccountNumber__c.value;
      this.accountId = data.fields.FinServ__PrimaryOwner__c.value;
      this.financialAccountId = data.fields.Id.value;
      this.productName = data.fields.Product_Name__c.value;
      this.ocvId = data.fields.OCV_ID__c.value;
      this.getStatementsData(this.ocvId, accountNumber);
    } else if (error) {
      this.handleError(error);
    }
  }

  async handleRowAction(event) {
    this.isLoading = true;

    try {
      const row = event.detail.row;

      const additionalDetails = {
        accountId: this.accountId,
        financialAccountId: this.financialAccountId,
        fromDate: row.startDate,
        toDate: row.endDate,
        statementType: this.productName
      };

      const signedUrl = await getStatementUrl({
        ocvId: this.ocvId,
        statementId: row.statementId,
        additionalDetails: additionalDetails
      });

      window.open(signedUrl, "_blank");
    } catch (error) {
      this.handleError(error);
    } finally {
      this.isLoading = false;
    }
  }

  async getStatementsData(ocvId, accountNumber) {
    try {
      const { statements } = await getStatements({
        ocvId,
        accountNumber
      });

      if (!statements || (statements && !Array.isArray(statements))) {
        throw new Error("Error: Unknown data.");
      }

      if (statements.length === 0) {
        this.statements = [];
        this.error = "There are currently no statements for this account.";
      } else if (statements.length > 0) {
        const formattedData = this.formatStatements(
          statements,
          this.productName
        );
        this.sortStatements(formattedData, "startDate", "desc");
      }
    } catch (error) {
      this.handleError(error);
    } finally {
      this.isLoading = false;
    }
  }

  formatStatements(data, productName) {
    return data.map((item) => {
      const statement = {};
      statement.statementId = item.statementId;
      statement.startDate = this.formatDate(item.statementFrom);
      statement.endDate = this.formatDate(item.statementTo);
      statement.productName = productName;

      return statement;
    });
  }

  formatDate(data) {
    return `${data.day.value}/${data.month.value}/${data.year.value}`;
  }

  handleSort(event) {
    const { fieldName: sortedBy, sortDirection } = event.detail;
    this.sortStatements(this.statements, sortedBy, sortDirection);
  }

  sortStatements(data, sortedBy, sortDirection) {
    const cloneData = [...data];

    cloneData.sort(this.sortBy(sortedBy, sortDirection === "asc" ? 1 : -1));

    this.statements = cloneData;
    this.sortDirection = sortDirection;
    this.sortedBy = sortedBy;
  }

  sortBy(field, reverse, primer) {
    const key = primer
      ? function (x) {
          return primer(x[field]);
        }
      : function (x) {
          return x[field];
        };

    return function (a, b) {
      a = key(a);
      b = key(b);
      return reverse * ((a > b) - (b > a));
    };
  }

  handleError(error) {
    let msg = ERROR_UNKNOWN_TITLE;

    if (error.message) {
      msg = error.message;
    }

    this.error = msg;
  }
}
