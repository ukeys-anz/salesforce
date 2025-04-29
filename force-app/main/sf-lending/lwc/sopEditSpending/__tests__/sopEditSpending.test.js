import { createElement } from "lwc";
import SopEditSpending from "c/sopEditSpending";

const SPENDING_DATA = require("./data/spendings.json");

describe("c-sop-edit-spending", () => {
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

  it("should return true if there are expense children", async () => {
    const element = createElement("c-sop-edit-spending", {
      is: SopEditSpending
    });
    element.content = JSON.stringify(SPENDING_DATA);
    element.sop = "25ead5ce-1c02-4f91-953a-f0c60dfb47b7";
    element.recordId = "a0B5B00000D1g3UUAR";
    document.body.appendChild(element);
    await flushPromises();
    let expenseName = element.shadowRoot.querySelector(
      "lightning-formatted-text[data-jest-id='expenseName']"
    );
    expect(expenseName).toBeTruthy();
    let monthlySpend = element.shadowRoot.querySelector(
      "lightning-formatted-text[data-jest-id='monthlySpend']"
    );
    expect(monthlySpend).toBeTruthy();
    let saveButton = element.shadowRoot.querySelector(
      "lightning-button[data-jest-id='saveButton']"
    );
    expect(saveButton).toBeTruthy();
  });
});
