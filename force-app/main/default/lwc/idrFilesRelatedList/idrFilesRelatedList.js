import { LightningElement, api, track, wire } from "lwc";
import getCaseRelatedFiles from "@salesforce/apex/IDRFilesRelatedListController.getCaseRelatedFiles";
import searchFilesContent from "@salesforce/apex/IDRFilesRelatedListController.searchFilesContent";
import removeFileFromCase from "@salesforce/apex/IDRFilesRelatedListController.removeFileFromCase";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { getRecord } from "lightning/uiRecordApi";
import STATUS_FIELD from "@salesforce/schema/Case.Status";
import IDR_LEVEL_1_CHECK from "@salesforce/customPermission/IDR_Level_1";
import { handleErrorShowToast } from "c/utils";

const FIELDS = [STATUS_FIELD];

const columns = [
  {
    label: "File Name",
    fieldName: "fileUrl",
    sortable: true,
    type: "url",
    initialWidth: 250,
    wrapText: true,
    typeAttributes: { label: { fieldName: "fileName" } }
  },
  {
    label: "Created Date",
    fieldName: "createdDate",
    sortable: true,
    initialWidth: 150
  },
  {
    label: "Date Of Document",
    fieldName: "dateOfDocument",
    sortable: true,
    wrapText: true,
    initialWidth: 150
  },
  {
    label: "Party who sent/created file",
    fieldName: "partyWhoSent",
    sortable: true,
    wrapText: true,
    initialWidth: 200
  },
  {
    label: "Document Flag",
    fieldName: "flag",
    sortable: true,
    wrapText: true,
    initialWidth: 150
  },
  {
    label: "Document Category",
    fieldName: "documentType",
    sortable: true,
    wrapText: true,
    initialWidth: 200
  },
  {
    label: "Owner",
    fieldName: "ownerName",
    sortable: true,
    initialWidth: 100
  },
  {
    label: "File Type",
    fieldName: "fileType",
    wrapText: true,
    sortable: true,
    initialWidth: 100
  }
];

export default class IDRFilesRelatedList extends LightningElement {
  @api recordId;
  @track files;
  @track filesToDisplay;
  @track commonPath;
  searchFileName;
  searchFileType;
  searchOwner;
  searchContains;
  searchStartDate;
  searchEndDate;
  AllFieldSearchResult;
  allFileIdList;
  defaultSortDirection = "asc";
  sortDirection = "asc";
  sortedBy;
  activeSections = ["search", "filelist"];
  displayRemovalConfirmation = false;
  fileId;

  @wire(getRecord, { recordId: "$recordId", fields: FIELDS })
  wiredProject({ data }) {
    if (data) {
      if (
        data.apiName === "Case" &&
        IDR_LEVEL_1_CHECK &&
        (data.recordTypeInfo.name === "Customer Complaint" ||
          data.recordTypeInfo.name === "General Inquiry CMOS" ||
          data.recordTypeInfo.name === "Non-Customer Complaint")
      ) {
        this.columns = columns;
        this.columns.push({
          type: "action",
          typeAttributes: {
            rowActions: [{ label: "Remove from Case", name: "remove" }]
          }
        });
      }
    }
  }

  columns = columns;
  connectedCallback() {
    getCaseRelatedFiles({ caseId: this.recordId })
      .then((result) => {
        let filelist = result;
        this.files = filelist;
        this.filesToDisplay = this.files;
        this.allFileIdList = [];
        for (let i = 0; i < filelist.length; i++) {
          this.allFileIdList.push(filelist[i].fileId);
        }
      })
      .catch((error) => {
        let errorMessage = "Failed to retrive case files";
        if (error.body) {
          if (Array.isArray(error.body)) {
            errorMessage = error.body.map((e) => e.message).join(", ");
          } else if (typeof error.body.message === "string") {
            errorMessage = error.body.message;
          }
        }
        const toastEvent = new ShowToastEvent({
          message: errorMessage,
          variant: "error"
        });
        this.dispatchEvent(toastEvent);
      });
  }
  closeRemovalConfirmation() {
    this.displayRemovalConfirmation = false;
  }
  handleRemovalConfirmation() {
    removeFileFromCase({
      idCase: this.recordId,
      idFile: this.fileId
    })
      .then((result) => {
        if (result) {
          const toastEvent = new ShowToastEvent({
            title: "Success",
            message: "File Removed",
            variant: "success"
          });
          this.dispatchEvent(toastEvent);
          this.displayRemovalConfirmation = false;
          this.refreshFileList();
        }
      })
      .catch((error) => {
        let errorMessage = "Failed to remove file from Case";
        if (error.body) {
          if (Array.isArray(error.body)) {
            errorMessage = error.body.map((e) => e.message).join(", ");
          } else if (typeof error.body.message === "string") {
            errorMessage = error.body.message;
          }
        }
        const toastEvent = new ShowToastEvent({
          message: errorMessage,
          variant: "error"
        });
        this.dispatchEvent(toastEvent);
      });
  }
  handleRowAction(event) {
    const actionName = event.detail.action.name;
    const row = event.detail.row;
    switch (actionName) {
      case "remove":
        this.fileId = row.fileId;
        this.displayRemovalConfirmation = true;
        break;
      default:
    }
  }

