import HECS_HELP_IMG from "@salesforce/resourceUrl/SOP_Debt_Education";
import DEBT_LOAN from "@salesforce/resourceUrl/SOP_Debt_Loan";
import CREDIT_CARD_IMG from "@salesforce/resourceUrl/SOP_Debt_Credit_Card";
import HOME_IMG from "@salesforce/resourceUrl/SOP_Debt_Mortgage";
import OVERDRAFT_MANUAL_CREDIT_IMG from "@salesforce/resourceUrl/SOP_Debt_Building_Government";
import BUY_NOW_IMG from "@salesforce/resourceUrl/SOP_Debt_Payment_Future";

const SOURCE_ANZ = "LIABILITY_SOURCE_TYPE_ANZ";
const SOURCE_CREDIT_BUREAU = "LIABILITY_SOURCE_TYPE_BUREAU";
const SOURCE_MANUAL = "LIABILITY_SOURCE_TYPE_MANUAL";
const ACTION_EDIT = "Edit";
const ACTION_ADD = "Add";
const CONSTRUCTION_LOAN = "Construction";
const VARIABLE_PI_LOAN = "Variable P&I";
const VARIABLE_IO_LOAN = "Variable IO";
const FIXED_IO_LOAN = "Fixed IO";
//Variables for home loan types currently unused
// const FIXED_PI_LOAN = "Fixed P&I";

export const TYPE_MAP = {
  LIABILITY_TYPE_CREDIT_CARD: {
    title: "Credit Card",
    image: CREDIT_CARD_IMG
  },
  LIABILITY_TYPE_HOME_LOAN: {
    title: "Home Loan",
    image: HOME_IMG
  },
  LIABILITY_TYPE_LEASE_HIRE_PURCHASE: {
    title: "Vehicle Lease/Hire Purchase",
    image: DEBT_LOAN
  },
  LIABILITY_TYPE_PERSONAL_LOAN: {
    title: "Personal Loan",
    image: DEBT_LOAN
  },
  LIABILITY_TYPE_STUDENT_LOAN: {
    title: "HECS-HELP",
    image: HECS_HELP_IMG
  },
  LIABILITY_TYPE_VEHICLE_LOAN: {
    title: "Vehicle Loan",
    image: DEBT_LOAN
  },
  LIABILITY_TYPE_LINE_OF_CREDIT: {
    title: "Line of Credit",
    image: DEBT_LOAN
  },
  LIABILITY_TYPE_OVERDRAFT: {
    title: "Overdraft",
    image: OVERDRAFT_MANUAL_CREDIT_IMG
  },
  LIABILITY_TYPE_MARGIN_LOAN: {
    title: "Margin Loan",
    image: OVERDRAFT_MANUAL_CREDIT_IMG
  },
  //BNPL used as credit card
  LIABILITY_TYPE_BPL_FACILITY: {
    title: "Buy Now Pay Later",
    image: BUY_NOW_IMG
  },
  LIABILITY_TYPE_OTHER_LIABILITY: {
    title: "Other Limit Liability",
    image: DEBT_LOAN
  },
  //Catch-all for other loan types. These can be pre-populated from bureau or manually added
  LIABILITY_TYPE_OTHER_LOAN: {
    title: "Other Loan",
    image: DEBT_LOAN
  },
  //Property loan excluding home loan
  LIABILITY_TYPE_PROPERTY_LOAN: {
    title: "Property Loan",
    image: HOME_IMG
  },
  //BNPL used as term loan
  LIABILITY_TYPE_BPL_LOAN: {
    title: "Buy Now Pay Later",
    image: BUY_NOW_IMG
  }
};

const isActionAdd = (actionType) => actionType === ACTION_ADD;
const isActionEdit = (actionType) => actionType === ACTION_EDIT;

const COMMON_FIELDS = {
  fields: (actionType, debt) => ({
    disableBelongsTo:
      isActionEdit(actionType) && debt.sourceType !== SOURCE_MANUAL,
    disableInstitution:
      isActionEdit(actionType) && debt.sourceType !== SOURCE_MANUAL
  })
};

const PERSONAL_VEHICLE_OTHER_LOAN = {
  fields: (actionType, debt) => ({
    ...COMMON_FIELDS.fields(actionType, debt),
    showInstitution: true,
    showBalanceTitle: true,
    showRemainingTermTitle: true,
    showOtherLoanDetailsTitle: true,
    showBalanceOwing: isActionAdd(actionType)
      ? true
      : isActionEdit(actionType) && !debt.customerStatedClosed
        ? true
        : false,
    showRepaymentFrequency: isActionAdd(actionType)
      ? true
      : isActionEdit(actionType) && !debt.customerStatedClosed
        ? true
        : false,
    showRepaymentAmount: isActionAdd(actionType)
      ? true
      : isActionEdit(actionType) && !debt.customerStatedClosed
        ? true
        : false,
    showCustomerExcludedDebt:
      isActionEdit(actionType) && debt.sourceType === SOURCE_CREDIT_BUREAU,
    showCustomerExcludedDebtMessage:
      isActionEdit(actionType) &&
      debt.sourceType === SOURCE_CREDIT_BUREAU &&
      debt.customerStatedClosed,
    disableCustomerStatedClosed:
      isActionEdit(actionType) &&
      debt.sourceType === SOURCE_CREDIT_BUREAU &&
      !debt.customerStatedClosed,
    showBalanceOwingCheckbox:
      isActionEdit(actionType) &&
      debt.sourceType === SOURCE_CREDIT_BUREAU &&
      !debt.customerStatedClosed,
    showBalanceOwingSplit:
      isActionEdit(actionType) && debt.sourceType !== SOURCE_MANUAL,
    showCreditBureauBalanceOwing:
      isActionEdit(actionType) && debt.sourceType === SOURCE_CREDIT_BUREAU,
    showBureauBalanceSpacing:
      isActionEdit(actionType) &&
      debt.sourceType === SOURCE_ANZ &&
      !debt.customerStatedClosed,
    showCreditBureauRemainingTerm:
      isActionEdit(actionType) && debt.sourceType === SOURCE_CREDIT_BUREAU,
    showInterestRateOther:
      isActionEdit(actionType) && debt.sourceType === SOURCE_ANZ,
    showDebtEvidence:
      isActionEdit(actionType) && debt.sourceType !== SOURCE_MANUAL,
    showRemainingTermCheckbox:
      isActionEdit(actionType) &&
      debt.sourceType === SOURCE_CREDIT_BUREAU &&
      !debt.customerStatedClosed,
    disableInterestRate: true
  })
};

