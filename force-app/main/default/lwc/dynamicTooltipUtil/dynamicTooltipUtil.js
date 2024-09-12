import { LightningElement, api } from "lwc";
import { fetchTooltipContent } from "c/tooltipContents";

export default class DynamicTooltipUtil extends LightningElement {
  @api headerTitle;
  @api resourceName;
  hasRendered = false;

  renderedCallback() {
    if (!this.hasRendered) {
      this.hasRendered = true;
      const contentSpan = document.createElement("span");
      contentSpan.innerHTML = fetchTooltipContent(this.resourceName);
      const tooltipContentMarkup = this.template.querySelector(
        ".tooltip-content-markup"
      );
      if (tooltipContentMarkup) {
        tooltipContentMarkup.appendChild(contentSpan);
      }
    }
  }

  closeModal(event) {
    event.preventDefault();
    const closeModalEvent = new CustomEvent("closemodal");
    this.dispatchEvent(closeModalEvent);
  }
}
