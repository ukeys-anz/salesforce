import { OmniscriptBaseMixin } from "omnistudio/omniscriptBaseMixin";
import { LightningElement, track } from "lwc";
import tmp from "./prodServiceError.html";

export default class ProdServiceError extends OmniscriptBaseMixin(
  LightningElement
) {
  @track showError = false;
  @track errorMsg = "";

  render() {
    if (this.omniJsonData && this.omniJsonData.showProdServiceError === "Yes") {
      this.errorMsg +=
        "Please update " +
        this.omniJsonData.prodErrorMsg.substring(
          0,
          this.omniJsonData.prodErrorMsg.length - 2
        ) +
        " before closing the case.";
      this.showError = true;
    }
    return tmp;
  }
}
