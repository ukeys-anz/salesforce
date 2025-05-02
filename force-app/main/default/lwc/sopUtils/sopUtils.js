import { LightningElement, wire } from "lwc";
import { loadStyle } from "lightning/platformResourceLoader";
import styling from "@salesforce/resourceUrl/sopStyling";
import getUserRole from "@salesforce/apex/AuthenticateCustomerController.getUserRole";
import { getRecord, getFieldValue } from "lightning/uiRecordApi";
import STATUS_FIELD from "@salesforce/schema/ResidentialLoanApplication.Status";
import { CurrentPageReference } from "lightning/navigation";

export default class SopUtils extends LightningElement {
  // Button Labels
  editButtonLabel = "Edit";
  deleteButtonLabel = "Delete";
  editDebtButtonLabel = "Edit Debt";

  //Common card labels
  lastModified = "Last Modified";

  // Debt Card Headings
  hecsHelpLabel = "HECS-HELP";
  otherLimitLiabilityLabel = "Other Limit Liability";
  creditCardLabel = "Credit Card";
  homeLoanLabel = "Home Loan";
  overdraftLabel = "Overdraft";
  buyNowPayLater = "Buy Now Pay Later";

  // Debt Card Messages and texts
  debtMessage =
    "These are the debts including any loans, credit cards, buy now pay later or other lines of credit.";
  totalDebts = "Total Debts";
  loanRefinanceLabel = "Loan being refinanced - can't be changed";
  additioanlRepayLabel = "May not include additional repayments.";

  // Debt Card Detail Labels
  belongsToLabel = "Belongs To";
  debtTypeLabel = "Debt Type";
  balanceOwningLabel = "Balance Owing";
  withheldFromPayLabel = "Withheld From Pay";
  debtChangesEvidenceLabel = "Debt Changes Evidence";
  debtSourceLabel = "Debt Source";
  paidOffClosedLabel = "Paid Off & Closed";
  institutionLabel = "Institution";
  bsbLabel = "BSB";
  accountNumberLabel = "Account Number";
  limitLabel = "Limit";
  balanceLabel = "Balance";
  interestRateLabel = "Interest Rate";
  overdraftLimitLabel = "Overdraft Limit";
  updatedAmountForUMILabel = "Updated amount used for UMI";
  creditBureauOverdraftLimitLabel = "Credit Bureau Overdraft Limit";
  creditBureauBalanceLabel = "Credit Bureau Balance";
  redrawLabel = "Redraw";
  remainingTermLabel = "Remaining Term";
  creditBureauRemainingTermLabel = "Credit Bureau Remaining Term";
  reapymentAmountLabel = "Repayment Amount";
  frequencyLabel = "frequency";
  addedToSavingsLabel = "This has also been added to Savings";

  // Currency Code
  currenyCode = "AUD";

  //Credit Card Detail labels
  creditLimitLabel = "Credit Limit";
  minimumMonthlyRepaymentLabel = "Minimum Monthly Repayment";
  monthlyRepaymentLabel = "Monthly Repayment";
  cardNumberLabel = "Card Number";
  creditBureauLimitLabel = "Credit Bureau Credit Limit";
  paidInFullLabel = "Paid In Full (Monthly)";

  //Income Card Labels
  paymentPerYear = "Payments Per Year:";
  amount = "Amount:";
  frequency = "Frequency:";
  incomeTax = "Income Tax:";
  addIncome = "Add Income";
  whoWorksHere = "Who Works Here";
  employer = "Employer";
  employmentType = "Employment Type";
  startDate = "Start Date";
  incomeSource = "Income Source";
  incomeVerified = "Income Verified";

  //Income Card Messages and text
  incomeMessage =
    "This includes income over the last 12 months. It can also add any earnings from side hustles.";
  transactionMsgHeader = "System calculated income";
  transactionMsgBody =
    "The income below is system calculated based on a minimum of 3 months (and up to 12 months) of salary and wages transactions into the customer's account.";
  Bonuses = "Bonuses";
  baseSalary = "Base Salary";
  salaryAndWages = "Salary and Wages";
  commission = "Commission:";
  overtime = "Overtime:";
  totalIncome = "Total Income";

  //Asset Card Headings
  propertyHeader = "Property";
  investmentHeader = "Investment";
  superHeader = "Super";
  vehicleHeader = "Vehicle";
  contentsHeader = "Contents";
  otherHeader = "Other";

  // Asset Card Messages and texts
  assetsMessage =
    "These are all the assets - including any properties, vehicles, investments or any other asset owned.";
  helpText =
    "This is the same amount as the Property Market Value in the Property tab. If this amount is $0, the Property Valuation is pending.";
  totalAssets = "Total Assets";

  //Asset Card Labels
  assetType = "Asset Type";
  address = "Address";
  propertyValuation = "Property Valuation";
  noDataText = "There are no additional assets.";
  name = "Name";
  value = "Value";
  vehicleType = "Vehicle Type";

  //Savings Card Detail labels
  savingsMessage = "This includes any cash and money in your bank accounts.";
  totalSavings = "Total Savings";
  anzPlusHeader = "ANZ Plus";
  anzHeader = "ANZ";
  otherBanksHeader = "Other Institutions";
  cashHeader = "Cash";
  noDataTextSavings = "This customer has no additional savings.";
  productName = "Product Name";
  savingsType = "Savings type";
  savingsAmount = "Amount";
  bankBalance = "Bank Balance";
  cashSavingsType = "Cash";

  //Buy Now Pay Later Details labels
  arrangementTypeLabel = "Arrangement Type";
  spendLimitLabel = "Spend limit";
  creditBureauSpendLimitlabel = "Credit Bureau Spend Limit";
  creditbureauBalanceOwinglabel = "Credit Bureau Balance Owing";
  updatedTermUMILabel = "Updated term used for UMI";
  repaymentFrequencyLabel = "Repayment Frequency";

  // Application Status
  statusReferred = "STATE_REFERRED";

  recordId;
  userRole;
  editIncomeExpenseRole = [
    "BOH_Coach",
    "Credit_Assessment_Officer",
    "Credit_Assessor_Lead",
    "BOH_Coach_Lead"
  ];

  @wire(CurrentPageReference)
  getPageReferenceParameters(currentPageReference) {
    if (currentPageReference) {
      this.recordId = currentPageReference.attributes.recordId;
    }
  }

  // This method get the role of the logged in user
  @wire(getUserRole)
  wiredUserRole({ data }) {
    if (data) {
      this.userRole = data;
    }
  }

  @wire(getRecord, {
    recordId: "$recordId",
    fields: [STATUS_FIELD]
  })
  applicationRecord;

  get applicationStatus() {
    return getFieldValue(this.applicationRecord.data, STATUS_FIELD);
  }

  get isEditIncomeExpenseRole() {
    return this.editIncomeExpenseRole.includes(this.userRole);
  }

  connectedCallback() {
    Promise.all([loadStyle(this, styling)]);
  }
}
