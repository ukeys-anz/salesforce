import { createElement } from "lwc";
import { ShowToastEventName } from "lightning/platformShowToastEvent";
import { publish, subscribe } from "lightning/messageService";
import { createTestWireAdapter } from "@salesforce/wire-service-jest-util";
import CloseModal from "@salesforce/messageChannel/CloseModal__c";
import ViewCards from "c/viewCards";

const MessageContext = createTestWireAdapter();
const APEX_CARDS_SUCCESS = require("./data/response.json");
const APEX_CARDS_LOAD_MORE_SUCCESS = require("./data/loadMoreLink.json");
const APEX_CARDS_INACTIVE = require("./data/responseInactiveCard.json");
const APEX_CARDS_NO_ELIGIBILITIES = require("./data/responseNoEligibilities.json");
const APEX_CARDS_TEMP_LOCK = require("./data/responseTempLockedCard.json");
const APEX_CARDS_FRAUD_SUCCESS_NOT_TEMP_LOCK_STATUS = require("./data/fraudLockCards-notTemporaryLockStatus.json");
const APEX_CARDS_FRAUD_SUCCESS_TEMP_LOCK_STATUS = require("./data/fraudLockCards-temporaryLockStatus.json");
const APEX_CARD_BLOCK_CNP = require("./data/fraudLockCards-fraudStatus.json");
const APEX_CLOSED_CARD_LIST = require("./data/listOfClosedCard.json");

