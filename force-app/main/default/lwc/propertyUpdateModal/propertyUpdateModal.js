import { api } from "lwc";
import LightningModal from "lightning/modal";
import reassessCollateralAssessment from "@salesforce/apex/LoanApplicationPropertyController.reassessCollateralAssessment";
import { showToast } from "c/utils";

export default class PropertyUpdateModal extends LightningModal {
  @api recordId;
  isExecuting = false; //use to prevent multiple executions
  showError = false;

  handleCancel() {
    this.close();
  }

  async handleSubmit() {
    //if currently being executed, return
    if (this.isExecuting) {
      return;
    }

    this.isExecuting = true;
    try {
      let resp = await reassessCollateralAssessment({
        recordId: this.recordId
      });

      if (!resp) {
        throw new Error("Failed to reassess collateral assessment");
      }

      showToast(
        this,
        "Update Property",
        "Property information has been successfully updated.",
        "",
        "Success",
        ""
      );
      this.close();
    } catch (error) {
      this.showError = true;
    } finally {
      this.isExecuting = false;
    }
  }
}