//Fields for Vehicle Loan, Vehicle Lease/Hire Purchase and Other Loan
const VEHICLE_OTHER_LOAN = {
  fields: (actionType, debt) => ({
    ...PERSONAL_VEHICLE_OTHER_LOAN.fields(actionType, debt),
    showYears: isActionAdd(actionType)
      ? true
      : isActionEdit(actionType) &&
          (debt.sourceType === SOURCE_MANUAL ||
            (debt.sourceType === SOURCE_CREDIT_BUREAU &&
              !debt.customerStatedClosed))
        ? true
        : false,
    showMonths: isActionAdd(actionType)
      ? true
      : isActionEdit(actionType) &&
          (debt.sourceType === SOURCE_MANUAL ||
            (debt.sourceType === SOURCE_CREDIT_BUREAU &&
              !debt.customerStatedClosed))
        ? true
        : false,
    showAccountNumber:
      isActionEdit(actionType) && debt.sourceType === SOURCE_CREDIT_BUREAU
  })
};

const DEBT_TYPES = {
  LIABILITY_TYPE_HOME_LOAN: {
    fields: (actionType, debt) => ({
      ...COMMON_FIELDS.fields(actionType, debt),
      showInstitution: true,
      showProductName:
        isActionEdit(actionType) && debt.sourceType === SOURCE_ANZ,
      showBSB: isActionEdit(actionType) && debt.sourceType === SOURCE_ANZ,
      showAccountNumber:
        isActionEdit(actionType) &&
        (debt.sourceType === SOURCE_ANZ ||
          debt.sourceType === SOURCE_CREDIT_BUREAU),
      showAccountStatus:
        isActionEdit(actionType) && debt.sourceType === SOURCE_ANZ,
      showBalanceTitle: true,
      showBalanceOwingSplit: true,
      showBalanceOwing:
        isActionAdd(actionType) ||
        (isActionEdit(actionType) && !debt.customerStatedClosed),
      showAvailableRedraw:
        isActionAdd(actionType) ||
        (isActionEdit(actionType) && !debt.customerStatedClosed),
      redrawRequired:
        isActionEdit(actionType) && debt.sourceType === SOURCE_ANZ,
      showCustomerExcludedDebt:
        isActionEdit(actionType) && debt.sourceType === SOURCE_CREDIT_BUREAU,
      showCustomerExcludedDebtMessage:
        isActionEdit(actionType) &&
        debt.sourceType === SOURCE_CREDIT_BUREAU &&
        debt.customerStatedClosed,
      disableCustomerStatedClosed:
        isActionEdit(actionType) &&
        debt.sourceType === SOURCE_CREDIT_BUREAU &&
        !debt.customerStatedClosed,
      showCreditBureauBalanceOwing:
        isActionEdit(actionType) && debt.sourceType === SOURCE_CREDIT_BUREAU,
      showUndrawnAmount:
        isActionAdd(actionType) ||
        (isActionEdit(actionType) &&
          ((debt.sourceType === SOURCE_ANZ &&
            debt.homeLoanType === CONSTRUCTION_LOAN) ||
            debt.sourceType === SOURCE_MANUAL)),
      showUndrawnAmountSplit:
        isActionEdit(actionType) &&
        debt.sourceType === SOURCE_CREDIT_BUREAU &&
        !debt.customerStatedClosed,
      showRemainingTermTitle: true,
      showYears:
        isActionAdd(actionType) ||
        (isActionEdit(actionType) && !debt.customerStatedClosed),
      showMonths:
        isActionAdd(actionType) ||
        (isActionEdit(actionType) && !debt.customerStatedClosed),
      showCreditBureauRemainingTerm:
        isActionEdit(actionType) && debt.sourceType === SOURCE_CREDIT_BUREAU,
      showOtherLoanDetailsTitle: true,
      showRateType: isActionEdit(actionType) && debt.sourceType === SOURCE_ANZ,
      showRepaymentType:
        isActionEdit(actionType) && debt.sourceType === SOURCE_ANZ,
      showInterestRateOther:
        isActionAdd(actionType) ||
        (isActionEdit(actionType) && !debt.customerStatedClosed),
      showRepaymentFrequency:
        isActionAdd(actionType) ||
        (isActionEdit(actionType) &&
          !debt.customerStatedClosed &&
          debt.homeLoanType !== VARIABLE_IO_LOAN &&
          debt.homeLoanType !== FIXED_IO_LOAN &&
          debt.homeLoanType !== CONSTRUCTION_LOAN),
      showRepaymentAmount:
        isActionAdd(actionType) ||
        (isActionEdit(actionType) &&
          !debt.customerStatedClosed &&
          debt.homeLoanType !== VARIABLE_IO_LOAN &&
          debt.homeLoanType !== FIXED_IO_LOAN &&
          debt.homeLoanType !== CONSTRUCTION_LOAN),
      showTaxDeductible:
        isActionAdd(actionType) ||
        (isActionEdit(actionType) && !debt.customerStatedClosed),
      showLinkedProperty: true,
      linkedPropertyRequired:
        isActionAdd(actionType) ||
        (isActionEdit(actionType) && !debt.customerStatedClosed),
      showDebtEvidence: true,
      disableInterestRate:
        isActionEdit(actionType) && debt.sourceType === SOURCE_ANZ,
      requireUndrawnAmount: false,
      showInterestRateUMICheckbox:
        isActionAdd(actionType) ||
        (isActionEdit(actionType) &&
          (debt.sourceType === SOURCE_MANUAL ||
            (debt.sourceType === SOURCE_CREDIT_BUREAU &&
              !debt.customerStatedClosed))),
      showBalanceOwingCheckbox:
        isActionEdit(actionType) &&
        debt.sourceType === SOURCE_CREDIT_BUREAU &&
        !debt.customerStatedClosed,
      showRemainingTermCheckbox:
        isActionEdit(actionType) &&
        debt.sourceType === SOURCE_CREDIT_BUREAU &&
        !debt.customerStatedClosed,
      showSubsequentInterestRate:
        isActionEdit(actionType) &&
        debt.sourceType === SOURCE_ANZ &&
        debt.homeLoanType !== VARIABLE_PI_LOAN
    })
  },
  LIABILITY_TYPE_CREDIT_CARD: {
    fields: (actionType, debt) => ({
      ...COMMON_FIELDS.fields(actionType, debt),
      showInstitution: true,
      showLimitTitle: true,
      showLimit:
        isActionAdd(actionType) ||
        (isActionEdit(actionType) && !debt.customerStatedClosed),
      showOtherCreditDetailsTitle: true,
      showBalanceOwing: isActionAdd(actionType)
        ? true
        : isActionEdit(actionType) && !debt.customerStatedClosed
          ? true
          : false,
      showPaidInFull: isActionAdd(actionType)
        ? true
        : isActionEdit(actionType) &&
            debt.sourceType !== SOURCE_ANZ &&
            !debt.customerStatedClosed
          ? true
          : false,
      showMonthlyRepayment: isActionAdd(actionType)
        ? false
        : (isActionEdit(actionType) &&
              !debt.institutionalLiability.paidInFull &&
              debt.sourceType === SOURCE_MANUAL) ||
            (debt.sourceType === SOURCE_CREDIT_BUREAU &&
              !debt.customerStatedClosed &&
              !debt.institutionalLiability?.paidInFull)
          ? true
          : (isActionEdit(actionType) &&
                debt.sourceType === SOURCE_CREDIT_BUREAU &&
                debt.customerStatedClosed) ||
              (debt.sourceType !== SOURCE_ANZ &&
                (debt.institutionalLiability?.paidInFull !== true ||
                  debt.institutionalLiability?.paidInFull !== false))
            ? false
            : false,
      showCardNumber:
        isActionEdit(actionType) && debt.sourceType === SOURCE_CREDIT_BUREAU,
      showCustomerExcludedDebt:
        isActionEdit(actionType) && debt.sourceType === SOURCE_CREDIT_BUREAU,
      showCustomerExcludedDebtMessage:
        isActionEdit(actionType) &&
        debt.sourceType === SOURCE_CREDIT_BUREAU &&
        debt.customerStatedClosed,
      disableCustomerStatedClosed:
        isActionEdit(actionType) &&
        debt.sourceType === SOURCE_CREDIT_BUREAU &&
        !debt.customerStatedClosed,
      showCreditBureauLimit:
        isActionEdit(actionType) && debt.sourceType === SOURCE_CREDIT_BUREAU,
      showUMICheckbox:
        isActionEdit(actionType) &&
        debt.sourceType === SOURCE_CREDIT_BUREAU &&
        !debt.customerStatedClosed,
      showMinMonthRepayment:
        isActionEdit(actionType) && debt.sourceType === SOURCE_ANZ,
      showInterestRate:
        isActionEdit(actionType) && debt.sourceType === SOURCE_ANZ,
      disableInterestRate: true,
      showDebtEvidence:
        isActionEdit(actionType) && debt.sourceType !== SOURCE_MANUAL,
      disableBelongsTo:
        isActionEdit(actionType) && debt.sourceType !== SOURCE_MANUAL,
      disableInstitution:
        isActionEdit(actionType) && debt.sourceType !== SOURCE_MANUAL
    })
  },
  LIABILITY_TYPE_PERSONAL_LOAN: {
    fields: (actionType, debt) => ({
      ...PERSONAL_VEHICLE_OTHER_LOAN.fields(actionType, debt),
      showYears: isActionAdd(actionType)
        ? true
        : isActionEdit(actionType) &&
            (debt.sourceType === SOURCE_ANZ ||
              debt.sourceType === SOURCE_MANUAL ||
              (debt.sourceType === SOURCE_CREDIT_BUREAU &&
                !debt.customerStatedClosed))
          ? true
          : false,
      showMonths: isActionAdd(actionType)
        ? true
        : isActionEdit(actionType) &&
            (debt.sourceType === SOURCE_ANZ ||
              debt.sourceType === SOURCE_MANUAL ||
              (debt.sourceType === SOURCE_CREDIT_BUREAU &&
                !debt.customerStatedClosed))
          ? true
          : false,
      showBSB: isActionEdit(actionType) && debt.sourceType === SOURCE_ANZ,
      showAccountNumber:
        isActionEdit(actionType) && debt.sourceType !== SOURCE_MANUAL,
      showAccountStatus:
        isActionEdit(actionType) && debt.sourceType === SOURCE_ANZ,
      showAvailableRedraw:
        isActionEdit(actionType) && debt.sourceType === SOURCE_ANZ,
      redrawRequired:
        isActionEdit(actionType) && debt.sourceType === SOURCE_ANZ,
      showLoanType: isActionEdit(actionType) && debt.sourceType === SOURCE_ANZ,
      showRemainingTermCheckbox:
        isActionEdit(actionType) &&
        debt.sourceType === SOURCE_CREDIT_BUREAU &&
        !debt.customerStatedClosed
    })
  },
  LIABILITY_TYPE_VEHICLE_LOAN: {
    fields: (actionType, debt) => ({
      ...VEHICLE_OTHER_LOAN.fields(actionType, debt)
    })
  },
  LIABILITY_TYPE_LEASE_HIRE_PURCHASE: {
    fields: (actionType, debt) => ({
      ...VEHICLE_OTHER_LOAN.fields(actionType, debt)
    })
  },
  LIABILITY_TYPE_OTHER_LOAN: {
    fields: (actionType, debt) => ({
      ...VEHICLE_OTHER_LOAN.fields(actionType, debt)
    })
  },
  //Spend Limit
  LIABILITY_TYPE_BPL_FACILITY: {
    fields: (actionType, debt) => ({
      ...COMMON_FIELDS.fields(actionType, debt),
      showInstitution: true,
      showArrangementType: true,
      showAccountNumber:
        isActionEdit(actionType) && debt.sourceType !== SOURCE_MANUAL,
      showCustomerExcludedDebt:
        isActionEdit(actionType) && debt.sourceType === SOURCE_CREDIT_BUREAU,
      showCustomerExcludedDebtMessage:
        isActionEdit(actionType) &&
        debt.sourceType === SOURCE_CREDIT_BUREAU &&
        debt.customerStatedClosed,
      disableCustomerStatedClosed:
        isActionEdit(actionType) &&
        debt.sourceType === SOURCE_CREDIT_BUREAU &&
        !debt.customerStatedClosed,
      showLimitTitle: isActionEdit(actionType),
      showUMICheckbox:
        isActionEdit(actionType) &&
        debt.sourceType === SOURCE_CREDIT_BUREAU &&
        !debt.customerStatedClosed,
      showLimit: isActionAdd(actionType)
        ? true
        : isActionEdit(actionType) && !debt.customerStatedClosed
          ? true
          : false,
      showCreditBureauLimit:
        isActionEdit(actionType) && debt.sourceType === SOURCE_CREDIT_BUREAU,
      showOtherBNPLDetailsTitle: true,
      showBalanceOwingOtherDetails: isActionAdd(actionType)
        ? true
        : isActionEdit(actionType) && !debt.customerStatedClosed
          ? true
          : false,
      showPaidInFull: isActionAdd(actionType)
        ? true
        : isActionEdit(actionType) && !debt.customerStatedClosed
          ? true
          : false,
      showMonthlyRepayment: isActionAdd(actionType)
        ? false
        : isActionEdit(actionType) &&
            !debt.customerStatedClosed &&
            debt.institutionalLiability?.paidInFull === false
          ? true
          : false,
      showDebtEvidence:
        isActionEdit(actionType) && debt.sourceType !== SOURCE_MANUAL,
      disableOwnershipSplit: isActionEdit(actionType),
      disableBelongsTo: isActionEdit(actionType),
      disableInterestRate: true
    })
  },
  //Fixed Amount
  LIABILITY_TYPE_BPL_LOAN: {
    fields: (actionType, debt) => ({
      ...COMMON_FIELDS.fields(actionType, debt),
      showInstitution: true,
      showArrangementType: true,
      showAccountNumber:
        isActionEdit(actionType) && debt.sourceType !== SOURCE_MANUAL,
      showCustomerExcludedDebt:
        isActionEdit(actionType) && debt.sourceType === SOURCE_CREDIT_BUREAU,
      showCustomerExcludedDebtMessage:
        isActionEdit(actionType) &&
        debt.sourceType === SOURCE_CREDIT_BUREAU &&
        debt.customerStatedClosed,
      disableCustomerStatedClosed:
        isActionEdit(actionType) &&
        debt.sourceType === SOURCE_CREDIT_BUREAU &&
        !debt.customerStatedClosed,
      showBalanceOwingCheckbox:
        isActionEdit(actionType) &&
        debt.sourceType === SOURCE_CREDIT_BUREAU &&
        !debt.customerStatedClosed,
      showBalanceTitle: true,
      showBalanceOwing: isActionAdd(actionType)
        ? true
        : isActionEdit(actionType) && !debt.customerStatedClosed
          ? true
          : false,
      showCreditBureauBalanceOwing:
        isActionEdit(actionType) && debt.sourceType === SOURCE_CREDIT_BUREAU,
      showRemainingTermTitle: true,
      showRemainingTermCheckbox:
        isActionEdit(actionType) &&
        debt.sourceType === SOURCE_CREDIT_BUREAU &&
        !debt.customerStatedClosed,
      showYears: isActionAdd(actionType)
        ? true
        : isActionEdit(actionType) && !debt.customerStatedClosed
          ? true
          : false,
      showMonths: isActionAdd(actionType)
        ? true
        : isActionEdit(actionType) && !debt.customerStatedClosed
          ? true
          : false,
      showCreditBureauRemainingTerm:
        isActionEdit(actionType) && debt.sourceType === SOURCE_CREDIT_BUREAU,
      showOtherBNPLDetailsTitle: true,
      showRepaymentFrequency: isActionAdd(actionType)
        ? true
        : isActionEdit(actionType) && !debt.customerStatedClosed
          ? true
          : false,
      showRepaymentAmount: isActionAdd(actionType)
        ? true
        : isActionEdit(actionType) && !debt.customerStatedClosed
          ? true
          : false,
      showDebtEvidence:
        isActionEdit(actionType) && debt.sourceType !== SOURCE_MANUAL,
      disableOwnershipSplit: isActionEdit(actionType),
      disableBelongsTo: isActionEdit(actionType),
      disableInterestRate: true
    })
  },
  LIABILITY_TYPE_STUDENT_LOAN: {
    //Ignore rule as student loan doesnt need additional checks
    //eslint-disable-next-line no-unused-vars
    fields: (actionType, debt) => ({
      showBalanceOwing: true,
      showWithheldFromPay: true,
      disableOwnershipSplit: isActionEdit(actionType),
      disableBelongsTo: isActionEdit(actionType),
      disableInterestRate: true
    })
  },
  LIABILITY_TYPE_LINE_OF_CREDIT: {
    fields: (actionType, debt) => ({
      ...COMMON_FIELDS.fields(actionType, debt),
      showInstitution: true,
      showLimitTitle: true,
      showLimit: isActionAdd(actionType)
        ? true
        : isActionEdit(actionType) && !debt.customerStatedClosed
          ? true
          : false,
      showOtherDetailsTitle: true,
      showBalanceOwing: isActionAdd(actionType)
        ? true
        : isActionEdit(actionType) && !debt.customerStatedClosed
          ? true
          : false,
      showTaxDeductible: isActionAdd(actionType)
        ? true
        : isActionEdit(actionType) && !debt.customerStatedClosed
          ? true
          : false,
      showLinkedProperty: true,
      linkedPropertyRequired:
        isActionAdd(actionType) ||
        (isActionEdit(actionType) && !debt.customerStatedClosed),
      showAccountStatus:
        isActionEdit(actionType) && debt.sourceType === SOURCE_ANZ,
      showBSB: isActionEdit(actionType) && debt.sourceType === SOURCE_ANZ,
      showAccountNumber:
        isActionEdit(actionType) &&
        (debt.sourceType === SOURCE_ANZ ||
          debt.sourceType === SOURCE_CREDIT_BUREAU),
      showInterestRate:
        isActionEdit(actionType) && debt.sourceType === SOURCE_ANZ,
      disableInterestRate:
        isActionEdit(actionType) && debt.sourceType === SOURCE_ANZ,
      showDebtEvidence:
        isActionEdit(actionType) &&
        (debt.sourceType === SOURCE_ANZ ||
          debt.sourceType === SOURCE_CREDIT_BUREAU),
      showCreditBureauLimit:
        isActionEdit(actionType) && debt.sourceType === SOURCE_CREDIT_BUREAU,
      showCustomerExcludedDebt:
        isActionEdit(actionType) && debt.sourceType === SOURCE_CREDIT_BUREAU,
      showCustomerExcludedDebtMessage:
        isActionEdit(actionType) &&
        debt.sourceType === SOURCE_CREDIT_BUREAU &&
        debt.customerStatedClosed,
      disableCustomerStatedClosed:
        isActionEdit(actionType) &&
        debt.sourceType === SOURCE_CREDIT_BUREAU &&
        !debt.customerStatedClosed,
      disableBelongsTo:
        isActionEdit(actionType) &&
        (debt.sourceType === SOURCE_ANZ ||
          debt.sourceType === SOURCE_CREDIT_BUREAU),
      disableInstitution:
        isActionEdit(actionType) && debt.sourceType !== SOURCE_MANUAL,
      showUMICheckbox:
        isActionEdit(actionType) &&
        debt.sourceType === SOURCE_CREDIT_BUREAU &&
        !debt.customerStatedClosed
    })
  },
  LIABILITY_TYPE_OVERDRAFT: {
    fields: (actionType, debt) => ({
      ...COMMON_FIELDS.fields(actionType, debt),
      showInstitution: true,
      showLimitTitle: true,
      showLimit:
        isActionAdd(actionType) ||
        (isActionEdit(actionType) && !debt.customerStatedClosed),
      showOtherOverdraftDetailsTitle: true,
      showBSB: isActionEdit(actionType) && debt.sourceType === SOURCE_ANZ,
      showAccountNumber:
        isActionEdit(actionType) && debt.sourceType !== SOURCE_MANUAL,
      showAccountStatus:
        isActionEdit(actionType) && debt.sourceType === SOURCE_ANZ,
      showCustomerExcludedDebt:
        isActionEdit(actionType) && debt.sourceType === SOURCE_CREDIT_BUREAU,
      showCustomerExcludedDebtMessage:
        isActionEdit(actionType) &&
        debt.sourceType === SOURCE_CREDIT_BUREAU &&
        debt.customerStatedClosed,
      disableCustomerStatedClosed:
        isActionEdit(actionType) &&
        debt.sourceType === SOURCE_CREDIT_BUREAU &&
        !debt.customerStatedClosed,
      showUMICheckbox:
        isActionEdit(actionType) &&
        debt.sourceType === SOURCE_CREDIT_BUREAU &&
        !debt.customerStatedClosed,
      showCreditBureauLimit:
        isActionEdit(actionType) && debt.sourceType === SOURCE_CREDIT_BUREAU,
      showBalanceOwing: isActionAdd(actionType)
        ? true
        : isActionEdit(actionType) && !debt.customerStatedClosed
          ? true
          : false,
      showInterestRate:
        isActionEdit(actionType) && debt.sourceType === SOURCE_ANZ,
      disableInterestRate: true,
      showDebtEvidence:
        isActionEdit(actionType) && debt.sourceType !== SOURCE_MANUAL
    })
  },
  LIABILITY_TYPE_MARGIN_LOAN: {
    fields: (actionType, debt) => ({
      ...COMMON_FIELDS.fields(actionType, debt),
      showInstitution: true,
      showLimitTitle: true,
      showLimit: true,
      showBSB: isActionEdit(actionType) && debt.sourceType === SOURCE_ANZ,
      showAccountNumber:
        isActionEdit(actionType) && debt.sourceType === SOURCE_ANZ,
      showAccountStatusMessage:
        isActionEdit(actionType) && debt.sourceType === SOURCE_ANZ,
      showOtherDetailsTitle:
        isActionEdit(actionType) && debt.sourceType === SOURCE_ANZ,
      showBalanceOwing:
        isActionEdit(actionType) && debt.sourceType === SOURCE_ANZ,
      showInterestRate:
        isActionEdit(actionType) && debt.sourceType === SOURCE_ANZ,
      disableInterestRate: true,
      showDebtEvidence:
        isActionEdit(actionType) && debt.sourceType !== SOURCE_MANUAL
    })
  },
  //No other liability for add yet
  LIABILITY_TYPE_OTHER_LIABILITY: {
    fields: (actionType, debt) => ({
      ...COMMON_FIELDS.fields(actionType, debt),
      disableBelongsTo: true,
      showInstitution: true,
      disableInstitution: true,
      showBSB: true,
      showAccountNumber: true,
      showAccountStatus: true,
      showLimitTitle: true,
      showLimit: true,
      showOtherOverdraftDetailsTitle: true,
      showBalanceOwing: true,
      showInterestRate: true,
      disableInterestRate: true,
      showDebtEvidence: true
    })
  }
};

