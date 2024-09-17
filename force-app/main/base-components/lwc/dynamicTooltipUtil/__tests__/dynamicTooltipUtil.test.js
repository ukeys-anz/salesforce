import { createElement } from "lwc";
import DynamicTooltipUtil from "c/dynamicTooltipUtil";

describe("c-dynamic-tooltip-util", () => {
  afterEach(() => {
    // The jsdom instance is shared across test cases in a single file so reset the DOM
    while (document.body.firstChild) {
      document.body.removeChild(document.body.firstChild);
    }
  });

  it("1, Test if tooltip content for total financial position visible", () => {
    const element = createElement("c-dynamic-tooltip-util", {
      is: DynamicTooltipUtil
    });
    element.headerTitle = "Total Financial Position*";
    element.resourceName = "totalFinancialPosition";
    document.body.appendChild(element);

    let tooltipContent = element.shadowRoot.querySelector(
      "div[data-id='tooltip-content-loaded']"
    );

    expect(tooltipContent).toBeTruthy();
    expect(tooltipContent.textContent).toContain(
      "ANZ Plus , ANZ Save and ANZ Plus Flex Saver"
    );
  });

  it("2, Test if tooltip content for total saved of financial position visible", () => {
    const element = createElement("c-dynamic-tooltip-util", {
      is: DynamicTooltipUtil
    });
    element.headerTitle = "Total Saved";
    element.resourceName = "totalSavedFinancialPosition";
    document.body.appendChild(element);

    let tooltipContent = element.shadowRoot.querySelector(
      "div[data-id='tooltip-content-loaded']"
    );

    expect(tooltipContent).toBeTruthy();
    expect(tooltipContent.textContent).toContain("your ANZ Save account");
  });

  it("3, Test if tooltip content for total saved of S1 Financial Account visible", () => {
    const element = createElement("c-dynamic-tooltip-util", {
      is: DynamicTooltipUtil
    });
    element.headerTitle = "Total Saved";
    element.resourceName = "savings";
    document.body.appendChild(element);

    let tooltipContent = element.shadowRoot.querySelector(
      "div[data-id='tooltip-content-loaded']"
    );

    expect(tooltipContent).toBeTruthy();
    expect(tooltipContent.textContent).toContain("ANZ Save");
  });

  it("4, Test if tooltip content for total saved of S2 Financial Account visible", () => {
    const element = createElement("c-dynamic-tooltip-util", {
      is: DynamicTooltipUtil
    });
    element.headerTitle = "Total Saved";
    element.resourceName = "savingss2";
    document.body.appendChild(element);

    let tooltipContent = element.shadowRoot.querySelector(
      "div[data-id='tooltip-content-loaded']"
    );

    expect(tooltipContent).toBeTruthy();
    expect(tooltipContent.textContent).toContain("ANZ Plus Flex Saver");
  });

  it("1, Test if tooltip content for total financial position visible", () => {
    const element = createElement("c-dynamic-tooltip-util", {
      is: DynamicTooltipUtil
    });
    element.headerTitle = "Everyday Funds";
    element.resourceName = "checking";
    document.body.appendChild(element);

    let tooltipContent = element.shadowRoot.querySelector(
      "div[data-id='tooltip-content-loaded']"
    );

    expect(tooltipContent).toBeTruthy();
    expect(tooltipContent.textContent).toContain("ANZ Plus");
  });
});
