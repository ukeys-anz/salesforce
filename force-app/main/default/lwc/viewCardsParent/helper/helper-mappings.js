export const STATUSMAP = new Map([
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

export const ELIGIBILITYMAP = new Map([
  ["ELIGIBILITY_ACTIVATION", "ELIGIBILITY_CARD_ACTIVATION"],
  ["ELIGIBILITY_REPLACEMENT_LOST", "ELIGIBILITY_CARD_REPLACEMENT_LOST"],
  ["ELIGIBILITY_REPLACEMENT_STOLEN", "ELIGIBILITY_CARD_REPLACEMENT_STOLEN"],
  ["ELIGIBILITY_REPLACEMENT_DAMAGED", "ELIGIBILITY_CARD_REPLACEMENT_DAMAGED"],
  ["ELIGIBILITY_CONTROLS", "ELIGIBILITY_CARD_CONTROLS"],
  ["ELIGIBILITY_DETAILS", "ELIGIBILITY_GET_DETAILS"]
]);

export const DELIVERYSTATUSMAP = new Map([
  ["STATE_UNSPECIFIED", ""],
  ["STATE_ORDERED", "Card Ordered"],
  ["STATE_SHIPPED", "Card Shipped"],
  ["STATE_OUT_FOR_DELIVERY", "Out for Delivery"],
  ["STATE_DELIVERED", "Delivered"],
  ["STATE_RETURNED_TO_SENDER", "Return to Sender"]
]);

export function updateCardFields(cards) {
  cards.forEach((card) => {
    card.status = STATUSMAP.get(card.status);
    card.eligibilities = updateEligibilityValues(card.eligibilities);
    card.delivery_status = DELIVERYSTATUSMAP.get(card.delivery_status);
  });
  return cards;
}

function updateEligibilityValues(listOfEligibilities) {
  // retains the values of those eligibilities which is not defined in ELIGIBILITYMAP
  return listOfEligibilities.map(
    (eachEligibility) => ELIGIBILITYMAP.get(eachEligibility) || eachEligibility
  );
}
