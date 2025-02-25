import { createElement } from "lwc";
import sopSpendingsL2Item from "c/sopSpendingsL2Item";

const L2_DATA = require("./data/spendingsL2Item.json");

describe("c-sop-spendings-L2-item", () => {
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

  it("should return true if there is L2 item", async () => {
    const element = createElement("c-sop-spendings-L2-item", {
      is: sopSpendingsL2Item
    });
    element.expenseDataL2 = L2_DATA;
    document.body.appendChild(element);
    await flushPromises();

    let monthlySpend = element.shadowRoot.querySelector(
      "lightning-formatted-number[data-jest-id='monthlySpend']"
    );
    expect(monthlySpend).toBeTruthy();
  });
});
