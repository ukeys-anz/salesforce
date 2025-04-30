import { api } from "lwc";
import LightningModal from "lightning/modal";
import { handleErrorShowToast } from "c/utils";
import getBelongsToOptions from "@salesforce/apex/SOPController.getBelongsToOptions";

export const TYPE_MAP = {
  LIABILITY_TYPE_UNSPECIFIED: "Unspecified",
  LIABILITY_TYPE_CREDIT_CARD: "Credit Card",
  LIABILITY_TYPE_HOME_LOAN: "Home Loan",
  LIABILITY_TYPE_LEASE_HIRE_PURCHASE: "Vehicle Lease/Hire Purchase",
  LIABILITY_TYPE_PERSONAL_LOAN: "Personal Loan",
  LIABILITY_TYPE_STUDENT_LOAN: "HECS-HELP",
  LIABILITY_TYPE_VEHICLE_LOAN: "Vehicle Loan",
  LIABILITY_TYPE_LINE_OF_CREDIT: "Line of Credit",
  LIABILITY_TYPE_OVERDRAFT: "Overdraft",
  LIABILITY_TYPE_MARGIN_LOAN: "Margin Loan",
  LIABILITY_TYPE_BPL_FACILITY: "Buy Now Pay Later",
  LIABILITY_TYPE_OTHER_LIABILITY: "Other Limit Liability",
  LIABILITY_TYPE_OTHER_LOAN: "Other Loan",
  LIABILITY_TYPE_PROPERTY_LOAN: "Property Loan",
  LIABILITY_TYPE_BPL_LOAN: "Buy Now Pay Later"
};

export default class SopEditDebtsContainer extends LightningModal {
  @api recordId;
  @api debtData;
  @api debtType;
  @api parties;
  @api refinancedAssets;
  @api propertyAssets;
  modalTitle = "Edit Debt";
  belongsToOptions;
  loading;
  hasBelongsToError;
  belongsToErrorMessage =
    "Failed to retrieve party list. Please refresh and try again. Raise a fault through TechAssist if the problem persists";
  showCancelButton = true;
  showSaveButton = false;

  async connectedCallback() {
    try {
      this.loading = true;
      this.modalTitle = `Edit ${TYPE_MAP[this.debtType]}`;
      this.belongsToOptions = await getBelongsToOptions({
        parties: this.parties,
        loanAppId: this.recordId
      });
      this.showSaveButton = true;
    } catch (error) {
      this.hasBelongsToError = true;
      this.showSaveButton = false;
      handleErrorShowToast(
        this,
        "Edit Debt",
        error,
        "Failed to initiate edit debt data. Please refresh and try again. Raise a fault through TechAssist if the problem persists"
      );
    } finally {
      this.loading = false;
    }
  }

  //Close modal on the click of cancel button
  handleClose() {
    this.close();
  }

  async handleSave() {
    this.showSaveButton = false;
    this.showCancelButton = false;
    if (
      await this.template
        .querySelector("c-sop-add-edit-debts")
        .handleAddEditDebt()
    ) {
      this.close();
    } else {
      this.showSaveButton = true;
      this.showCancelButton = true;
    }
  }
}
