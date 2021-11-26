import { STATUS } from "./model";

function cardIsLockedForUse(status) {
  let lockedStatus = [
    STATUS.Temporary_Block,
    STATUS.Temporary_Lock,
    STATUS.Block_ATM_POS_CNP_BCH,
    STATUS.Block_ATM_POS_Exclude_CNP,
    STATUS.Block_CNP,
    STATUS.Block_ATM,
    STATUS.Block_ATM_POS_CNP,
    STATUS.Block_POS_Exclude_CNP
  ];
  return lockedStatus.includes(status);
}

function cardIsDisabledForUse(status) {
  let disabledStatus = [
    STATUS.Closed,
    STATUS.Delinquent_Retain_Card,
    STATUS.Replace_Status,
    STATUS.Card_Status_Invalid,
    STATUS.Delinquent_Return_Card,
    STATUS.Lost,
    STATUS.Stolen,
    STATUS.Un_Issued
  ];
  return disabledStatus.includes(status);
}

export function cardImageHandler(card_images, status = "") {
  let imagePath = card_images.default;

  if (status == STATUS.Issued) {
    imagePath = card_images.active;
  } else if (cardIsLockedForUse(status)) {
    imagePath = card_images.locked;
  } else if (cardIsDisabledForUse(status)) {
    imagePath = card_images.disabled;
  }
  return imagePath;
}
