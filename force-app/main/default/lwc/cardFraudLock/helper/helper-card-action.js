import { STATUS, findCardActionKeyFromLabel } from "./model";

const primaryButtonToCardStatusMapping = {
  Fraud_Unlock: STATUS.Issued,
  Remove_Temporary_Lock: STATUS.Issued,
  Cancel_Card: STATUS.Delinquent_Retain_Card
};

export function primaryButtonToCardStatus(btnLabel) {
  const buttonKey = findCardActionKeyFromLabel(btnLabel);
  return primaryButtonToCardStatusMapping[buttonKey];
}

const CARD_ACTION_REASONS = {
  Fraud_Lock: "",
  Fraud_Unlock: "",
  Remove_Temporary_Lock: "",
  Cancel_Card: "Fraud"
};

export function cardActionReason(cardAction) {
  const cardActionKey = findCardActionKeyFromLabel(cardAction);
  return CARD_ACTION_REASONS[cardActionKey];
}
