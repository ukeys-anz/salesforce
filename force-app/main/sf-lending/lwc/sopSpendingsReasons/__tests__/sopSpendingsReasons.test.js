import { createElement } from "lwc";
import sopSpendingsReasons from "c/sopSpendingsReasons";
const REASON_DATA = require("./data/spendingsReasons.json");

describe("c-sop-spendings-reasons", () => {
  afterEach(() => {
    // Clean up the DOM after each test
    while (document.body.firstChild) {
      document.body.removeChild(document.body.firstChild);
    }
    jest.clearAllMocks();
  });

  async function flushPromises() {
    return Promise.resolve();
  }

  it("should return true if there are reasons", async () => {
    const element = createElement("c-sop-spendings-reasons", {
      is: sopSpendingsReasons
    });
    element.expenseReasonsData = REASON_DATA;
    document.body.appendChild(element);
    await flushPromises();
    let reason = element.shadowRoot.querySelector(
      "lightning-formatted-text[data-jest-id='reason']"
    );
    expect(reason).toBeTruthy();
  });
});
