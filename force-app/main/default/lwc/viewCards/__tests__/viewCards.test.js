import { createElement } from "lwc";
import { ShowToastEventName } from "lightning/platformShowToastEvent";
import { publish, subscribe } from "lightning/messageService";
import { createTestWireAdapter } from "@salesforce/wire-service-jest-util";
import { getRecord } from "lightning/uiRecordApi";
import { registerLdsTestWireAdapter } from "@salesforce/sfdx-lwc-jest";

import ViewCards from "c/viewCards";
import getCardList from "@salesforce/apex/CoachBankingAPIRepository.getCardListAura";
import CloseModal from "@salesforce/messageChannel/CloseModal__c";

const getRecordAdapter = registerLdsTestWireAdapter(getRecord);
const MessageContext = createTestWireAdapter();
const APEX_NO_CARDS = require("./data/noCard.json");
const APEX_CARDS_SUCCESS = require("./data/response.json");
const APEX_CARDS_INVALID = require("./data/invalidResp.json");
const APEX_CARDS_NO_ELIGIBILITIES = require("./data/responseNoEligibilities.json");
const APEX_CARDS_FRAUD_SUCCESS_NOT_TEMP_LOCK_STATUS = require("./data/fraudLockCards-notTemporaryLockStatus.json");
const APEX_CARDS_FRAUD_SUCCESS_TEMP_LOCK_STATUS = require("./data/fraudLockCards-temporaryLockStatus.json");
const APEX_CARD_BLOCK_CNP = require("./data/fraudLockCards-fraudStatus.json");
const APEX_GET_CARD_LIST_FAILURE = require("./data/getCardList-failure.json");
const mockOcvId = require("./data/wire-mock-OCV_ID.json");

jest.mock(
  "@salesforce/apex/CoachBankingAPIRepository.getCardListAura",
  () => {
    return {
      default: jest.fn()
    };
  },
  { virtual: true }
);

