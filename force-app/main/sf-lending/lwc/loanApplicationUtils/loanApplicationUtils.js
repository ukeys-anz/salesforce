/**
 *
 * @author Raman Gupta
 * @since 06/2025
 * @description Utils module which stores methods that can be shared between Loan Application related Lightning Web Components
 */

export const repaymentFrequencyMap = new Map([
  ["REPAYMENT_FREQUENCY_WEEKLY", "Weekly"],
  ["REPAYMENT_FREQUENCY_FORTNIGHTLY", "Fortnightly"],
  ["REPAYMENT_FREQUENCY_MONTHLY", "Monthly"],
  ["REPAYMENT_FREQUENCY_QUARTERLY", "Quarterly"],
  ["REPAYMENT_FREQUENCY_BI_ANNUAL", "Bi-Annually"],
  ["REPAYMENT_FREQUENCY_ANNUAL", "Annually"]
]);

export const repaymentTypeMap = new Map([
  ["REPAYMENT_TYPE_INTEREST_ONLY", "Interest Only"],
  ["REPAYMENT_TYPE_PRINCIPAL_INTEREST", "Principal and Interest"]
]);

export const interestRateTypeMap = new Map([
  ["INTEREST_RATE_TYPE_FIXED", "Fixed"],
  ["INTEREST_RATE_TYPE_VARIABLE", "Variable"]
]);

export const propertyUseMap = new Map([
  ["LOAN_PRODUCT_TYPE_OWNER_OCCUPIED", "Live In"],
  ["LOAN_PRODUCT_TYPE_INVESTOR", "Investment"]
]);
