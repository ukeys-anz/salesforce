import { createElement } from "lwc";
import sopSpendingsL1Item from "c/sopSpendingsL1Item";

const L1_DATA = require("./data/spendingsL1Item.json");

describe("c-sop-spendings-L1-item", () => {
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

  it("should return true if there is L1 item", async () => {
    const element = createElement("c-sop-spendings-L1-item", {
      is: sopSpendingsL1Item
    });
    element.expenseDataL1 = L1_DATA;
    document.body.appendChild(element);
    await flushPromises();

    let monthlySpend = element.shadowRoot.querySelector(
      "lightning-formatted-number[data-jest-id='monthlySpend']"
    );
    expect(monthlySpend).toBeTruthy();
  });
});
