import { LightningElement, api } from "lwc";

export default class CardTempBlock extends LightningElement {
  @api rId;

  closeAction() {
    const closeWindow = new CustomEvent("close");
    this.dispatchEvent(closeWindow);
  }
}
