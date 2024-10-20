import { LightningElement, api, track } from "lwc";
export default class ApplicationFormProductDatatable extends LightningElement {
  @api columns;
  @track _applicationFormProducts = [];
  @track paginatedData = [];
  @track currentPage = 1;
  @track pageSize = 3;
  @track hasData = false;
  connectedCallback() {
    this.updatePagination();
    this.checkForData();
  }
  @api
  set applicationFormProducts(data) {
    this._applicationFormProducts = data;
    this.updatePagination();
    this.checkForData();
  }
  get applicationFormProducts() {
    return this._applicationFormProducts;
  }
  checkForData() {
    this.hasData =
      this._applicationFormProducts && this._applicationFormProducts.length > 0;
  }
  updatePagination() {
    const startIndex = (this.currentPage - 1) * this.pageSize;
    const endIndex = startIndex + this.pageSize;
    this.paginatedData = this._applicationFormProducts.slice(
      startIndex,
      endIndex
    );
  }
  get dataTableTotalPages() {
    return Math.ceil(this._applicationFormProducts.length / this.pageSize);
  }
  get dataTablePageNumbers() {
    return [...Array(this.dataTableTotalPages).keys()].map((i) => i + 1);
  }
  get disableDataTablePrevious() {
    return this.currentPage <= 1;
  }
  get disableDataTableNext() {
    return this.currentPage >= this.dataTableTotalPages;
  }
  get dataTableTotalPagesGreaterThanOne() {
    return this.dataTableTotalPages > 1;
  }
  handlePreviousPage() {
    if (this.currentPage > 1) {
      this.currentPage -= 1;
      this.updatePagination();
    }
  }
  handleNextPage() {
    if (this.currentPage < this.dataTableTotalPages) {
      this.currentPage += 1;
      this.updatePagination();
    }
  }
  handlePageClick(event) {
    const selectedPage = parseInt(event.target.dataset.page, 10);
    if (selectedPage && selectedPage !== this.currentPage) {
      this.currentPage = selectedPage;
      this.updatePagination();
    }
  }
}
