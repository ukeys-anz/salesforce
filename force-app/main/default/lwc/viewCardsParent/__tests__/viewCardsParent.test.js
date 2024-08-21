import { createElement } from "lwc";
import ViewCardsParent from "c/viewCardsParent";
import getCardList from "@salesforce/apex/CardDetailsController.getCardList";
import { CurrentPageReference } from "lightning/navigation";

const APEX_NO_CARDS = require("./data/getListAllCardNoResponse.json");
const APEX_CARDS_SUCCESS = require("./data/getListAllCardValidResponse.json");
const MOCK_CURRENT_PAGEREFERENCE_DATA = require("./data/mockCurrentPageReferenceData.json");
const APEX_CARDS_INVALID = require("./data/getListAllCardInvalidResponse.json");
const APEX_CLOSED_CARD_ONLY = require("./data/getListAllClosedCardResponse.json");

jest.mock(
  "@salesforce/apex/CardDetailsController.getCardList",
  () => {
    return {
      default: jest.fn()
    };
  },
  { virtual: true }
);

describe("c-view-cards-parent", () => {
  afterEach(() => {
    // The jsdom instance is shared across test cases in a single file so reset the DOM
    while (document.body.firstChild) {
      document.body.removeChild(document.body.firstChild);
    }
    jest.clearAllMocks();
  });

  async function flushPromises() {
    return Promise.resolve();
  }

  it("1. tests if nocards error visible", async () => {
    getCardList.mockResolvedValue(APEX_NO_CARDS);

    const element = createElement("c-view-cards-parent", {
      is: ViewCardsParent
    });
    CurrentPageReference.emit(MOCK_CURRENT_PAGEREFERENCE_DATA);

    document.body.appendChild(element);
    await flushPromises();

    let nocards = element.shadowRoot.querySelector("span[data-id='nocards']");
    expect(nocards.textContent).toBe(
      "This customer doesn't have any accounts with an active card attached."
    );
  });

  it("2. tests if valid active cards are visible", async () => {
    getCardList.mockResolvedValue(APEX_CARDS_SUCCESS);

    const element = createElement("c-view-cards-parent", {
      is: ViewCardsParent
    });
    CurrentPageReference.emit(MOCK_CURRENT_PAGEREFERENCE_DATA);

    document.body.appendChild(element);
    await flushPromises();

    let activecards = element.shadowRoot.querySelector(
      "lightning-accordion-section[data-id='activeCardsSection']"
    );

    expect(activecards).toBeAccessible();
  });

  it("3. tests if 1 invalid card is removed", async () => {
    getCardList.mockResolvedValue(APEX_CARDS_INVALID);

    const element = createElement("c-view-cards-parent", {
      is: ViewCardsParent
    });
    CurrentPageReference.emit(MOCK_CURRENT_PAGEREFERENCE_DATA);

    document.body.appendChild(element);
    await flushPromises();

    let invalidCardsRemoved = element.shadowRoot.querySelector(
      "lightning-accordion-section[data-id='closeCardsSection']"
    );

    expect(invalidCardsRemoved).toBeFalsy();
  });

  it("5. tests if no active cards are visible", async () => {
    getCardList.mockResolvedValue(APEX_CLOSED_CARD_ONLY);

    const element = createElement("c-view-cards-parent", {
      is: ViewCardsParent
    });
    CurrentPageReference.emit(MOCK_CURRENT_PAGEREFERENCE_DATA);

    document.body.appendChild(element);
    await flushPromises();

    let noactivecards = element.shadowRoot.querySelector(
      "p[data-id='noactivecard']"
    );
    expect(noactivecards.textContent).toBe(
      "This customer doesn't have any accounts with an active card attached."
    );
  });
});
