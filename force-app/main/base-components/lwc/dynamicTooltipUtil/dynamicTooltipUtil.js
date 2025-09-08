import { LightningElement, api } from "lwc";
import {
  loadTooltipMap,
  fetchTooltipContent
} from "./helper/dynamicTooltipUtilHelper";

export default class DynamicTooltipUtil extends LightningElement {
  @api headerTitle;
  @api resourceName;
  @api productName;

  async connectedCallback() {
    // Load the tooltip data from the static resource
    await loadTooltipMap();
    this.getTooltipContent();
  }

  getTooltipContent() {
    const tooltipContentMarkup = this.template.querySelector(
      ".tooltip-content-markup"
    );
    if (tooltipContentMarkup) {
      // eslint-disable-next-line @lwc/lwc/no-inner-html
      tooltipContentMarkup.innerHTML = fetchTooltipContent(
        this.resourceName,
        this.productName
      );
    }
  }

  closeModal(event) {
    event.preventDefault();
    const closeModalEvent = new CustomEvent("closemodal");
    this.dispatchEvent(closeModalEvent);
  }
}
