import LightningModal from "lightning/modal";

export default class LoanPreferenceEditDetails extends LightningModal {
  handleClose() {
    this.close("okay");
  }
}
