import { createElement } from "lwc";
import SopFinanceSavings from "c/sopFinanceSavings";

const SAVINGS_DATA = require("./data/savingsData.json");

describe("c-sop-finance-savings", () => {
  afterEach(() => {
    // The jsdom instance is shared across test cases in a single file so reset the DOM
    while (document.body.firstChild) {
      document.body.removeChild(document.body.firstChild);
    }
  });

  async function flushPromises() {
    return Promise.resolve();
  }

  it("test savings are visible", async () => {
    const element = createElement("c-sop-finance-savings", {
      is: SopFinanceSavings
    });

    element.sopSavingsData = SAVINGS_DATA;
    document.body.appendChild(element);
    await flushPromises();
    let heading = element.shadowRoot.querySelector(
      "lightning-formatted-text[data-id='savingSummaryHeading']"
    );
    expect(heading).toBeTruthy();
  });
});
