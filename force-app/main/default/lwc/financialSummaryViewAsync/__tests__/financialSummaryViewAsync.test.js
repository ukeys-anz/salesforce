import { createElement } from "lwc";
import financialSummaryViewAsync from "c/financialSummaryViewAsync";
import getSummariesByResponseId from "@salesforce/apex/FinancialSummaryController.getSummariesByResponseId";
import getDataFromCallout from "@salesforce/apex/FinancialSummaryController.getDataFromCallout";
import { setImmediate } from "timers";
import getFinSummaryMetadata from "@salesforce/apex/FinancialSummaryController.getFinSummaryMetadata";
const GET_FINSUMMARY_SETTING_METADATA = require("./data/getFinSummaryMetadata.json");
const CALLING_FINANCIAL_SUMMARIES = require("./data/callingFinancialSummaries.json");
const FULL_FINANCIAL_SUMMARIES_FROM_CACHE = require("./data/getFullSummariesFromCache.json");
const FEW_FINANCIAL_SUMMARIES_FROM_CACHE = require("./data/getFewSummariesFromCache.json");
const REFRESH_FINANCIAL_SUMMARIES = require("./data/getSummariesAfterRefresh.json");
const ERROR_RESPOSNE_FROM_CACHE = require("./data/getErrorResponseFromCache.json");

jest.mock(
  "@salesforce/apex/FinancialSummaryController.getSummariesByResponseId",
  () => {
    return {
      default: jest.fn()
    };
  },
  { virtual: true }
);

jest.mock(
  "@salesforce/apex/FinancialSummaryController.getDataFromCallout",
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

jest.mock(
  "@salesforce/apex/FinancialSummaryController.getFinSummaryMetadata",
  () => {
    return {
      default: jest.fn()
    };
  },
  { virtual: true }
);

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
    getFinSummaryMetadata.mockResolvedValue(GET_FINSUMMARY_SETTING_METADATA);
    const element = createElement("c-financial-summary-view-async", {
      is: financialSummaryViewAsync
    });
    element.jtestRunning = true;
    document.body.appendChild(element);
    await flushPromises();
    const pElement = element.shadowRoot.querySelectorAll(
      "c-financial-summary-view-card"
    );
    expect(pElement[0].headerOtherValue).toBe("Calculation is in progress");
    expect(pElement[0].headerValue).toBe(undefined);
  });

  it("Verify Financial Summaries from Cache", async () => {
    getSummariesByResponseId.mockResolvedValue(
      FULL_FINANCIAL_SUMMARIES_FROM_CACHE
    );
    getFinSummaryMetadata.mockResolvedValue(GET_FINSUMMARY_SETTING_METADATA);
    const element = createElement("c-financial-summary-view-async", {
      is: financialSummaryViewAsync
    });
    element.jtestRunning = true;
    document.body.appendChild(element);
    await flushPromises();
    const pElement = element.shadowRoot.querySelectorAll(
      "c-financial-summary-view-card"
    );
    let totalBalance, totalAssetFinanceBalance;
    let totalBalanceVisible = false;
    let terminalsVisible = false;
    let assetBalanceVisible = false;
    pElement.forEach((card) => {
      if (card.headerName === "Total Customer Balance") {
        totalBalance = card.headerValue;
        totalBalanceVisible = true;
        return;
      }
      if (card.headerName === "Total Asset Financial Balance") {
        totalAssetFinanceBalance = card.headerValue;
        assetBalanceVisible = true;
      }
    });
    if (totalBalanceVisible) {
      expect(totalBalance).toBe(
        FULL_FINANCIAL_SUMMARIES_FROM_CACHE.totalBalance
      );
    }
    if (assetBalanceVisible) {
      expect(totalAssetFinanceBalance).toBe(
        FULL_FINANCIAL_SUMMARIES_FROM_CACHE.totalAssetFinanceBalance
      );
    }
  });

  it("Verify Financial Summaries in case of error", async () => {
    getSummariesByResponseId.mockResolvedValue(ERROR_RESPOSNE_FROM_CACHE);
    getFinSummaryMetadata.mockResolvedValue(GET_FINSUMMARY_SETTING_METADATA);
    const element = createElement("c-financial-summary-view-async", {
      is: financialSummaryViewAsync
    });
    element.jtestRunning = true;
    document.body.appendChild(element);
    await flushPromises();
    const pElement = element.shadowRoot.querySelectorAll(
      "c-financial-summary-view-card"
    );
    expect(pElement[0].headerOtherValue).toBe(
      ERROR_RESPOSNE_FROM_CACHE.totalBalanceAck
    );
  });

  it("Verify calling specific Financial Summaries API", async () => {
    getSummariesByResponseId.mockResolvedValue(
      FEW_FINANCIAL_SUMMARIES_FROM_CACHE
    );
    getFinSummaryMetadata.mockResolvedValue(GET_FINSUMMARY_SETTING_METADATA);
    getDataFromCallout.mockResolvedValue(REFRESH_FINANCIAL_SUMMARIES);
    const element = createElement("c-financial-summary-view-async", {
      is: financialSummaryViewAsync
    });
    element.jtestRunning = true;
    document.body.appendChild(element);
    await flushPromises();
    const pElement = element.shadowRoot.querySelectorAll(
      "c-financial-summary-view-card"
    );
    expect(pElement[0].headerValue).toBe(
      FEW_FINANCIAL_SUMMARIES_FROM_CACHE.totalBalance
    );
    expect(pElement[0].headerOtherValue).toBe("Calculation is in progress");
  });

  it("Verify Financial Summaries on Refresh", async () => {
    getSummariesByResponseId.mockResolvedValue(CALLING_FINANCIAL_SUMMARIES);
    getFinSummaryMetadata.mockResolvedValue(GET_FINSUMMARY_SETTING_METADATA);
    getDataFromCallout.mockRejectedValue(REFRESH_FINANCIAL_SUMMARIES);
    const element = createElement("c-financial-summary-view-async", {
      is: financialSummaryViewAsync
    });
    element.jtestRunning = true;
    document.body.appendChild(element);
    const buttonElement = element.shadowRoot.querySelector(
      "lightning-button-icon"
    );
    buttonElement.click();
    await flushPromises();

    const pElement = element.shadowRoot.querySelectorAll(
      "c-financial-summary-view-card"
    );
    let countValue = 0;
    let countOtherValue = 0;

    pElement.forEach((card) => {
      if (card.headerValue) {
        countValue += 1;
        return;
      }
      if (card.headerOtherValue) {
        countOtherValue += 1;
      }
    });
    expect(countValue).toBe(0);
    expect(countOtherValue).toBe(5);
  });
});
