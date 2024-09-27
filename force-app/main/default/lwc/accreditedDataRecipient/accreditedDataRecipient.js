import { LightningElement, track, wire } from "lwc";
import getDataFromApi from "@salesforce/apex/ADRController.getDataFromApi";
import modal from "@salesforce/resourceUrl/accreditedDataRecipientCSS";
import { loadStyle } from "lightning/platformResourceLoader";
import ADRModal from "c/adrActionModal";
import { ShowToastEvent } from "lightning/platformShowToastEvent";

const RECORDS_PER_PAGE = 100;

export default class AccreditedDataRecipient extends LightningElement {
  scrollToTop() {
    const cardContent = this.template.querySelector(".centered-container");
    if (cardContent) {
      cardContent.scrollIntoView({ top: 0, behavior: "smooth" });
    }
  }

  columns = [
    {
      label: "Accredited Data Recipient",
      fieldName: "nameBrandConcat",
      hideDefaultActions: true,
      sortable: true,
      fixedWidth: 600,
      cellAttributes: { class: "column-padding" },
      wrapText: true
    },
    {
      label: "Status",
      fieldName: "statusUpdateConcat",
      hideDefaultActions: true,
      sortable: true,
      fixedWidth: 300,
      cellAttributes: { class: "column-padding" }
    },
    {
      label: "",
      type: "button",
      typeAttributes: {
        label: { fieldName: "buttonLabel" },
        name: "actionButton",
        title: { fieldName: "buttonTitle" },
        disabled: { fieldName: "isButtonDisabled" },
        variant: { fieldName: "buttonVariant" },
        class: "large-button",
        hideDefaultActions: true,
        fixedWidth: 300
      },
      cellAttributes: {
        alignment: "center",
        class: "column-padding"
      }
    }
  ];

  searchKey = "";
  @track data = [];
  @track filteredData = [];
  @track paginatedData = [];
  currentPage = 1;
  sortBy = "nameBrandConcat";
  sortDirection = "asc";
  isLoading = true;
  showError = false;
  errorMessage = "";
  totalRecords = 0;
  actionName = "";
  currentDateTime = new Date();

  connectedCallback() {
    loadStyle(this, modal);
  }

  @wire(getDataFromApi, { dateTimeValue: "$currentDateTime" })
  wiredData({ error, data }) {
    if (data) {
      this.data = data.map((item) => {
        if (item.isError === "insufficientAccess") {
          this.showError = true;
          this.errorMessage =
            "You don't have required permission to perform this action.";
          this.isLoading = false;
        } else if (item.isError === "serverError") {
          this.showError = true;
          this.errorMessage =
            "The server encountered an unexpected error. Please retry after some time.";
          this.isLoading = false;
        }

        let buttonVariant = "";
        let isButtonDisabled = true;

        if (item.status === "ACTIVE") {
          this.actionName = "Suspend";
          buttonVariant = "destructive";
          isButtonDisabled = false;
        } else if (item.status === "ANZX_SUSPENDED") {
          this.actionName = "Reactivate";
          buttonVariant = "brand";
          isButtonDisabled = false;
        } else {
          this.actionName = "";
          buttonVariant = "base";
          isButtonDisabled = true;
        }

        return {
          ...item,
          buttonLabel: this.actionName,
          buttonVariant: buttonVariant,
          isButtonDisabled: isButtonDisabled,
          buttonTitle: this.actionName,
          class: "slds-m-left_x-medium",
          status: item.status
        };
      });

      this.filteredData = this.data;
      this.sortData();
      this.totalRecords = this.filteredData.length;
      this.currentPage = 1;
      this.updatePaginatedData();
      this.isLoading = false;
      if (this.searchKey) {
        this.filterData();
      }
    } else if (error) {
      this.showNotification(
        "Error",
        "Error occurred while fetching ADR details.",
        "error"
      );
      this.isLoading = false;
    }
  }

  showNotification(titleText, messageText, variant) {
    const evt = new ShowToastEvent({
      title: titleText,
      message: messageText,
      variant: variant
    });
    this.dispatchEvent(evt);
  }

  updatePaginatedData() {
    if (this.currentPage > this.totalPages) {
      this.currentPage = this.totalPages;
    }
    const start = (this.currentPage - 1) * RECORDS_PER_PAGE;
    const end = start + RECORDS_PER_PAGE;
    this.paginatedData = this.filteredData.slice(start, end);
  }

  handleSearchInput(event) {
    this.searchKey = event.target.value.toLowerCase();
    this.filterData();
  }

  filterData() {
    if (this.searchKey) {
      this.filteredData = this.data.filter((item) => {
        const nameBrandConcat = item?.nameBrandConcat?.toLowerCase() || "";
        return nameBrandConcat.includes(this.searchKey);
      });
    } else {
      this.filteredData = this.data;
      this.currentPage = 1;
    }

    this.totalRecords = this.filteredData.length;
    this.sortData();
    this.updatePaginatedData();
  }

  handleSort(event) {
    const { fieldName: sortedBy, sortDirection } = event.detail;
    this.sortBy = sortedBy;
    this.sortDirection = sortDirection;
    this.sortData();
    this.updatePaginatedData();
  }

  sortData() {
    const { sortBy, sortDirection } = this;
    if (sortBy) {
      const sortedData = [...this.filteredData].sort((a, b) => {
        let valueA = a[sortBy] ? a[sortBy].toLowerCase() : "";
        let valueB = b[sortBy] ? b[sortBy].toLowerCase() : "";
        return (
          valueA.localeCompare(valueB) * (sortDirection === "asc" ? 1 : -1)
        );
      });
      this.filteredData = sortedData;
    }
  }

  handlePrevious() {
    if (this.currentPage > 1) {
      this.currentPage--;
      this.updatePaginatedData();
    }
    this.scrollToTop();
  }

  handleNext() {
    if (this.currentPage * RECORDS_PER_PAGE < this.totalRecords) {
      this.currentPage++;
      this.updatePaginatedData();
    }
    this.scrollToTop();
  }

  handleRowLevelAct(event) {
    const actionToPerform = event.detail.row.buttonTitle;
    const rspId = event.detail.row.id;
    const buttonVariant = event.detail.row.buttonVariant;
    const nameBrandConcat = event.detail.row.nameBrandConcat;
    ADRModal.open({
      label: "Action Modal",
      size: "small",
      options: { actionToPerform, rspId, buttonVariant, nameBrandConcat },
      onrefresh: (e) => {
        e.stopPropagation();
        this.isLoading = true;
        this.currentDateTime = new Date();
      }
    });
  }

  get isFirstPage() {
    return this.currentPage === 1;
  }

  get isLastPage() {
    return this.currentPage * RECORDS_PER_PAGE >= this.totalRecords;
  }

  get totalPages() {
    return Math.ceil(this.totalRecords / RECORDS_PER_PAGE) || 1;
  }
}
