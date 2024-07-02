import { LightningElement, api } from "lwc";
import PropertyUpdateModal from "c/propertyUpdateModal";
export default class PropertyUpdate extends LightningElement {
  @api recordId;

  handleOpenClick() {
    PropertyUpdateModal.open({
      size: "small",
      recordId: this.recordId
    });
  }
}
