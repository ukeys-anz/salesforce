import { STATUS, CARD_ELIGIBILITY } from "./model";
// to create a button and make it visible | disable

class ButtonFactory {
  constructor(card, userPermisson) {
    this.card = card;
    this.userPermisson = userPermisson;
  }

  createButtonSchema(label, buttonConfig) {
    if (buttonConfig.buttonVisible(this.card, this.userPermisson)) {
      return {
        label: label,
        actionFunction: buttonConfig.action,
        disable: buttonConfig.buttonDisable(this.card),
        variant: buttonConfig.variant ? buttonConfig.variant : "Neutral"
      };
    }
  }
}

// functions according to each button - will be passed to parent
function lockCardAction(inputInfo) {
  return {
    tokenizedCardNumber: inputInfo.card.tokenized_card_number,
    showLock: !inputInfo.showLock
  };
}

function replaceCardAction(inputInfo) {
  let cardEligibilities = inputInfo.card.eligibilities;

  return {
    tokenizedCardNumber: inputInfo.card.tokenized_card_number,
    replaceLostUnavailable: !cardEligibilities.includes(
      "ELIGIBILITY_CARD_REPLACEMENT_LOST"
    ),
    replaceStolenUnavailable: !cardEligibilities.includes(
      "ELIGIBILITY_CARD_REPLACEMENT_STOLEN"
    ),
    replaceDamagedUnavailable: !cardEligibilities.includes(
      "ELIGIBILITY_CARD_REPLACEMENT_DAMAGED"
    ),
    replaceLockUnavailable: lockCardDisabled(inputInfo.card),
    showReplace: !inputInfo.showReplace
  };
}

function fraudCardsAction(inputInfo) {
  return {
    buttonClicked: inputInfo.label,
    tokenizedCardNumber: inputInfo.card.tokenized_card_number,
    showFraudLock: !inputInfo.showFraudLock,
    cardFraudLockStatus: inputInfo.card.status,
    last4Digits: inputInfo.card.last_4_digits
  };
}

function fraudButtonVisible(card, userPermission) {
  let allowedStatus = [
    STATUS.Issued,
    STATUS.Block_CNP,
    STATUS.Block_ATM_POS_Exclude_CNP,
    STATUS.Block_ATM_POS_CNP_BCH
  ];
  return (
    userPermission.hasFraudPermission && allowedStatus.includes(card.status)
  );
}

function removeTemporaryLockVisible(card, userPermission) {
  let allowedStatus = [STATUS.Temporary_Lock, STATUS.Temporary_Block];
  return (
    userPermission.hasFraudPermission && allowedStatus.includes(card.status)
  );
}

function lockCardVisible(card, userPermission) {
  return userPermission.hasLockPermission && card.status == STATUS.Issued;
}

function replaceCardVisible(card, userPermission) {
  let allowedStatus = [
    STATUS.Issued,
    STATUS.Temporary_Lock,
    STATUS.Temporary_Block
  ];
  return (
    userPermission.hasReplacePermission && allowedStatus.includes(card.status)
  );
}

function cancelCardVisible(card, userPermission) {
  let allowedStatus = [
    STATUS.Issued,
    STATUS.Block_CNP,
    STATUS.Block_ATM_POS_Exclude_CNP,
    STATUS.Block_ATM_POS_CNP_BCH,
    STATUS.Temporary_Lock,
    STATUS.Temporary_Block
  ];
  return (
    userPermission.hasCancelCardPermission &&
    allowedStatus.includes(card.status)
  );
}

function defaultButtonDisabled(card) {
  return false;
}

function fraudUnlockDisabled(card) {
  return card.status == STATUS.Issued;
}

// If Temp Lock is applied or eligibility does not include Controls, then Lock Button should be disabled
function lockCardDisabled(card) {
  const cardControlEligExists = card.eligibilities.includes(
    "ELIGIBILITY_CARD_CONTROLS"
  );
  return card.cardIsTempLocked || !cardControlEligExists;
}

function replaceDisabled(card) {
  const replaceEligibility = [
    CARD_ELIGIBILITY.Card_Damaged,
    CARD_ELIGIBILITY.Card_Lost,
    CARD_ELIGIBILITY.Card_Stolen
  ];
  return !card.eligibilities.some((el) => replaceEligibility.includes(el));
}

// function according to the label of the button
const buttonConfigObject = {
  "Fraud Lock": {
    buttonVisible: fraudButtonVisible,
    action: fraudCardsAction,
    buttonDisable: defaultButtonDisabled
  },
  "Fraud Unlock": {
    buttonVisible: fraudButtonVisible,
    action: fraudCardsAction,
    buttonDisable: fraudUnlockDisabled
  },
  "Remove Temporary Lock": {
    buttonVisible: removeTemporaryLockVisible,
    action: fraudCardsAction,
    buttonDisable: defaultButtonDisabled
  },
  "Cancel Card": {
    buttonVisible: cancelCardVisible,
    action: fraudCardsAction,
    buttonDisable: defaultButtonDisabled,
    variant: "destructive-text"
  },
  "Lock Card": {
    buttonVisible: lockCardVisible,
    action: lockCardAction,
    buttonDisable: lockCardDisabled
  },
  "Replace Card": {
    buttonVisible: replaceCardVisible,
    action: replaceCardAction,
    buttonDisable: replaceDisabled
  }
};

// CSS class for button div according to the number of buttons on a card
const cardButtonContainerClassName = (card) => {
  card.className =
    card.buttons.length > 3 ? "allButtonsContainer" : "buttonsContainer";
  return card;
};

// for each card: will make a buttons array according to button schema and make the cards to have new schema with cards.buttons
// and set statusToShow and cardIsTempLocked on each card then sort the list of cards
export function createButtonsFromArray(cards, userPermission) {
  for (let i = 0; i < cards.length; i++) {
    let buttonArray = [];
    let buttonFactory = new ButtonFactory(cards[i], userPermission);
    for (let key in buttonConfigObject) {
      let btnToPushToArray = buttonFactory.createButtonSchema(
        key,
        buttonConfigObject[key]
      );
      if (btnToPushToArray) {
        buttonArray = [...buttonArray, btnToPushToArray];
      }
    }
    cards[i].buttons = buttonArray;
    cards[i] = cardButtonContainerClassName(cards[i]);
  }
  return cards;
}
