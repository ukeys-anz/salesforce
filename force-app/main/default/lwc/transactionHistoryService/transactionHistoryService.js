import TransactionAPIUpliftedToV1 from "@salesforce/label/c.TransactionAPIUpliftedToV1";

export const TRANSACTION_STATUSES = {
  Unspecified: "Unknown",
  Pending: "Pending",
  Posted: "Posted"
};

export const TRANSACTION_TYPES = {
  Unknown: "Unknown",
  Card: "Card",
  Direct_Debit: "Direct Debit",
  Fee: "Fee",
  Interest: "Interest",
  Deposit_Withdrawal: "Deposit Withdrawal",
  Transfer: "Transfer",
  PAYID: "PAYID",
  BSB_ACC: "BSB/ACC",
  BPAY: "BPAY",
  Other: "Other",
  Salary: "Salary",
  Payment: "Payment"
};

export const CARD_TYPES = {
  Unknown: "Unknown",
  Visa: "Visa",
  Mastercard: "Mastercard",
  EFTPOS: "EFTPOS",
  American_Express: "American Express"
};

export const PAYMENT_TYPES = {
  // conditional mapping based on custom label for v1 and v1b1
  PAYMENT_TYPE_UNSPECIFIED: "PAYMENT_TYPE_UNSPECIFIED", // common in both v1 and v1b1
  PAYMENT_TYPE_FAST: !isTransactionsV1() ? "PAYMENT_TYPE_FAST" : "FAST",
  PAYMENT_TYPE_LOW: !isTransactionsV1() ? "PAYMENT_TYPE_LOW" : "LOW",
  PAYMENT_TYPE_SWIFT: !isTransactionsV1() ? "PAYMENT_TYPE_SWIFT" : "SWIFT",
  PAYMENT_TYPE_XBR: !isTransactionsV1() ? "PAYMENT_TYPE_XBR" : "XBR",
  PAYMENT_TYPE_RTGS: !isTransactionsV1() ? "PAYMENT_TYPE_RTGS" : "RTGS",
  PAYMENT_TYPE_FAST_RETURN: !isTransactionsV1()
    ? "PAYMENT_TYPE_FAST_RETURN"
    : "FAST_RETURN",
  PAYMENT_TYPE_BKT: !isTransactionsV1() ? "PAYMENT_TYPE_BKT" : "BKT"
};

export const PAYMENT_SUB_TYPES = {
  // conditional mapping based on custom label
  PAYMENT_SUB_TYPE_UNSPECIFIED: "PAYMENT_SUB_TYPE_UNSPECIFIED", // common in both v1 and v1b1
  PAYMENT_SUB_TYPE_SCT: !isTransactionsV1() ? "PAYMENT_SUB_TYPE_SCT" : "SCT",
  PAYMENT_SUB_TYPE_ONUS: !isTransactionsV1() ? "PAYMENT_SUB_TYPE_ONUS" : "ONUS",
  PAYMENT_SUB_TYPE_SOLICITED: !isTransactionsV1()
    ? "PAYMENT_SUB_TYPE_SOLICITED"
    : "SOLICITED",
  PAYMENT_SUB_TYPE_UNSOLICITED: !isTransactionsV1()
    ? "PAYMENT_SUB_TYPE_UNSOLICITED"
    : "UNSOLICITED",
  PAYMENT_SUB_TYPE_ICS1: !isTransactionsV1() ? "PAYMENT_SUB_TYPE_ICS1" : "ICS1",
  PAYMENT_SUB_TYPE_DE: !isTransactionsV1() ? "PAYMENT_SUB_TYPE_DE" : "DE"
};

export const TRANSACTION_HISTORY_RETRIEVE_ERROR =
  "Failed to retrieve transaction history. Please refresh and try again. If the problem persists, please contact your System Administrator.";
export const DISPUTE_RECORD_TYPES_RETRIEVE_ERROR =
  "Failed to retrieve dispute record types. Please refresh and try again. If the problem persists, please contact your System Administrator.";
export const PERSON_ACCOUNT_ID_RETRIEVE_ERROR =
  "Failed to retrieve contact Id. Please refresh and try again. If the problem persists, please contact your System Administrator.";