describe("c-view-cards", () => {
  afterEach(() => {
    while (document.body.firstChild) {
      document.body.removeChild(document.body.firstChild);
    }
  });

  async function flushPromises() {
    return Promise.resolve();
  }

  it("1. tests if card detail are visible", async () => {
    const element = createElement("c-view-cards", {
      is: ViewCards
    });
    element.cardsFromParent = APEX_CARDS_SUCCESS;
    element.isActiveCardSection = "true";
    document.body.appendChild(element);

    await flushPromises();
    let cardHolderName = element.shadowRoot.querySelector(
      "p[data-test-id='cardholder']"
    );
    expect(cardHolderName).toBeTruthy();
    expect(cardHolderName.textContent).toBe("Peter Charalambous");

    let last4digit = element.shadowRoot.querySelector(
      "p[data-test-id='last-4-digits']"
    );
    expect(last4digit.textContent).toBe("9876");

    let status = element.shadowRoot.querySelector("p[data-test-id='status']");
    expect(status.textContent).toBe("Issued");
  });

  it("2. tests load more link visibility when the user has greater than six cards", async () => {
    const element = createElement("c-view-cards", {
      is: ViewCards
    });
    element.cardsFromParent = APEX_CARDS_LOAD_MORE_SUCCESS;
    element.isActiveCardSection = "true";
    document.body.appendChild(element);
    await flushPromises();

    await flushPromises();
    let loadMore = element.shadowRoot.querySelector(
      "button[data-test-id='load-more']"
    );
    expect(loadMore).not.toBeNull();
  });

  it("3. tests load more link visibility when the user has fewer than six cards.", async () => {
    const element = createElement("c-view-cards", {
      is: ViewCards
    });
    element.cardsFromParent = APEX_CARDS_SUCCESS;
    element.isActiveCardSection = "true";
    document.body.appendChild(element);
    await flushPromises();

    await flushPromises();
    let loadMore = element.shadowRoot.querySelector(
      "button[data-test-id='load-more']"
    );
    expect(loadMore).toBeNull();
  });

  it("4. tests if all the card buttons are made for active card section", async () => {
    const element = createElement("c-view-cards", {
      is: ViewCards
    });
    element.cardsFromParent = APEX_CARDS_SUCCESS;
    element.isActiveCardSection = "true";
    document.body.appendChild(element);
    await flushPromises();
    let buttons = element.shadowRoot.querySelectorAll(
      "lightning-button[data-button='card-button']"
    );
    expect(buttons.length).toBe(12);
  });

  it("5. tests if card buttons are not made for closed Section", async () => {
    const element = createElement("c-view-cards", {
      is: ViewCards
    });
    element.cardsFromParent = APEX_CARDS_SUCCESS;
    document.body.appendChild(element);
    await flushPromises();
    let buttons = element.shadowRoot.querySelectorAll(
      "lightning-button[data-button='card-button']"
    );
    expect(buttons.length).toBe(0);
  });

  it("6. tests if lock card is enabled", async () => {
    const element = createElement("c-view-cards", {
      is: ViewCards
    });
    element.cardsFromParent = APEX_CARDS_SUCCESS;
    element.isActiveCardSection = "true";
    document.body.appendChild(element);
    await flushPromises();
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

  it("7. tests if lock card is enabled", async () => {
    const element = createElement("c-view-cards", {
      is: ViewCards
    });
    element.cardsFromParent = APEX_CARDS_SUCCESS;
    element.isActiveCardSection = "true";
    document.body.appendChild(element);
    await flushPromises();
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

  it("8. tests if lock card is disabled", async () => {
    const element = createElement("c-view-cards", {
      is: ViewCards
    });
    element.cardsFromParent = APEX_CARDS_TEMP_LOCK;
    element.isActiveCardSection = "true";
    document.body.appendChild(element);
    await flushPromises();
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

  it("9. tests if lock card is invisible", async () => {
    const element = createElement("c-view-cards", {
      is: ViewCards
    });
    element.cardsFromParent = APEX_CARD_BLOCK_CNP;
    element.isActiveCardSection = "true";
    document.body.appendChild(element);
    await flushPromises();
    let buttons = element.shadowRoot.querySelectorAll(
      "lightning-button[data-button='card-button']"
    );
    let lockButton;
    buttons.forEach((btn) => {
      if (btn.label === "Lock Card") {
        lockButton = btn;
      }
    });

    expect(lockButton).toBeFalsy();
  });

  it("10. tests if replace card is enabled", async () => {
    const element = createElement("c-view-cards", {
      is: ViewCards
    });
    element.cardsFromParent = APEX_CARDS_SUCCESS;
    element.isActiveCardSection = "true";
    document.body.appendChild(element);
    await flushPromises();
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

  it("11. tests if replace card is disabled", async () => {
    const element = createElement("c-view-cards", {
      is: ViewCards
    });
    element.cardsFromParent = APEX_CARDS_NO_ELIGIBILITIES;
    element.isActiveCardSection = "true";
    document.body.appendChild(element);
    await flushPromises();
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

  it("12. tests if fraud lock button is enabled", async () => {
    const element = createElement("c-view-cards", {
      is: ViewCards
    });
    element.cardsFromParent = APEX_CARDS_SUCCESS;
    element.isActiveCardSection = "true";
    document.body.appendChild(element);
    await flushPromises();
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

  it("13. tests if fraud unlock button is disabled", async () => {
    const element = createElement("c-view-cards", {
      is: ViewCards
    });
    element.cardsFromParent = APEX_CARDS_SUCCESS;
    element.isActiveCardSection = "true";
    document.body.appendChild(element);
    await flushPromises();
    let buttons = element.shadowRoot.querySelectorAll(
      "lightning-button[data-button='card-button']"
    );
    let fraudLockButton;
    buttons.forEach((btn) => {
      if (btn.label === "Fraud Unlock") {
        fraudLockButton = btn;
      }
    });
    expect(fraudLockButton).toHaveProperty("disabled", true);
  });

  it("14. tests if fraud unlock button is enabled", async () => {
    const element = createElement("c-view-cards", {
      is: ViewCards
    });
    element.cardsFromParent = APEX_CARD_BLOCK_CNP;
    element.isActiveCardSection = "true";
    document.body.appendChild(element);
    await flushPromises();
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

  it("15. tests if cancel card button is visible", async () => {
    const element = createElement("c-view-cards", {
      is: ViewCards
    });
    element.cardsFromParent = APEX_CARDS_FRAUD_SUCCESS_NOT_TEMP_LOCK_STATUS;
    element.isActiveCardSection = "true";
    document.body.appendChild(element);
    await flushPromises();
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

  it("16. tests if remove temporary lock button is invisible", async () => {
    const element = createElement("c-view-cards", {
      is: ViewCards
    });
    element.cardsFromParent = APEX_CARDS_FRAUD_SUCCESS_NOT_TEMP_LOCK_STATUS;
    element.isActiveCardSection = "true";
    document.body.appendChild(element);
    await flushPromises();
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

  it("17. tests if remove temporary lock button is visible", async () => {
    const element = createElement("c-view-cards", {
      is: ViewCards
    });
    element.cardsFromParent = APEX_CARDS_FRAUD_SUCCESS_TEMP_LOCK_STATUS;
    element.isActiveCardSection = "true";
    document.body.appendChild(element);
    await flushPromises();
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

  it("18. tests if fraud lock and fraud unlock button are invisible", async () => {
    const element = createElement("c-view-cards", {
      is: ViewCards
    });
    element.cardsFromParent = APEX_CARDS_FRAUD_SUCCESS_TEMP_LOCK_STATUS;
    element.isActiveCardSection = "true";
    document.body.appendChild(element);
    await flushPromises();
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

  it("19. check clicking on fraud lock button take us to the cardFraudLock component", async () => {
    const element = createElement("c-view-cards", {
      is: ViewCards
    });
    element.cardsFromParent = APEX_CARDS_FRAUD_SUCCESS_NOT_TEMP_LOCK_STATUS;
    element.isActiveCardSection = "true";
    document.body.appendChild(element);
    await flushPromises();
    let buttons = element.shadowRoot.querySelectorAll(
      "lightning-button[data-button='card-button']"
    );
    let fraudLockButton;
    buttons.forEach((btn) => {
      if (btn.label === "Fraud Lock") {
        fraudLockButton = btn;
      }
    });

    expect(fraudLockButton).toBeTruthy();
    fraudLockButton.click();
    await flushPromises();
    let child = element.shadowRoot.querySelector("c-card-fraud-lock");
    expect(child).toBeTruthy();
  });

  it("20. check clicking on lock button take us to the cardTempLock component", async () => {
    const element = createElement("c-view-cards", {
      is: ViewCards
    });
    element.cardsFromParent = APEX_CARDS_SUCCESS;
    element.isActiveCardSection = "true";
    document.body.appendChild(element);
    await flushPromises();
    let buttons = element.shadowRoot.querySelectorAll(
      "lightning-button[data-button='card-button']"
    );
    let loackCardButton;
    buttons.forEach((btn) => {
      if (btn.label === "Lock Card") {
        loackCardButton = btn;
      }
    });

    expect(loackCardButton).toBeTruthy();
    loackCardButton.click();
    await flushPromises();
    let child = element.shadowRoot.querySelector("c-card-temp-lock");
    expect(child).toBeTruthy();
  });

  it("21. check clicking on replace card button take us to the replaceCard component", async () => {
    const element = createElement("c-view-cards", {
      is: ViewCards
    });
    element.cardsFromParent = APEX_CARDS_SUCCESS;
    element.isActiveCardSection = "true";
    document.body.appendChild(element);
    await flushPromises();
    let buttons = element.shadowRoot.querySelectorAll(
      "lightning-button[data-button='card-button']"
    );
    let replaceCardButton;
    buttons.forEach((btn) => {
      if (btn.label === "Replace Card") {
        replaceCardButton = btn;
      }
    });

    expect(replaceCardButton).toBeTruthy();
    replaceCardButton.click();
    await flushPromises();
    let child = element.shadowRoot.querySelector("c-replace-card");
    expect(child).toBeTruthy();
  });

  it("22. tests clicking on lock card within replace/lost path takes us to the lockCard component", async () => {
    const element = createElement("c-view-cards", {
      is: ViewCards
    });
    element.cardsFromParent = APEX_CARDS_SUCCESS;
    element.isActiveCardSection = "true";
    document.body.appendChild(element);
    await flushPromises();
    let buttons = element.shadowRoot.querySelectorAll(
      "lightning-button[data-button='card-button']"
    );
    let replaceButton;
    buttons.forEach((btn) => {
      if (btn.label === "Replace Card") {
        replaceButton = btn;
      }
    });

    replaceButton.click();
    await flushPromises();
    let replaceCardComponent = element.shadowRoot.querySelector(
      "c-replace-card"
    );

    replaceCardComponent.replaceLostUnavailable = false;
    let lostButton = replaceCardComponent.shadowRoot.querySelector(
      "button[data-id='lost-path']"
    );
    lostButton.click();
    await flushPromises();
    let lockButtonPath = replaceCardComponent.shadowRoot.querySelector(
      "button[data-id='lock-button-path']"
    );
    lockButtonPath.click();
    await flushPromises();
    let lockCardComponent = element.shadowRoot.querySelector(
      "c-card-temp-lock"
    );
    expect(lockCardComponent).toBeTruthy();
  });

  it("23. check the first subscribe and it's toast message", async () => {
    const element = createElement("c-view-cards", {
      is: ViewCards
    });
    element.cardsFromParent = APEX_CARDS_SUCCESS;
    element.isActiveCardSection = "true";
    document.body.appendChild(element);

    await flushPromises();

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

  it("24. tests status of non activated card", async () => {
    const element = createElement("c-view-cards", {
      is: ViewCards
    });
    element.cardsFromParent = APEX_CARDS_INACTIVE;
    element.isActiveCardSection = "true";
    document.body.appendChild(element);

    await flushPromises();

    let status = element.shadowRoot.querySelector("p[data-test-id='status']");
    expect(status.textContent).toBe("Issued (Not Activated)");
  });

  it("25. tests if card controls are visible", async () => {
    const element = createElement("c-view-cards", {
      is: ViewCards
    });
    element.cardsFromParent = APEX_CARDS_SUCCESS;
    element.isActiveCardSection = "true";
    document.body.appendChild(element);

    await flushPromises();

    let cardControls = element.shadowRoot.querySelectorAll(
      "div[data-id='loaded-card-controls']"
    );
    expect(cardControls).toBeTruthy();
  });

  it("26. tests if controls are hidden on fraud statuses", async () => {
    const element = createElement("c-view-cards", {
      is: ViewCards
    });
    element.cardsFromParent = APEX_CARDS_FRAUD_SUCCESS_NOT_TEMP_LOCK_STATUS;
    element.isActiveCardSection = "true";
    document.body.appendChild(element);

    await flushPromises();

    let fraudMessage = element.shadowRoot.querySelectorAll(
      "p[data-id='fraud-no-controls']"
    );
    expect(fraudMessage).toBeTruthy();
  });

  it("27. tests if temp lock flag is visible when applicable", async () => {
    const element = createElement("c-view-cards", {
      is: ViewCards
    });
    element.cardsFromParent = APEX_CARDS_TEMP_LOCK;
    element.isActiveCardSection = "true";
    document.body.appendChild(element);

    await flushPromises();

    let status = element.shadowRoot.querySelector(".status");

    expect(status.textContent).toBe("Issued (Temporary Lock)");
  });

  it("28. tests if status is not visible for closed cards section", async () => {
    const element = createElement("c-view-cards", {
      is: ViewCards
    });
    element.cardsFromParent = APEX_CLOSED_CARD_LIST;
    document.body.appendChild(element);

    await flushPromises();
    let status = element.shadowRoot.querySelector(".status");
    expect(status).toBeFalsy();
  });

  it("29. tests delivery status of activated card", async () => {
    const element = createElement("c-view-cards", {
      is: ViewCards
    });
    element.cardsFromParent = APEX_CARDS_SUCCESS;
    element.isActiveCardSection = "true";
    document.body.appendChild(element);

    await flushPromises();

    let deliveryStatus = element.shadowRoot.querySelector(
      "p[data-test-id='deliveryStatus']"
    );
    expect(deliveryStatus.textContent).toBe("Delivered 03/11/2023");
  });
});