describe("c-view-cards", () => {
  afterEach(() => {
    // The jsdom instance is shared across test cases in a single file so reset the DOM
    while (document.body.firstChild) {
      document.body.removeChild(document.body.firstChild);
    }
  });

  function flushPromises() {
    // eslint-disable-next-line no-undef
    return new Promise((resolve) => setImmediate(resolve));
  }

  it("1. tests if view cards button visible", () => {
    const element = createElement("c-view-cards", {
      is: ViewCards
    });
    document.body.appendChild(element);
    let button = element.shadowRoot.querySelector(
      "lightning-button[data-id='get-cards-button']"
    );
    expect(button).toBeTruthy();
  });

  it("2. tests if card detail is visible", () => {
    getCardList.mockResolvedValue(APEX_CARDS_SUCCESS);
    const element = createElement("c-view-cards", {
      is: ViewCards
    });
    document.body.appendChild(element);
    let button = element.shadowRoot.querySelector(
      "lightning-button[data-id='get-cards-button']"
    );
    button.click();
    return flushPromises().then(() => {
      let card = element.shadowRoot.querySelector(
        "div[data-id='loaded-card-details']"
      );
      expect(card).toBeTruthy();

      let status = element.shadowRoot.querySelector(".status");

      expect(status.textContent).toBe("Issued");

      let initialWalletSection = element.shadowRoot.querySelector(
        ".dig-wallet"
      );
      expect(initialWalletSection).toBeTruthy();

      let initialWallets = Array.from(
        element.shadowRoot.querySelectorAll(".dig-wallet>.wallet-detail")
      );
      expect(initialWallets.length).toBe(2);

      let walletList = initialWallets.map((p) => p.textContent);
      expect(walletList[0]).toBe("SamsungPay - 1");
    });
  });

  it("3. tests invalid json renders error message", () => {
    getCardList.mockResolvedValue(APEX_CARDS_INVALID);
    const element = createElement("c-view-cards", {
      is: ViewCards
    });
    document.body.appendChild(element);
    let button = element.shadowRoot.querySelector(
      "lightning-button[data-id='get-cards-button']"
    );
    button.click();
    return flushPromises().then(() => {
      let error = element.shadowRoot.querySelector("c-error");
      expect(error).toBeTruthy();
    });
  });

  it("4. tests load more cards", () => {
    getCardList.mockResolvedValue(APEX_CARDS_SUCCESS);
    const element = createElement("c-view-cards", {
      is: ViewCards
    });
    document.body.appendChild(element);

    let button = element.shadowRoot.querySelector(
      "lightning-button[data-id='get-cards-button']"
    );
    button.click();
    return flushPromises()
      .then(() => {
        let button = element.shadowRoot.querySelector(
          "button[data-id='load-more-button']"
        );
        expect(button).toBeTruthy();
        button.click();
      })
      .then(() => {
        let card = element.shadowRoot.querySelector(
          "div[data-id='loaded-card-details']"
        );
        expect(card).toBeTruthy();
      });
  });

  it("5. tests collapse cards", () => {
    getCardList.mockResolvedValue(APEX_CARDS_SUCCESS);
    const element = createElement("c-view-cards", {
      is: ViewCards
    });
    document.body.appendChild(element);

    let button = element.shadowRoot.querySelector(
      "lightning-button[data-id='get-cards-button']"
    );
    button.click();
    return flushPromises()
      .then(() => {
        let button = element.shadowRoot.querySelector(
          "button[data-id='load-more-button']"
        );
        expect(button).toBeTruthy();

        button.click();
      })
      .then(() => {
        let button = element.shadowRoot.querySelector(
          "lightning-button[data-id='collapse-expand-button']"
        );
        expect(button).toBeTruthy();
        button.click();
      })
      .then(() => {
        let loadedCard = element.shadowRoot.querySelector(
          "div[data-id='loaded-card-details']"
        );
        expect(loadedCard).toBeTruthy();
      });
  });

  it("6. tests if all the card buttons are made", () => {
    getCardList.mockResolvedValue(APEX_CARDS_SUCCESS);
    const element = createElement("c-view-cards", {
      is: ViewCards
    });

    document.body.appendChild(element);

    let button = element.shadowRoot.querySelector(
      "lightning-button[data-id='get-cards-button']"
    );
    button.click();
    return flushPromises().then(() => {
      let card = element.shadowRoot.querySelector(
        "div[data-id='loaded-card-details']"
      );
      expect(card).toBeTruthy();

      let buttons = element.shadowRoot.querySelectorAll(
        "lightning-button[data-button='card-button']"
      );

      expect(buttons.length).toBe(5);
    });
  });

  it("7. tests if lock card is enabled", () => {
    getCardList.mockResolvedValue(APEX_CARDS_SUCCESS);
    const element = createElement("c-view-cards", {
      is: ViewCards
    });

    document.body.appendChild(element);

    let button = element.shadowRoot.querySelector(
      "lightning-button[data-id='get-cards-button']"
    );
    button.click();
    return flushPromises().then(() => {
      let card = element.shadowRoot.querySelector(
        "div[data-id='loaded-card-details']"
      );
      expect(card).toBeTruthy();

      let buttons = element.shadowRoot.querySelectorAll(
        "lightning-button[data-button='card-button']"
      );
      let lockButton;
      buttons.forEach((btn) => {
        if (btn.label === "Lock Card") {
          lockButton = btn;
        }
      });
      expect(lockButton).toHaveProperty("disabled", false);
    });
  });

  it("8. tests if lock card is disabled", () => {
    getCardList.mockResolvedValue(APEX_CARDS_NO_ELIGIBILITIES);
    const element = createElement("c-view-cards", {
      is: ViewCards
    });

    document.body.appendChild(element);
    let button = element.shadowRoot.querySelector(
      "lightning-button[data-id='get-cards-button']"
    );
    button.click();
    return flushPromises().then(() => {
      let card = element.shadowRoot.querySelector(
        "div[data-id='loaded-card-details']"
      );
      expect(card).toBeTruthy();

      let buttons = element.shadowRoot.querySelectorAll(
        "lightning-button[data-button='card-button']"
      );

      let lockButton;
      buttons.forEach((btn) => {
        if (btn.label === "Lock Card") {
          lockButton = btn;
        }
      });

      expect(lockButton).toHaveProperty("disabled", true);
    });
  });

  it("9. tests if replace card is enabled", () => {
    getCardList.mockResolvedValue(APEX_CARDS_SUCCESS);
    const element = createElement("c-view-cards", {
      is: ViewCards
    });

    document.body.appendChild(element);
    let button = element.shadowRoot.querySelector(
      "lightning-button[data-id='get-cards-button']"
    );
    button.click();
    return flushPromises().then(() => {
      let card = element.shadowRoot.querySelector(
        "div[data-id='loaded-card-details']"
      );
      expect(card).toBeTruthy();

      let buttons = element.shadowRoot.querySelectorAll(
        "lightning-button[data-button='card-button']"
      );

      let replaceButton;
      buttons.forEach((btn) => {
        if (btn.label === "Replace Card") {
          replaceButton = btn;
        }
      });

      expect(replaceButton).toHaveProperty("disabled", false);
    });
  });

  it("10. tests if replace card is disabled", () => {
    getCardList.mockResolvedValue(APEX_CARDS_NO_ELIGIBILITIES);
    const element = createElement("c-view-cards", {
      is: ViewCards
    });

    document.body.appendChild(element);
    let button = element.shadowRoot.querySelector(
      "lightning-button[data-id='get-cards-button']"
    );
    button.click();
    return flushPromises().then(() => {
      let card = element.shadowRoot.querySelector(
        "div[data-id='loaded-card-details']"
      );
      expect(card).toBeTruthy();

      let buttons = element.shadowRoot.querySelectorAll(
        "lightning-button[data-button='card-button']"
      );

      let replaceButton;
      buttons.forEach((btn) => {
        if (btn.label === "Replace Card") {
          replaceButton = btn;
        }
      });
      expect(replaceButton).toHaveProperty("disabled", true);
    });
  });

  it("11. tests if fraud lock button is enabled", () => {
    getCardList.mockResolvedValue(APEX_CARDS_SUCCESS);
    const element = createElement("c-view-cards", {
      is: ViewCards
    });

    document.body.appendChild(element);
    let button = element.shadowRoot.querySelector(
      "lightning-button[data-id='get-cards-button']"
    );
    button.click();
    return flushPromises().then(() => {
      let card = element.shadowRoot.querySelector(
        "div[data-id='loaded-card-details']"
      );
      expect(card).toBeTruthy();

      let buttons = element.shadowRoot.querySelectorAll(
        "lightning-button[data-button='card-button']"
      );

      let fraudLockButton;
      buttons.forEach((btn) => {
        if (btn.label === "Fraud Lock") {
          fraudLockButton = btn;
        }
      });
      expect(fraudLockButton).toHaveProperty("disabled", false);
    });
  });

  it("12. tests if fraud unlock button is disabled", () => {
    getCardList.mockResolvedValue(APEX_CARDS_SUCCESS);
    const element = createElement("c-view-cards", {
      is: ViewCards
    });

    document.body.appendChild(element);
    let button = element.shadowRoot.querySelector(
      "lightning-button[data-id='get-cards-button']"
    );
    button.click();
    return flushPromises().then(() => {
      let card = element.shadowRoot.querySelector(
        "div[data-id='loaded-card-details']"
      );
      expect(card).toBeTruthy();

      let buttons = element.shadowRoot.querySelectorAll(
        "lightning-button[data-button='card-button']"
      );

      let fraudUnlockButton;
      buttons.forEach((btn) => {
        if (btn.label === "Fraud Unlock") {
          fraudUnlockButton = btn;
        }
      });
      expect(fraudUnlockButton).toHaveProperty("disabled", true);
    });
  });

  it("13. tests if fraud unlock button is enabled", () => {
    getCardList.mockResolvedValue(APEX_CARD_BLOCK_CNP);
    const element = createElement("c-view-cards", {
      is: ViewCards
    });

    document.body.appendChild(element);
    let button = element.shadowRoot.querySelector(
      "lightning-button[data-id='get-cards-button']"
    );
    button.click();
    return flushPromises().then(() => {
      let card = element.shadowRoot.querySelectorAll(
        "div[data-id='loaded-card-details']"
      );
      expect(card).toBeTruthy();

      let buttons = element.shadowRoot.querySelectorAll(
        "lightning-button[data-button='card-button']"
      );

      let fraudUnlockButton;
      buttons.forEach((btn) => {
        if (btn.label === "Fraud Unlock") {
          fraudUnlockButton = btn;
        }
      });
      expect(fraudUnlockButton).toHaveProperty("disabled", false);
    });
  });

  it("14. tests if cancel card button is visible", () => {
    getCardList.mockResolvedValue(
      APEX_CARDS_FRAUD_SUCCESS_NOT_TEMP_LOCK_STATUS
    );
    const element = createElement("c-view-cards", {
      is: ViewCards
    });

    document.body.appendChild(element);
    let button = element.shadowRoot.querySelector(
      "lightning-button[data-id='get-cards-button']"
    );
    button.click();
    return flushPromises().then(() => {
      let card = element.shadowRoot.querySelectorAll(
        "div[data-id='loaded-card-details']"
      );
      expect(card).toBeTruthy();

      let buttons = element.shadowRoot.querySelectorAll(
        "lightning-button[data-button='card-button']"
      );

      let cancelCardButton;
      buttons.forEach((btn) => {
        if (btn.label === "Cancel Card") {
          cancelCardButton = btn;
        }
      });
      expect(cancelCardButton).toBeTruthy();
    });
  });

  it("15. tests if rempove temporary lock button is invisible", () => {
    getCardList.mockResolvedValue(
      APEX_CARDS_FRAUD_SUCCESS_NOT_TEMP_LOCK_STATUS
    );
    const element = createElement("c-view-cards", {
      is: ViewCards
    });

    document.body.appendChild(element);
    let button = element.shadowRoot.querySelector(
      "lightning-button[data-id='get-cards-button']"
    );
    button.click();
    return flushPromises().then(() => {
      let card = element.shadowRoot.querySelectorAll(
        "div[data-id='loaded-card-details']"
      );
      expect(card).toBeTruthy();

      let buttons = element.shadowRoot.querySelectorAll(
        "lightning-button[data-button='card-button']"
      );

      let removeTempLockButton;
      buttons.forEach((btn) => {
        if (btn.label === "Remove Temporary Lock") {
          removeTempLockButton = btn;
        }
      });

      expect(removeTempLockButton).toBeFalsy();
    });
  });

  it("16. tests if rempove temporary lock button is visible", () => {
    getCardList.mockResolvedValue(APEX_CARDS_FRAUD_SUCCESS_TEMP_LOCK_STATUS);
    const element = createElement("c-view-cards", {
      is: ViewCards
    });

    document.body.appendChild(element);
    let button = element.shadowRoot.querySelector(
      "lightning-button[data-id='get-cards-button']"
    );
    button.click();
    return flushPromises().then(() => {
      let card = element.shadowRoot.querySelectorAll(
        "div[data-id='loaded-card-details']"
      );
      expect(card).toBeTruthy();

      let buttons = element.shadowRoot.querySelectorAll(
        "lightning-button[data-button='card-button']"
      );

      let removeTempLockButton;
      buttons.forEach((btn) => {
        if (btn.label === "Remove Temporary Lock") {
          removeTempLockButton = btn;
        }
      });
      expect(removeTempLockButton).toBeTruthy();
    });
  });

  it("17. tests if fraud lock and fraud unlock button are invisible", () => {
    getCardList.mockResolvedValue(APEX_CARDS_FRAUD_SUCCESS_TEMP_LOCK_STATUS);
    const element = createElement("c-view-cards", {
      is: ViewCards
    });

    document.body.appendChild(element);
    let button = element.shadowRoot.querySelector(
      "lightning-button[data-id='get-cards-button']"
    );
    button.click();
    return flushPromises().then(() => {
      let card = element.shadowRoot.querySelectorAll(
        "div[data-id='loaded-card-details']"
      );
      expect(card).toBeTruthy();

      let buttons = element.shadowRoot.querySelectorAll(
        "lightning-button[data-button='card-button']"
      );

      let fraudLockButton;
      let fraudUnlockButton;
      buttons.forEach((btn) => {
        if (btn.label === "Fraud Lock") {
          fraudLockButton = btn;
        } else if (btn.label === "Fraud Unlock") {
          fraudUnlockButton = btn;
        }
      });
      expect(fraudLockButton).toBeFalsy();
      expect(fraudUnlockButton).toBeFalsy();
    });
  });

  it("18. check if there is no cards", () => {
    getCardList.mockResolvedValue(APEX_NO_CARDS);
    const element = createElement("c-view-cards", {
      is: ViewCards
    });

    document.body.appendChild(element);
    let button = element.shadowRoot.querySelector(
      "lightning-button[data-id='get-cards-button']"
    );
    button.click();
    return flushPromises().then(() => {
      let noCardSpan = element.shadowRoot.querySelector("span");
      expect(noCardSpan).toBeTruthy();
      expect(noCardSpan.textContent).toBe("No cards available on account");
    });
  });

  it("19. check clicking on fraud lock button take us to the cardFraudLock component", () => {
    getCardList.mockResolvedValue(
      APEX_CARDS_FRAUD_SUCCESS_NOT_TEMP_LOCK_STATUS
    );
    const element = createElement("c-view-cards", {
      is: ViewCards
    });

    document.body.appendChild(element);

    let button = element.shadowRoot.querySelector(
      "lightning-button[data-id='get-cards-button']"
    );
    button.click();

    return flushPromises()
      .then(() => {
        let cardButtons = element.shadowRoot.querySelectorAll(
          "lightning-button[data-button='card-button']"
        );
        let fraudLockButton;
        cardButtons.forEach((btn) => {
          if (btn.label === "Fraud Lock") {
            fraudLockButton = btn;
          }
        });

        expect(fraudLockButton).toBeTruthy();
        fraudLockButton.click();
      })
      .then(() => {
        let child = element.shadowRoot.querySelector("c-card-fraud-lock");
        expect(child).toBeTruthy();
      });
  });

  it("20. check clicking on lock button take us to the cardTempLock component", () => {
    getCardList.mockResolvedValue(APEX_CARDS_SUCCESS);
    const element = createElement("c-view-cards", {
      is: ViewCards
    });

    document.body.appendChild(element);

    let button = element.shadowRoot.querySelector(
      "lightning-button[data-id='get-cards-button']"
    );
    button.click();

    return flushPromises()
      .then(() => {
        let cardButtons = element.shadowRoot.querySelectorAll(
          "lightning-button[data-button='card-button']"
        );
        let lockButton;
        cardButtons.forEach((btn) => {
          if (btn.label === "Lock Card") {
            lockButton = btn;
          }
        });

        expect(lockButton).toBeTruthy();
        lockButton.click();
      })
      .then(() => {
        let child = element.shadowRoot.querySelector("c-card-temp-lock");
        expect(child).toBeTruthy();
      });
  });

  it("21. check clicking on replace card button take us to the replaceCard component", () => {
    getCardList.mockResolvedValue(APEX_CARDS_SUCCESS);
    const element = createElement("c-view-cards", {
      is: ViewCards
    });

    document.body.appendChild(element);

    let button = element.shadowRoot.querySelector(
      "lightning-button[data-id='get-cards-button']"
    );
    button.click();

    return flushPromises()
      .then(() => {
        let cardButtons = element.shadowRoot.querySelectorAll(
          "lightning-button[data-button='card-button']"
        );
        let replaceButton;
        cardButtons.forEach((btn) => {
          if (btn.label === "Replace Card") {
            replaceButton = btn;
          }
        });

        expect(replaceButton).toBeTruthy();
        replaceButton.click();
      })
      .then(() => {
        let child = element.shadowRoot.querySelector("c-replace-card");
        expect(child).toBeTruthy();
      });
  });

  it("22. check the show toast", () => {
    getCardList.mockRejectedValue(APEX_GET_CARD_LIST_FAILURE);
    const element = createElement("c-view-cards", {
      is: ViewCards
    });
    document.body.appendChild(element);

    const handler = jest.fn();
    element.addEventListener(ShowToastEventName, handler);

    let button = element.shadowRoot.querySelector(
      "lightning-button[data-id='get-cards-button']"
    );
    button.click();

    return flushPromises().catch(() => {
      const cError = element.shadowRoot.querySelector("c-error");
      expect(handler).toHaveBeenCalled();
      expect(cError).toBeTruthy();
    });
  });

  it("23. check the first subscribe and it's toast message", () => {
    getCardList.mockResolvedValue(APEX_CARDS_SUCCESS);

    const element = createElement("c-view-cards", {
      is: ViewCards
    });

    document.body.appendChild(element);

    const handler = jest.fn();
    element.addEventListener(ShowToastEventName, handler);

    const makeDifferentPublish = () => {
      for (let key in objectForPublish) {
        publish(MessageContext, CloseModal, objectForPublish[key]);
        expect(subscribe).toHaveBeenCalled();
        expect(handler).toHaveBeenCalled();
      }
    };
    const payloadMaker = (name) => {
      return {
        update: true,
        name: name,
        success: true,
        message: "Test subscribe"
      };
    };
    const objectForPublish = {
      fraud: payloadMaker("showFraudLock"),
      replace: payloadMaker("replace"),
      lock: payloadMaker("lock")
    };
    return flushPromises().then(() => {
      makeDifferentPublish();
    });
  });
});

describe("c-view-cards | wire", () => {
  beforeEach(() => {
    const element = createElement("c-view-cards", {
      is: ViewCards
    });
    document.body.appendChild(element);
  });

  function flushPromises() {
    // eslint-disable-next-line no-undef
    return new Promise((resolve) => setImmediate(resolve));
  }
  it("1. check wire OCV_ID", () => {
    getRecordAdapter.emit(mockOcvId);
    return flushPromises().then(() => {
      const ocvID = mockOcvId.fields.OCV_ID__c.value;
      expect(ocvID).toBe("Test OCV_ID");
    });
  });

  it("2. should through an error when there is no ocvId", () => {
    expect(() => {
      getRecordAdapter.emit({});
    }).toThrow();
  });
});
