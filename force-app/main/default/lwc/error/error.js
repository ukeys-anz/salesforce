import { LightningElement, api } from "lwc";

export default class Error extends LightningElement {
  @api message;
  @api code;
  @api permissionIssue;
  errorMessage;

  connectedCallback() {
    if (this.permissionIssue) {
      this.errorMessage = `Don’t worry, it's not broken. To view this you need a higher permission level.`;
    }
    if (this.code && this.message) {
      this.errorMessage = `${this.code.toUpperCase()} - ${this.message}`;
    } else if (!this.code && this.message) {
      this.errorMessage = this.message;
    }
  }
}
