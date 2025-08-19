import { createElement } from "lwc";
import DynamicTooltipUtil from "c/dynamicTooltipUtil";
import { loadScript } from "lightning/platformResourceLoader";

jest.mock("lightning/platformResourceLoader", () => {
  return {
    loadScript: jest.fn()
  };
});

describe("c-dynamic-tooltip-util - tooltip rendering", () => {
  beforeEach(() => {
    document.body.innerHTML = "";
    jest.clearAllMocks();
  });

  const mockTooltipData = {
    totalFinancialPosition:
      "<span>The amount shown in <strong>{productName}</strong> account.</span>",
    accountBalance: "<p><em>{productName}</em> balance details.</p>"
  };

  function setupComponent(resourceName, productName) {
    loadScript.mockImplementation(() => {
      window.tooltipData = mockTooltipData;
      return Promise.resolve();
    });

    const element = createElement("c-dynamic-tooltip-util", {
      is: DynamicTooltipUtil
    });

    element.headerTitle = "Header";
    element.resourceName = resourceName;
    element.productName = productName;
    document.body.appendChild(element);

    return Promise.resolve()
      .then(() => Promise.resolve())
      .then(() => element);
  }

  it("1. renders correct tooltip text with product name", async () => {
    const element = await setupComponent("totalFinancialPosition", "ANZ Plus");
    const contentDiv = element.shadowRoot.querySelector(
      '[data-id="tooltip-content-loaded"]'
    );

    expect(contentDiv.textContent).toContain("The amount shown in");
    expect(contentDiv.textContent).toContain("ANZ Plus");
  });

  it("2. renders correct text for another tooltip key", async () => {
    const element = await setupComponent("accountBalance", "Savings");
    const contentDiv = element.shadowRoot.querySelector(
      '[data-id="tooltip-content-loaded"]'
    );

    expect(contentDiv.textContent).toContain("Savings balance details.");
  });

  it("3. renders empty content if resource name is missing", async () => {
    const element = await setupComponent("", "AnyProduct");
    const contentDiv = element.shadowRoot.querySelector(
      '[data-id="tooltip-content-loaded"]'
    );

    expect(contentDiv.textContent.trim()).toBe("");
  });

  it("4. renders content without replacing productName if placeholder is missing", async () => {
    // mock static data without {productName} placeholder
    loadScript.mockImplementation(() => {
      window.tooltipData = {
        missingPlaceholder: ""
      };
      return Promise.resolve();
    });

    const element = createElement("c-dynamic-tooltip-util", {
      is: DynamicTooltipUtil
    });

    element.headerTitle = "Header";
    element.resourceName = "missingPlaceholder";
    element.productName = "InvisibleProduct";
    document.body.appendChild(element);

    await Promise.resolve();
    await Promise.resolve();

    const contentDiv = element.shadowRoot.querySelector(
      '[data-id="tooltip-content-loaded"]'
    );
    expect(contentDiv.textContent).toContain("");
    expect(contentDiv.textContent).not.toContain("InvisibleProduct");
  });

  it("5. dispatches closemodal event when close button is clicked", async () => {
    const element = createElement("c-dynamic-tooltip-util", {
      is: DynamicTooltipUtil
    });

    element.headerTitle = "Header";
    document.body.appendChild(element);

    const handler = jest.fn();
    element.addEventListener("closemodal", handler);

    const closeButton = element.shadowRoot.querySelector("button");
    closeButton.click();

    expect(handler).toHaveBeenCalled();
  });
});
