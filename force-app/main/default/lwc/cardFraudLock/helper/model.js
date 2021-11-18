export const PRIMARYCARDACTIONS = {
  Fraud_Lock: "Fraud Lock",
  Fraud_Unlock: "Fraud Unlock",
  Remove_Temporary_Lock: "Remove Temporary Lock",
  Cancel_Card: "Cancel Card"
};

export const STATUS = {
  Block_ATM_POS_Exclude_CNP: "Block ATM & POS (Exclude CNP)",
  Block_CNP: "Block CNP",
  Block_ATM_POS_CNP_BCH: "Block ATM, POS, CNP & BCH",
  Issued: "Issued",
  Delinquent_Retain_Card: "Delinquent (Retain Card)"
};

export const FRAUD_BUTTONS_TEXT = {
  Block_ATM_POS_Exclude_CNP: "Physical Transactions",
  Block_ATM_POS_CNP_BCH: "All Transactions",
  Block_CNP: "Online Transactions"
};

export function findKeyFromValue(object, value) {
  for (let key in object) {
    if (object[key] == value) {
      return key;
    }
  }
}

export function findCardActionKeyFromLabel(btnLabel) {
  return findKeyFromValue(PRIMARYCARDACTIONS, btnLabel);
}

export function findStatusKeyFromStatus(status) {
  return findKeyFromValue(STATUS, status);
}
