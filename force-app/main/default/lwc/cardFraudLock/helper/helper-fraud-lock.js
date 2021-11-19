import { STATUS, FRAUD_BUTTONS_TEXT, PRIMARYCARDACTIONS } from "./model";

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

export function showFraudLockOptions(btnLabel) {
  return btnLabel === PRIMARYCARDACTIONS.Fraud_Lock;
}
