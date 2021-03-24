import { LightningElement, wire, api, track } from "lwc";
import { refreshApex } from "@salesforce/apex";
import getRestrictedCaseData from "@salesforce/apex/GetRestrictedCaseInfo.getRestrictedCaseData";

const actions = [{ label: "Add Case Comment", name: "add_case_comment" }];
const columns = [
  {
    label: "Case Number",
    fieldName: "CaseNumber",
    type: "text",
    sortable: true
  },
  {
    label: "Status",
    fieldName: "Status",
    sortable: true
  },
  {
    label: "Customer Number",
    fieldName: "IDR_Customer_Number__c",
    sortable: true
  },
  {
    label: "Customer Type",
    fieldName: "IDR_Complainant_Type__c",
    sortable: true,
    type: "picklist"
  },
  {
    label: "First Name",
    fieldName: "IDR_NC_First_Name__c",
    sortable: true
  },
  {
    label: "Last Name",
    fieldName: "IDR_NC_Last_Name__c",
    sortable: true
  },
  {
    type: "action",
    typeAttributes: {
      rowActions: actions,
      menuAlignment: "right"
    }
  }
];

export default class RestrictedCaseDetails extends LightningElement {
  @track value;
  @track error;
  @track data;
  @api searchKey = "";
  result;

  @track page = 1;
  @track items = [];
  @track data = [];
  @track columns;
  @track startingRecord = 1;
  @track endingRecord = 0;
  @track pageSize = 10;
  @track totalRecountCount = 0;
  @track totalPage = 0;
  @track showData = false;
  @track isEditForm = false;

  connectedCallback() {
    this.getRestrictedCaseDetails();
  }

  getRestrictedCaseDetails() {
    getRestrictedCaseData({
      searchKey: this.searchKey,
      sortBy: this.sortBy,
      sortDirection: this.sortedDirection
    })
      .then((result) => {
        this.items = result;
        this.totalRecountCount = result.length;
        this.totalPage = Math.ceil(this.totalRecountCount / this.pageSize);

        this.data = this.items.slice(0, this.pageSize);
        this.endingRecord = this.pageSize;
        this.columns = columns;

        this.error = undefined;
      })
      .catch((error) => {
        this.error = error;
        this.data = undefined;
      });
  }
  //clicking on previous button this method will be called
  previousHandler() {
    if (this.page > 1) {
      this.page = this.page - 1; //decrease page by 1
      this.displayRecordPerPage(this.page);
    }
  }

  //clicking on next button this method will be called
  nextHandler() {
    if (this.page < this.totalPage && this.page !== this.totalPage) {
      this.page = this.page + 1; //increase page by 1
      this.displayRecordPerPage(this.page);
    }
  }

  //this method displays records page by page
  displayRecordPerPage(page) {
    this.startingRecord = (page - 1) * this.pageSize;
    this.endingRecord = this.pageSize * page;

    this.endingRecord =
      this.endingRecord > this.totalRecountCount
        ? this.totalRecountCount
        : this.endingRecord;

    this.data = this.items.slice(this.startingRecord, this.endingRecord);

    this.startingRecord = this.startingRecord + 1;
  }

  // Used to sort the 'Age' column
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

  onHandleSort(event) {
    const { fieldName: sortedBy, sortDirection } = event.detail;
    const cloneData = [...this.items];

    cloneData.sort(this.sortBy(sortedBy, sortDirection === "asc" ? 1 : -1));
    this.data = cloneData;
    this.sortDirection = sortDirection;
    this.sortedBy = sortedBy;
  }

  handleSearch(event) {
    if (event.keyCode === 13) {
      this.showData = true;
      this.searchKey = event.target.value;
      this.getRestrictedCaseDetails();
    }
  }
  handleKeyChange(event) {
    if (event.target.value === null || event.target.value === "") {
      this.showData = false;
    }
  }

  handleRowActions(event) {
    let actionName = event.detail.action.name;
    window.console.log("actionName ====> " + actionName);
    let row = event.detail.row;
    if (actionName === "add_case_comment") {
      this.isEditForm = true;
      window.console.log("row ====> " + row.Id);
    }
  }
  closeModal() {
    this.isEditForm = false;
  }
}
