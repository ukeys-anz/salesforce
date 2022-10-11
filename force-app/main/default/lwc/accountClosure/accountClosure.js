import getPackageClosureAura from "@salesforce/apex/StravinskyController.getPackageClosureAura";
import { api, LightningElement } from "lwc";
import hasAccountClosurePermission from "@salesforce/customPermission/ANZx_Account_Closure";
import { handleErrorShowToast, showToast } from "c/utils";

export default class AccountClosure extends LightningElement {
  @api recordId;
  loading = false;
  anzPlusValue;
  anzSaveValue;
  cardValue;
  packageValue;
  showConfirmation = false;
  packageData = {
    meta: {
      accountA1: { status: null },
      accountS1: { status: null },
      card: { status: null },
      overall_package: { status: null }
    }
  };

  get displayEnabledButton() {
    return hasAccountClosurePermission;
  }

  toggleConfirmation() {
    this.showConfirmation = !this.showConfirmation;
  }

  async handleClosure() {
    if (hasAccountClosurePermission) {
      this.loading = true;
      this.toggleConfirmation();
      try {
        this.packageData = await getPackageClosureAura({
          recordId: this.recordId
        });

        //Set default messages and variant
        let message = "Account closure successful";
        let variant = "Success";

        if (this.packageData?.status?.code === 200) {
          //Build out the meta to display success statuses
          //as its not returned from API
          this.packageData.meta = {
            accountA1: { status: "Success" },
            accountS1: { status: "Success" },
            card: { status: "Success" },
            overall_package: { status: "Success" }
          };
          this.loading = false;
          showToast(this, "Account Closure", message, "", variant, "");
        } else {
          //Set variable if any of the packages fail to close
          let hasError;
          if (this.packageData?.meta) {
            Object.entries(this.packageData.meta).forEach((value) => {
              //Convert status to proper casing
              value[1].status =
                value[1].status.charAt(0) +
                value[1].status.substring(1).toLowerCase();

              //If status isnt successful show error
              if (value[1].status !== "Success") {
                value[1].status = value[1].error;
                hasError = true;
              }
            });
          }
          //If anything fails to close, change message and variant of toast
          if (hasError) {
            message = "Account Closure completed with errors";
            variant = "Warning";
          }
          showToast(this, "Account Closure", message, "", variant, "");
          this.loading = false;
        }
      } catch (error) {
        this.loading = false;
        handleErrorShowToast(
          this,
          "Account Closure Failed",
          error,
          "Account Closure Failed. Please refresh and try again. Raise a fault through TechAssist if the problem persists"
        );
      }

      this.loading = false;
    }
  }

  showToast(theTitle, theMessage) {
    const event = new ShowToastEvent({
      title: theTitle,
      message: theMessage
    });
    this.dispatchEvent(event);
  }
}
