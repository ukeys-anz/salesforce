import { createElement } from "lwc";
import ViewFullCardNumber from "c/viewFullCardNumber";
import getFullCardNumberDetails from "@salesforce/apex/CardDetailsController.getFullCardNumberDetails";

const MOCK_GET_FULL_CARD_NUMBER_ERROR = require("./data/viewFullCardNumberError.json");
const MOCK_GET_FULL_CARD_NUMBER_SUCCESS = require("./data/viewFullCardNumberSuccess.json");

// Mock the imported Apex method
jest.mock(
  "@salesforce/apex/CardDetailsController.getFullCardNumberDetails",
  () => {
    return {
      default: jest.fn()
    };
  },
  { virtual: true }
);

describe("c-get-full-card-number", () => {
  afterEach(() => {
    // Clean up DOM after each test
    while (document.body.firstChild) {
      document.body.removeChild(document.body.firstChild);
    }
    jest.clearAllMocks();
  });

  async function flushPromises() {
    return Promise.resolve();
  }

  it("renders the modal header with the correct label", async () => {
    const element = createElement("c-get-full-card-number", {
      is: ViewFullCardNumber
    });
    document.body.appendChild(element);
    await flushPromises();
    const header = element.shadowRoot.querySelector("lightning-modal-header");
    expect(header.label).toBe("Get Card Number");
  });

  it("renders full card details after successful API call", async () => {
    // Mock resolved value of the Apex call
    getFullCardNumberDetails.mockResolvedValue(
      MOCK_GET_FULL_CARD_NUMBER_SUCCESS
    );

    const element = createElement("c-get-full-card-number", {
      is: ViewFullCardNumber
    });
    element.cardNumber = MOCK_GET_FULL_CARD_NUMBER_SUCCESS;
    element.cardHolder = "Alexandra Lee";
    element.accountType = "Sole";
    element.ocvId = "10002446";
    document.body.appendChild(element);

    // Simulate connectedCallback
    await flushPromises();

    const cardHoldername = element.shadowRoot.querySelector(
      'lightning-input[data-id="cardHolder"]'
    );
    const accountType = element.shadowRoot.querySelector(
      'lightning-input[data-id="accountType"]'
    );
    const fullCardNumber = element.shadowRoot.querySelector(
      'lightning-input[data-id="fullCardNumber"]'
    );
    expect(cardHoldername.value).toBe("Alexandra Lee");
    expect(accountType.value).toBe("Sole");
    expect(fullCardNumber.value).toBe(MOCK_GET_FULL_CARD_NUMBER_SUCCESS);
  });

  it("handles API error and shows error message", async () => {
    // Mock rejected value of the Apex call
    getFullCardNumberDetails.mockRejectedValue(MOCK_GET_FULL_CARD_NUMBER_ERROR);
    const element = createElement("c-get-full-card-number", {
      is: ViewFullCardNumber
    });
    element.cardNumber = MOCK_GET_FULL_CARD_NUMBER_SUCCESS;
    element.cardHolder = "Alexandra Lee";
    element.accountType = "Sole";
    element.ocvId = "10002446";
    document.body.appendChild(element);

    await flushPromises();

    const errorMsg = element.shadowRoot.querySelector(
      'c-error[data-id="error"]'
    );
    expect(errorMsg).not.toBeNull();
  });

  it("hides the full card number after the specified timeout", async () => {
    getFullCardNumberDetails.mockResolvedValue(
      MOCK_GET_FULL_CARD_NUMBER_SUCCESS
    );
    jest.useFakeTimers(); // Use fake timers for timeout handling
    const element = createElement("c-get-full-card-number", {
      is: ViewFullCardNumber
    });
    element.cardNumber = MOCK_GET_FULL_CARD_NUMBER_SUCCESS;
    element.cardHolder = "Alexandra Lee";
    element.accountType = "Sole";
    element.ocvId = "10002446";
    document.body.appendChild(element);

    await flushPromises();

    const fullCardNumberwhentimerstarts = element.shadowRoot.querySelector(
      'lightning-input[data-id="fullCardNumber"]'
    );
    expect(fullCardNumberwhentimerstarts).not.toBeNull();
    expect(fullCardNumberwhentimerstarts.value).toBe(
      MOCK_GET_FULL_CARD_NUMBER_SUCCESS
    );

    // Fast-forward until timer has been executed
    jest.advanceTimersByTime(130000);
    await flushPromises();

    const fullCardNumber = element.shadowRoot.querySelector(
      'lightning-input[data-id="fullCardNumber"]'
    );
    expect(fullCardNumber).toBeNull();
    jest.useRealTimers(); // Restore the real timers after the test
  });

  it("copies the full card number to clipboard when the copy button is clicked", async () => {
    // Mock resolved value of the Apex call
    getFullCardNumberDetails.mockResolvedValue(
      MOCK_GET_FULL_CARD_NUMBER_SUCCESS
    );
    const element = createElement("c-get-full-card-number", {
      is: ViewFullCardNumber
    });

    // Mock the clipboard API
    navigator.clipboard = {
      writeText: jest.fn()
    };

    element.cardNumber = MOCK_GET_FULL_CARD_NUMBER_SUCCESS;
    element.cardHolder = "Alexandra Lee";
    element.accountType = "Sole";
    element.ocvId = "10002446";
    document.body.appendChild(element);

    await flushPromises();

    const copyButton = element.shadowRoot.querySelector(
      "lightning-button-icon"
    );
    copyButton.click();

    // Check if the clipboard API was called with the correct value
    expect(navigator.clipboard.writeText).toHaveBeenCalledWith(
      MOCK_GET_FULL_CARD_NUMBER_SUCCESS
    );
  });
});
