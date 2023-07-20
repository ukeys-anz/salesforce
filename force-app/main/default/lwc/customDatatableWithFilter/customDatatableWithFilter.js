import fetchDataForInteraction from "@salesforce/apex/InteractionMessageController.fetchDataForInteraction";
import INTERACTION_STATUS from "@salesforce/schema/Interaction.Status__c";
import { getObjectInfo, getPicklistValues } from "lightning/uiObjectInfoApi";
import { LightningElement, api, wire, track } from "lwc";
import { NavigationMixin } from "lightning/navigation";

const SORT_DIRECTION = "desc";
const SORTED_BY = "Interaction_Auto_Number__c";

export default class CustomDatatableWithFilter extends NavigationMixin(
  LightningElement
) {
  ampm = true;

  //Params to build and show page numbers
  @api perpage = 15;
  @api setsize = 5000;
  @api defaultSortDirection = SORT_DIRECTION;
  @api sortedBy = SORTED_BY;
  @api sortDirection = SORT_DIRECTION;
  @api anyRecordId;
  @api recordTypeDeveloperName;
  @api originalRecords;
  _defaultSortDirection;
  _sortDirection;
  _sortedBy;
  _originalRecords;
  _localOriginalRecords;
  _originalColumns;
  statusValue = [];
  loading = false;
  boolIsMessage = false;
  page = 1;
  filterClass = "slds-hide";
  fieldsforcall = [
    { label: "Name", fieldName: "Name", sortable: true },
    {
      label: "Interaction Number",
      fieldName: "Interaction_Auto_Number__c",
      type: "datatableColumnClickHandler",
      typeAttributes: {
        recordId: {
          fieldName: "Id"
        },
        cellValue: {
          fieldName: "Interaction_Auto_Number__c"
        },
        sObjectApiName: "Interaction"
      },
      sortable: true
    },
    { label: "Who", fieldName: "Interaction_Purpose__c", sortable: true },
    { label: "Channel", fieldName: "InteractionType", sortable: true },
    { label: "Direction", fieldName: "Direction__c", sortable: true },
    {
      label: "Start Time",
      fieldName: "StartTime",
      type: "date",
      typeAttributes: {
        year: "numeric",
        month: "numeric",
        day: "numeric",
        hour: "2-digit",
        minute: "2-digit",
        hour12: this.ampm
      },
      sortable: true
    },
    { label: "Attendees", fieldName: "Attendees__c", sortable: true }
  ];

  fieldsformessage = [
    { label: "Name", fieldName: "Name", sortable: true },
    {
      label: "Interaction Number",
      fieldName: "Interaction_Auto_Number__c",
      type: "datatableColumnClickHandler",
      typeAttributes: {
        recordId: {
          fieldName: "Id"
        },
        cellValue: {
          fieldName: "Interaction_Auto_Number__c"
        },
        sObjectApiName: "Interaction"
      },
      sortable: true
    },
    { label: "Who", fieldName: "Interaction_Purpose__c", sortable: true },
    { label: "Channel", fieldName: "InteractionType", sortable: true },
    { label: "Status", fieldName: "Status__c", sortable: true },
    { label: "Direction", fieldName: "Direction__c", sortable: true },
    {
      label: "Start Time",
      fieldName: "StartTime",
      type: "date",
      typeAttributes: {
        year: "numeric",
        month: "numeric",
        day: "numeric",
        hour: "2-digit",
        minute: "2-digit",
        hour12: this.ampm
      },
      sortable: true
    },
    { label: "Attendees", fieldName: "Attendees__c", sortable: true },
    {
      type: "action",
      typeAttributes: { rowActions: this.getRowActions }
    }
  ];

  fieldsforstore = [
    { label: "Name", fieldName: "Name", sortable: true },
    {
      label: "Interaction Number",
      fieldName: "Interaction_Auto_Number__c",
      type: "datatableColumnClickHandler",
      typeAttributes: {
        recordId: {
          fieldName: "Id"
        },
        cellValue: {
          fieldName: "Interaction_Auto_Number__c"
        },
        sObjectApiName: "Interaction"
      },
      sortable: true
    },
    { label: "Who", fieldName: "Interaction_Purpose__c", sortable: true },
    { label: "Channel", fieldName: "InteractionType", sortable: true },
    { label: "Place", fieldName: "Place__c", sortable: true },
    { label: "Action Taken", fieldName: "Resolution__c", sortable: true },
    {
      label: "Start Time",
      fieldName: "StartTime",
      type: "date",
      typeAttributes: {
        year: "numeric",
        month: "numeric",
        day: "numeric",
        hour: "2-digit",
        minute: "2-digit",
        hour12: this.ampm
      },
      sortable: true
    },
    { label: "Attendees", fieldName: "Attendees__c", sortable: true }
  ];
  @track pages = [];

  @wire(getObjectInfo, { objectApiName: "Interaction" })
  objectInfo;

  @wire(getPicklistValues, {
    recordTypeId: "$objectInfo.data.defaultRecordTypeId",
    fieldApiName: INTERACTION_STATUS
  })
  statusPickListValues;

  get checkboxOptions() {
    if (this.statusPickListValues.data) {
      return this.statusPickListValues.data.values;
    }
    return null;
  }

  renderedCallback() {
    this.renderButtons();
  }

  /**
   * Renders the buttons
   */
  renderButtons = () => {
    this.template.querySelectorAll("button").forEach((but) => {
      but.style.backgroundColor =
        this.page === parseInt(but.dataset.id, 10) ? "dodgerblue" : "white";
      but.style.color =
        this.page === parseInt(but.dataset.id, 10) ? "white" : "black";
    });
  };

  get pagesList() {
    let mid = Math.floor(this.setsize / 2) + 1;
    if (this.page > mid) {
      return this.pages.slice(this.page - mid, this.page + mid - 1);
    }
    return this.pages.slice(0, this.setsize);
  }

  connectedCallback() {
    this.boolIsMessage = this.recordTypeDeveloperName === "Message";
    this._defaultSortDirection = this.defaultSortDirection;
    this._sortedBy = this.sortedBy;
    this._originalRecords = this._localOriginalRecords = this.originalRecords;
    this.getRecordsFromDB();

    this._originalColumns = this.fetchOriginalColumns(
      this.recordTypeDeveloperName
    );
    this._sortDirection = this.sortDirection;
  }

  //   originalColumns(value) {
  //     if(value){
  //         switch(this.recordTypeDeveloperName){
  //             case 'Message':
  //                 this._originalColumns =  fieldsformessage;
  //                 break;
  //             case 'General':
  //                 this._originalColumns =  fieldsforcall;
  //                 break;
  //             case 'Store':
  //                 this._originalColumns =  fieldsforstore;
  //                 break;
  //             default:
  //                 this._originalColumns = [];
  //         }
  //     }
  //   }

  pageData = () => {
    if (!this._originalRecords) {
      return [];
    }
    let page = this.page;
    let perpage = this.perpage;
    let startIndex = page * perpage - perpage;
    let endIndex = page * perpage;
    return this._originalRecords.slice(startIndex, endIndex);
  };

  setPages = (data) => {
    this.pages = [];
    let numberOfPages = Math.ceil(data.length / this.perpage);
    for (let index = 1; index <= numberOfPages; index++) {
      this.pages.push(index);
    }
  };

  get hasPrev() {
    return this.page > 1;
  }

  get hasNext() {
    return this.page < this.pages.length;
  }

  onNext = () => {
    ++this.page;
  };

  onPrev = () => {
    --this.page;
  };

  onPageClick = (event) => {
    this.page = parseInt(event.target.dataset.id, 10);
  };

  get currentPageData() {
    return this.pageData();
  }

  setPagination() {
    this.setPages(this._originalRecords);
  }

  handleStatusChange(event) {
    this.statusValue = event.detail.value;
    this.getRecordsFromDB();
  }

  getRecordsFromDB() {
    this.loading = !this.loading;
    fetchDataForInteraction({
      anyRecordId: this.anyRecordId,
      recordTypeDeveloperName: this.recordTypeDeveloperName,
      statusSearch: this.statusValue
    })
      .then((data) => {
        this._originalRecords = this._localOriginalRecords = data;
        this.sortData(this._sortedBy, this._defaultSortDirection);
        this.setPagination();
        this.loading = !this.loading;
      })
      .catch((error) => {
        console.error(JSON.stringify(error));
        this.setPagination();
        this.loading = !this.loading;
      });
  }

  getRowActions(row, doneCallback) {
    let actions;
    if (row.Status__c !== "Closed & Archived") {
      actions = [
        { label: "Reply To Customer", name: "ReplyToCustomer" },
        { label: "View Transcript", name: "ViewTranscript" }
      ];
    } else {
      actions = [{ label: "View Transcript", name: "ViewTranscript" }];
    }
    doneCallback(actions);
  }

  handleRowAction(event) {
    const actionName = event.detail.action.name;
    const row = event.detail.row;
    if (actionName) {
      if (row) {
        //Shivam will add his code in this method to use these varaible
      }
    }
  }

  handleSort(event) {
    let fieldName = event.detail.fieldName;
    let sortDirection = event.detail.sortDirection;
    this._sortedBy = fieldName;
    this._sortDirection = sortDirection;
    this.sortData(fieldName, sortDirection);
  }

  sortData(fieldName, sortDirection) {
    // serialize the data before calling sort function
    const cloneData = [...this._originalRecords];

    // Return the value stored in the field
    let keyValue = (a) => {
      if (fieldName === "StartTime") {
        // assuming "date" is your date field
        return new Date(a[fieldName]); // convert string to Date object
      }
      return a[fieldName];
    };

    // checking reverse direction
    let isReverse = sortDirection === "asc" ? 1 : -1;

    // sorting data
    cloneData.sort((a, b) => {
      a = keyValue(a) !== null && keyValue(a) !== undefined ? keyValue(a) : ""; // handling null values
      b = keyValue(b) !== null && keyValue(b) !== undefined ? keyValue(b) : "";
      if (typeof a === "string" && typeof b === "string") {
        return isReverse * a.localeCompare(b);
      } else if (a instanceof Date && b instanceof Date) {
        return isReverse * (a - b);
      }
      return isReverse * ((+b === b && +a !== a) || a - b);
    });

    // set the sorted data to data table data
    this._originalRecords = this._localOriginalRecords = cloneData;
  }

  handleDatatableColumnClick(event) {
    this[NavigationMixin.Navigate]({
      type: "standard__recordPage",
      attributes: {
        recordId: event.detail.recordId,
        actionName: "view"
      }
    });
  }

  fetchOriginalColumns(value) {
    switch (value) {
      case "Message":
        return this.fieldsformessage;
      case "General":
        return this.fieldsforcall;
      case "Store":
        return this.fieldsforstore;
      default:
        return [];
    }
  }

  handleFilterClick() {
    this.filterClass =
      this.filterClass === "slds-hide" ? "slds-show" : "slds-hide";
  }

  handleSearch(event) {
    let objDataTable = this.template.querySelector(
      "c-datatable-with-column-click"
    );
    let cloneData = [...this._localOriginalRecords];
    let searchKey = event.target.value;

    try {
      let parsedColumn = JSON.parse(JSON.stringify(objDataTable.columns));
      let filteredData = [];
      for (let i = 0; i < parsedColumn.length; i++) {
        let filter = cloneData.filter(function (el) {
          let eachVisibleField = parsedColumn[i].fieldName;
          return (
            (el[eachVisibleField]
              ? el[eachVisibleField].toLowerCase()
              : ""
            ).indexOf(searchKey.toLowerCase()) > -1
          );
        });
        for (let j = 0; j < filter.length; j++) {
          if (filteredData.indexOf(filter[j]) === -1) {
            filteredData.push(filter[j]);
          }
        }
      }
      this._originalRecords = filteredData;
    } catch (e) {
      console.error(JSON.stringify(e));
    }
    this.setPagination();
  }

  handleCloseClick(event) {
    event.preventDefault();
    if (this.filterClass === "slds-show") {
      this.filterClass = "slds-hide";
    }
  }
}
