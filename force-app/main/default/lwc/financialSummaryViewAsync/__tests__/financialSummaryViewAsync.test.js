import { createElement } from "lwc";
import financialSummaryViewAsync from "c/financialSummaryViewAsync";
import getSummariesByResponseId from "@salesforce/apex/CCRMFinancialSummaryController.getSummariesByResponseId";
import summariesCallout from "@salesforce/apex/CCRMFinancialSummaryController.summariesCallout";
import { setImmediate } from "timers";
const CALLING_FINANCIAL_SUMMARIES = require("./data/callingFinancialSummaries.json");
const FULL_FINANCIAL_SUMMARIES_FROM_CACHE = require("./data/getFullSummariesFromCache.json");
const FEW_FINANCIAL_SUMMARIES_FROM_CACHE = require("./data/getFewSummariesFromCache.json");
const REFRESH_FINANCIAL_SUMMARIES = require("./data/getSummariesAfterRefresh.json");

jest.mock(
  "@salesforce/apex/CCRMFinancialSummaryController.getSummariesByResponseId",
  () => {
    return {
      default: jest.fn()
    };
  },
  { virtual: true }
);

jest.mock(
  "@salesforce/apex/CCRMFinancialSummaryController.summariesCallout",
  () => {
    return {
      default: jest.fn()
    };
  },
  { virtual: true }
);

jest.mock("lightning/messageService", () => {
  return {
    subscribe: jest.fn(),
    unsubscribe: jest.fn()
  };
});

describe("c-financial-summary-view-async", () => {
  afterEach(() => {
    while (document.body.firstChild) {
      document.body.removeChild(document.body.firstChild);
    }
    jest.clearAllMocks();
  });

  function flushPromises() {
    return new Promise((resolve) => setImmediate(resolve));
  }

  it("Verify Financial Summaries on Load", async () => {
    getSummariesByResponseId.mockResolvedValue(CALLING_FINANCIAL_SUMMARIES);
    const element = createElement("c-financial-summary-view-async", {
      is: financialSummaryViewAsync
    });
    document.body.appendChild(element);
    await flushPromises();
    const pElement = element.shadowRoot.querySelectorAll(
      "lightning-formatted-text"
    );
    console.log(pElement);
    expect(pElement[0].value).toBe("Calculation is in progress");
  });

  it("Verify Financial Summaries from Cache", async () => {
    getSummariesByResponseId.mockResolvedValue(
      FULL_FINANCIAL_SUMMARIES_FROM_CACHE
    );
    const element = createElement("c-financial-summary-view-async", {
      is: financialSummaryViewAsync
    });
    document.body.appendChild(element);
    await flushPromises();
    const pElement = element.shadowRoot.querySelectorAll(
      "lightning-formatted-number"
    );
    console.log(FULL_FINANCIAL_SUMMARIES_FROM_CACHE.totalBalance);
    expect(pElement[0].value).toBe(
      FULL_FINANCIAL_SUMMARIES_FROM_CACHE.totalBalance
    );
    expect(pElement[1].value).toBe(
      FULL_FINANCIAL_SUMMARIES_FROM_CACHE.totalMerchantTerminals
    );
    expect(pElement[2].value).toBe(
      FULL_FINANCIAL_SUMMARIES_FROM_CACHE.totalAssetFinanceBalance
    );
  });

  it("Verify calling specific Financial Summaries API", async () => {
    getSummariesByResponseId.mockResolvedValue(
      FEW_FINANCIAL_SUMMARIES_FROM_CACHE
    );
    summariesCallout.mockResolvedValue(REFRESH_FINANCIAL_SUMMARIES);
    const element = createElement("c-financial-summary-view-async", {
      is: financialSummaryViewAsync
    });
    document.body.appendChild(element);
    await flushPromises();
    const pElement = element.shadowRoot.querySelectorAll(
      "lightning-formatted-number"
    );
    const pElementText = element.shadowRoot.querySelectorAll(
      "lightning-formatted-text"
    );
    console.log("pElementText --> ", pElementText[0].value);
    console.log(FEW_FINANCIAL_SUMMARIES_FROM_CACHE.totalBalance);
    expect(pElement[0].value).toBe(
      FEW_FINANCIAL_SUMMARIES_FROM_CACHE.totalBalance
    );
    expect(pElement[1].value).toBe(
      FEW_FINANCIAL_SUMMARIES_FROM_CACHE.totalMerchantTerminals
    );
    expect(pElementText[0].value).toBe("Calculation is in progress");
  });

  it("Verify Financial Summaries on Refresh", async () => {
    getSummariesByResponseId.mockResolvedValue(CALLING_FINANCIAL_SUMMARIES);
    summariesCallout.mockRejectedValue(REFRESH_FINANCIAL_SUMMARIES);
    const element = createElement("c-financial-summary-view-async", {
      is: financialSummaryViewAsync
    });
    document.body.appendChild(element);
    const buttonElement = element.shadowRoot.querySelector(
      "lightning-button-icon"
    );
    buttonElement.click();
    await flushPromises();

    const pElement = element.shadowRoot.querySelectorAll(
      "lightning-formatted-number"
    );
    const pElementText = element.shadowRoot.querySelectorAll(
      "lightning-formatted-text"
    );
    expect(pElement.length).toBe(0);
    expect(pElementText.length).toBe(3);
  });
});
