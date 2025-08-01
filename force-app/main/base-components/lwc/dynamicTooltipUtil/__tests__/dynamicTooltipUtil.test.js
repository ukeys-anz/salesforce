import { createElement } from "lwc";
import DynamicTooltipUtil from "c/dynamicTooltipUtil";
const mockToolTip = require("./data/mockToolTip.json");

jest.mock(
  "@salesforce/resourceUrl/tooltipData",
  () => "./data/mockToolTip.json",
  {
    virtual: true
  }
);

global.fetch = jest.fn(() =>
  Promise.resolve({
    json: () => mockToolTip
  })
);

async function flushPromises() {
  return Promise.resolve();
}

describe("c-dynamic-tooltip-util", () => {
  afterEach(() => {
    // The jsdom instance is shared across test cases in a single file so reset the DOM
    while (document.body.firstChild) {
      document.body.removeChild(document.body.firstChild);
    }
    jest.clearAllMocks();
  });

  it("1, Test if tooltip content for total financial position visible", async () => {
    await flushPromises();
    const element = createElement("c-dynamic-tooltip-util", {
      is: DynamicTooltipUtil
    });
    element.headerTitle = "Total Financial Position*";
    element.resourceName = "totalFinancialPosition";
    element.productName = "ANZ Plus , ANZ Save and ANZ Plus Flex Saver";
    document.body.appendChild(element);
    await flushPromises();

    let tooltipContent = element.shadowRoot.querySelector(
      "div[data-id='tooltip-content-loaded']"
    );

    expect(tooltipContent).toBeTruthy();
    expect(tooltipContent.textContent).toContain(
      "ANZ Plus , ANZ Save and ANZ Plus Flex Saver"
    );
  });

  it("2, Test if tooltip content for total saved of financial position visible", async () => {
    await flushPromises();
    const element = createElement("c-dynamic-tooltip-util", {
      is: DynamicTooltipUtil
    });
    element.headerTitle = "Total Saved";
    element.resourceName = "totalSavedFinancialPosition";
    element.productName = "ANZ Save";
    document.body.appendChild(element);
    await flushPromises();
    let tooltipContent = element.shadowRoot.querySelector(
      "div[data-id='tooltip-content-loaded']"
    );

    expect(tooltipContent).toBeTruthy();
    expect(tooltipContent.textContent).toContain("their ANZ Save account");
  });

  it("3, Test if tooltip content for total saved of S1 Financial Account visible", async () => {
    await flushPromises();
    const element = createElement("c-dynamic-tooltip-util", {
      is: DynamicTooltipUtil
    });
    element.headerTitle = "Total Saved";
    element.resourceName = "SAVING01";
    element.productName = "ANZ Save";
    document.body.appendChild(element);
    await flushPromises();
    let tooltipContent = element.shadowRoot.querySelector(
      "div[data-id='tooltip-content-loaded']"
    );

    expect(tooltipContent).toBeTruthy();
    expect(tooltipContent.textContent).toContain("ANZ Save");
  });

  it("4, Test if tooltip content for total saved of S2 Financial Account visible", async () => {
    await flushPromises();
    const element = createElement("c-dynamic-tooltip-util", {
      is: DynamicTooltipUtil
    });
    element.headerTitle = "Flex Funds";
    element.resourceName = "SAVING02";
    element.productName = "ANZ Plus Flex Saver";
    document.body.appendChild(element);
    await flushPromises();
    let tooltipContent = element.shadowRoot.querySelector(
      "div[data-id='tooltip-content-loaded']"
    );

    expect(tooltipContent).toBeTruthy();
    expect(tooltipContent.textContent).toContain("ANZ Plus Flex Saver");
  });

  it("5, Test if tooltip content for checking account visible", async () => {
    await flushPromises();
    const element = createElement("c-dynamic-tooltip-util", {
      is: DynamicTooltipUtil
    });
    element.headerTitle = "Everyday Funds";
    element.resourceName = "TRANSACT01";
    element.productName = "ANZ Plus";
    document.body.appendChild(element);
    await flushPromises();
    let tooltipContent = element.shadowRoot.querySelector(
      "div[data-id='tooltip-content-loaded']"
    );

    expect(tooltipContent).toBeTruthy();
    expect(tooltipContent.textContent).toContain("ANZ Plus");
  });
});
