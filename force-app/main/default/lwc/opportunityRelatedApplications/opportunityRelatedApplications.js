import { LightningElement, api, wire, track } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import getApplicationFormsWithProducts from "@salesforce/apex/RelatedAppOnOppController.getApplicationFormsWithProducts";
import getTotalApplicationFormsCount from "@salesforce/apex/RelatedAppOnOppControllerRepository.getTotalRecords";
import { subscribe, MessageContext } from "lightning/messageService";
import CloseModal from "@salesforce/messageChannel/CloseModal__c";
import { refreshApex } from "@salesforce/apex";

export default class OpportunityRelatedApplications extends NavigationMixin(
  LightningElement
) {
  @api recordId;
  @track applicationForms = [];
  currentPage = 1;
  pageSize = 3;
  hasError = false;
  totalApplicationFormsCount = 0;
  subscription = null;
  wiredApplicationFormsResult;
  wiredTotalCountResult;

  columns = [
    {
      label: "Name",
      fieldName: "nameUrl",
      type: "url",
      typeAttributes: { label: { fieldName: "name" }, target: "_self" },
      sortable: true
    },
    {
      label: "Stage",
      fieldName: "stage",
      type: "text",
      sortable: true
    },
    {
      label: "Product",
      fieldName: "productUrl",
      type: "url",
      typeAttributes: { label: { fieldName: "productName" }, target: "_self" },
      sortable: true
    },
    {
      label: "Close Date",
      fieldName: "closeDate",
      type: "date",
      sortable: true
    }
  ];

  get hasData() {
    return this.applicationForms.length > 0;
  }
  get noDataNoError() {
    return !this.hasError && !this.hasData;
  }

  @wire(MessageContext)
  messageContext;

  @wire(getApplicationFormsWithProducts, {
    opportunityId: "$recordId",
    pageSize: "$pageSize",
    pageNumber: "$currentPage"
  })
  wiredApplicationForms(result) {
    this.wiredApplicationFormsResult = result;
    const { data, error } = result;
    if (data) {
      this.applicationForms = data;
      this.hasError = false;
    } else if (error) {
      this.hasError = true;
      console.error("Error:", error);
    }
  }

  @wire(getTotalApplicationFormsCount, { opportunityId: "$recordId" })
  wiredTotalCount(result) {
    this.wiredTotalCountResult = result;
    const { data, error } = result;
    if (data) {
      this.totalApplicationFormsCount = data;
    } else if (error) {
      this.hasError = true;
      console.error("Error fetching total count:", error);
    }
  }

  connectedCallback() {
    this.subscription = subscribe(this.messageContext, CloseModal, (message) =>
      this.handleMessage(message)
    );
  }

  handleMessage(message) {
    if (message.name === "launchAppOnOpp") {
      if (this.wiredApplicationFormsResult) {
        refreshApex(this.wiredApplicationFormsResult);
      }
      if (this.wiredTotalCountResult) {
        refreshApex(this.wiredTotalCountResult);
      }
    }
  }

  get totalPages() {
    if (this.totalApplicationFormsCount && this.pageSize) {
      return Math.ceil(this.totalApplicationFormsCount / this.pageSize);
    }
    return null;
  }

  get disablePrevious() {
    return this.currentPage <= 1;
  }

  get disableNext() {
    return this.currentPage >= this.totalPages;
  }

  handlePreviousPage() {
    if (this.currentPage > 1) {
      this.currentPage--;
    }
  }

  handleNextPage() {
    if (this.currentPage < this.totalPages) {
      this.currentPage++;
    }
  }

  handlePageClick(event) {
    const selectedPage = parseInt(event.target.dataset.page, 10);
    if (selectedPage && selectedPage !== this.currentPage) {
      this.currentPage = selectedPage;
    }
  }

  navigateToApplicationForm(event) {
    const recordId = event.target.dataset.id;
    this[NavigationMixin.Navigate]({
      type: "standard__recordPage",
      attributes: {
        recordId: recordId,
        objectApiName: "ApplicationFormProduct",
        actionName: "view"
      }
    });
  }

  get pageNumbers() {
    return [...Array(this.totalPages).keys()].map((i) => i + 1);
  }

  get totalPagesGreaterThanOne() {
    return this.totalPages > 1;
  }
}
