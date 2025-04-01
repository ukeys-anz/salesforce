import { loadStyle } from "lightning/platformResourceLoader";
import styling from "@salesforce/resourceUrl/sopStyling";
import LightningModal from "lightning/modal";

export default class SopModalUtils extends LightningModal {
  //Constant labels
  addIncome = "Add Income";
  employerDetails = "Employer Details";
  whoWorksHere = "Who Works Here";
  employer = "Employer";
  employmentType = "Employment type";
  startDate = "Start Date";
  incomeSource = "Income Source";
  incomeDetails = "Income Details";
  addIncomeType = "Add Income Type";
  baseSalary = "Base Salary";
  incomeTaxLabel = "Income Tax";
  frequencyLabel = "Frequency";
  amountLabel = "amount";
  overtime = "Overtime";
  bonus = "Bonus";
  comission = "Comission";
  editIncome = "Edit Income";

  incomeVerified = "Income Verified";
  incomeVerification = "Income Verification";
  save = "Save";
  cancel = "Cancel";
  validationMsg = "This field value is missing.";
  baseMsg = "Please exclude any overtime, bonus, etc.";
  overTimeMsg = "You can delete this income if it's not applicable.";
  bonusMsg = "You can delete this income if it's not applicable.";
  comissionMsg = "You can delete this income if it's not applicable.";
  incomeDetailError = "This income type already exists.";
  //Delete modal constants
  incomeDelConfirmation = "Are you sure you want to delete this income record?";
  incomeDelErrorMsg =
    "You can't delete this income record, as there must be at least one income record for this application.";
  incomeDelErrorMsgDetails =
    "Please add another income record before deleting this one.";
  debtDelConfirmation = "Are you sure you want to delete this debt record?";
  debtDelErrorMsg =
    "You can't delete this home loan record, as there must be at least one home loan record for this application.";
  debtDelErrorMsgDetails =
    "Please add another home loan record before deleting this one.";
  deleteIncomeLabel = "Delete Income";
  deleteDebtLabel = "Delete Debt";

  connectedCallback() {
    Promise.all([loadStyle(this, styling)]);
  }
}
