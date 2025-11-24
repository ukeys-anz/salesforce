import { LightningElement, api } from "lwc";
import EvidenceModal from "c/merchantEvidenceModal";

export default class MerchantEvidencePopup extends LightningElement {
  @api recordId;
  connectedCallback() {
    // Automatically open modal when Case record loads
    this.showPopup();
  }

  async showPopup() {
    await EvidenceModal.open({
      label: "Case Update Modal",
      size: "small",
      recordId: this.recordId,
      isFromPopup: true
    });
  }
}
