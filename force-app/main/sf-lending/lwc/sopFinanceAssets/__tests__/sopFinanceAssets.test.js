import { createElement } from "lwc";
import SopFinanceAssets from "c/sopFinanceAssets";

const ASSET_DATA = require("./data/assetData.json");

describe("c-sop-finance-assets", () => {
  afterEach(() => {
    // The jsdom instance is shared across test cases in a single file so reset the DOM
    while (document.body.firstChild) {
      document.body.removeChild(document.body.firstChild);
    }
  });

  async function flushPromises() {
    return Promise.resolve();
  }

  it("test assets are visible", async () => {
    const element = createElement("c-sop-finance-assets", {
      is: SopFinanceAssets
    });

    element.sopAssetsData = ASSET_DATA;
    document.body.appendChild(element);
    await flushPromises();
    let heading = element.shadowRoot.querySelector(
      "lightning-formatted-text[data-id='assetsSummaryHeading']"
    );
    expect(heading).toBeTruthy();
  });
});
