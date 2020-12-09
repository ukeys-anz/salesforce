import { LightningElement, api } from "lwc";

export default class Error extends LightningElement {
  @api message;
  @api code;
  errorMessage;

  connectedCallback() {
    if (this.code && this.message) {
      this.errorMessage = `${this.code.toUpperCase()} - ${this.message}`;
    } else if (!this.code && this.message) {
      this.errorMessage = this.message;
    }
  }
}