  refreshFileList() {
    this.searchFileName = "";
    this.searchFileType = "";
    this.searchOwner = "";
    this.searchContains = "";
    this.searchStartDate = "";
    this.searchEndDate = "";
    getCaseRelatedFiles({ caseId: this.recordId })
      .then((result) => {
        let filelist = result;
        this.files = filelist;
        this.filesToDisplay = this.files;
        this.allFileIdList = [];
        for (let i = 0; i < filelist.length; i++) {
          this.allFileIdList.push(filelist[i].fileId);
        }
      })
      .catch((error) => {
        let errorMessage = "Failed to refresh case files list";
        if (error.body) {
          if (Array.isArray(error.body)) {
            errorMessage = error.body.map((e) => e.message).join(", ");
          } else if (typeof error.body.message === "string") {
            errorMessage = error.body.message;
          }
        }
        const toastEvent = new ShowToastEvent({
          message: errorMessage,
          variant: "error"
        });
        this.dispatchEvent(toastEvent);
      });
  }

  sortData(fieldname, direction) {
    let parseData = JSON.parse(JSON.stringify(this.filesToDisplay));
    let getField = fieldname === "fileUrl" ? "fileName" : fieldname;

    // Return the value stored in the field
    let keyValue = (a) => {
      return a[getField];
    };
    // cheking reverse direction
    let isReverse = direction === "asc" ? 1 : -1;
    // sorting data
    parseData.sort((x, y) => {
      x = keyValue(x) ? keyValue(x) : ""; // handling null values
      y = keyValue(y) ? keyValue(y) : "";
      let a = x.toLowerCase();
      let b = y.toLowerCase();

      return isReverse * ((a > b) - (b > a));
    });
    this.filesToDisplay = parseData;
  }

  onHandleSort(event) {
    this.sortedBy = event.detail.fieldName;
    this.sortDirection = event.detail.sortDirection;
    try {
      this.sortData(this.sortedBy, this.sortDirection);
    } catch (err) {
      handleErrorShowToast(
        this,
        "Sorting failed",
        err,
        "Failed to sort data. Please refresh and try again. Raise a fault through TechAssist if the problem persists."
      );
    }
  }
  UpdateFileNameSearch(event) {
    this.searchFileName = event.target.value;
    this.filterFiles();
  }
  UpdateFileTypeSearch(event) {
    this.searchFileType = event.target.value;
    this.filterFiles();
  }
  UpdateOwnerSearch(event) {
    this.searchOwner = event.target.value;
    this.filterFiles();
  }
  UpdateStartDateSearch(event) {
    this.searchStartDate = event.target.value;
    this.filterFiles();
  }
  UpdateEndDateSearch(event) {
    this.searchEndDate = event.target.value;
    this.filterFiles();
  }
  UpdateContainsSearch(event) {
    this.searchContains = event.target.value;
    //minimum length of 2 characters is required for salesforce search
    if (this.searchContains.length > 1 && this.allFileIdList.length > 0) {
      let searchKeyWords = this.searchContains.split("+");
      searchFilesContent({
        searchArray: searchKeyWords,
        validDocIdList: this.allFileIdList
      })
        .then((result) => {
          this.AllFieldSearchResult = result;
          this.filterFiles();
        })
        .catch((error) => {
          let errorMessage = "Failed to search files content";
          if (error.body) {
            if (Array.isArray(error.body)) {
              errorMessage = error.body.map((e) => e.message).join(", ");
            } else if (typeof error.body.message === "string") {
              errorMessage = error.body.message;
            }
          }
          const toastEvent = new ShowToastEvent({
            message: errorMessage,
            variant: "error"
          });
          this.dispatchEvent(toastEvent);
        });
    } else {
      this.AllFieldSearchResult = [];
      this.filterFiles();
    }
  }
  filterFiles() {
    this.filesToDisplay = [];
    for (let i = 0; i < this.files.length; i++) {
      let fileMatch = true;

      let fileName = this.files[i].fileName.toLowerCase();
      let fileType = this.files[i].fileType.toLowerCase();
      let OwnerName = this.files[i].ownerName.toLowerCase();

      if (
        (this.searchFileName &&
          !fileName.includes(this.searchFileName.toLowerCase())) ||
        (this.searchFileType &&
          !fileType.includes(this.searchFileType.toLowerCase())) ||
        (this.searchOwner &&
          !OwnerName.includes(this.searchOwner.toLowerCase())) ||
        (this.searchContains &&
          !this.AllFieldSearchResult.includes(this.files[i].fileId)) ||
        (this.searchStartDate &&
          this.files[i].createdDate < this.searchStartDate) ||
        (this.searchEndDate && this.files[i].createdDate > this.searchEndDate)
      ) {
        fileMatch = false;
      }
      if (fileMatch) {
        this.filesToDisplay.push(this.files[i]);
      }
    }
  }
}
