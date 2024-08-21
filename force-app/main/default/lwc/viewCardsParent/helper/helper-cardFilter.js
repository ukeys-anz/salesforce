export const activeCardStatusList = [
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

export const closedCardStatusList = [
  "Closed",
  "Delinquent (Retain Card)",
  "Lost",
  "Stolen",
  "Delinquent (Return Card)"
];

export function filterCardsBasedOnStatus(cardsList, isActiveList) {
  return isActiveList
    ? cardsList.filter((card) => activeCardStatusList.includes(card.status))
    : cardsList.filter((card) => closedCardStatusList.includes(card.status));
}
