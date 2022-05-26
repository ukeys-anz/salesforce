/**
 * @author Mouhamed "Mo" Assafiri
 * @date Oct 2021
 */

import { LightningElement, api } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { CloseActionScreenEvent } from "lightning/actions";
import { closeFocusedTab } from "c/utils";
import escalateCaseToCMOS from "@salesforce/apex/CaseEscalateToCMOSController.escalateCaseToCMOS";

export default class EscalateToCRC extends NavigationMixin(LightningElement) {
  @api recordId;
  isLoading = false;

  closeAction() {
    this.dispatchEvent(new CloseActionScreenEvent());
    this.isLoading = false;
  }

  escalate() {
    this.isLoading = true;

    escalateCaseToCMOS({
      recordId: this.recordId
    })
      .then(() => {
        this.handleEscalateSuccess();
        closeFocusedTab();
        // Refresh the View once task created
        /**
         * LWC does not support refreshing of the other
         * components on the page and this is the most
         * elegant solution without doing window.refresh()
         * which is much slower 26/06/2022
         */
        /* eslint-disable no-eval */
        eval("$A.get('e.force:refreshView').fire();");
      })
      .catch((error) => {
        var message;

        console.log(error);

        if (typeof error.body != "undefined") {
          message = error.body.message;
        } else {
          message = error;
          console.error(error);
        }

        const title = "Error";
        const variant = "error";

        const event = new ShowToastEvent({ title, message, variant });
        this.dispatchEvent(event);
        this.isLoading = false;
      });
  }

  handleEscalateSuccess() {
    let title = "Success";
    let message = "Case Escalated to CRC";
    let variant = "success";

    const event = new ShowToastEvent({ title, message, variant });
    this.dispatchEvent(event);
    this.closeAction();
  }
}
