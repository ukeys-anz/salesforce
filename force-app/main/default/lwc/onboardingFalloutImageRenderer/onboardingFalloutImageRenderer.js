import { LightningElement, api } from "lwc";

export default class OnboardingFalloutImageRenderer extends LightningElement {
  @api currentFileType;
  @api errorImage;
  @api errorMsg;
  @api showRedBorder;
  @api changeStyle;

  disableRightClick(event) {
    event.preventDefault();
  }

  get cssClass() {
    return (
      "slds-col slds-size_1-of-1 slds-wrap imgContainer" +
      (this.changeStyle ? "Cases" : "")
    );
  }
}
