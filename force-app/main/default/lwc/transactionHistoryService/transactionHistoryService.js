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
  PAYMENT_TYPE_UNSPECIFIED: "PAYMENT_TYPE_UNSPECIFIED",
  PAYMENT_TYPE_FAST: "PAYMENT_TYPE_FAST",
  PAYMENT_TYPE_LOW: "PAYMENT_TYPE_LOW",
  PAYMENT_TYPE_SWIFT: "PAYMENT_TYPE_SWIFT",
  PAYMENT_TYPE_XBR: "PAYMENT_TYPE_XBR",
  PAYMENT_TYPE_RTGS: "PAYMENT_TYPE_RTGS",
  PAYMENT_TYPE_FAST_RETURN: "PAYMENT_TYPE_FAST_RETURN",
  PAYMENT_TYPE_BKT: "PAYMENT_TYPE_BKT"
};

export const PAYMENT_SUB_TYPES = {
  PAYMENT_SUB_TYPE_UNSPECIFIED: "PAYMENT_SUB_TYPE_UNSPECIFIED",
  PAYMENT_SUB_TYPE_SCT: "PAYMENT_SUB_TYPE_SCT",
  PAYMENT_SUB_TYPE_ONUS: "PAYMENT_SUB_TYPE_ONUS",
  PAYMENT_SUB_TYPE_SOLICITED: "PAYMENT_SUB_TYPE_SOLICITED",
  PAYMENT_SUB_TYPE_UNSOLICITED: "PAYMENT_SUB_TYPE_UNSOLICITED",
  PAYMENT_SUB_TYPE_ICS1: "PAYMENT_SUB_TYPE_ICS1",
  PAYMENT_SUB_TYPE_DE: "PAYMENT_SUB_TYPE_DE"
};

export const TRANSACTION_HISTORY_RETRIEVE_ERROR =
  "Failed to retrieve transaction history. Please refresh and try again. If the problem persists, please contact your System Administrator.";
export const DISPUTE_RECORD_TYPES_RETRIEVE_ERROR =
  "Failed to retrieve dispute record types. Please refresh and try again. If the problem persists, please contact your System Administrator.";
export const PERSON_ACCOUNT_ID_RETRIEVE_ERROR =
  "Failed to retrieve contact Id. Please refresh and try again. If the problem persists, please contact your System Administrator.";
