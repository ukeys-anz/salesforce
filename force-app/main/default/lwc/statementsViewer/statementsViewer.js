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
import TYPE_FIELD from "@salesforce/schema/FinServ__FinancialAccount__c.FinServ__FinancialAccountType__c";
const DEFAULT_PAGE_SIZE = 10;

const FIELDS = [
  FINANCIAL_ACCOUNT_NUMBER_FIELD,
  FINANCIAL_ACCOUNT_PRIMARY_OWNER_FIELD,
  FINANCIAL_ACCOUNT_ID_FIELD,
  PRODUCT_NAME_FIELD,
  OCV_ID_FIELD,
  TYPE_FIELD
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
  { label: "Start Date", fieldName: "startDate", type: "date", sortable: true },
  { label: "End Date", fieldName: "endDate", type: "date" }
];

const ERROR_UNKNOWN_TITLE = "An error has occurred.";

export default class StatementsViewer extends LightningElement {
  @api recordId;
  @track statements;

  accountId;
  financialAccountId;
  ocvId;
  productName;
  accountNumber;

  columns = columns;
  sortedBy;
  defaultSortDirection = "desc";
  sortDirection = "desc";
  isLoading = true;
  showLoadMoreButton = true;
  error;

  get hasPermissionIssue() {
    return !hasViewStatementsPermission;
  }

  get hasError() {
    return this.error !== undefined && this.error !== null;
  }

  get hasStatements() {
    return this.statements && this.statements.length > 0;
  }

  get hasMoreStatements() {
    return this.showLoadMoreButton;
  }

  @wire(getRecord, {
    recordId: "$recordId",
    fields: FIELDS
  })
  wiredFinancialAccount({ data, error }) {
    if (data) {
      this.accountNumber = data.fields.FinServ__FinancialAccountNumber__c.value;
      this.accountId = data.fields.FinServ__PrimaryOwner__c.value;
      this.financialAccountId = data.fields.Id.value;
      this.ocvId = data.fields.OCV_ID__c.value;
      if (data.fields.FinServ__FinancialAccountType__c.value === "Home Loan") {
        this.productName = "ANZ Plus Home Loan";
      } else {
        this.productName = data.fields.Product_Name__c.value;
      }
      this.getStatementsData(
        this.ocvId,
        this.accountNumber,
        DEFAULT_PAGE_SIZE.toString()
      );
    } else if (error) {
      this.handleError(error);
    }
  }

  async getStatementsData(ocvId, accountNumber, pageSize) {
    try {
      const { statements } = await getStatements({
        ocvId,
        accountNumber,
        pageSize
      });

      if (!statements || statements.length === 0) {
        this.statements = [];
        this.showLoadMoreButton = false;
      }
      if (statements) {
        if (!Array.isArray(statements)) {
          throw new Error("Error: Unknown data.");
        }
        if (statements.length > 0) {
          // if returned data size no greater than default size, hide load more button
          if (statements.length < DEFAULT_PAGE_SIZE) {
            this.showLoadMoreButton = false;
          }
          // if no more statements, hide load more button and no need to process data
          else if (
            this.statements &&
            this.statements.length === statements.length
          ) {
            this.showLoadMoreButton = false;
            this.isLoading = false;
            return;
          }

          const formattedData = this.formatStatements(
            statements,
            this.productName
          );

          this.sortStatements(formattedData, "startDate", "desc");
        }
      }
    } catch (error) {
      this.handleError(error);
    } finally {
      this.isLoading = false;
    }
  }

  async handleLoadMore() {
    this.isLoading = true;

    const pageSize = this.statements.length + DEFAULT_PAGE_SIZE;

    this.getStatementsData(this.ocvId, this.accountNumber, pageSize.toString());
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

      const { statement } = await getStatementUrl({
        ocvId: this.ocvId,
        statementId: row.statementId,
        additionalDetails: additionalDetails
      });

      window.open(statement.url, "_blank");
    } catch (error) {
      this.handleError(error);
    } finally {
      this.isLoading = false;
    }
  }

  formatStatements(data, productName) {
    return data.map((item) => {
      const statement = {};
      statement.statementId = item.statement_id;
      statement.startDate = this.formatDate(item.statement_from);
      statement.endDate = this.formatDate(item.statement_to);
      statement.productName = productName;

      return statement;
    });
  }

  formatDate(data) {
    const month =
      Number(data.month.value) >= 1 && Number(data.month.value) <= 9
        ? `0${data.month.value}`
        : data.month.value;

    return `${data.year.value}-${month}-${data.day.value}`;
  }

  handleSort(event) {
    const { fieldName: sortedBy, sortDirection } = event.detail;
    this.sortStatements(this.statements, sortedBy, sortDirection);
  }

  sortStatements(data, sortedBy, sortDirection) {
    // create a copy of statements data before sorting
    let cloneData = [...data];

    let parser = (v) => v;

    if (sortedBy.type === "date") {
      parser = (v) => v && new Date(v);
    }

    let sortMult = sortDirection === "asc" ? 1 : -1;

    cloneData.sort((a, b) => {
      let a1 = parser(a[sortedBy]),
        b1 = parser(b[sortedBy]);
      let r1 = a1 < b1,
        r2 = a1 === b1;
      return r2 ? 0 : r1 ? -sortMult : sortMult;
    });

    this.statements = cloneData;
    this.sortDirection = sortDirection;
    this.sortedBy = sortedBy;
  }

  handleError(error) {
    let msg = ERROR_UNKNOWN_TITLE;

    if (error.message) {
      msg = error.message;
    }

    this.error = msg;
  }
}
