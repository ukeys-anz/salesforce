/**
 * @author Mouhamed "Mo" Assafiri
 * @date Mar 2022
 */

import { LightningElement, track, api } from "lwc";
import { getRecordNotifyChange } from "lightning/uiRecordApi";
import { NavigationMixin } from "lightning/navigation";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { CloseActionScreenEvent } from "lightning/actions";
import mergeOCV from "@salesforce/apex/ChatterMigrationServiceController.migrateViaButton";
import { handleErrorShowToast } from "c/utils";

export default class OCVMerge extends NavigationMixin(LightningElement) {
  @api recordId;
  @track isLoading = false;

  closeAction() {
    this.dispatchEvent(new CloseActionScreenEvent());
  }

  mergeOCVAction() {
    this.isLoading = true;

    mergeOCV({
      recordId: this.recordId
    })
      .then(() => {
        // Refresh the View once Merged
        getRecordNotifyChange([{ recordId: this.recordId }]);

        let title = "Success";
        let message = "Chatter Migration Successful";
        let variant = "success";

        const event = new ShowToastEvent({ title, message, variant });
        this.dispatchEvent(event);

        this.closeAction();
      })
      .catch((error) => {
        var message;

        if (typeof error.body != "undefined") {
          message = error.body.message;
        } else {
          message = error;
        }

        handleErrorShowToast(this, "Error", error, message, "pester");
      })
      .finally(() => {
        this.isLoading = false;
      });
  }
}
