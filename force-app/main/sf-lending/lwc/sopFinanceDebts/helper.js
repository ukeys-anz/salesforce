import HECS_HELP_IMG from "@salesforce/resourceUrl/SOP_Debt_Education";
import DEBT_LOAN from "@salesforce/resourceUrl/SOP_Debt_Loan";
import ANZ_IMG from "@salesforce/resourceUrl/SOP_ANZ_Lotus_Circle";
import CREDIT_CARD_IMG from "@salesforce/resourceUrl/SOP_Debt_Credit_Card";
import HOME_IMG from "@salesforce/resourceUrl/SOP_Debt_Mortgage";
import OVERDRAFT_MANUAL_CREDIT_IMG from "@salesforce/resourceUrl/SOP_Debt_Building_Government";
import BUY_NOW_IMG from "@salesforce/resourceUrl/SOP_Debt_Payment_Future";

const BPL_FACILITY = "LIABILITY_TYPE_BPL_FACILITY";
const BPL_LOAN = "LIABILITY_TYPE_BPL_LOAN";

const SOURCE_ANZ = "ANZ";
const SOURCE_CREDIT_BUREAU = "Credit Bureau";
const SOURCE_MANUAL = "Manual";

export const ACCOUNT_STATUS = {
  ACCOUNT_STATE_UNSPECIFIED: "Unspecified", // there is no info about what status the account is in
  ACCOUNT_STATE_OPEN: "Open", // the account is open
  ACCOUNT_STATE_ACTIVE: "Active", // the account is active
  ACCOUNT_STATE_SUSPENDED: "Suspended", // the account is suspended
  ACCOUNT_STATE_DORMANT: "Dormant", // the account is dormant
  ACCOUNT_STATE_CLOSED: "Closed" // the account is closed
};

export const DEBTS_MAP = [
  {
    title: "Home Loan",
    debts: []
  },
  {
    title: "Line of Credit",
    debts: []
  },
  {
    title: "Credit Card",
    debts: []
  },
  {
    title: "Personal Loan",
    debts: []
  },
  {
    title: "Vehicle Loan",
    debts: []
  },
  {
    title: "Buy Now Pay Later",
    debts: []
  },
  {
    title: "Vehicle Lease/Hire Purchase",
    debts: []
  },
  {
    title: "HECS-HELP",
    debts: []
  },
  {
    title: "Overdraft",
    debts: []
  },
  {
    title: "Margin Loan",
    debts: []
  },
  {
    title: "Other Loan",
    debts: []
  },
  {
    title: "Other Limit Liability",
    debts: []
  }
];

export const FREQUENCY_MAP = {
  FREQUENCY_UNSPECIFIED: "Unspecified",
  FREQUENCY_MONTHLY: "Monthly",
  FREQUENCY_FORTNIGHTLY: "Fortnightly",
  FREQUENCY_WEEKLY: "Weekly",
  FREQUENCY_YEARLY: "Yearly",
  FREQUENCY_QUARTERLY: "Quarterly",
  FREQUENCY_HALF_YEARLY: "Half Yearly",
  FREQUENCY_SEASONAL: "Seasonal",
  FREQUENCY_OTHER: "Other"
};

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
  //BNPL used as credit card
  LIABILITY_TYPE_BPL_FACILITY: "Buy Now Pay Later",
  LIABILITY_TYPE_OTHER_LIABILITY: "Other Limit Liability",
  // Catch-all for other loan types. These can be pre-populated from bureau or manually added
  LIABILITY_TYPE_OTHER_LOAN: "Other Loan",
  // Property loan excluding home loan
  LIABILITY_TYPE_PROPERTY_LOAN: "Property Loan",
  //BNPL used as term loan
  LIABILITY_TYPE_BPL_LOAN: "Buy Now Pay Later"
};

const COMMON_FIELDS = {
  showPaidOffAndClosed: (debt) => debt.paidOffAndClosed,
  showCustomerExcludedDebtMessage: (debt) =>
    !debt.paidOffAndClosed && debt.customerStatedClosed && !debt.hasRefinance,
  showDebtChangeEvidence: (debt) =>
    debt.readableSourceType !== SOURCE_MANUAL && debt.evidenceProvided
};

