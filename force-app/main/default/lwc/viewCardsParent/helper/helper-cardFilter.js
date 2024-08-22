const ACTIVE_CARD_STATUS_LIST = [
  "Issued",
  "Block CNP",
  "Block ATM & POS (Exclude CNP)",
  "Block ATM, POS, CNP & BCH",
  "Temporary Lock",
  "Temporary Block",
  "Replace Status",
  "Unissued (N&D ICI Cards)",
  "Block ATM",
  "Block ATM, POS & CNP",
  "Block POS (exclude CNP)"
];

const CLOSED_CARD_STATUS_LIST = [
  "Closed",
  "Delinquent (Retain Card)",
  "Lost",
  "Stolen",
  "Delinquent (Return Card)"
];

export function filterCardsBasedOnStatus(cardsList, isActiveList) {
  return isActiveList
    ? cardsList.filter((card) => ACTIVE_CARD_STATUS_LIST.includes(card.status))
    : cardsList.filter((card) => CLOSED_CARD_STATUS_LIST.includes(card.status));
}
