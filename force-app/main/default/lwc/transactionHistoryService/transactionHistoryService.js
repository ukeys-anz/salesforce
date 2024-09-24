import TransactionAPIUpliftedToV1 from "@salesforce/label/c.TransactionAPIUpliftedToV1";

//Added to check the value present in Transaction Initiator Column and Ownership field
export const MULTI_PARTY = "Multi-party";
export const JOINT = "Joint";
export const THIS_CUSTOMER = "This Customer";
export const CO_OWNER = "Co-Owner";

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
  Payment: "Payment",
  PayTo: "PayTo"
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
  PAYTO: TRANSACTION_TYPES.PayTo,

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

export const cardSchemeApiValues = {
  //For V1
  CARD_SCHEME_UNSPECIFIED: "CARD_SCHEME_UNSPECIFIED",
  VISA: "CARD_SCHEME_VISA",
  MASTERCARD: "CARD_SCHEME_MASTERCARD",
  EFTPOS: "CARD_SCHEME_EFTPOS",
  AMERICAN_EXPRESS: "CARD_SCHEME_AMERICAN_EXPRESS"
};

export const dateOptions = {
  weekday: "long",
  year: "numeric",
  month: "long",
  day: "numeric"
};

export const timeOptions = { hour: "2-digit", minute: "2-digit" };

export const dateTimeOptions = {
  weekday: "short",
  year: "numeric",
  month: "short",
  day: "numeric",
  hour: "2-digit",
  minute: "2-digit"
};

function isTransactionsV1() {
  return TransactionAPIUpliftedToV1 === "True";
}

//https://github.com/anzx/apis/blob/7d0b87fc98b728bccc3548113e9e0afc83012045/anz/fabricapis/fabric/service/transactions/v1/transaction.proto#L225C1-L235C2
export const CARD_METHOD = {
  CARD_METHOD_UNSPECIFIED: "CARD_METHOD_UNSPECIFIED", // Default assignment for this enum
  MANUAL: "MANUAL", // Manual invocation of a card
  SWIPE: "SWIPE", // Card was swiped through a reader
  CHIP: "CHIP", // Card chip was inserted into a reader
  CONTACTLESS: "CONTACTLESS", // Contactless Payment
  CARD_ON_FILE: "CARD_ON_FILE", // Merchant has card on file which they use to invoke
  IN_APP: "IN_APP", // Card invoked in application
  ONLINE: "ONLINE", // Card invoked in a website
  DIGITAL: "DIGITAL" // Card invoked via digital wallet
};

//https://github.com/anzx/apis/blob/7d0b87fc98b728bccc3548113e9e0afc83012045/anz/fabricapis/fabric/service/transactions/v1/transaction.proto#L249-L260
export const CARD_WALLET = {
  CARD_WALLET_UNSPECIFIED: "CARD_WALLET_UNSPECIFIED", // Default assignment for this enum
  APPLE_PAY: "APPLE_PAY", // Apple Wallet
  GOOGLE_PAY: "GOOGLE_PAY", // Google Wallet
  SAMSUNG_PAY: "SAMSUNG_PAY", // Samsung Wallet
  FITBIT: "FITBIT", // Fitbit Wallet
  GARMIN: "GARMIN", // Garmin Wallet
  PAYPAL: "PAYPAL", // Paypal Wallet
  VISA_ECOM_ENABLER: "VISA_ECOM_ENABLER",
  VISA_COF_ECOM: "VISA_COF_ECOM",
  OTHER_NFC_WALLET: "OTHER_NFC_WALLET",
  EFTPOS_MTR: "EFTPOS_MTR"
};

export const CARD_TRANSACTION_METHOD = {
  Apple_Pay_payWave: "Apple Pay payWave",
  Google_Pay_payWave: "Google Pay payWave",
  Samsung_Pay_payWave: "Samsung Pay payWave",
  Apple_Pay_Online_or_In_App: "Apple Pay Online or In-App",
  Google_Pay_Online_or_In_App: "Google Pay Online or In-App",
  Samsung_Pay_Online_or_In_App: "Samsung Pay Online or In-App",
  Apple_Pay_Recurring_Billing: "Apple Pay Recurring Billing",
  Google_Pay_Recurring_Billing: "Google Pay Recurring Billing",
  Samsung_Pay_Recurring_Billing: "Samsung Pay Recurring Billing",
  Card_Chip_PIN: "Card Chip & PIN",
  Card_payWave: "Card payWave",
  Card_Magnetic_Swipe: "Card Magnetic Swipe",
  Card_Saved_on_File_With_Merchant: "Card Saved on File With Merchant",
  Card_Manually_Keyed_in_to_Terminal: "Card Manually Keyed in to Terminal",
  Card_Manually_Keyed_in_to_Website: "Card Manually Keyed in to Website"
};
