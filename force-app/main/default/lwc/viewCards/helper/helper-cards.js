import { createButtonsFromArray } from "./helper-button-class";
import { mapCardControls, mapTempLockOnACard } from "./helper-cardControls";
import {
  STATUS,
  MAPPED_STATUS,
  CUSTOMER_ACTIONS,
  FRAUD_BLOCK_MESSAGE
} from "./model";

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
    card.fraudBlockMessage = getFraudBlockMessage(
      card.cardBlockType,
      card.falconEvent?.requiredCustomerAction
    );
  }
  return card;
}

function getFraudBlockMessage(cardBlockType, customerAction) {
  if (!cardBlockType || cardBlockType.toLowerCase() === "manual") {
    return FRAUD_BLOCK_MESSAGE.DEFAULT;
  }
  const msgMap = {
    [CUSTOMER_ACTIONS.OWN_DISOWN]: FRAUD_BLOCK_MESSAGE.SELF_SERVICE,
    [CUSTOMER_ACTIONS.CALL_ANZ]: FRAUD_BLOCK_MESSAGE.NON_SELF_SERVICE
  };

  if (cardBlockType.toLowerCase() === "automated") {
    return msgMap[customerAction] || FRAUD_BLOCK_MESSAGE.DEFAULT;
  }

  return FRAUD_BLOCK_MESSAGE.ERROR;
}
