import {
  findStatusKeyFromStatus,
  findCardActionKeyFromLabel,
  findTeamToContactKeyFromTeamToContact
} from "./model";

export const fraudChatterMessage = (status, last4Digits, teamToContact) => {
  const teamToContactPhone = {
    Card_Dispute_Team: "(03) 4050-7895",
    Fraud_Team: "(03) 4050-7110"
  };
  let teamToContactKey = findTeamToContactKeyFromTeamToContact(teamToContact);

  let referToTeam =
    "\n\nPlease refer customer to the " +
    teamToContact +
    " on " +
    teamToContactPhone[teamToContactKey] +
    " for all questions relating to their card.";

  const fraudChatterMessages = {
    Block_ATM_POS_Exclude_CNP:
      "A physical transaction block has been placed on the customer's debit card ending in " +
      last4Digits +
      " by the ANZ Plus " +
      teamToContact +
      ". This means all physical transactions are blocked, including ATM and point of sale." +
      referToTeam,
    Block_CNP:
      "An online transaction block has been placed on the customer's debit card ending in " +
      last4Digits +
      " by the ANZ Plus  " +
      teamToContact +
      ". This means all online transactions are blocked." +
      referToTeam,
    Block_ATM_POS_CNP_BCH:
      "A physical and online transaction block has been placed on the customer's debit card ending in " +
      last4Digits +
      " by the ANZ Plus  " +
      teamToContact +
      ". This means all transactions are blocked, including physical, online, ATM and digital wallet." +
      referToTeam
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
      ".",
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