/**
 *
 * @param debtType type of debt to handle field visibility for
 * @param actionType add or edit action
 * @returns
 */
export function handleFieldVisibility(type, debt, actionType) {
  const debtConfig = DEBT_TYPES[type];
  let fields = {};
  Object.entries(debtConfig.fields(actionType, debt)).forEach(
    ([key, value]) => {
      fields[key] = value;
    }
  );
  return fields;
}

const COMMON_EDIT_PAYLOADS = {
  liability: (debt) => ({
    liability: {
      uid: debt.uid,
      sources: [debt.sourceType],
      type: debt.type,
      name: debt.name,
      institutionalLiability: {
        financialInstitution: debt.institutionalLiability?.financialInstitution,
        principalInterestRemainingTerm:
          debt.institutionalLiability?.principalInterestRemainingTerm,
        verifiedPrincipalInterestRemainingTerm:
          debt.sourceType === SOURCE_CREDIT_BUREAU
            ? debt.institutionalLiability
                ?.verifiedPrincipalInterestRemainingTerm
            : null,
        repaymentAmountValue: debt.institutionalLiability?.repaymentAmount,
        repaymentFrequency: debt.institutionalLiability?.repaymentFrequency,
        validatedPrincipalInterestRemainingTerm:
          debt.sourceType === SOURCE_CREDIT_BUREAU
            ? debt.institutionalLiability
                ?.validatedPrincipalInterestRemainingTerm
            : null
      },
      validatedOutstandingBalance:
        debt.sourceType === SOURCE_CREDIT_BUREAU
          ? debt.validatedOutstandingBalance
          : null,
      outstandingBalanceValue: debt.outstandingBalance,
      verifiedOutstandingBalanceValue:
        debt.sourceType === SOURCE_CREDIT_BUREAU
          ? debt.verifiedOutstandingBalance
          : null,
      account: {
        id: debt.accountId,
        accountNumber: debt.accountNumber,
        status: debt.status,
        bsb: debt.bsb
      },
      paidOffAndClosed: debt.paidOffAndClosed,
      evidenceProvided: debt.evidenceProvided,
      customerStatedClosed:
        debt.sourceType === SOURCE_CREDIT_BUREAU
          ? debt.customerStatedClosed
          : null,
      etag: debt.etag
    }
  })
};