//Remapping the status and types returned from the API so they
//are more readable on the UI
export const transactionStatusMapping = {
  //For V1
  TRANSACTION_STATUS_UNSPECIFIED: TRANSACTION_STATUSES.Unspecified, // common in both v1 and v1b1
  PENDING: TRANSACTION_STATUSES.Pending,
  POSTED_INTRADAY: TRANSACTION_STATUSES.Posted,
  POSTED_PRIORDAY: TRANSACTION_STATUSES.Posted,

  //For BetaV1, this will be removed once Mule has onboarded V1
  TRANSACTION_STATUS_PENDING: TRANSACTION_STATUSES.Pending,
  TRANSACTION_STATUS_POSTED: TRANSACTION_STATUSES.Posted
};

export const transactionTypeMapping = {
  //For V1
  CARD: TRANSACTION_TYPES.Card,
  DIRECT_DEBIT: TRANSACTION_TYPES.Direct_Debit,
  INTEREST: TRANSACTION_TYPES.Interest,
  DEPOSIT_WITHDRAWAL: TRANSACTION_TYPES.Deposit_Withdrawal, // DEPOSIT_WITHDRAWAL with typo as this is what Fabric sends, confirmed with their team
  TRANSFER: TRANSACTION_TYPES.Transfer,
  PAYID: TRANSACTION_TYPES.PAYID,
  BSB_ACC_NUM: TRANSACTION_TYPES.BSB_ACC,
  BPAY: TRANSACTION_TYPES.BPAY,
  SALARY: TRANSACTION_TYPES.Salary,
  PAYMENT: TRANSACTION_TYPES.Payment,

  //For BetaV1, this will be removed once Mule has onboarded V1
  TRANSACTION_TYPE_UNSPECIFIED: TRANSACTION_TYPES.Unknown, // common in both v1 and v1b1
  TRANSACTION_TYPE_CARD: TRANSACTION_TYPES.Card,
  TRANSACTION_TYPE_PAYMENT: TRANSACTION_TYPES.Payment,
  TRANSACTION_TYPE_DIRECT_DEBIT: TRANSACTION_TYPES.Direct_Debit,
  TRANSACTION_TYPE_FEE: TRANSACTION_TYPES.Fee,
  TRANSACTION_TYPE_INTEREST: TRANSACTION_TYPES.Interest,
  TRANSACTION_TYPE_DEPOSIT_WITHDRAWL: TRANSACTION_TYPES.Deposit_Withdrawal, // TRANSACTION_TYPE_DEPOSIT_WITHDRAWL with typo as this is what Fabric sends, confirmed with their team
  TRANSACTION_TYPE_TRANSFER: TRANSACTION_TYPES.Transfer,
  TRANSACTION_TYPE_PAYID: TRANSACTION_TYPES.PAYID,
  TRANSACTION_TYPE_BSB_ACC_NUM: TRANSACTION_TYPES.BSB_ACC,
  TRANSACTION_TYPE_BPAY: TRANSACTION_TYPES.BPAY,
  TRANSACTION_TYPE_SALARY: TRANSACTION_TYPES.Salary,
  TRANSACTION_TYPE_OTHER: TRANSACTION_TYPES.Other
};

export const cardMapping = {
  //For V1
  CARD_SCHEME_UNSPECIFIED: CARD_TYPES.Unknown, // common in both v1 and v1b1
  VISA: CARD_TYPES.Visa,
  MASTERCARD: CARD_TYPES.Mastercard,
  EFTPOS: CARD_TYPES.EFTPOS,
  AMERICAN_EXPRESS: CARD_TYPES.American_Express,

  //For BetaV1, this will be removed once Mule has onboarded V1
  CARD_SCHEME_VISA: CARD_TYPES.Visa,
  CARD_SCHEME_MASTERCARD: CARD_TYPES.Mastercard,
  CARD_SCHEME_EFTPOS: CARD_TYPES.EFTPOS,
  CARD_SCHEME_AMERICAN_EXPRESS: CARD_TYPES.American_Express
};

export const dateOptions = {
  weekday: "long",
  year: "numeric",
  month: "long",
  day: "numeric"
};

export const timeOptions = { hour: "2-digit", minute: "2-digit" };

function isTransactionsV1() {
  return TransactionAPIUpliftedToV1 === "True";
}
