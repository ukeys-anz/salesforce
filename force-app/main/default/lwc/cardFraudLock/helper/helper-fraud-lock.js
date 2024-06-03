import {
  STATUS,
  FRAUD_BUTTONS_TEXT,
  TEAM_TO_CONTACT_TEXT,
  PRIMARYCARDACTIONS
} from "./model";

const FRAUD_LOCK_OPTIONS = [
  {
    status: STATUS.Block_ATM_POS_Exclude_CNP,
    label: FRAUD_BUTTONS_TEXT.Block_ATM_POS_Exclude_CNP
  },
  { status: STATUS.Block_CNP, label: FRAUD_BUTTONS_TEXT.Block_CNP },
  {
    status: STATUS.Block_ATM_POS_CNP_BCH,
    label: FRAUD_BUTTONS_TEXT.Block_ATM_POS_CNP_BCH
  }
];

const TEAM_TO_CONTACT_OPTIONS = [
  {
    label: TEAM_TO_CONTACT_TEXT.Card_Dispute_Team
  },
  {
    label: TEAM_TO_CONTACT_TEXT.Fraud_Team
  }
];

export function fraudLockOptionsSchema(cardStatus) {
  return FRAUD_LOCK_OPTIONS.map((fraudLockStatusOption) => {
    return {
      status: fraudLockStatusOption.status,
      label: fraudLockStatusOption.label,
      variantSituation:
        cardStatus === fraudLockStatusOption.status ? "brand" : "brand-outline"
    };
  });
}

export function teamToContactOptionsSchema(teamToContect) {
  return TEAM_TO_CONTACT_OPTIONS.map((teamToContactOption) => {
    return {
      label: teamToContactOption.label,
      variantSituation:
        teamToContect === teamToContactOption.label ? "brand" : "brand-outline"
    };
  });
}

export function showFraudLockOptions(btnLabel) {
  return btnLabel === PRIMARYCARDACTIONS.Fraud_Lock;
}
