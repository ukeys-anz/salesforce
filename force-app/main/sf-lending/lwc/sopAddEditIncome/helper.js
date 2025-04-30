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
  "startDateValue",
  "type"
];
export const incomeDetailsFields = [
  "amountValue",
  "amountType",
  "frequency",
  "bonusPayments"
];

export const incomeTypesDetailSalary = [
  {
    isBase: true,
    amountType: "",
    frequency: "",
    amountValue: "",
    type: "INCOME_TYPE_BASE_SALARY"
  }
];

export const incomeTypesDetailRental = [
  {
    amountType: "INCOME_AMOUNT_TYPE_GROSS",
    frequency: "",
    amountValue: "",
    type: ""
  }
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

export const rentalIncomeTypeOptions = [
  { label: "Standard Lease", value: "INCOME_TYPE_RESIDENTIAL_STANDARD_LEASE" },
  {
    label: "Private Lease",
    value: "INCOME_TYPE_RESIDENTIAL_PRIVATE_LEASE"
  },
  { label: "Short Stay", value: "INCOME_TYPE_RESIDENTIAL_SHORT_STAY" }
];

export function checkDateInPast(aDate) {
  if (new Date() < aDate) {
    return false;
  }
  return true;
}

export function getISOdate(dateStr) {
  if (!dateStr) return "";
  const myDate = new Date(dateStr);
  const offset = myDate.getTimezoneOffset();
  const localDate = new Date(myDate.getTime() - offset * 60 * 1000);
  return localDate.toISOString().split("T")[0];
}

export function createIncomeOptions(noRental) {
  return [
    {
      label: "Salary and Wages",
      value: "salary"
    },
    {
      label: "Rental Income",
      value: "rental",
      disabled: noRental
    }
  ];
}

export function createBelongsToOption(partyIdToFirstNameMap) {
  let belongsToOptions = [{ label: "--Please Select--", value: "" }];
  belongsToOptions = belongsToOptions.concat(
    Object.keys(partyIdToFirstNameMap).map((key) => ({
      label: partyIdToFirstNameMap[key],
      value: key
    }))
  );
  return belongsToOptions;
}
