export const incomeTypeOptions = [
  {
    label: "Overtime",
    value: "isOverTime"
  },
  {
    label: "Comission",
    value: "isCommission"
  },
  {
    label: "Bonus",
    value: "isBonuses"
  }
];
export const incomeTaxOptions = [
  {
    label: "Before Tax",
    value: "INCOME_AMOUNT_TYPE_GROSS"
  },
  {
    label: "After Tax",
    value: "INCOME_AMOUNT_TYPE_NET"
  }
];
export const frequencyOptions = [
  {
    label: "Weekly",
    value: "INCOME_FREQUENCY_WEEKLY"
  },
  {
    label: "Fortnightly",
    value: "INCOME_FREQUENCY_FORTNIGHTLY"
  },
  {
    label: "Monthly",
    value: "INCOME_FREQUENCY_MONTHLY"
  },
  {
    label: "Yearly",
    value: "INCOME_FREQUENCY_YEARLY"
  }
];

export const typeMap = {
  isOverTime: "INCOME_TYPE_OVERTIME",
  isCommission: "INCOME_TYPE_COMMISSION",
  isBonuses: "INCOME_TYPE_BONUS"
};

export const mandatoryFields = [
  "belongsTo",
  "businessName",
  "basis",
  "startDateValue"
];
export const incomeDetailsFields = [
  "amountValue",
  "amountType",
  "frequency",
  "bonusPayments"
];
export const FIELDS_MISSING_MSG = "Please fill in all the mandatory fields.\n";
export const INCOME_DETAIL_MISSING_MSG =
  "Mandatory Information is missing from the Income Details. An entry is required for all the fields within each Income Type. Please review and try again.\n";
export const FUTURE_DATE_MSG =
  "The Start Date cannot be in the future. Please review and try again.\n";

export const employmentTypeOptions = [
  { label: "Full Time", value: "EMPLOYMENT_BASIS_FULL_TIME" },
  { label: "Part Time", value: "EMPLOYMENT_BASIS_PART_TIME" },
  { label: "Contractor", value: "EMPLOYMENT_BASIS_CONTRACTOR" },
  { label: "Casual", value: "EMPLOYMENT_BASIS_CASUAL" }
];

export function checkDateInPast(aDate) {
  if (new Date() < aDate) {
    return false;
  }
  return true;
}
