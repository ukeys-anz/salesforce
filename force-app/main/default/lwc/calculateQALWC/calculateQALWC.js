import { LightningElement, api } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { updateRecord } from "lightning/uiRecordApi";
import calculateQA from "@salesforce/apex/CalculateQARatingandAssessment.calculateQA";

export default class CalculateQALWC extends LightningElement {
  @api recordId;

  @api invoke() {
    calculateQA({ recordId: this.recordId })
      .then((result) => {
        if (result) {
          this.dispatchEvent(
            new ShowToastEvent({
              title: "Success",
              message: "Assessment outcome updated successfully",
              variant: "success"
            })
          );
          this.error = undefined;
          updateRecord({ fields: { Id: this.recordId } });
        }
      })
      .catch((error) => {
        if (error.body) {
          this.dispatchEvent(
            new ShowToastEvent({
              title: "Error",
              message: "Assessment outcome was unsuccessful. Please try again.",
              variant: "error"
            })
          );
        }
      });
  }
}
