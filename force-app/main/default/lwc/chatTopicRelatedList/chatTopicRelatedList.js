import { LightningElement, api, track } from "lwc";
import getChatTopics from "@salesforce/apex/chatTopicRelatedListController.getChatTopics";
import getChatTopicsFromCase from "@salesforce/apex/chatTopicRelatedListController.getChatTopicsFromCase";
import { ShowToastEvent } from "lightning/platformShowToastEvent";

// Datatable Columns
const columns = [
  {
    label: "Name",
    fieldName: "Name",
    type: "text",
    wrapText: true,
    sortable: true
  },
  {
    label: "Status",
    fieldName: "Status__c",
    type: "text",
    sortable: true
  },
  {
    label: "Last Modified Date",
    fieldName: "LastModifiedDate",
    type: "date",
    sortable: true
  },
  {
    type: "button",
    typeAttributes: {
      label: "Re-initiate",
      name: "Re-initiate",
      title: "Re-initiate",
      disabled: false,
      value: "Re-initiate",
      iconPosition: "left"
    }
  }
];

export default class RetrieveChatTopics extends LightningElement {
  @api recordId;
  @api objectName;
  @track page = 1; //this will initialize 1st page
  @track items = []; //it contains all the records.
  @track data = []; //data to be displayed in the table
  @track columns; //holds column info.
  @track startingRecord = 1; //start record position per page
  @track endingRecord = 0; //end record position per page
  @track pageSize = 3; //default value we are assigning
  @track totalRecountCount = 0; //total record count received from all retrieved records
  @track title = "Chat Topics ";
  @track titleWithCount = this.title + "(" + this.totalRecountCount + ")";

  @track totalPage = 0; //total number of page is needed to display all records
  @track sortBy = "LastModifiedDate";
  @track sortDirection = "desc";
  @track showLoadingSpinner = false;
  @track paginatorRequired = false;

  connectedCallback() {
    if (this.objectName === "Account") {
      this.fetchChatTopicsFromAccount();
    }
    if (this.objectName === "Case") {
      this.fetchChatTopicsFromCase();
    }
  }

  fetchChatTopicsFromAccount() {
    getChatTopics({
      accountId: this.recordId,
      field: this.sortBy,
      sortOrder: this.sortDirection
    })
      .then(result => {
        if (result) {
          this.items = result;
          this.totalRecountCount = result.length; //here it is 23
          if (this.totalRecountCount > 3) {
            this.paginatorRequired = true;
          }
          this.titleWithCount = this.title + "(" + this.totalRecountCount + ")";
          this.totalPage = Math.ceil(this.totalRecountCount / this.pageSize); //here it is 5

          //initial data to be displayed ----------->
          //slice will take 0th element and ends with 5, but it doesn't include 5th element
          //so 0 to 4th rows will be displayed in the table
          this.data = this.items.slice(0, this.pageSize);
          this.endingRecord = this.pageSize;
          this.columns = columns;
          this.showLoadingSpinner = false;
        }
      })
      .catch(error => {
        let errorMessage = "Failed to load chat records";
        if (error.body && error.body.message) {
          errorMessage = error.body.message;
        }
        this.showToast("Chat Topic Load Failed", errorMessage, error);
      });
  }

  fetchChatTopicsFromCase() {
    getChatTopicsFromCase({
      caseId: this.recordId
    })
      .then(result => {
        if (result) {
          this.totalRecountCount = result.length;
          this.titleWithCount = this.title + "(" + this.totalRecountCount + ")";
          let currentData = [];

          result.forEach(row => {
            let rowData = {};

            rowData.Name = row.Chat_Topic__r.Name;
            rowData.Status__c = row.Chat_Topic__r.Status__c;
            rowData.LastModifiedDate = row.Chat_Topic__r.LastModifiedDate;

            currentData.push(rowData);
          });
          this.data = currentData;
          this.columns = columns;
          this.showLoadingSpinner = false;
        }
      })
      .catch(error => {
        let errorMessage = "Failed to load chat records";
        if (error.body && error.body.message) {
          errorMessage = error.body.message;
        }
        this.showToast("Chat Topic Load Failed", errorMessage, error);
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
    /*let's say for 2nd page, it will be => "Displaying 6 to 10 of 23 records. Page 2 of 5"
      page = 2; pageSize = 5; startingRecord = 5, endingRecord = 10
      so, slice(5,10) will give 5th to 9th records.
      */
    this.startingRecord = (page - 1) * this.pageSize;
    this.endingRecord = this.pageSize * page;

    this.endingRecord =
      this.endingRecord > this.totalRecountCount
        ? this.totalRecountCount
        : this.endingRecord;

    this.data = this.items.slice(this.startingRecord, this.endingRecord);

    //increment by 1 to display the startingRecord count,
    //so for 2nd page, it will show "Displaying 6 to 10 of 23 records. Page 2 of 5"
    this.startingRecord = this.startingRecord + 1;
  }

  updateColumnSorting(event) {
    this.showLoadingSpinner = true;
    this.startingRecord = 1;
    this.page = 1;
    this.sortBy = event.detail.fieldName;
    this.sortDirection = event.detail.sortDirection;
    this.connectedCallback();
  }

  callRowAction() {
    //do nothing for now
  }

  showToast(theTitle, theMessage, theVariant) {
    const event = new ShowToastEvent({
      title: theTitle,
      message: theMessage,
      variant: theVariant
    });
    this.dispatchEvent(event);
  }
}
