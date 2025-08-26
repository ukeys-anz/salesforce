import { LightningElement, api, track } from "lwc";
import { handleErrorShowToast, showToast } from "c/utils";
import verifyInsurance from "@salesforce/apex/ProofOfInsuranceController.verifyInsurance";

export default class VerifyProofOfInsurance extends LightningElement {
  @api recordId;
  @track isShowModal = false;

  showModalBox() {
    this.isShowModal = true;
  }

  hideModalBox() {
    this.isShowModal = false;
  }

  _requestObj;
  @api set requestObj(requestObj) {
    this._requestObj = requestObj;
  }
  get requestObj() {
    return this._requestObj;
  }

  isExecuting = false;

  async handleVerify() {
    if (this.isExecuting) {
      return;
    }
    this.isExecuting = true;
    try {
      let response = await verifyInsurance({
        settlementId: this.requestObj.settlementId,
        mortgageContractId: this.requestObj.mortgageContractId,
        propertyId: this.requestObj.propertyId,
        documentId: this.requestObj.document.id,
        documentFileVersion:
          this.requestObj.document.documentFileDetails[0].documentFileVersion
      });
      //The API should always set to State verified, but the response has multiple states,
      //so handling here just in case something on API ever changes to avoid errors
      if (response?.proofOfInsuranceVerification?.state === "STATE_VERIFIED") {
        this.hideModalBox();
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
    const selectEvent = new CustomEvent("closeevent", {
      detail: "closeModal"
    });
    this.dispatchEvent(selectEvent);
  }
}
