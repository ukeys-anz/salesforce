import { LightningElement, api } from "lwc";
import { fetchTooltipContent } from "./helper/dynamicTooltipUtilHelper";

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
        // eslint-disable-next-line @lwc/lwc/no-inner-html
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
