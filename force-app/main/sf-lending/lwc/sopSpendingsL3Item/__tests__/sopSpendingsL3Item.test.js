import { createElement } from "lwc";
import sopSpendingsL3Item from "c/sopSpendingsL3Item";

const L3_DATA = require("./data/spendingsL3Item.json");

describe("c-sop-spendings-L3-item", () => {
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

  it("should return true if there is L3 item", async () => {
    const element = createElement("c-sop-spendings-L3-item", {
      is: sopSpendingsL3Item
    });
    element.expenseDataL3 = L3_DATA;
    document.body.appendChild(element);
    await flushPromises();

    let monthlySpend = element.shadowRoot.querySelector(
      "lightning-formatted-number[data-jest-id='monthlySpend']"
    );
    expect(monthlySpend).toBeTruthy();
  });
});
