import { LightningElement, api } from "lwc";
import { notifyRecordUpdateAvailable } from "lightning/uiRecordApi";
import updateSubmitFlag from "@salesforce/apex/SubmitDisputeController.updateSubmitFlag";
import verifyCardTokenNumber from "@salesforce/apex/SubmitDisputeController.verifyCardTokenNumber";

// Util methods
import { handleErrorShowToast, showToast } from "c/utils";

const FIELD_CUSTOM_VALIDATION_EXCEPTION = "FIELD_CUSTOM_VALIDATION_EXCEPTION,";
const INSUFFICIENT_ACCESS_OR_READONLY = "INSUFFICIENT_ACCESS_OR_READONLY,";
const TOAST_ERROR_TITLE = "Dispute not submitted";
const TOAST_ERROR_DEFAULT_MESSAGE = "Dispute unable to be submitted";

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
            TOAST_ERROR_TITLE,
            "",
            TOAST_ERROR_DEFAULT_MESSAGE,
            ""
          );
        }
      })
      .catch((error) => {
        this.loading = false;
        handleErrorShowToast(
          this,
          TOAST_ERROR_TITLE,
          this.processError(error),
          TOAST_ERROR_DEFAULT_MESSAGE,
          ""
        );
      });
  };

  processError(error) {
    let msg = error.body.message;
    let searchTxtIndex = msg.indexOf(FIELD_CUSTOM_VALIDATION_EXCEPTION);
    let err = JSON.parse(JSON.stringify(error)); //shallow copy of error obj

    if (searchTxtIndex !== -1) {
      err.body.message = msg.slice(
        searchTxtIndex + FIELD_CUSTOM_VALIDATION_EXCEPTION.length,
        -(msg.length - msg.lastIndexOf(": ["))
      );
      return err;
    }
    if (msg.indexOf(INSUFFICIENT_ACCESS_OR_READONLY) !== -1) {
      err.body.message = "You are not allowed to submit the Dispute Case.";
      return err;
    }
    return error;
  }
}
