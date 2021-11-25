import {
  findCardActionKeyFromLabel,
  FRAUD_BUTTONS_TEXT,
  findStatusKeyFromStatus
} from "./model";

const messageSchema = {
  Fraud_Lock: {
    firstMessage: "",
    secondMessage:
      "A chatter post from you will be added to the customer's profile on to advise that you have placed this block.",
    thirdMessage: "",
    title: "Submit Card Block",
    label: "Confirm Lock",
    variant: "brand",
    strongText: false
  },
  Fraud_Unlock: {
    firstMessage:
      "Are you sure you want to remove all blocks from the customers card?",
    secondMessage:
      "A chatter post will be placed on the customer's profile on to advise that you have removed all locks.",
    thirdMessage:
      "Please let the customer know it takes up to 15 minutes for the unblocking to take effect, and they shouldn't make any purchases for that time.",
    title: "Remove Card Block",
    label: "Confirm Unlock",
    variant: "brand",
    strongText: false
  },
  Remove_Temporary_Lock: {
    firstMessage: "Are you sure you want to remove temporary block?",
    secondMessage: "",
    thirdMessage: "",
    title: "Remove Temporary Block",
    label: "Confirm Remove Temporary Lock",
    variant: "brand",
    strongText: false
  },
  Cancel_Card: {
    firstMessage:
      "Are you sure you want to permanently cancel the customer's card?",
    secondMessage:
      "A chatter post will be placed on the customer's profile to advise that you have cancelled their card.",
    thirdMessage:
      "this action is permanent and the card cannot be re-instated. This option should only be selected as part of confirmed business processes.",
    title: "Permanently Cancel Card",
    label: "Confirm Card Cancellation",
    variant: "destructive",
    strongText: true
  }
};

export function firstMessageForFraudOption(fraudStatusChosen, message) {
  let statusKey = findStatusKeyFromStatus(fraudStatusChosen);
  if (statusKey != null) {
    message.firstMessage = `Are you sure you want to place ${FRAUD_BUTTONS_TEXT[statusKey]} Block on the customers card?`;
  }
  return message;
}

export function messageHandler(btnLabel) {
  const button = findCardActionKeyFromLabel(btnLabel);
  let message = messageSchema[button];
  return message;
}