const EDIT_DEBT_TYPES = {
  LIABILITY_TYPE_HOME_LOAN: {
    liability: (debt) => ({
      liability: {
        etag: debt.etag,
        uid: debt.uid,
        sources: [debt.sourceType],
        type: debt.type,
        name: debt.name,
        verifiedOutstandingBalanceValue:
          debt.sourceType === SOURCE_CREDIT_BUREAU
            ? debt.verifiedOutstandingBalance
            : null,
        outstandingBalanceValue: !debt.customerStatedClosed
          ? debt.outstandingBalance
          : null,
        validatedOutstandingBalance:
          debt.sourceType === SOURCE_CREDIT_BUREAU
            ? debt.validatedOutstandingBalance
            : null,
        termType: debt.sourceType !== SOURCE_MANUAL ? debt.termType : null,
        institutionalLiability: {
          financialInstitution:
            debt.institutionalLiability?.financialInstitution,
          principalInterestRemainingTerm:
            debt.sourceType === SOURCE_CREDIT_BUREAU
              ? debt.institutionalLiability?.principalInterestRemainingTerm
              : null,
          verifiedPrincipalInterestRemainingTerm:
            debt.sourceType === SOURCE_CREDIT_BUREAU
              ? debt.institutionalLiability
                  ?.verifiedPrincipalInterestRemainingTerm
              : null,
          validatedPrincipalInterestRemainingTerm:
            debt.sourceType === SOURCE_CREDIT_BUREAU
              ? debt.institutionalLiability
                  ?.validatedPrincipalInterestRemainingTerm
              : null,
          interestRate: debt.institutionalLiability?.originalInterestRateValue,
          taxDeductiblePercentage:
            debt.institutionalLiability.taxDeductiblePercentageOriginal,
          redrawAmountValue: debt.institutionalLiability?.redrawAmount,
          repaymentAmountValue: debt.institutionalLiability?.repaymentAmount,
          repaymentFrequency: debt.institutionalLiability?.repaymentFrequency,
          interestRateValidated:
            debt.institutionalLiability?.interestRateValidated,
          paymentMethod: debt.institutionalLiability?.paymentMethod
        },
        account: {
          id: debt.accountId,
          accountNumber: debt.accountNumber,
          status: debt.status,
          bsb: debt.bsb
        },
        undrawnAmountValue: debt.undrawnAmount,
        paidOffAndClosed: debt.paidOffAndClosed,
        evidenceProvided: debt.evidenceProvided,
        customerStatedClosed:
          debt.sourceType === SOURCE_CREDIT_BUREAU
            ? debt.customerStatedClosed
            : null,
        assets: debt.assets
      }
    })
  },
  LIABILITY_TYPE_CREDIT_CARD: {
    liability: (debt) => ({
      liability: {
        uid: debt.uid,
        sources: [debt.sourceType],
        type: debt.type,
        name: debt.name,
        institutionalLiability: {
          financialInstitution:
            debt.institutionalLiability?.financialInstitution,
          limitValue: debt.institutionalLiability?.limitAmount,
          paidInFull:
            debt.sourceType !== SOURCE_ANZ
              ? debt.institutionalLiability?.paidInFull === true
                ? true
                : false
              : null,
          repaymentAmountValue: debt.institutionalLiability?.repaymentAmount,
          repaymentFrequency: debt.institutionalLiability?.repaymentFrequency,
          validatedLimit:
            debt.sourceType === SOURCE_CREDIT_BUREAU
              ? debt.institutionalLiability?.validatedLimit
              : null,
          interestRate:
            debt.sourceType === SOURCE_ANZ
              ? debt.institutionalLiability?.originalInterestRateValue
              : null
        },
        verifiedOutstandingBalanceValue:
          debt.sourceType === SOURCE_CREDIT_BUREAU
            ? debt.verifiedOutstandingBalance
            : null,
        outstandingBalanceValue: debt.outstandingBalance,
        account: {
          id: debt.accountId,
          accountNumber: debt.accountNumber,
          status: debt.status,
          bsb: debt.bsb
        },
        paidOffAndClosed: debt.paidOffAndClosed,
        evidenceProvided: debt.evidenceProvided,
        customerStatedClosed:
          debt.sourceType === SOURCE_CREDIT_BUREAU
            ? debt.customerStatedClosed
            : null,
        etag: debt.etag
      }
    })
  },
  LIABILITY_TYPE_VEHICLE_LOAN: {
    liability: (debt) => ({
      ...COMMON_EDIT_PAYLOADS.liability(debt)
    })
  },
  LIABILITY_TYPE_PERSONAL_LOAN: {
    liability: (debt) => ({
      liability: {
        uid: debt.uid,
        sources: [debt.sourceType],
        type: debt.type,
        name: debt.name,
        institutionalLiability: {
          financialInstitution:
            debt.institutionalLiability?.financialInstitution,
          principalInterestRemainingTerm:
            debt.institutionalLiability?.principalInterestRemainingTerm,
          verifiedPrincipalInterestRemainingTerm:
            debt.sourceType === SOURCE_CREDIT_BUREAU
              ? debt.institutionalLiability
                  ?.verifiedPrincipalInterestRemainingTerm
              : null,
          repaymentAmountValue: debt.institutionalLiability?.repaymentAmount,
          repaymentFrequency: debt.institutionalLiability?.repaymentFrequency,
          redrawAmountValue:
            debt.sourceType === SOURCE_ANZ
              ? debt.institutionalLiability.redrawAmount
              : null,
          validatedPrincipalInterestRemainingTerm:
            debt.sourceType === SOURCE_CREDIT_BUREAU
              ? debt.institutionalLiability
                  ?.validatedPrincipalInterestRemainingTerm
              : null
        },
        validatedOutstandingBalance:
          debt.sourceType === SOURCE_CREDIT_BUREAU
            ? debt.validatedOutstandingBalance
            : null,
        outstandingBalanceValue: debt.outstandingBalance,
        verifiedOutstandingBalanceValue:
          debt.sourceType === SOURCE_CREDIT_BUREAU
            ? debt.verifiedOutstandingBalance
            : null,
        account: {
          id: debt.accountId,
          accountNumber: debt.accountNumber,
          status: debt.status,
          bsb: debt.bsb
        },
        paidOffAndClosed: debt.paidOffAndClosed,
        evidenceProvided: debt.evidenceProvided,
        customerStatedClosed:
          debt.sourceType === SOURCE_CREDIT_BUREAU
            ? debt.customerStatedClosed
            : null,
        etag: debt.etag,
        termType: debt.sourceType !== SOURCE_MANUAL ? debt.termType : null
      }
    })
  },
  LIABILITY_TYPE_LEASE_HIRE_PURCHASE: {
    liability: (debt) => ({
      ...COMMON_EDIT_PAYLOADS.liability(debt)
    })
  },
  LIABILITY_TYPE_OTHER_LOAN: {
    liability: (debt) => ({
      ...COMMON_EDIT_PAYLOADS.liability(debt)
    })
  },
  //Spend limit
  LIABILITY_TYPE_BPL_FACILITY: {
    liability: (debt) => ({
      liability: {
        uid: debt.uid,
        sources: [debt.sourceType],
        type: debt.type,
        name: debt.name,
        verifiedOutstandingBalanceValue:
          debt.sourceType === SOURCE_CREDIT_BUREAU
            ? debt.verifiedOutstandingBalance
            : null,
        outstandingBalanceValue: debt.outstandingBalance,
        paidOffAndClosed: debt.paidOffAndClosed,
        customerStatedClosed:
          debt.sourceType === SOURCE_CREDIT_BUREAU
            ? debt.customerStatedClosed
            : null,
        institutionalLiability: {
          financialInstitution:
            debt.institutionalLiability?.financialInstitution,
          limitValue: debt.institutionalLiability?.limitAmount,
          paidInFull:
            debt.institutionalLiability?.paidInFull === true ? true : false,
          repaymentAmountValue: debt.institutionalLiability?.repaymentAmount,
          repaymentFrequency: debt.institutionalLiability?.repaymentFrequency,
          validatedLimit:
            debt.sourceType === SOURCE_CREDIT_BUREAU
              ? debt.institutionalLiability?.validatedLimit
              : null
        },
        account: {
          id: debt.accountId,
          accountNumber: debt.accountNumber,
          status: debt.status,
          bsb: debt.bsb
        },
        etag: debt.etag
      }
    })
  },
  //Fixed
  LIABILITY_TYPE_BPL_LOAN: {
    liability: (debt) => ({
      liability: {
        uid: debt.uid,
        sources: [debt.sourceType],
        type: debt.type,
        name: debt.name,
        verifiedOutstandingBalanceValue:
          debt.sourceType === SOURCE_CREDIT_BUREAU
            ? debt.verifiedOutstandingBalance
            : null,
        outstandingBalanceValue: debt.outstandingBalance,
        paidOffAndClosed: debt.paidOffAndClosed,
        evidenceProvided: debt.evidenceProvided,
        customerStatedClosed:
          debt.sourceType === SOURCE_CREDIT_BUREAU
            ? debt.customerStatedClosed
            : null,
        institutionalLiability: {
          financialInstitution:
            debt.institutionalLiability?.financialInstitution,
          limitValue: debt.institutionalLiability?.limitAmount,
          repaymentAmountValue: debt.institutionalLiability?.repaymentAmount,
          repaymentFrequency: debt.institutionalLiability.repaymentFrequency,
          principalInterestRemainingTerm:
            debt.institutionalLiability?.principalInterestRemainingTerm,
          verifiedPrincipalInterestRemainingTerm:
            debt.sourceType === SOURCE_CREDIT_BUREAU
              ? debt.institutionalLiability
                  ?.verifiedPrincipalInterestRemainingTerm
              : null,
          validatedPrincipalInterestRemainingTerm:
            debt.sourceType === SOURCE_CREDIT_BUREAU
              ? debt.institutionalLiability
                  ?.validatedPrincipalInterestRemainingTerm
              : null
        },
        validatedOutstandingBalance:
          debt.sourceType === SOURCE_CREDIT_BUREAU
            ? debt.validatedOutstandingBalance
            : null,
        account: {
          id: debt.accountId,
          accountNumber: debt.accountNumber,
          status: debt.status,
          bsb: debt.bsb
        },
        etag: debt.etag
      }
    })
  },
  LIABILITY_TYPE_MARGIN_LOAN: {
    liability: (debt) => ({
      liability: {
        uid: debt.uid,
        sources: [debt.sourceType],
        type: debt.type,
        name: debt.name,
        institutionalLiability: {
          financialInstitution:
            debt.institutionalLiability?.financialInstitution,
          limitValue: debt.institutionalLiability?.limitAmount,
          interestRate:
            debt.sourceType === SOURCE_CREDIT_BUREAU
              ? debt.originalInterestRateValue
              : null
        },
        outstandingBalanceValue:
          debt.sourceType === SOURCE_CREDIT_BUREAU
            ? debt.outstandingBalance
            : null,
        verifiedOutstandingBalanceValue:
          debt.sourceType === SOURCE_CREDIT_BUREAU
            ? debt.verifiedOutstandingBalance
            : null,
        account: {
          id: debt.accountId,
          accountNumber: debt.accountNumber,
          status: debt.status,
          bsb: debt.bsb
        },
        paidOffAndClosed: debt.paidOffAndClosed,
        evidenceProvided: debt.evidenceProvided,
        customerStatedClosed:
          debt.sourceType === SOURCE_CREDIT_BUREAU
            ? debt.customerStatedClosed
            : null,
        etag: debt.etag
      }
    })
  },
  LIABILITY_TYPE_LINE_OF_CREDIT: {
    liability: (debt) => ({
      liability: {
        etag: debt.etag,
        uid: debt.uid,
        sources: [debt.sourceType],
        type: debt.type,
        name: debt.name,
        verifiedOutstandingBalanceValue:
          debt.sourceType === SOURCE_CREDIT_BUREAU
            ? debt.verifiedOutstandingBalance
            : null,
        outstandingBalanceValue: !debt.customerStatedClosed
          ? debt.outstandingBalance
          : null,
        institutionalLiability: {
          financialInstitution:
            debt.institutionalLiability?.financialInstitution,
          limitValue: debt.institutionalLiability?.limitAmount,
          principalInterestRemainingTerm:
            debt.sourceType === SOURCE_CREDIT_BUREAU
              ? debt.institutionalLiability?.principalInterestRemainingTerm
              : null,
          verifiedPrincipalInterestRemainingTerm:
            debt.sourceType === SOURCE_CREDIT_BUREAU
              ? debt.institutionalLiability
                  ?.verifiedPrincipalInterestRemainingTerm
              : null,
          validatedLimit:
            debt.sourceType === SOURCE_CREDIT_BUREAU
              ? debt.institutionalLiability.validatedLimit
              : null,
          interestRate:
            debt.sourceType === SOURCE_ANZ
              ? debt.institutionalLiability.originalInterestRateValue
              : null,
          taxDeductiblePercentage:
            debt.institutionalLiability.taxDeductiblePercentageOriginal
        },
        account: {
          id: debt.accountId,
          accountNumber: debt.accountNumber,
          status: debt.status,
          bsb: debt.bsb
        },
        paidOffAndClosed: debt.paidOffAndClosed,
        evidenceProvided: debt.evidenceProvided,
        customerStatedClosed:
          debt.sourceType === SOURCE_CREDIT_BUREAU
            ? debt.customerStatedClosed
            : null,
        assets: debt.assets
      }
    })
  },
  LIABILITY_TYPE_OVERDRAFT: {
    liability: (debt) => ({
      liability: {
        etag: debt.etag,
        uid: debt.uid,
        sources: [debt.sourceType],
        type: debt.type,
        name: debt.name,
        verifiedOutstandingBalanceValue:
          debt.sourceType === SOURCE_CREDIT_BUREAU
            ? debt.verifiedOutstandingBalance
            : null,
        outstandingBalanceValue: debt.outstandingBalance,
        institutionalLiability: {
          financialInstitution:
            debt.institutionalLiability?.financialInstitution,
          limitValue: debt.institutionalLiability?.limitAmount,
          interestRate:
            debt.sourceType === SOURCE_ANZ
              ? debt.institutionalLiability.originalInterestRateValue
              : null,
          validatedLimit:
            debt.sourceType === SOURCE_CREDIT_BUREAU
              ? debt.institutionalLiability.validatedLimit
              : null
        },
        account: {
          id: debt.accountId,
          accountNumber: debt.accountNumber,
          status: debt.status,
          bsb: debt.bsb
        },
        paidOffAndClosed: debt.paidOffAndClosed,
        evidenceProvided: debt.evidenceProvided,
        customerStatedClosed:
          debt.sourceType === SOURCE_CREDIT_BUREAU
            ? debt.customerStatedClosed
            : null
      }
    })
  },
  LIABILITY_TYPE_STUDENT_LOAN: {
    liability: (debt) => ({
      liability: {
        uid: debt.uid,
        sources: [debt.sourceType],
        type: debt.type,
        name: debt.name,
        outstandingBalanceValue: debt.outstandingBalance,
        studentLoan: {
          hecsWithheldPayment: debt.studentLoan?.hecsWithheldPayment
        },
        paidOffAndClosed: debt.paidOffAndClosed,
        evidenceProvided: debt.evidenceProvided,
        etag: debt.etag
      }
    })
  },
  LIABILITY_TYPE_OTHER_LIABILITY: {
    liability: (debt) => ({
      liability: {
        uid: debt.uid,
        sources: [debt.sourceType],
        etag: debt.etag,
        name: debt.name,
        institutionalLiability: {
          financialInstitution:
            debt.institutionalLiability?.financialInstitution,
          limitValue: debt.institutionalLiability?.limitAmount,
          interestRate: debt.institutionalLiability?.originalInterestRateValue
        },
        account: {
          id: debt.accountId,
          accountNumber: debt.accountNumber,
          status: debt.status,
          bsb: debt.bsb
        },
        outstandingBalanceValue: debt.outstandingBalance,
        paidOffAndClosed: debt.paidOffAndClosed,
        evidenceProvided: debt.evidenceProvided
      }
    })
  }
};

