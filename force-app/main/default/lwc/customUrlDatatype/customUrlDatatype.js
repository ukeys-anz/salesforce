import { LightningElement, api } from "lwc";

export default class customUrlDatatype extends LightningElement {
  @api rowdata;
  @api value;
  @api tooltip;
  @api label;

  handleOnClick(event) {
    event.preventDefault();

    const clickUrlEvent = new CustomEvent("clickurl", {
      composed: true,
      bubbles: true,
      cancelable: true,
      detail: this.rowdata
    });
    this.dispatchEvent(clickUrlEvent);
  }
}
