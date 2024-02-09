import { LightningElement, api } from "lwc";
import { notifyRecordUpdateAvailable } from "lightning/uiRecordApi";
import updateSubmitFlag from "@salesforce/apex/SubmitDisputeController.updateSubmitFlag";
import verifyCardTokenNumber from "@salesforce/apex/SubmitDisputeController.verifyCardTokenNumber";

// Util methods
import { handleErrorShowToast, showToast } from "c/utils";

export default class SubmitDispute extends LightningElement {
  @api recordId;
  loading;
  cardTokenNumberIsMissing;
  showMissingTokenCardModal;

  handleCancel() {
    this.showMissingTokenCardModal = false;
  }

  handleProceed() {
    this.showMissingTokenCardModal = false;
    this.callUpdate();
  }

  @api invoke() {
    verifyCardTokenNumber({ caseId: this.recordId }).then((result) => {
      this.cardTokenNumberIsMissing = result;

      if (this.cardTokenNumberIsMissing) {
        this.showMissingTokenCardModal = true;
      } else {
        this.callUpdate();
      }
    });
  }

  callUpdate = () => {
    this.loading = true;
    updateSubmitFlag({
      caseId: this.recordId
    })
      .then((result) => {
        if (result) {
          this.loading = false;
          showToast(
            this,
            "Dispute submitted",
            "Dispute submitted successfully",
            "",
            "Success",
            ""
          );
          notifyRecordUpdateAvailable([{ recordId: this.recordId }]);
        } else {
          this.loading = false;
          handleErrorShowToast(
            this,
            "Dispute not submitted",
            "",
            "Dispute unable to be submitted",
            ""
          );
        }
      })
      .catch((error) => {
        handleErrorShowToast(
          this,
          "Dispute not submitted",
          error,
          "Dispute unable to be submitted",
          ""
        );
      });
  };
}
