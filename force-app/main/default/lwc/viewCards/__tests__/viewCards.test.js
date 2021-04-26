import { createElement } from "lwc";
import ViewCards from "c/viewCards";

/**
 * NOTE 22/04/2021 - Peter Charalambous
 * Data is currently hard coded in the LWC as the API is currently not set up
 * Once API is up and running and an apex class exists, the data can be mocked
 * properly and the below tests can be updated accordingly
 */

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
      "button[data-id='get-cards-button']"
    );
    expect(button).toBeTruthy();
  });

  it("tests if initial card detail is visible", () => {
    const element = createElement("c-view-cards", {
      is: ViewCards
    });
    document.body.appendChild(element);
    let button = element.shadowRoot.querySelector(
      "button[data-id='get-cards-button']"
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

  it("tests load more cards", () => {
    const element = createElement("c-view-cards", {
      is: ViewCards
    });
    document.body.appendChild(element);
    let button = element.shadowRoot.querySelector(
      "button[data-id='get-cards-button']"
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
          "div[data-id='Bruce Willis']"
        );
        expect(card).toBeTruthy();
      });
    });
  });

  it("tests collapse cards", () => {
    const element = createElement("c-view-cards", {
      is: ViewCards
    });
    document.body.appendChild(element);
    let button = element.shadowRoot.querySelector(
      "button[data-id='get-cards-button']"
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
          "button[data-id='collapse-button']"
        );
        expect(button).toBeTruthy();
        button.click();

        return flushPromises().then(() => {
          let button = element.shadowRoot.querySelector(
            "button[data-id='collapse-button']"
          );
          expect(button).toBeFalsy();

          let loadedCard = element.shadowRoot.querySelector(
            "div[data-id='Bruce Willis']"
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
});
