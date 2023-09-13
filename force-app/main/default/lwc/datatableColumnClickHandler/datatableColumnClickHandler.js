import { LightningElement, api } from "lwc";

export default class DatatableColumnClickHandler extends LightningElement {
  @api cellValue;
  @api recordId;
  @api sObjectApiName;

  handleClick() {
    const event = new CustomEvent("datatablecolumnclickhandler", {
      composed: true,
      bubbles: true,
      cancelable: true,
      detail: {
        recordId: this.recordId,
        objectApiName: this.sObjectApiName
      }
    });
    this.dispatchEvent(event);
  }
}
