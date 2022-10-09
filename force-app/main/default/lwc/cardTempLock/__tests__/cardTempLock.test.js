import { createElement } from "lwc";
import CardTempLock from "c/cardTempLock";
import { setImmediate } from "timers";

describe("c-card-temp-lock", () => {
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

  it("checks if lock button visible", () => {
    const element = createElement("c-card-temp-lock", {
      is: CardTempLock
    });
    document.body.appendChild(element);

    return flushPromises().then(() => {
      let button = element.shadowRoot.querySelector(
        "button[data-id='lock-button']"
      );

      expect(button).toBeTruthy();
    });
  });
});
