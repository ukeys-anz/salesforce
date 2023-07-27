import { LightningElement, track, wire, api } from "lwc";
import getDisableOmni from "@salesforce/apex/Vlocity_Utils.getDisableOmni";
// Util methods
import { handleErrorShowToast } from "c/utils";

export default class closeCase extends LightningElement {
  @track showLWC = false;
  @track showOmni = false;
  @api recordId;

  @wire(getDisableOmni, {})
  responseData({ error, data }) {
    if (data) {
      this.showLWC = true;
      this.showOmni = false;
    } else {
      this.showOmni = true;
      this.showLWC = false;
      if (error) {
        // error handling
        handleErrorShowToast(
          this,
          "Please reach out to administrator ",
          error,
          error.body.message,
          "pester"
        );
      }
    }
  }
}
