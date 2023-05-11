import { findStatusKeyFromStatus, findCardActionKeyFromLabel } from "./model";

export const fraudChatterMessage = (status, last4Digits) => {
  const fraudChatterMessages = {
    Block_ATM_POS_Exclude_CNP:
      "A physical transaction block has been placed on the customer's debit card ending in " +
      last4Digits +
      " by the ANZ Plus Fraud team. This means all physical transactions are blocked, including ATM and point of sale.\n\nPlease refer customer to the fraud team on (03) 4050-7110 for all questions relating to their card.",
    Block_CNP:
      "An online transaction block has been placed on the customer's debit card ending in " +
      last4Digits +
      " by the ANZ Plus Fraud team. This means all online transactions are blocked.\n\nPlease refer customer to the fraud team on (03) 4050-7110 for all questions relating to their card.",
    Block_ATM_POS_CNP_BCH:
      "A physical and online transaction block has been placed on the customer's debit card ending in " +
      last4Digits +
      " by the ANZ Plus Fraud team. This means all transactions are blocked, including physical, online, ATM and digital wallet.\n\nPlease refer customer to the fraud team on (03) 4050-7110 for all questions relating to their card."
  };
  let statusKey = findStatusKeyFromStatus(status);
  return fraudChatterMessages[statusKey];
};

export const primaryButtonChatterMessage = (
  btnLabel,
  last4Digits,
  currentUserName
) => {
  const messageForPrimaryButtons = {
    Fraud_Unlock:
      "All fraud locks have been removed from the customer's debit card ending in " +
      last4Digits +
      " by the ANZ Plus Fraud team.",
    Remove_Temporary_Lock:
      "All temporary locks have been removed from the customer's debit card ending in " +
      last4Digits +
      " by the ANZ Plus Fraud team.",
    Cancel_Card:
      "The customer's debit card ending in " +
      last4Digits +
      " has been permanently cancelled as part of an account closure process by " +
      currentUserName +
      "."
  };
  let btnKey = findCardActionKeyFromLabel(btnLabel);
  return messageForPrimaryButtons[btnKey];
};
