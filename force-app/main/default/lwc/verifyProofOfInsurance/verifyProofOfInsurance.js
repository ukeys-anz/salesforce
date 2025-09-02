import { LightningElement, api } from "lwc";
import { handleErrorShowToast, showToast } from "c/utils";
import verifyInsurance from "@salesforce/apex/ProofOfInsuranceController.verifyInsurance";
import { CloseActionScreenEvent } from "lightning/actions";

export default class VerifyProofOfInsurance extends LightningElement {
  _recordId;
  @api set recordId(recordId) {
    if (recordId !== this._recordId) {
      this._recordId = recordId;
    }
  }
  get recordId() {
    return this._recordId;
  }

  isExecuting = false;

  async handleVerify() {
    if (this.isExecuting) {
      return;
    }
    this.isExecuting = true;
    try {
      let response = await verifyInsurance({ recordId: this._recordId });
      //The API should always set to State verified, but the response has multiple states,
      //so handling here just in case something on API ever changes to avoid errors
      if (response?.proofOfInsuranceVerification?.state === "STATE_VERIFIED") {
        this.dispatchEvent(new CloseActionScreenEvent());
        showToast(
          this,
          "Verify Insurance",
          "The Proof of Insurance Document has been successfully verified.",
          "",
          "Success",
          ""
        );
      } else if (
        response?.proofOfInsuranceVerification?.state === "STATE_REJECTED"
      ) {
        showToast(
          this,
          "Verify Insurance",
          "The Proof of Insurance Document verification has been rejected.",
          "",
          "Warn",
          ""
        );
      } else {
        throw new Error("Insurance verification failed");
      }
    } catch (error) {
      handleErrorShowToast(
        this,
        "Verify Insurance Failed",
        error,
        "Verify Insurance Failed. Please refresh and try again. Raise a fault through TechAssist if the problem persists."
      );
    } finally {
      this.isExecuting = false;
    }
  }

  handleCancel() {
    this.dispatchEvent(new CloseActionScreenEvent());
  }
}
