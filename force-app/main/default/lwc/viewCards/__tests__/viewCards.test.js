import { createElement } from "lwc";
import ViewCards from "c/viewCards";
import getCardList from "@salesforce/apex/CoachBankingAPIRepository.getCardListAura";

jest.mock(
  "@salesforce/apex/CoachBankingAPIRepository.getCardListAura",
  () => {
    return {
      default: jest.fn()
    };
  },
  { virtual: true }
);

const APEX_CARDS_SUCCESS = require("./data/response.json");
const APEX_CARDS_INVALID = require("./data/invalidResp.json");
const APEX_CARDS_NO_ELIGIBILITIES = require("./data/responseNoEligibilities.json");

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

  it("tests if view cards button visible", () => {
    const element = createElement("c-view-cards", {
      is: ViewCards
    });
    document.body.appendChild(element);
    let button = element.shadowRoot.querySelector(
      "lightning-button[data-id='get-cards-button']"
    );
    expect(button).toBeTruthy();
  });

  it("tests if initial card detail is visible", () => {
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
        "div[data-id='first-card-details']"
      );
      expect(card).toBeTruthy();

      let status = element.shadowRoot.querySelector(
        "p[data-id='initial-status']"
      );

      expect(status.textContent).toBe("Issued");
    });
  });

  it("tests invalid json renders error message", () => {
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

  it("tests load more cards", () => {
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
      let button = element.shadowRoot.querySelector(
        "button[data-id='load-more-button']"
      );
      expect(button).toBeTruthy();
      button.click();

      return flushPromises().then(() => {
        let card = element.shadowRoot.querySelector(
          "div[data-id='loaded-card-details']"
        );
        expect(card).toBeTruthy();
      });
    });
  });

  it("tests collapse cards", () => {
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
      let button = element.shadowRoot.querySelector(
        "button[data-id='load-more-button']"
      );
      expect(button).toBeTruthy();

      button.click();

      return flushPromises().then(() => {
        let button = element.shadowRoot.querySelector(
          "lightning-button[data-id='collapse-expand-button']"
        );
        expect(button).toBeTruthy();
        button.click();

        return flushPromises().then(() => {
          let loadedCard = element.shadowRoot.querySelector(
            "div[data-id='loaded-card-details']"
          );
          expect(loadedCard).toBeFalsy();

          let initialCard = element.shadowRoot.querySelector(
            "div[data-id='first-card-details']"
          );
          expect(initialCard).toBeTruthy();
        });
      });
    });
  });

  it("tests if lock card is enabled", () => {
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
        "div[data-id='first-card-details']"
      );
      expect(card).toBeTruthy();

      let lockButton = element.shadowRoot.querySelector(
        "lightning-button[data-button='initial-lock-card-button']"
      );

      expect(lockButton).toHaveProperty("disabled", false);
    });
  });

  it("tests if lock card is disabled", () => {
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
        "div[data-id='first-card-details']"
      );
      expect(card).toBeTruthy();

      let lockButton = element.shadowRoot.querySelector(
        "lightning-button[data-button='initial-lock-card-button']"
      );

      expect(lockButton).toHaveProperty("disabled", true);
    });
  });

  it("tests if replace card is enabled", () => {
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
        "div[data-id='first-card-details']"
      );
      expect(card).toBeTruthy();

      let replaceButton = element.shadowRoot.querySelector(
        "lightning-button[data-button='initial-replace-card-button']"
      );

      expect(replaceButton).toHaveProperty("disabled", false);
    });
  });

  it("tests if replace card is disabled", () => {
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
        "div[data-id='first-card-details']"
      );
      expect(card).toBeTruthy();

      let replaceButton = element.shadowRoot.querySelector(
        "lightning-button[data-button='initial-replace-card-button']"
      );

      expect(replaceButton).toHaveProperty("disabled", true);
    });
  });
});
