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
  ["CARD_STATUS_CODE_BLOCKATMPOSCNP", "Block ATM, POS & CNP"],
  ["CARD_STATUS_CODE_BLOCKATM", "Block ATM"]
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

/**
 * For backward compatibility of v1 model (CardListModelV1) to v1alpha1 model (CardListModel),
 * there is a mapping in CardListModelConverter.convertToCardListModel() method.
 * The mapping of destCard.name is not compatable with the format of newName (i.e. "cards/<cardNumber>"),
 * therefor we are relying on the tokenized_card_number and constructing the template `cards/${newCard.tokenized_card_number}` to
 * match the destCard.newName format.
 *
 * Example of a card object post backward compatibility mapping:
 * {
    ...
    "name": "CLEORA GULGOWSKI",
    "newName": "cards/2319934995000711",
    ...
    "tokenized_card_number": "4863166870601770",
    ....
  }
 */
export function updateCardFields(cards) {
  cards.forEach((card) => {
    card.status = STATUS_MAP.get(card.status);
    card.eligibilities = updateEligibilityValues(card.eligibilities);
    card.cardIssueDate = getCardFormattedDate(card.card_issue_date);
    card.delivery_status = getDeliveryStatus(card);
    // Add replacement card details if new name is present
    if (!card.newName) {
      return;
    }
    let replacementCard = cards.find(
      (newCard) => card.newName == `cards/${newCard.tokenized_card_number}`
    );
    if (replacementCard) {
      card.replacementCard = {
        tokenized_card_number: replacementCard.tokenized_card_number,
        last_4_digits: replacementCard.last_4_digits,
        replacementDate: getCardFormattedDate(card.replacementDate)
      };
    }
  });
  return cards;
}

function updateEligibilityValues(listOfEligibilities) {
  // retains the values of those eligibilities which is not defined in ELIGIBILITY_MAP
  return listOfEligibilities.map(
    (eachEligibility) => ELIGIBILITY_MAP.get(eachEligibility) || eachEligibility
  );
}

function getCardFormattedDate(theDate) {
  if (!theDate?.day?.value) {
    return null;
  }
  return `${theDate.day.value}/${theDate.month.value}/${theDate.year.value}`;
}

function getDeliveryStatus(card) {
  if (!card.delivery_date) {
    return null;
  }
  return (
    DELIVERYSTATUS_MAP.get(card.delivery_status) +
    " " +
    card.delivery_date.day +
    "/" +
    card.delivery_date.month +
    "/" +
    card.delivery_date.year
  );
}
