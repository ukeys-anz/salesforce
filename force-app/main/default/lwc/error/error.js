import { LightningElement, api } from "lwc";

export default class Error extends LightningElement {
  @api message;
  @api code;
  @api permissionIssue;
  @api errorImageUrl;
  errorMessage;

  connectedCallback() {
    if (this.permissionIssue) {
      this.errorMessage = `Don’t worry, it's not broken. You need an extra permission level to view this.`;
    }
    if (this.code && this.message) {
      this.errorMessage = `${this.code.toUpperCase()} - ${this.message}`;
    } else if (!this.code && this.message) {
      this.errorMessage = this.message;
    }
  }
}
