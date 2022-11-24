import { LightningElement, api } from "lwc";
import { CloseActionScreenEvent } from "lightning/actions";
import { handleErrorShowToast } from "c/utils";
import deleteProspectContact from "@salesforce/apex/CCRMCustomerProfileUpdateHelper.deleteProspectContact";

export default class ProspectDeleteContact extends LightningElement {
  @api recordId;
  isLoading = false;

  async handleConfirmDelete() {
    this.isLoading = true;
    try {
      await deleteProspectContact({ recordId: this.recordId });
    } catch (error) {
      handleErrorShowToast(
        this,
        null,
        error,
        "Error deleting Contact",
        "sticky"
      );
    } finally {
      this.isLoading = false;
      this.dispatchEvent(new CloseActionScreenEvent());
    }
  }

  handleCancel() {
    this.dispatchEvent(new CloseActionScreenEvent());
  }
}