export function handleEditPayload(debt) {
  const editDebtConfig = EDIT_DEBT_TYPES[debt.type];
  let payload = {};
  Object.entries(editDebtConfig.liability(debt)).forEach(([key, value]) => {
    payload[key] = value;
  });
  //Clear nulls
  payload = Object.fromEntries(
    Object.entries(payload).filter(([_, v]) => v != null)
  );
  return payload;
}

export function handleAddDefaults() {
  return {
    parent: null,
    liability: {
      type: null,
      institutionalLiability: {
        limitValue: null,
        financialInstitution: null,
        paidInFull: null,
        repaymentAmountValue: null,
        debtType: null,
        repaymentFrequency: null,
        principalInterestRemainingTerm: null,
        validatedLimit: null,
        minimumMonthRepaymentValue: null,
        interestRate: null,
        redrawAmountValue: null,
        validatedPrincipalInterestRemainingTerm: null
      },
      balanceOwing: null,
      account: {
        financialInstitution: null,
        id: null,
        bsb: null,
        accountNumber: null,
        status: null
      },
      sources: [],
      ownership: [{ partyId: null, proportion: { value: null } }],
      studentLoan: {
        hecsWithheldPayment: null
      },
      validatedOutstandingBalance: null,
      paidOffAndClosed: false,
      evidenceProvided: null,
      customerStatedClosed: null,
      verifiedOutstandingBalanceValue: null,
      assets: []
    },
    uid: null,
    name: null,
    etag: null
  };
}

