import { api } from "lwc";
import LightningModal from "lightning/modal";
import SOP_DEBTS from "@salesforce/resourceUrl/SOP_Debts";
import getBelongsToOptions from "@salesforce/apex/SOPController.getBelongsToOptions";
import { handleErrorShowToast } from "c/utils";

const TYPE_MAP = {
  LIABILITY_TYPE_CREDIT_CARD: "Credit Card",
  LIABILITY_TYPE_HOME_LOAN: "Home Loan",
  LIABILITY_TYPE_LEASE_HIRE_PURCHASE: "Vehicle Lease/Hire Purchase",
  LIABILITY_TYPE_PERSONAL_LOAN: "Personal Loan",
  LIABILITY_TYPE_STUDENT_LOAN: "HECS-HELP",
  LIABILITY_TYPE_LINE_OF_CREDIT: "Line of Credit",
  LIABILITY_TYPE_VEHICLE_LOAN: "Vehicle Loan",
  LIABILITY_TYPE_OVERDRAFT: "Overdraft",
  LIABILITY_TYPE_MARGIN_LOAN: "Margin Loan",
  LIABILITY_TYPE_OTHER_LOAN: "Other Loan",
  LIABILITY_TYPE_BPL_FACILITY: "Buy Now Pay Later",
  LIABILITY_TYPE_BPL_LOAN: "Buy Now Pay Later"
};
export default class SopAddDebtsContainer extends LightningModal {
  @api recordId;
  @api parties;
  @api refinancedAssets;
  @api propertyAssets;
  logoImage = SOP_DEBTS;
  selectedDebtType;
  noSelectedDebtError = false;
  showDebtSelection = true;
  showBNPLSelection = false;
  showAddForm = false;
  showNextButton = true;
  showBackButton = false;
  showSaveButton = false;
  showCancelButton = true;
  modalTitle = "Add Debt";
  belongsToOptions;
  hasBelongsToError;
  belongsToErrorMessage =
    "Failed to retrieve party list. Please refresh and try again. Raise a fault through TechAssist if the problem persists";
  debtOptions = [
    { label: "Home Loan", value: "LIABILITY_TYPE_HOME_LOAN" },
    { label: "Credit Card", value: "LIABILITY_TYPE_CREDIT_CARD" },
    { label: "Personal Loan", value: "LIABILITY_TYPE_PERSONAL_LOAN" },
    { label: "Vehicle Loan", value: "LIABILITY_TYPE_VEHICLE_LOAN" },
    { label: "Buy Now Pay Later", value: "BNPL" }, //BNPL has its own selection form
    {
      label: "Vehicle Lease / Hire Purchase",
      value: "LIABILITY_TYPE_LEASE_HIRE_PURCHASE"
    },
    { label: "HECS - HELP", value: "LIABILITY_TYPE_STUDENT_LOAN" },
    { label: "Line of Credit", value: "LIABILITY_TYPE_LINE_OF_CREDIT" },
    { label: "Overdraft", value: "LIABILITY_TYPE_OVERDRAFT" },
    { label: "Margin Loan", value: "LIABILITY_TYPE_MARGIN_LOAN" },
    { label: "Other Loan", value: "LIABILITY_TYPE_OTHER_LOAN" }
  ];

  bnplOptions = [
    {
      label: "Fixed Amount - A lump sum paid off over time",
      value: "LIABILITY_TYPE_BPL_LOAN"
    },
    {
      label: "Spend Limit - Spend up to a limit like a credit card",
      value: "LIABILITY_TYPE_BPL_FACILITY"
    }
  ];

  async connectedCallback() {
    try {
      this.belongsToOptions = await getBelongsToOptions({
        parties: this.parties,
        loanAppId: this.recordId
      });
    } catch (error) {
      this.hasBelongsToError = true;
      this.showDebtSelection = false;
      this.showBNPLSelection = false;
      this.showAddForm = false;
      this.showNextButton = false;
      this.showBackButton = false;
      this.showSaveButton = false;
      handleErrorShowToast(
        this,
        "Add Debt Failure",
        error,
        this.belongsToErrorMessage
      );
    }
  }

  //Close modal on the click of cancel button
  handleClose() {
    this.close();
  }

  //Store the selected Loan Type
  handleDebtType(event) {
    this.selectedDebtType = event.target.value;
    this.noSelectedDebtError = false;
  }

  handleAddDebtForSelectedType() {
    if (
      !this.selectedDebtType ||
      (this.showBNPLSelection && this.selectedDebtType === "BNPL")
    ) {
      this.noSelectedDebtError = true;
      return;
    }
    this.showDebtSelection = false;
    if (this.selectedDebtType === "BNPL") {
      this.showAddForm = false;
      this.showBNPLSelection = true;
      return;
    }
    this.showBNPLSelection = false;
    this.showAddForm = true;
    this.showNextButton = false;
    this.showBackButton = true;
    this.showSaveButton = true;
    this.modalTitle = `Add ${TYPE_MAP[this.selectedDebtType]}`;
  }

  handleBack() {
    this.showDebtSelection = true;
    this.showAddForm = false;
    this.showBNPLSelection = false;
    this.showNextButton = true;
    this.showBackButton = false;
    this.showSaveButton = false;
    this.selectedDebtType = null;
    this.modalTitle = "Add Debt";
  }

  async handleSave() {
    this.showSaveButton = false;
    this.showCancelButton = false;
    this.showBackButton = false;
    if (
      await this.template
        .querySelector("c-sop-add-edit-debts")
        .handleAddEditDebt()
    ) {
      this.showAddForm = false;
      this.close();
    } else {
      this.showSaveButton = true;
      this.showCancelButton = true;
      this.showBackButton = true;
    }
  }
}