//Fields for Vehicle Loan, Vehicle Lease/Hire Purchase and Other Loan
const VEHICLE_OTHER_LOAN = {
  ...COMMON_FIELDS,
  showInstitution: true,
  showBsb: (debt) => debt.readableSourceType === SOURCE_ANZ,
  showAccountNumber: (debt) =>
    [SOURCE_ANZ, SOURCE_CREDIT_BUREAU].includes(debt.readableSourceType),
  showAccountStatus: (debt) => debt.readableSourceType === SOURCE_ANZ,
  showBalanceOwing: (debt) => !debt.customerStatedClosed,
  showBalanceOwingMessage: (debt) =>
    debt.validatedOutstandingBalance && !debt.customerStatedClosed,
  showBureauBalanceOwing: (debt) =>
    debt.readableSourceType === SOURCE_CREDIT_BUREAU,
  showRedraw: (debt) => debt.readableSourceType === SOURCE_ANZ,
  showInterestRate: (debt) => debt.readableSourceType === SOURCE_ANZ,
  showRemainingTerm: (debt) => !debt.customerStatedClosed,
  showRemainingTermMessage: (debt) =>
    debt.institutionalLiability?.validatedPrincipalInterestRemainingTerm &&
    !debt.customerStatedClosed,
  showBureauRemainingTerm: (debt) =>
    debt.readableSourceType === SOURCE_CREDIT_BUREAU,
  showRepaymentAmount: (debt) => !debt.customerStatedClosed,
  showRepaymentFrequency: (debt) => !debt.customerStatedClosed,
  showCustomerExcludedDebt: (debt) =>
    debt.readableSourceType === SOURCE_CREDIT_BUREAU,
  // prettier-ignore
  image: (debt) =>
    (debt.readableSourceType === SOURCE_ANZ ? ANZ_IMG : DEBT_LOAN)
};

