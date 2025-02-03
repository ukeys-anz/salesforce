import { LightningElement, api, track, wire } from "lwc";
import getOcrListForCustomer from "@salesforce/apex/OCRRelatedListController.getOcrListForCustomer";
import {
  EnclosingTabId,
  IsConsoleNavigation,
  openSubtab
} from "lightning/platformWorkspaceApi";
const DEFAULT_PAGE_SIZE = 10;
const ACCOUNTS_HOME_URL = "/lightning/o/Account/home";
const COLUMNS = [
  {
    label: "Opportunity Name",
    fieldName: "OpportunityUrl",
    type: "url",
    typeAttributes: {
      label: { fieldName: "OpportunityName" },
      tooltip: { fieldName: "OpportunityName" },
      target: "_self"
    },
    sortable: true
  },
  { label: "Stage", fieldName: "Stage", sortable: true },
  {
    label: "Amount",
    fieldName: "Amount",
    type: "currency",
    cellAttributes: { alignment: "left" },
    sortable: true
  },
  { label: "Customer Needs", fieldName: "CustomerNeeds", sortable: true },
  { label: "Relationship", fieldName: "Relationship", sortable: true },
  {
    label: "Created Date",
    type: "date",
    fieldName: "CreatedDate",
    typeAttributes: {
      month: "2-digit",
      day: "2-digit",
      year: "numeric",
      hour: "2-digit",
      minute: "2-digit"
    },
    sortable: true
  }
];
const FIELD_MAPPINGS = {
  OpportunityUrl: "Opportunity.Name",
  Stage: "Opportunity.StageName",
  Amount: "Opportunity.Amount",
  CustomerNeeds: "Opportunity.Customer_Needs__c",
  Relationship: "Role",
  CreatedDate: "CreatedDate"
};
export default class OcrRelatedListPoc extends LightningElement {
  @api recordId;
  @api secondLoad = false;
  @track ocrList = [];
  defaultPageSize = DEFAULT_PAGE_SIZE;
  columns = COLUMNS;
  fieldMappings = FIELD_MAPPINGS;
  noRecords;
  totalRecords = 0;
  isLoading = false;
  customerName;
  customerUrl;
  accountsHomeUrl = ACCOUNTS_HOME_URL;
  showNewButton = false;

  //Sorting related properties
  sortedBy = "CreatedDate";
  sortedDirection = "desc";
  defaultSortDirection = "asc";

  @wire(EnclosingTabId)
  parentTabId;

  @wire(IsConsoleNavigation)
  isConsoleNavigation;

  get oppCount() {
    return this.totalRecords > this.defaultPageSize && this.secondLoad === false
      ? `${this.defaultPageSize}+`
      : this.totalRecords;
  }

  get cardTitle() {
    return `Other Related Opportunities (${this.oppCount})`;
  }

  get showData() {
    return this.ocrList.length > 0;
  }

  get showViewAll() {
    return this.secondLoad === false && this.totalRecords >= 1;
  }

  get calculateHeight() {
    return this.secondLoad === false
      ? "height: auto; position: relative"
      : "height: 480px; position: relative";
  }

  get calculateHeaderMargin() {
    return this.secondLoad === false
      ? "margin-top: 0rem;"
      : "margin-top: -1rem; margin-bottom: -0.5rem;";
  }

  get sortedByColumnLabel() {
    if (this.sortedBy === "OpportunityUrl") {
      return "Opportunity Name";
    }
    let sortColumn = this.columns.find(
      (item) => item.fieldName === this.sortedBy
    );
    return sortColumn.label;
  }

  connectedCallback() {
    this.isLoading = true;
    this.loadRecords(this.sortedBy, this.sortedDirection);
  }

  loadRecords(sb, sd) {
    const inputWrapper = {
      recordId: this.recordId,
      pageSize: !this.secondLoad ? this.defaultPageSize : null,
      sortByField: sb,
      sortOrder: sd
    };
    getOcrListForCustomer({ inputWrapper })
      .then((result) => {
        if (result && result.relatedRecordList?.length >= 0) {
          this.formatResult(result.relatedRecordList);
          this.totalRecords = result?.countOfRecords;
          this.customerName = result?.relatedRecordList[0]?.Contact?.Name;
          this.customerUrl = `/${this.recordId}`;
          this.isLoading = false;
        } else {
          this.noRecords = true;
          this.isLoading = false;
        }
      })
      .catch((error) => {
        console.error(error);
      });
  }

  formatResult(result) {
    let localResult = [...result];
    let updatedResult = [];
    localResult.forEach((item) => {
      let record = {};
      record.OcrId = item.Id;
      record.OpportunityId = item.OpportunityId;
      record.OpportunityUrl = `/${item.OpportunityId}`;
      record.OpportunityName = item.Opportunity.Name;
      record.Stage = item.Opportunity.StageName;
      record.Amount = item.Opportunity.Amount;
      record.CustomerNeeds = item.Opportunity.Customer_Needs__c;
      record.Relationship = item.Role;
      record.CreatedDate = item.CreatedDate;
      updatedResult.push(record);
    });
    this.ocrList = updatedResult;
  }

  //This method will be called whenever a table header is clicked for sorting.
  handleSort(event) {
    console.log(JSON.stringify(event.detail));
    const { fieldName: sortedBy, sortDirection: sortedDirection } =
      event.detail;
    this.sortedBy = sortedBy;
    this.sortedDirection = sortedDirection;
    this.isLoading = true;
    this.loadRecords(this.fieldMappings[sortedBy], sortedDirection);
  }

  handleViewAll() {
    if (this.isConsoleNavigation) {
      openSubtab(this.parentTabId, {
        pageReference: {
          type: "standard__component",
          attributes: {
            componentName: "c__ocrRelatedListViewAllContainer"
          },
          state: {
            c__recId: this.recordId
          }
        },
        label: "Other Related Opportunities",
        icon: "standard:opportunity",
        focus: true
      }).catch((error) => {
        console.error("Error in opening tab", JSON.stringify(error));
      });
    }
  }

  handleRefresh() {
    this.isLoading = true;
    this.loadRecords(this.fieldMappings[this.sortedBy], this.sortedDirection);
  }
}
