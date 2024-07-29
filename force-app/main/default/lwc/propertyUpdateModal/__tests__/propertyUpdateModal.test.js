import { createElement } from "lwc";
import PropertyUpdateModal from "c/propertyUpdateModal";
import { setImmediate } from "timers";

describe("c-property-update-modal", () => {
  afterEach(() => {
    // The jsdom instance is shared across test cases in a single file so reset the DOM
    while (document.body.firstChild) {
      document.body.removeChild(document.body.firstChild);
    }
    jest.clearAllMocks();
  });

  function flushPromises() {
    return new Promise((resolve) => setImmediate(resolve));
  }

  it("tests the error is displayed", async () => {
    const element = createElement("c-property-update-modal", {
      is: PropertyUpdateModal
    });
    element.recordId = "";
    document.body.appendChild(element);
    let submit = element.shadowRoot.querySelector(
      "lightning-button[data-id='submit-btn']"
    );

    expect(submit).toBeTruthy();

    submit.click();

    await flushPromises();

    let error = element.shadowRoot.querySelector("div[data-id='error']");

    expect(error).toBeTruthy();
  });
});
