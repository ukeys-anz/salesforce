import { createElement } from "lwc";
import SopEditSpendingItems from "c/sopEditSpendingItems";

const SPENDING_DATA = require("./data/spendingItems.json");

describe("c-sop-edit-spending-items", () => {
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

  it("should return true if there are expense items", async () => {
    const element = createElement("c-sop-edit-spending-items", {
      is: SopEditSpendingItems
    });
    element.expenseItem = SPENDING_DATA;
    document.body.appendChild(element);
    await flushPromises();
    let monthlySpendInput = element.shadowRoot.querySelector(
      "lightning-input[data-jest-id='monthlySpendInput']"
    );
    expect(monthlySpendInput).toBeTruthy();

    let description = element.shadowRoot.querySelector(
      "lightning-formatted-text[data-jest-id='description']"
    );
    expect(description).not.toBeNull();
    if (description) {
      expect(description.value).toBe("Other Justification");
    }
  });
});
