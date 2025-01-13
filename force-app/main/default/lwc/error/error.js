import { LightningElement, api } from "lwc";

export default class Error extends LightningElement {
  @api message;
  @api code;
  @api permissionIssue;
  @api errorImageUrl;
  @api customClassFromParent;
  errorClass = "slds-card slds-grid slds-grid_vertical-align-center";
  classesForText =
    "slds-text-align_center slds-text-color_weak slds-text-heading_small";
  emojiClass = "emoji";
  emojiSize = "large";
  iconVariant = "default";
  errorMessage;

  connectedCallback() {
    if (this.customClassFromParent) {
      this.errorClass = `${this.errorClass} ${this.customClassFromParent}`;
      this.classesForText =
        "slds-text-align_center slds-text-color_white slds-text-body_regular";
      this.emojiClass = "emojiSmall";
      this.emojiSize = "small";
      this.iconVariant = "inverse";
    }
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
