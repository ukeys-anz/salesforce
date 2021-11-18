import { STATUS, CARD_ELIGIBILITY, MAPPED_STATUS } from "./model";
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
    tokenizedCardNumber: inputInfo.tokenizedCardNumber,
    showLock: !inputInfo.showLock
  };
}

function replaceCardAction(inputInfo) {
  let cardEligibilities = inputInfo.card.eligibilities;
  return {
    tokenizedCardNumber: inputInfo.card.tokenizedCardNumber,
    replaceLostUnavailable: !cardEligibilities.includes(
      "ELIGIBILITY_CARD_REPLACEMENT_LOST"
    ),
    replaceStolenUnavailable: !cardEligibilities.includes(
      "ELIGIBILITY_CARD_REPLACEMENT_STOLEN"
    ),
    replaceDamagedUnavailable: !cardEligibilities.includes(
      "ELIGIBILITY_CARD_REPLACEMENT_DAMAGED"
    ),
    replaceLockUnavailable: !cardEligibilities.includes("ELIGIBILITY_BLOCK"),
    showReplace: !inputInfo.showReplace
  };
}

function fraudCardsAction(inputInfo) {
  return {
    buttonClicked: inputInfo.label,
    tokenizedCardNumber: inputInfo.card.tokenizedCardNumber,
    showFraudLock: !inputInfo.showFraudLock,
    cardFraudLockStatus: inputInfo.card.status,
    last4Digits: inputInfo.card.last4Digits
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
  let allowedStatus = [
    STATUS.Issued,
    STATUS.Temporary_Block,
    STATUS.Temporary_Lock
  ];
  return (
    userPermission.hasLockPermission && allowedStatus.includes(card.status)
  );
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
//cancel

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
    userPermission.hasFraudPermission && allowedStatus.includes(card.status)
  );
}

function defaultButtonDisabled(card) {
  return false;
}

function fraudUnlockDisabled(card) {
  return card.status == STATUS.Issued;
}

function lockCardDisabled(card) {
  return !card.eligibilities.includes(CARD_ELIGIBILITY.Card_Block);
}

function replaceDisabled(card) {
  const replaceEligibility = [
    CARD_ELIGIBILITY.Card_Damaged,
    CARD_ELIGIBILITY.Card_Lost,
    CARD_ELIGIBILITY.Card_Stolen
  ];
  return !card.eligibilities.some((el) => replaceEligibility.includes(el));
}

function mappingStatusOnACard(card) {
  for (let key in STATUS) {
    if (card.status === STATUS[key]) {
      card.statusToShow = MAPPED_STATUS[key];
    }
  }
  return card;
}

function sortCardsHandler(cards, status) {
  if (cards.length > 1) {
    cards.sort((card) => {
      return card.status === status ? -1 : 1;
    });
  }
  return cards;
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

// for each card: will make a buttons array according to button schema and make the cards to have new schema with cards.buttons
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
    cards[i] = mappingStatusOnACard(cards[i]);
  }
  cards = sortCardsHandler(cards, STATUS.Issued);
  return cards;
}
