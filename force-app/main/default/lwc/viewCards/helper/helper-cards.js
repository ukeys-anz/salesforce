import { createButtonsFromArray } from "./helper-button-class";
import { mapCardControls, mapTempLockOnACard } from "./helper-cardControls";
import { STATUS, MAPPED_STATUS } from "./model";

const inactiveStatuses = [
  STATUS.Closed,
  STATUS.Delinquent_Retain_Card,
  STATUS.Replace_Status,
  STATUS.Card_Status_Invalid,
  STATUS.Delinquent_Return_Card,
  STATUS.Lost,
  STATUS.Stolen,
  STATUS.Un_Issued
];

const FRAUD_STATUSES = [
  STATUS.Block_ATM,
  STATUS.Block_ATM_POS_CNP,
  STATUS.Block_POS_Exclude_CNP,
  STATUS.Block_CNP,
  STATUS.Block_ATM_POS_Exclude_CNP,
  STATUS.Block_ATM_POS_CNP_BCH
];

// function to handle mapping controls, tempLock flag, Status & buttons on the cards & sort
export function mapCardDetailsHandler(cards, userPermission) {
  for (let i = 0; i < cards.length; i++) {
    cards[i] = mapTempLockOnACard(cards[i]);
    cards[i] = mapCardControls(cards[i]);
    cards[i] = mappingStatusOnACard(cards[i]);
  }

  let mappedCards = createButtonsFromArray(cards, userPermission);

  let sortedCards = sortCardsHandler(mappedCards);

  return sortedCards;
}

function sortCardsHandler(cards) {
  if (cards.length > 1) {
    cards.sort((cardA, cardB) => {
      if (cardA.status === STATUS.Issued) {
        return -1;
      }
      if (inactiveStatuses.includes(cardB.status)) {
        return -1;
      }
      return 1;
    });
  }
  return cards;
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
  return card;
}
