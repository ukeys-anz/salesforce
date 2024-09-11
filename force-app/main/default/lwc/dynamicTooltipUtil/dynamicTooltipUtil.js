import { LightningElement, api } from "lwc";
import { fetchTooltipContent } from "c/tooltipContents";

export default class DynamicTooltipUtil extends LightningElement {
  @api headerTitle;
  @api resourceName;
  hasRendered = false;

  renderedCallback() {
    if (!this.hasRendered) {
      this.hasRendered = true;
      const tooltipContentMarkup = this.template.querySelector(
        ".tooltip-content-markup"
      );
      if (tooltipContentMarkup) {
        tooltipContentMarkup.innerHTML = "";
        tooltipContentMarkup.innerHTML = fetchTooltipContent(this.resourceName);
      }
    }
  }

  closeModal(event) {
    event.preventDefault();
    const closeModalEvent = new CustomEvent("closemodal");
    this.dispatchEvent(closeModalEvent);
  }
}
