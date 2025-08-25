export const STATUS = {
  Issued: "Issued",
  Block_CNP: "Block CNP",
  Block_ATM_POS_Exclude_CNP: "Block ATM & POS (Exclude CNP)",
  Block_ATM_POS_CNP_BCH: "Block ATM, POS, CNP & BCH",
  Temporary_Lock: "Temporary Lock",
  Temporary_Block: "Temporary Block",
  Replace_Status: "Replace Status",
  Closed: "Closed",
  Delinquent_Retain_Card: "Delinquent (Retain Card)",
  Card_Status_Invalid: "CARDSTATUS_INVALID",
  Delinquent_Return_Card: "Delinquent (Return Card)",
  Lost: "Lost",
  Stolen: "Stolen",
  Un_Issued: "Unissued (N&D ICI Cards)",
  Block_ATM: "Block ATM",
  Block_ATM_POS_CNP: "Block ATM, POS & CNP",
  Block_POS_Exclude_CNP: "Block POS (exclude CNP)"
};

export const CARD_ELIGIBILITY = {
  Card_Lost: "ELIGIBILITY_CARD_REPLACEMENT_LOST",
  Card_Stolen: "ELIGIBILITY_CARD_REPLACEMENT_STOLEN",
  Card_Damaged: "ELIGIBILITY_CARD_REPLACEMENT_DAMAGED",
  Card_Block: "ELIGIBILITY_BLOCK"
};

export const MAPPED_STATUS = {
  Issued: "Issued",
  Block_ATM_POS_Exclude_CNP: "Physical Transactions Blocked",
  Block_ATM_POS_CNP_BCH: "All Transactions Blocked",
  Block_CNP: "Online Transactions Blocked",
  Delinquent_Retain_Card: "Card Cancelled",
  Temporary_Lock: "Temporary Lock",
  Temporary_Block: "Temporary Lock",
  Replace_Status: "Replace Status",
  Closed: "Closed",
  Card_Status_Invalid: "CARDSTATUS_INVALID",
  Delinquent_Return_Card: "Delinquent (Return Card)",
  Lost: "Lost",
  Stolen: "Stolen",
  Un_Issued: "Unissued (N&D ICI Cards)",
  Block_ATM: "Block ATM",
  Block_ATM_POS_CNP: "Block ATM, POS & CNP",
  Block_POS_Exclude_CNP: "Block POS (exclude CNP)"
};

export const CARD_CONTROLS_DEFINITION = [
  {
    key: "TCT_CONTACTLESS",
    label: "Contactless Payments",
    value: true,
    visible: true,
    isCheckbox: true
  },
  {
    key: "TCT_ATM_WITHDRAW",
    label: "ATM Withdrawals",
    value: true,
    visible: true,
    isCheckbox: true
  },
  {
    key: "TCT_E_COMMERCE",
    label: "Online Transactions",
    value: true,
    visible: true,
    isCheckbox: true
  },
  {
    key: "TCT_CROSS_BORDER",
    label: "Overseas Transactions (In-Store)",
    value: true,
    visible: true,
    isCheckbox: true
  },
  {
    key: "MCT_GAMBLING",
    label: "Gambling Block",
    value: false,
    tooltip:
      "Transactions categorised as gambling such as online betting and lottery tickets may be blocked when turned on.",
    visible: true,
    isCheckbox: true
  },
  {
    key: "MCT_GAMBLING",
    label: "Gambling Block Delay Status",
    type: "text",
    value: "N/A",
    tooltip:
      "There is a 48-hour delay after a customer requests to unblock gambling. The customer can return to their app to remove the block once the 48-hour delay has ended.",
    visible: true
  },
  {
    key: "GCT_GLOBAL",
    label: "Physical Lock",
    value: false,
    visible: false,
    isCheckbox: true
  }
];

export const CUSTOMER_ACTIONS = {
  OWN_DISOWN: "REQUIRED_CUSTOMER_ACTION_OWN_DISOWN",
  CALL_ANZ: "REQUIRED_CUSTOMER_ACTION_CALL_ANZ"
};

export const FRAUD_BLOCK_MESSAGE = {
  SELF_SERVICE:
    "Card controls are unavailable due to an automated fraud block. Customer must manage the notification in the app and will be referred to the Fraud team if needed.",
  NON_SELF_SERVICE:
    "Card controls are unavailable due to an automated fraud block that is not self-serviceable. Customer will be referred to the Fraud Team. Please refer the customer to the Fraud Detection team in Twilio.",
  DEFAULT:
    "Card controls are unavailable due to an automated or manual fraud block. See chatter posts for which team the customer should be referred to. If there's no associated chatter post, please refer the customer to the Fraud Detection team in Twilio.",
  ERROR:
    "Card Controls Information could not be retrieved due to an Error. Please Retry."
};
