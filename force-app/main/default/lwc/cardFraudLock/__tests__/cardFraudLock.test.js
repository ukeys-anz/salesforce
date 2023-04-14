import { createElement } from "lwc";
import { ShowToastEventName } from "lightning/platformShowToastEvent";
import { getRecord } from "lightning/uiRecordApi";
import { createTestWireAdapter } from "@salesforce/wire-service-jest-util";
import { publish, subscribe } from "lightning/messageService";
import { setImmediate } from "timers";

import fraudLock from "@salesforce/apex/FraudCardStatusController.setFraudCardStatus";
import CardFraudLock from "c/cardFraudLock";
import CloseModal from "@salesforce/messageChannel/CloseModal__c";

const mockApexSuccess = require("./data/apex-mock-success.json");
const mockApexFailure = require("./data/apex-mock-failure.json");
const mockWireFraudLock = require("./data/wire-mock-cardFraudLock.json");
const MessageContext = createTestWireAdapter();

jest.mock(
  "@salesforce/apex/FraudCardStatusController.setFraudCardStatus",
  () => ({
    default: jest.fn()
  }),
  { virtual: true }
);

describe("c-card-fraud-lock", () => {
  afterEach(() => {
    // The jsdom instance is shared across test cases in a single file so reset the DOM
    while (document.body.firstChild) {
      document.body.removeChild(document.body.firstChild);
    }
  });

  // Helper function to wait until the microtask queue is empty. This is needed for promise
  // timing when calling imperative Apex.
  function flushPromises() {
    // eslint-disable-next-line no-undef
    return new Promise((resolve) => setImmediate(resolve));
  }

  it("1. check if submit button visible", () => {
    const element = createElement("c-card-fraud-lock", {
      is: CardFraudLock
    });
    element.buttonClicked = "Fraud Lock";
    element.cardStatus = "Issued";

    document.body.appendChild(element);
    return flushPromises().then(() => {
      let button = element.shadowRoot.querySelector(
        "button[data-id='submit-button']"
      );
      expect(button).toBeTruthy();
    });
  });

  it("2. cheeck if cancel button visible", () => {
    const element = createElement("c-card-fraud-lock", {
      is: CardFraudLock
    });
    element.buttonClicked = "Fraud Lock";
    element.cardStatus = "Issued";

    document.body.appendChild(element);
    return flushPromises().then(() => {
      const buttons = element.shadowRoot.querySelectorAll("footer button");
      const cancelButton = buttons[1];
      expect(cancelButton.textContent).toBe("Cancel");
    });
  });

  it("3. check if fraud lock options visible", () => {
    const element = createElement("c-card-fraud-lock", {
      is: CardFraudLock
    });
    element.buttonClicked = "Fraud Lock";
    element.cardStatus = "Issued";

    document.body.appendChild(element);
    return flushPromises().then(() => {
      let fraudOptions = element.shadowRoot.querySelectorAll(
        "lightning-button.btn"
      );
      expect(fraudOptions[0]).toBeTruthy();
    });
  });

  it("4. cheeck if a fraud option chosen, the button should have brand variant", () => {
    const element = createElement("c-card-fraud-lock", {
      is: CardFraudLock
    });
    element.buttonClicked = "Fraud Lock";
    element.cardStatus = "Issued";

    document.body.appendChild(element);
    const buttons = element.shadowRoot.querySelectorAll("footer button");
    let fraudOptions = element.shadowRoot.querySelectorAll(
      "lightning-button.btn"
    );
    let blockCNPButton = fraudOptions[1];
    blockCNPButton.click();

    return flushPromises().then(() => {
      expect(blockCNPButton).toHaveProperty(["variant"], "brand");
    });
  });

  it("5. cheeck if a submit option clicked, we should navigate to the confirmation", () => {
    const element = createElement("c-card-fraud-lock", {
      is: CardFraudLock
    });
    element.buttonClicked = "Fraud Lock";
    element.cardStatus = "Issued";

    document.body.appendChild(element);

    let fraudOptions = element.shadowRoot.querySelectorAll(
      "lightning-button.btn"
    );
    let blockCNPButton = fraudOptions[1];
    blockCNPButton.click();

    let submitButton = element.shadowRoot.querySelector(
      "button[data-id='submit-button']"
    );
    submitButton.click();

    return flushPromises().then(() => {
      let title = element.shadowRoot.querySelector("header h2");
      expect(title.textContent).toBe("Submit Card Block");
    });
  });

  it("6. cheeck if a confirm button is visible", () => {
    const element = createElement("c-card-fraud-lock", {
      is: CardFraudLock
    });
    element.buttonClicked = "Fraud Lock";
    element.cardStatus = "Issued";

    document.body.appendChild(element);

    let fraudOptions = element.shadowRoot.querySelectorAll(
      "lightning-button.btn"
    );
    let blockCNPButton = fraudOptions[1];
    blockCNPButton.click();

    let submitButton = element.shadowRoot.querySelector(
      "button[data-id='submit-button']"
    );
    submitButton.click();

    return flushPromises().then(() => {
      let confirmButton = element.shadowRoot.querySelector(".confirm-button");
      expect(confirmButton).toBeTruthy();
    });
  });

  it("7. check if the buttonClicked is not Fraud Lock, the submit-button should be invisible", () => {
    const element = createElement("c-card-fraud-lock", {
      is: CardFraudLock
    });
    element.buttonClicked = "Fraud Unlock";
    element.cardStatus = "Block CNP";
    document.body.appendChild(element);

    return flushPromises().then(() => {
      const submitButton = element.shadowRoot.querySelector(
        "button[data-id='submit-button']"
      );
      expect(submitButton).toBeFalsy();
    });
  });

  it("8. check if the buttonClicked is not Fraud Lock, should be navigate to confirmation", () => {
    const element = createElement("c-card-fraud-lock", {
      is: CardFraudLock
    });
    element.buttonClicked = "Fraud Unlock";
    element.cardStatus = "Block CNP";
    document.body.appendChild(element);

    return flushPromises().then(() => {
      const paragraphs = element.shadowRoot.querySelectorAll("p");
      const secondMessage = paragraphs[1];
      expect(secondMessage.textContent).toBe(
        "A chatter post will be placed on the customer's profile on to advise that you have removed all locks."
      );
    });
  });

  it("9. test toast message when fraud lock clicked and no option has been chosen", () => {
    const TOAST_TITLE = "Choose a fraud lock option";
    const TOAST_MESSAGE =
      "Please select a fraud lock option as no lock status has been selected";
    const TOAST_VARIANT = "error";

    const element = createElement("c-card-fraud-lock", {
      is: CardFraudLock
    });
    element.buttonClicked = "Fraud Lock";
    element.cardStatus = "Issued";

    document.body.appendChild(element);

    const handler = jest.fn();
    element.addEventListener(ShowToastEventName, handler);

    return flushPromises()
      .then(() => {
        const confirmButton = element.shadowRoot.querySelector(
          'button[data-id="submit-button"]'
        );
        confirmButton.click();
      })
      .then(() => {
        expect(handler).toHaveBeenCalled();
        const handlerObject = handler.mock.calls[0][0];
        expect(handlerObject.detail.title).toBe(TOAST_TITLE);
        expect(handlerObject.detail.message).toBe(TOAST_MESSAGE);
        expect(handlerObject.detail.variant).toBe(TOAST_VARIANT);
      });
  });

  it("10. test toast message when fraud lock clicked and same option has been chosen", () => {
    const TOAST_TITLE = "Choose another fraud lock option";
    const TOAST_MESSAGE =
      "Please select another fraud lock option as this lock status has been already applied to the card";
    const TOAST_VARIANT = "error";

    const element = createElement("c-card-fraud-lock", {
      is: CardFraudLock
    });
    element.buttonClicked = "Fraud Lock";
    element.cardStatus = "Block CNP";

    document.body.appendChild(element);

    const handler = jest.fn();
    element.addEventListener(ShowToastEventName, handler);

    return flushPromises()
      .then(() => {
        const confirmButton = element.shadowRoot.querySelector(
          'button[data-id="submit-button"]'
        );
        confirmButton.click();
      })
      .then(() => {
        expect(handler).toHaveBeenCalled();
        const handlerObject = handler.mock.calls[0][0];
        expect(handlerObject.detail.title).toBe(TOAST_TITLE);
        expect(handlerObject.detail.message).toBe(TOAST_MESSAGE);
        expect(handlerObject.detail.variant).toBe(TOAST_VARIANT);
      });
  });

  it("11. test toast message when fraud unlock clicked and status changed accepted", () => {
    fraudLock.mockResolvedValue(mockApexSuccess);
    const TOAST_TITLE = "Card Unlocked";
    const TOAST_MESSAGE = "This card has been successfully unlocked";
    const TOAST_VARIANT = "success";

    const element = createElement("c-card-fraud-lock", {
      is: CardFraudLock
    });
    element.buttonClicked = "Fraud Unlock";
    element.cardStatus = "Block CNP";

    document.body.appendChild(element);

    const handler = jest.fn();
    element.addEventListener(ShowToastEventName, handler);

    return flushPromises()
      .then(() => {
        const confirmButton = element.shadowRoot.querySelector(
          'lightning-button[data-id="confirm-button"]'
        );
        confirmButton.click();
      })
      .then(() => {
        publish(MessageContext, CloseModal, {
          name: "showFraudLock",
          show: true
        });
        expect(handler).toHaveBeenCalled();
        const handlerObject = handler.mock.calls[0][0];
        expect(handlerObject.detail.title).toBe(TOAST_TITLE);
        expect(handlerObject.detail.message).toBe(TOAST_MESSAGE);
        expect(handlerObject.detail.variant).toBe(TOAST_VARIANT);
      });
  });

  it("12. test toast message when fraud unlock clicked and status changed not accepted", () => {
    fraudLock.mockRejectedValue(mockApexFailure);

    const element = createElement("c-card-fraud-lock", {
      is: CardFraudLock
    });
    element.buttonClicked = "Fraud Unlock";
    element.cardStatus = "Block CNP";

    document.body.appendChild(element);

    const payload = {
      update: true
    };
    publish(MessageContext, CloseModal, payload);

    return flushPromises()
      .then(() => {
        const confirmButton = element.shadowRoot.querySelector(
          'lightning-button[data-id="confirm-button"]'
        );
        confirmButton.click();
      })
      .catch(() => {
        expect(publish).toHaveBeenCalled();
        const publishObject = publish.mock.calls[0][2];
        expect(publishObject.name).toBe("showFraudLock");
        expect(publishObject.show).toBe(true);
      });
  });
});

describe("c-card-fraud-lock | wire", () => {
  beforeEach(() => {
    const element = createElement("c-card-fraud-lock", {
      is: CardFraudLock
    });
    element.buttonClicked = "Fraud Lock";
    element.cardStatus = "Issued";
    document.body.appendChild(element);
  });

  it("1. check wire OCV_ID", () => {
    getRecord.emit(mockWireFraudLock);
    return Promise.resolve().then(() => {
      const ocvID = mockWireFraudLock.fields.OCV_ID__c.value;
      expect(ocvID).toBe("Test OCV_ID");
    });
  });
});
