import { createButtonsFromArray } from "./helper-button-class";
import { mapCardControls, mapTempLockOnACard } from "./helper-cardControls";
import { STATUS, MAPPED_STATUS } from "./model";

const FRAUD_STATUSES = [
  STATUS.Block_ATM,
  STATUS.Block_ATM_POS_CNP,
  STATUS.Block_POS_Exclude_CNP,
  STATUS.Block_CNP,
  STATUS.Block_ATM_POS_Exclude_CNP,
  STATUS.Block_ATM_POS_CNP_BCH
];

// function to handle mapping controls, tempLock flag, Status & buttons on the cards & sort
export function mapCardDetailsHandler(
  cards,
  userPermission,
  isActiveCardSection
) {
  for (let i = 0; i < cards.length; i++) {
    cards[i] = mapTempLockOnACard(cards[i]);
    cards[i] = mapCardControls(cards[i]);
    cards[i] = mappingStatusOnACard(cards[i]);
  }

  let mappedCards = createButtonsFromArray(
    cards,
    userPermission,
    isActiveCardSection
  );

  return mappedCards;
}

function mappingStatusOnACard(card) {
  for (let key in STATUS) {
    if (card.status === STATUS[key]) {
      card.statusToShow = MAPPED_STATUS[key];
    }
  }

  // Handles appending not activated for cards with activation eligibility
  if (
    card.status === "Issued" &&
    card.eligibilities.includes("ELIGIBILITY_CARD_ACTIVATION")
  ) {
    card.statusToShow += " (Not Activated)";
  }

  // Handles appending Temp Lock text for temp locked cards
  if (card.cardIsTempLocked) {
    card.statusToShow += " (Temporary Lock)";
  }

  card.isIssued = card.status === STATUS.Issued;
  card.isFraudBlocked = FRAUD_STATUSES.includes(card.status);
  if (card.isFraudBlocked) {
    card.fraudBlockMessage = getFraudBlockMessage(card.cardBlockType);
  }
  return card;
}
function getFraudBlockMessage(cardBlockType) {
  if (!cardBlockType) {
    return `Card controls are unavailable due to an existing fraud block. See chatter posts for more details.`;
  }
  if (cardBlockType.toLowerCase() === "automated") {
    return `Card Controls are unavailable due to an automated fraud block. Please refer customer to the app to self-unblock the card.`;
  } else if (cardBlockType.toLowerCase() === "manual") {
    return `Card Controls are unavailable due to a manual fraud block. See Chatter post for more detail.`;
  }

  return `Card Controls Information could not be retrieved due to an Error. Please Retry.`;
}