const DEBT_TYPES = {
  "Home Loan": {
    fields: {
      showInstitution: true,
      showBsb: (debt) => debt.readableSourceType === SOURCE_ANZ,
      showAccountNumber: (debt) =>
        [SOURCE_ANZ, SOURCE_CREDIT_BUREAU].includes(debt.readableSourceType),
      showBalanceOwing: true,
      showBureauBalanceOwing: (debt) =>
        debt.readableSourceType === SOURCE_CREDIT_BUREAU,
      showBureauBalanceMessage: (debt) =>
        debt.readableSourceType === SOURCE_CREDIT_BUREAU,
      showRemainingTerm: true,
      showBureauRemainingTerm: (debt) =>
        debt.readableSourceType === SOURCE_CREDIT_BUREAU,
      showAccountStatus: (debt) => debt.readableSourceType === SOURCE_ANZ,
      showRepaymentAmount: true,
      showRepaymentFrequency: true,
      showRedraw: true,
      showInterestRate: true,
      // prettier-ignore
      image: (debt) =>
        (debt.readableSourceType === SOURCE_ANZ ? ANZ_IMG : HOME_IMG)
    }
  },
  "Credit Card": {
    fields: {
      ...COMMON_FIELDS,
      showInstitution: true,
      showCardNumber: (debt) =>
        debt.readableSourceType === SOURCE_CREDIT_BUREAU,
      showLimit: (debt) => !debt.customerStatedClosed,
      showLimitMessage: (debt) =>
        !debt.customerStatedClosed &&
        debt.institutionalLiability?.validatedLimit,
      showBureauLimit: (debt) =>
        debt.readableSourceType === SOURCE_CREDIT_BUREAU,
      showBalanceOwing: (debt) => !debt.customerStatedClosed,
      showPaidInFull: (debt) =>
        [SOURCE_MANUAL, SOURCE_CREDIT_BUREAU].includes(
          debt.readableSourceType
        ) && !debt.customerStatedClosed,
      showMonthlyRepayment: (debt) =>
        (!debt.institutionalLiability?.paidInFull &&
          debt.readableSourceType !== SOURCE_ANZ &&
          !debt.customerStatedClosed) ||
        debt.readableSourceType === SOURCE_ANZ,
      showInterestRate: (debt) => debt.readableSourceType === SOURCE_ANZ,
      showAccountStatus: (debt) => debt.readableSourceType === SOURCE_ANZ,
      showCustomerExcludedDebt: (debt) =>
        debt.readableSourceType === SOURCE_CREDIT_BUREAU,
      image: (debt) => {
        return debt.readableSourceType === SOURCE_ANZ
          ? ANZ_IMG
          : CREDIT_CARD_IMG;
      }
    }
  },
  "Personal Loan": {
    fields: {
      ...COMMON_FIELDS,
      showInstitution: true,
      showBsb: (debt) => debt.readableSourceType === SOURCE_ANZ,
      showAccountNumber: (debt) =>
        [SOURCE_ANZ, SOURCE_CREDIT_BUREAU].includes(debt.readableSourceType),
      showAccountStatus: (debt) => debt.readableSourceType === SOURCE_ANZ,

      showBalanceOwing: (debt) => !debt.customerStatedClosed,
      showBureauBalanceOwing: (debt) =>
        debt.readableSourceType === SOURCE_CREDIT_BUREAU,
      showBalanceOwingMessage: (debt) =>
        debt.validatedOutstandingBalance && !debt.customerStatedClosed,
      showRedraw: (debt) => debt.readableSourceType === SOURCE_ANZ,
      showLoanType: (debt) => debt.readableSourceType === SOURCE_ANZ,
      showInterestRate: (debt) => debt.readableSourceType === SOURCE_ANZ,
      showRemainingTerm: (debt) => !debt.customerStatedClosed,
      showRemainingTermMessage: (debt) =>
        debt.institutionalLiability?.validatedPrincipalInterestRemainingTerm &&
        !debt.customerStatedClosed,
      showBureauRemainingTerm: (debt) =>
        debt.readableSourceType === SOURCE_CREDIT_BUREAU,
      showRepaymentAmount: (debt) => !debt.customerStatedClosed,
      showRepaymentFrequency: (debt) => !debt.customerStatedClosed,
      showCustomerExcludedDebt: (debt) =>
        debt.readableSourceType === SOURCE_CREDIT_BUREAU,
      showDebtChangeEvidence: (debt) =>
        debt.readableSourceType !== SOURCE_MANUAL && debt.evidenceProvided,
      // prettier-ignore
      image: (debt) =>
        (debt.readableSourceType === SOURCE_ANZ ? ANZ_IMG : DEBT_LOAN)
    }
  },
  "Vehicle Loan": {
    fields: {
      ...VEHICLE_OTHER_LOAN
    }
  },
  "Vehicle Lease/Hire Purchase": {
    fields: {
      ...VEHICLE_OTHER_LOAN
    }
  },
  "Other Loan": {
    fields: {
      ...VEHICLE_OTHER_LOAN
    }
  },
  "Buy Now Pay Later": {
    fields: {
      ...COMMON_FIELDS,
      showInstitution: true,
      showArrangementType: true,
      showAccountNumber: (debt) =>
        debt.readableSourceType === SOURCE_CREDIT_BUREAU,
      showAccountStatus: (debt) => debt.readableSourceType === SOURCE_ANZ,
      showLimit: (debt) =>
        debt.type === BPL_FACILITY && !debt.customerStatedClosed,
      showLimitMessage: (debt) =>
        debt.type === BPL_FACILITY &&
        !debt.customerStatedClosed &&
        debt.institutionalLiability?.validatedLimit,
      showBureauLimit: (debt) =>
        debt.type === BPL_FACILITY &&
        debt.readableSourceType === SOURCE_CREDIT_BUREAU,
      showBalanceOwing: (debt) => !debt.customerStatedClosed,
      showBalanceOwingMessage: (debt) =>
        debt.validatedOutstandingBalance && !debt.customerStatedClosed,
      showPaidInFull: (debt) =>
        (debt.showBureauBalanceOwing =
          debt.type === BPL_FACILITY && !debt.customerStatedClosed),
      showBureauBalanceOwing: (debt) =>
        debt.readableSourceType === SOURCE_CREDIT_BUREAU &&
        debt.type === BPL_LOAN,
      showRemainingTerm: (debt) =>
        debt.type === BPL_LOAN && !debt.customerStatedClosed,
      showRemainingTermMessage: (debt) =>
        debt.type === BPL_LOAN &&
        !debt.customerStatedClosed &&
        debt.institutionalLiability?.validatedPrincipalInterestRemainingTerm,
      showBureauRemainingTerm: (debt) =>
        BPL_LOAN && debt.readableSourceType === SOURCE_CREDIT_BUREAU,
      showMonthlyRepayment: (debt) =>
        debt.type === BPL_FACILITY &&
        !debt.institutionalLiability?.paidInFull &&
        !debt.customerStatedClosed,
      showRepaymentFrequency: (debt) =>
        debt.type === BPL_LOAN && !debt.customerStatedClosed,
      showRepaymentAmount: (debt) =>
        debt.type === BPL_LOAN && !debt.customerStatedClosed,
      showCustomerExcludedDebt: (debt) =>
        debt.readableSourceType === SOURCE_CREDIT_BUREAU,
      showDebtChangeEvidence: (debt) =>
        debt.readableSourceType !== SOURCE_MANUAL && debt.evidenceProvided,
      image: BUY_NOW_IMG
    }
  },
  "HECS-HELP": {
    fields: {
      ...COMMON_FIELDS,
      showBalanceOwing: true,
      showWithheldFromPay: true,
      image: HECS_HELP_IMG
    }
  },
  "Line of Credit": {
    fields: {
      ...COMMON_FIELDS,
      showInstitution: true,
      showBsb: (debt) => debt.readableSourceType === SOURCE_ANZ,
      showAccountNumber: (debt) =>
        debt.readableSourceType === SOURCE_ANZ ||
        debt.readableSourceType === SOURCE_CREDIT_BUREAU,
      showAccountStatus: (debt) => debt.readableSourceType === SOURCE_ANZ,
      showLimit: true,
      showBureauLimit: (debt) =>
        debt.readableSourceType === SOURCE_CREDIT_BUREAU,
      showBalanceOwing: true,
      showInterestRate: (debt) => debt.readableSourceType === SOURCE_ANZ,
      image: (debt) => {
        return debt.readableSourceType === SOURCE_ANZ
          ? ANZ_IMG
          : OVERDRAFT_MANUAL_CREDIT_IMG;
      }
    }
  },
  Overdraft: {
    fields: {
      ...COMMON_FIELDS,
      showInstitution: true,
      showBsb: (debt) => debt.readableSourceType === SOURCE_ANZ,
      showAccountNumber: (debt) =>
        [SOURCE_ANZ, SOURCE_CREDIT_BUREAU].includes(debt.readableSourceType),
      showAccountStatus: (debt) => debt.readableSourceType === SOURCE_ANZ,
      showLimit: (debt) =>
        [SOURCE_ANZ, SOURCE_MANUAL].includes(debt.readableSourceType) ||
        (debt.readableSourceType === SOURCE_CREDIT_BUREAU &&
          !debt.customerStatedClosed),
      showLimitMessage: (debt) => debt.institutionalLiability?.validatedLimit,
      showBureauLimit: (debt) =>
        debt.readableSourceType === SOURCE_CREDIT_BUREAU,
      showBalanceOwing: (debt) => !debt.customerStatedClosed,
      showInterestRate: (debt) => debt.readableSourceType === SOURCE_ANZ,
      showCustomerExcludedDebt: (debt) =>
        debt.readableSourceType === SOURCE_CREDIT_BUREAU,
      showDebtSourceMessage: (debt) => debt.readableSourceType === SOURCE_ANZ,
      image: (debt) => {
        return debt.readableSourceType === SOURCE_ANZ
          ? ANZ_IMG
          : OVERDRAFT_MANUAL_CREDIT_IMG;
      }
    }
  },
  "Margin Loan": {
    fields: {
      ...COMMON_FIELDS,
      showInstitution: true,
      showBsb: (debt) => debt.readableSourceType === SOURCE_ANZ,
      showAccountNumber: (debt) => debt.readableSourceType === SOURCE_ANZ,
      showAccountStatus: (debt) => debt.readableSourceType === SOURCE_ANZ,
      showLimit: true,
      showBalanceOwing: (debt) => debt.readableSourceType === SOURCE_ANZ,
      showInterestRate: (debt) => debt.readableSourceType === SOURCE_ANZ,
      image: (debt) => {
        return debt.readableSourceType === SOURCE_ANZ
          ? ANZ_IMG
          : OVERDRAFT_MANUAL_CREDIT_IMG;
      }
    }
  },
  "Other Limit Liability": {
    fields: {
      ...COMMON_FIELDS,
      showInstitution: true,
      showBsb: true,
      showAccountNumber: true,
      showLimit: true,
      showInterestRate: true,
      image: DEBT_LOAN
    }
  }
};

export function handleFieldConditions(debt) {
  const debtConfig = DEBT_TYPES[debt.readableType];

  Object.entries(debtConfig.fields).forEach(([key, value]) => {
    debt[key] = typeof value === "function" ? value(debt) : value;
  });

  return debt;
}