export function handleExcludedDebtChangeVisibility(
  debtType,
  value,
  fieldVisibility,
  payload
) {
  //convert value from string
  let boolValue = value === "true" ? true : false;

  if (
    debtType === "LIABILITY_TYPE_BPL_FACILITY" ||
    debtType === "LIABILITY_TYPE_CREDIT_CARD"
  ) {
    fieldVisibility.showLimit = !boolValue;
    if (debtType === "LIABILITY_TYPE_BPL_FACILITY") {
      fieldVisibility.showBalanceOwingOtherDetails = !boolValue;
    } else {
      fieldVisibility.showBalanceOwing = !boolValue;
    }
    fieldVisibility.showPaidInFull = !boolValue;
    fieldVisibility.showUMICheckbox = !boolValue;

    if (boolValue) {
      fieldVisibility.showMonthlyRepayment = false;
    } else {
      fieldVisibility.showMonthlyRepayment =
        payload.liability.institutionalLiability.paidInFull === false
          ? true
          : false;
    }
  }

  let debtTypesList = [
    "LIABILITY_TYPE_OTHER_LOAN",
    "LIABILITY_TYPE_LEASE_HIRE_PURCHASE",
    "LIABILITY_TYPE_VEHICLE_LOAN",
    "LIABILITY_TYPE_BPL_LOAN",
    "LIABILITY_TYPE_PERSONAL_LOAN"
  ];

  if (debtTypesList.includes(debtType)) {
    fieldVisibility.showBalanceOwing = !boolValue;
    fieldVisibility.showRemainingTermTitle = !boolValue;
    fieldVisibility.showYears = !boolValue;
    fieldVisibility.showMonths = !boolValue;
    fieldVisibility.showRepaymentAmount = !boolValue;
    fieldVisibility.showRepaymentFrequency = !boolValue;
    fieldVisibility.showRemainingTermCheckbox = !boolValue;
    fieldVisibility.showBalanceOwingCheckbox = !boolValue;
  }

  if (debtType === "LIABILITY_TYPE_OVERDRAFT") {
    fieldVisibility.showBalanceOwing = !boolValue;
    fieldVisibility.showLimit = !boolValue;
    fieldVisibility.showUMICheckbox = !boolValue;
  }

  if (debtType === "LIABILITY_TYPE_LINE_OF_CREDIT") {
    fieldVisibility.showBalanceOwing = !boolValue;
    fieldVisibility.showLimit = !boolValue;
    fieldVisibility.showTaxDeductible = !boolValue;
    fieldVisibility.showUMICheckbox = !boolValue;
    fieldVisibility.linkedPropertyRequired = !boolValue;
  }

  if (debtType === "LIABILITY_TYPE_HOME_LOAN") {
    fieldVisibility.showBalanceOwingCheckbox = !boolValue;
    fieldVisibility.showBalanceOwing = !boolValue;
    fieldVisibility.showAvailableRedraw = !boolValue;
    fieldVisibility.showUndrawnAmount = !boolValue;
    fieldVisibility.showRemainingTermCheckbox = !boolValue;
    fieldVisibility.showYears = !boolValue;
    fieldVisibility.showMonths = !boolValue;
    fieldVisibility.showInterestRateUMICheckbox = !boolValue;
    fieldVisibility.showInterestRateOther = !boolValue;
    fieldVisibility.showRepaymentFrequency = !boolValue;
    fieldVisibility.showRepaymentAmount = !boolValue;
    fieldVisibility.showTaxDeductible = !boolValue;
    fieldVisibility.linkedPropertyRequired = !boolValue;
  }

  return fieldVisibility;
}
