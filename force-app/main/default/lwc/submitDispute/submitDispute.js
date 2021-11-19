import { LightningElement, api } from "lwc";
import DISPUTE_SUBMITTED from "@salesforce/schema/Case.Submitted__c";
import updateSubmitFlag from "@salesforce/apex/SubmitDisputeController.updateSubmitFlag";

// Util methods
import { handleErrorShowToast, showToast } from "c/utils";

export default class SubmitDispute extends LightningElement {
  @api recordId;
  loading = false;
  objectFields = [DISPUTE_SUBMITTED];

  @api invoke() {
    updateSubmitFlag({
      caseId: this.recordId
    })
      .then((result) => {
        if (result) {
          this.loading = true;
          showToast(
            this,
            "Dispute submitted",
            "Dispute submitted successfully",
            "",
            "Success",
            ""
          );
          // Refresh the View once task created
          /**
           * LWC does not support refreshing of the other
           * components on the page and this is the most
           * elegant solution without doing window.refresh()
           * which is much slower 02/09/2021
           */
          /* eslint-disable no-eval */
          eval("$A.get('e.force:refreshView').fire();");
        } else {
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
  }
}
