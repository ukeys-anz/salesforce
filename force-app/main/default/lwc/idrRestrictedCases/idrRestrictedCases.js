import { LightningElement, track } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import getRestrictedCaseData from "@salesforce/apex/IDRRestrictedCasesController.getRestrictedCaseData";
import insertCaseComment from "@salesforce/apex/IDRRestrictedCasesController.insertCaseComment";
import linkFileToCase from "@salesforce/apex/IDRRestrictedCasesController.linkFileToCase";

const actions = [
  { label: "Add Case Comment", name: "add_case_comment" },
  { label: "Upload Files", name: "update_files" }
];

const columns = [
  {
    label: "Case Number",
    fieldName: "caseNumber",
    sortable: true
  },
  {
    label: "Customer Number",
    fieldName: "customerNumber"
  },
  {
    label: "Customer Type",
    fieldName: "customerType",
    wrapText: true
  },
  {
    label: "First Name",
    fieldName: "firstName",
    wrapText: true
  },
  {
    label: "Last Name",
    fieldName: "lastName"
  },
  {
    label: "Case Owner",
    fieldName: "caseOwner"
  },
  {
    label: "Status",
    fieldName: "status"
  },
  {
    type: "action",
    typeAttributes: {
      rowActions: actions,
      menuAlignment: "slds-popover__body"
    }
  }
];

export default class IDRRestrictedCases extends LightningElement {
  @track data;
  @track columns = columns;
  @track searchKey = "";
  @track showData = false;
  @track noData = false;
  @track isEditForm = false;
  @track isUploadFile = false;
  @track showSave = false;
  @track commentBody;
  @track caseId;
  @track loading = false;
  documentIds = [];
  uploadedFiles = [];
  uploadedFileNames = "";

  loadData() {
    getRestrictedCaseData({
      searchKey: this.searchKey
    })
      .then((result) => {
        this.data = result;
        this.loading = false;
        if (this.data.length === 0) {
          this.noData = true;
        } else {
          this.showData = true;
        }
      })
      .catch((error) => {
        this.error = error;
        this.data = undefined;
        this.loading = false;
      });
  }

  handleSearch(event) {
    if (event.keyCode === 13) {
      this.loading = true;
      this.searchKey = event.target.value;
      this.loadData();
    }
  }

  handleKeyChange(event) {
    if (event.target.value === null || event.target.value === "") {
      this.showData = false;
      this.noData = false;
    }
  }

  handleRowActions(event) {
    let actionName = event.detail.action.name;
    let row = event.detail.row;
    this.caseId = row.caseId;
    if (actionName === "add_case_comment") {
      this.isEditForm = true;
      this.showSave = false;
    }
    if (actionName === "update_files") {
      this.isUploadFile = true;
    }
  }

  onHandleSort(event) {
    const { fieldName: sortedBy, sortDirection } = event.detail;
    const cloneData = [...this.data];
    cloneData.sort(this.sortBy(sortedBy, sortDirection === "asc" ? 1 : -1));
    this.data = cloneData;
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

  handleCommentChange(event) {
    this.commentBody = event.detail.value;
    this.showSave = true;
    if (event.detail.value === null || event.detail.value === "") {
      this.showSave = false;
    }
  }

  handleSubmit() {
    insertCaseComment({
      caseId: this.caseId,
      commentBody: this.commentBody
    })
      .then(() => {
        this.closeModal();
        this.dispatchEvent(
          new ShowToastEvent({
            title: "Success",
            message: "Case Comment added successfully",
            variant: "success"
          })
        );
      })
      .catch((error) => {
        this.closeModal();
        this.dispatchEvent(
          new ShowToastEvent({
            title: "Error while inserting case comment",
            message: error.body.message,
            variant: "error"
          })
        );
      });
  }

  get acceptedFormats() {
    return [
      ".png",
      ".jpg",
      ".jpeg",
      ".docx",
      ".tiff",
      ".tif",
      ".gif",
      ".bmp",
      ".pdf",
      ".doc",
      ".xls",
      ".xlsx",
      "xlsb",
      ".eml",
      ".rtf",
      ".txt",
      ".ppt",
      ".pptx",
      ".msg",
      ".csv",
      ".zip"
    ];
  }

  handleUploadFinished(event) {
    this.documentIds = [];
    this.uploadedFileNames = "";
    // Get the list of uploaded files
    this.uploadedFiles = event.detail.files;
    for (let i = 0; i < this.uploadedFiles.length; i++) {
      this.uploadedFileNames += this.uploadedFiles[i].name + ", ";
      this.documentIds.push(this.uploadedFiles[i].documentId);
    }
    linkFileToCase({
      caseId: this.caseId,
      contentDocIdList: this.documentIds
    })
      .then(() => {
        this.closeModal();
        this.dispatchEvent(
          new ShowToastEvent({
            title: "Success",
            message:
              this.uploadedFiles.length +
              " Files uploaded Successfully: " +
              this.uploadedFileNames,
            variant: "success"
          })
        );
      })
      .catch((error) => {
        this.closeModal();
        this.dispatchEvent(
          new ShowToastEvent({
            title: "Error while uploading the file",
            message: error.body.message,
            variant: "error"
          })
        );
      });
  }

  closeModal() {
    this.isEditForm = false;
    this.isUploadFile = false;
  }
}
