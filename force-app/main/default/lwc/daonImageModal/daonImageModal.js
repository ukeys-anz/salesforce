import { api } from "lwc";
import LightningModal from "lightning/modal";

export default class DaonImageModal extends LightningModal {
  @api url;

  disableClick(event) {
    event.preventDefault();
  }
}
