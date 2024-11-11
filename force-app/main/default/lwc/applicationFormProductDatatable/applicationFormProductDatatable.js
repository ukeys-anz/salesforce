import { LightningElement, api } from "lwc";
export default class ApplicationFormProductDatatable extends LightningElement {
  @api columns;
  _applicationFormProducts = [];
  currentPage = 1;
  pageSize = 3;

  @api
  set applicationFormProducts(data) {
    this._applicationFormProducts = data;
  }
  get applicationFormProducts() {
    return this._applicationFormProducts;
  }
  get hasData() {
    return this._applicationFormProducts?.length > 0;
  }

  get paginatedData() {
    const startIndex = (this.currentPage - 1) * this.pageSize;
    const endIndex = startIndex + this.pageSize;
    return this._applicationFormProducts.slice(startIndex, endIndex);
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
      this.currentPage--;
    }
  }
  handleNextPage() {
    if (this.currentPage < this.dataTableTotalPages) {
      this.currentPage++;
    }
  }
  handlePageClick(event) {
    const selectedPage = parseInt(event.target.dataset.page, 10);
    if (selectedPage && selectedPage !== this.currentPage) {
      this.currentPage = selectedPage;
    }
  }
}
