/**
 * @author Mouhamed "Mo" Assafiri
 * @date Oct 2021
 */

import { LightningElement, track, api } from "lwc";
import { getRecordNotifyChange } from "lightning/uiRecordApi";
import { NavigationMixin } from "lightning/navigation";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { CloseActionScreenEvent } from "lightning/actions";
import escalateCaseToCMOS from "@salesforce/apex/CaseEscalateToCMOSController.escalateCaseToCMOS";
import { handleErrorShowToast, handleErrors } from "c/utils";
export default class EscalateToCRC extends NavigationMixin(LightningElement) {
  @api recordId;
  @track isLoading = false;

  closeAction() {
    this.dispatchEvent(new CloseActionScreenEvent());
  }

  escalate() {
    this.isLoading = true;

    escalateCaseToCMOS({
      recordId: this.recordId
    })
      .then(() => {
        // Refresh the View once escalated
        getRecordNotifyChange([{ recordId: this.recordId }]);

        let title = "Success";
        let message = "Case Escalated to CRC";
        let variant = "success";

        const event = new ShowToastEvent({ title, message, variant });
        this.dispatchEvent(event);

        this.closeAction();
      })
      .catch((error) => {
        this.handleError(error);
      })
      .finally(() => {
        this.isLoading = false;
      });
  }

  handleError = (error) => {
    const errorMsg = handleErrors.call(this, error);
    handleErrorShowToast(this, "Error", "", errorMsg, "pester");
    this.closeAction();
  };
}
