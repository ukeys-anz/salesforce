import { STATUS } from "./model";

function cardIsLockedForUse(card) {
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
  return lockedStatus.includes(card.status) || card.cardIsTempLocked;
}

function cardIsDisabledForUse(card) {
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
  return disabledStatus.includes(card.status);
}

export function cardImageHandler(card_images, card) {
  let imagePath = card_images.default;

  if (card) {
    // When GCT_Global lock is applied, Status is still issued
    if (card.status == STATUS.Issued && !card.cardIsTempLocked) {
      imagePath = card_images.active;
    } else if (cardIsLockedForUse(card)) {
      imagePath = card_images.locked;
    } else if (cardIsDisabledForUse(card)) {
      imagePath = card_images.disabled;
    }
  }
  return imagePath;
}
