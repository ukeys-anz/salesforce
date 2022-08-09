import { createElement } from "lwc";
import ReplaceCard from "c/replaceCard";

describe("c-replace-card", () => {
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

  it("tests all three paths are available", () => {
    const element = createElement("c-replace-card", {
      is: ReplaceCard
    });
    element.replaceLostUnavailable = false;
    element.replaceStolenUnavailable = false;
    element.replaceDamagedUnavailable = false;

    document.body.appendChild(element);

    return flushPromises().then(() => {
      let lostButton = element.shadowRoot.querySelector(
        "button[data-id='lost-path']"
      );

      let stolenButton = element.shadowRoot.querySelector(
        "button[data-id='stolen']"
      );

      let damagedButton = element.shadowRoot.querySelector(
        "button[data-id='damaged']"
      );

      expect(lostButton).toHaveProperty("disabled", false);
      expect(stolenButton).toHaveProperty("disabled", false);
      expect(damagedButton).toHaveProperty("disabled", false);
    });
  });

  it("tests all three paths are unavailable", () => {
    const element = createElement("c-replace-card", {
      is: ReplaceCard
    });

    element.replaceLostUnavailable = true;
    element.replaceStolenUnavailable = true;
    element.replaceDamagedUnavailable = true;

    document.body.appendChild(element);
    return flushPromises().then(() => {
      let lostButton = element.shadowRoot.querySelector(
        "button[data-id='lost-path']"
      );

      let stolenButton = element.shadowRoot.querySelector(
        "button[data-id='stolen']"
      );

      let damagedButton = element.shadowRoot.querySelector(
        "button[data-id='damaged']"
      );

      expect(lostButton).toHaveProperty("disabled", true);
      expect(stolenButton).toHaveProperty("disabled", true);
      expect(damagedButton).toHaveProperty("disabled", true);
    });
  });

  it("tests lock available", () => {
    const element = createElement("c-replace-card", {
      is: ReplaceCard
    });

    element.replaceLostUnavailable = false;
    element.replaceLockUnavailable = false;

    document.body.appendChild(element);
    return flushPromises()
      .then(() => {
        let lostButton = element.shadowRoot.querySelector(
          "button[data-id='lost-path']"
        );

        lostButton.click();
      })
      .then(() => {
        let lockButtonPath = element.shadowRoot.querySelector(
          "button[data-id='lock-button-path']"
        );
        expect(lockButtonPath).toHaveProperty("disabled", false);
        lockButtonPath.click();
      });
  });

  it("tests lock path unavailable", () => {
    const element = createElement("c-replace-card", {
      is: ReplaceCard
    });

    element.replaceLostUnavailable = false;
    element.replaceLockUnavailable = true;

    document.body.appendChild(element);
    return flushPromises()
      .then(() => {
        let lostButton = element.shadowRoot.querySelector(
          "button[data-id='lost-path']"
        );

        lostButton.click();
      })
      .then(() => {
        let lockButtonPath = element.shadowRoot.querySelector(
          "button[data-id='lock-button-path']"
        );
        expect(lockButtonPath).toHaveProperty("disabled", true);
        lockButtonPath.click();
      });
  });

  it("tests lost path", () => {
    const element = createElement("c-replace-card", {
      is: ReplaceCard
    });

    element.replaceLostUnavailable = false;

    document.body.appendChild(element);
    return flushPromises()
      .then(() => {
        let lostButton = element.shadowRoot.querySelector(
          "button[data-id='lost-path']"
        );
        expect(lostButton).toHaveProperty("disabled", false);
        lostButton.click();
      })
      .then(() => {
        let lostButtonPath = element.shadowRoot.querySelector(
          "button[data-id='lost']"
        );
        lostButtonPath.click();
      })
      .then(() => {
        let replacementButton = element.shadowRoot.querySelector(
          "button[data-id='order-replacement-button']"
        );

        expect(replacementButton).toBeTruthy();
      });
  });

  it("tests stolen path", () => {
    const element = createElement("c-replace-card", {
      is: ReplaceCard
    });

    element.replaceStolenUnavailable = false;

    document.body.appendChild(element);
    return flushPromises()
      .then(() => {
        let stolenButton = element.shadowRoot.querySelector(
          "button[data-id='stolen']"
        );
        expect(stolenButton).toHaveProperty("disabled", false);
        stolenButton.click();
      })
      .then(() => {
        let replacementButton = element.shadowRoot.querySelector(
          "button[data-id='order-replacement-button']"
        );

        expect(replacementButton).toBeTruthy();
      });
  });

  it("tests damaged path", () => {
    const element = createElement("c-replace-card", {
      is: ReplaceCard
    });

    element.replaceDamagedUnavailable = false;

    document.body.appendChild(element);
    return flushPromises()
      .then(() => {
        let damagedButton = element.shadowRoot.querySelector(
          "button[data-id='damaged']"
        );
        expect(damagedButton).toHaveProperty("disabled", false);
        damagedButton.click();
      })
      .then(() => {
        let replacementButton = element.shadowRoot.querySelector(
          "button[data-id='order-replacement-button']"
        );

        expect(replacementButton).toBeTruthy();
      });
  });
});
