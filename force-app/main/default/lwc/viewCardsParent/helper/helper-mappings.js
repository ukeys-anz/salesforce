const STATUS_MAP = new Map([
  ["CARD_STATUS_CODE_ISSUED", "Issued"],
  ["CARD_STATUS_CODE_BLOCKCNP", "Block CNP"],
  ["CARD_STATUS_CODE_BLOCKATMPOSEXCLUDECNP", "Block ATM & POS (Exclude CNP)"],
  ["CARD_STATUS_CODE_BLOCKATMPOSCNPBCH", "Block ATM, POS, CNP & BCH"],
  ["CARD_STATUS_CODE_TEMPORARYBLOCK", "Temporary Block"],
  ["CARD_STATUS_CODE_CLOSED", "Closed"],
  ["CARD_STATUS_CODE_STOLEN", "Stolen"],
  ["CARD_STATUS_CODE_DELINQUENTRETURN", "Delinquent (Return Card)"],
  ["CARD_STATUS_CODE_DELINQUENTRETAIN", "Delinquent (Retain Card)"],
  ["CARD_STATUS_CODE_LOST", "Lost"],
  ["CARD_STATUS_CODE_UNSPECIFIED", "CARDSTATUS_INVALID"],
  ["CARD_STATUS_CODE_UNISSUEDNDICICARDS", "Unissued (N&D ICI Cards)"],
  ["CARD_STATUS_CODE_BLOCKPOSEXCLUDECNP", "Block POS (exclude CNP)"],
  ["CARD_STATUS_CODE_BLOCKATMPOSCNP", "Block ATM, POS & CNP"]
]);

const ELIGIBILITY_MAP = new Map([
  ["ELIGIBILITY_ACTIVATION", "ELIGIBILITY_CARD_ACTIVATION"],
  ["ELIGIBILITY_REPLACEMENT_LOST", "ELIGIBILITY_CARD_REPLACEMENT_LOST"],
  ["ELIGIBILITY_REPLACEMENT_STOLEN", "ELIGIBILITY_CARD_REPLACEMENT_STOLEN"],
  ["ELIGIBILITY_REPLACEMENT_DAMAGED", "ELIGIBILITY_CARD_REPLACEMENT_DAMAGED"],
  ["ELIGIBILITY_CONTROLS", "ELIGIBILITY_CARD_CONTROLS"],
  ["ELIGIBILITY_DETAILS", "ELIGIBILITY_GET_DETAILS"]
]);

const DELIVERYSTATUS_MAP = new Map([
  ["STATE_UNSPECIFIED", ""],
  ["STATE_ORDERED", "Card Ordered"],
  ["STATE_SHIPPED", "Card Shipped"],
  ["STATE_OUT_FOR_DELIVERY", "Out for Delivery"],
  ["STATE_DELIVERED", "Delivered"],
  ["STATE_RETURNED_TO_SENDER", "Return to Sender"]
]);

export function updateCardFields(cards) {
  cards.forEach((card) => {
    card.status = STATUS_MAP.get(card.status);
    card.eligibilities = updateEligibilityValues(card.eligibilities);
    card.card_issue_date =
      card.card_issue_date.day.value +
      "/" +
      card.card_issue_date.month.value +
      "/" +
      card.card_issue_date.year.value;
    card.delivery_status =
      DELIVERYSTATUS_MAP.get(card.delivery_status) +
      " " +
      card.delivery_date.day +
      "/" +
      card.delivery_date.month +
      "/" +
      card.delivery_date.year;
  });
  return cards;
}

function updateEligibilityValues(listOfEligibilities) {
  // retains the values of those eligibilities which is not defined in ELIGIBILITY_MAP
  return listOfEligibilities.map(
    (eachEligibility) => ELIGIBILITY_MAP.get(eachEligibility) || eachEligibility
  );
}
