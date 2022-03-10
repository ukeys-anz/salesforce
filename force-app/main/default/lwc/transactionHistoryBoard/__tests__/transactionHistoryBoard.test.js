import TransactionHistoryBoard from "c/transactionHistoryBoard";
import { createElement } from "lwc";
import getTransactions from "@salesforce/apex/CoachBankingAPIRepository.getTransactionHistoryAura";
import { publish } from "lightning/messageService";
import { getRecord } from "lightning/uiRecordApi";
import { registerLdsTestWireAdapter } from "@salesforce/sfdx-lwc-jest";

const APEX_TRANSACTIONS_SUCCESS = require("./data/transactionSuccess.json");
const APEX_TRANSACTIONS_SUCCESS_SECOND = require("./data/transactionSuccessTwo.json");
const APEX_TRANSACTIONS_SUCCESS_PARTIAL = require("./data/transactionPartial.json");
const APEX_TRANSACTIONS_FAILURE = require("./data/transactionFailure.json");
const TRANSACTION_TYPE_RECORD_TYPE_ID_MAP = {
  ATM_Dispute: "0122O000001VkrVQAS",
  Card_Dispute: "0122O000001VkrYQAS",
  Direct_Debit_Dispute: "0122O000001VkrbQAC",
  Direct_Entry_Dispute: "0122O000001VkrcQAC",
  NPP_Dispute: "0122O000001VkriQAC"
};

jest.mock(
  "@salesforce/apex/CoachBankingAPIRepository.getTransactionHistoryAura",
  () => {
    return {
      default: jest.fn()
    };
  },
  { virtual: true }
);

//https://github.com/salesforce/wire-service-jest-util/blob/master/docs/migrating-from-version-2.x-to-3.x.md
/* eslint-disable-next-line @lwc/lwc/no-unexpected-wire-adapter-usages */
const getRecordAdapter = registerLdsTestWireAdapter(getRecord);
const mockGetRecord = require("./data/getRecord.json");

describe("c-transactionHistoryBoard", () => {
  afterEach(() => {
    // The jsdom instance is shared across test cases in a single file so reset the DOM
    while (document.body.firstChild) {
      document.body.removeChild(document.body.firstChild);
    }
    jest.clearAllMocks();
  });

  function flushPromises() {
    // eslint-disable-next-line no-undef
    return new Promise((resolve) => setImmediate(resolve));
  }
  // check for header
  it("test default scenario", () => {
    const element = createElement("c-transactionHistoryBoard", {
      is: TransactionHistoryBoard
    });
    document.body.appendChild(element);
    element.transactionTypeDisputeIdMapFromParent = TRANSACTION_TYPE_RECORD_TYPE_ID_MAP;
    element.transactionData = APEX_TRANSACTIONS_SUCCESS;

    // Emit data from @wire
    getRecordAdapter.emit(mockGetRecord);

    return flushPromises().then(() => {
      const titleDiv = element.shadowRoot.querySelector(
        "div.slds-text-title_bold"
      );
      expect(titleDiv).not.toBeNull();
      expect(titleDiv.textContent).toBe("Transaction History");
    });
  });

  it("test partial response", () => {
    const element = createElement("c-transactionHistoryBoard", {
      is: TransactionHistoryBoard
    });
    document.body.appendChild(element);
    element.transactionTypeDisputeIdMapFromParent = TRANSACTION_TYPE_RECORD_TYPE_ID_MAP;
    element.transactionData = APEX_TRANSACTIONS_SUCCESS_PARTIAL;

    // Emit data from @wire
    getRecordAdapter.emit(mockGetRecord);

    return flushPromises().then(() => {
      const titleDiv = element.shadowRoot.querySelector(
        "div.slds-text-title_bold"
      );
      expect(titleDiv).not.toBeNull();
    });
  });

  it("test end date change", () => {
    const element = createElement("c-transactionHistoryBoard", {
      is: TransactionHistoryBoard
    });
    document.body.appendChild(element);
    element.transactionTypeDisputeIdMapFromParent = TRANSACTION_TYPE_RECORD_TYPE_ID_MAP;
    element.transactionData = APEX_TRANSACTIONS_SUCCESS;

    // Emit data from @wire
    getRecordAdapter.emit(mockGetRecord);

    return Promise.resolve()
      .then(() => {})
      .then(() => {})
      .then(() => {})
      .then(() => {
        const startDateInput = element.shadowRoot.querySelector(
          'lightning-input[data-id="startDateInput"]'
        );
        startDateInput.value = new Date().toISOString().slice(0, 10);
        startDateInput.dispatchEvent(
          new CustomEvent("change", {
            detail: { value: startDateInput.value }
          })
        );

        const endDateInput = element.shadowRoot.querySelector(
          'lightning-input[data-id="endDateInput"]'
        );
        endDateInput.value = new Date().toISOString().slice(0, 10);
        endDateInput.dispatchEvent(
          new CustomEvent("change", {
            detail: { value: endDateInput.value }
          })
        );
      })
      .then(() => {
        element.transactionData = APEX_TRANSACTIONS_SUCCESS_SECOND;
        const searchBtn = element.shadowRoot.querySelector("lightning-button");
        searchBtn.click();

        const titleDiv = element.shadowRoot.querySelector(
          "div.slds-text-title_bold"
        );
        expect(titleDiv).not.toBeNull();
        expect(titleDiv.textContent).toBe("Transaction History");
      });
  });

  it("test expand and load more button", () => {
    const element = createElement("c-transactionHistoryBoard", {
      is: TransactionHistoryBoard
    });
    document.body.appendChild(element);
    element.transactionTypeDisputeIdMapFromParent = TRANSACTION_TYPE_RECORD_TYPE_ID_MAP;
    element.transactionData = APEX_TRANSACTIONS_SUCCESS;

    // Emit data from @wire
    getRecordAdapter.emit(mockGetRecord);

    return Promise.resolve()
      .then(() => {})
      .then(() => {})
      .then(() => {})
      .then(() => {
        getTransactions.mockResolvedValue(APEX_TRANSACTIONS_SUCCESS_SECOND);
        const loadMoreBtn = element.shadowRoot.querySelector(
          "button.load-more"
        );
        expect(loadMoreBtn).not.toBeNull();
        loadMoreBtn.click();

        const expandBtn = element.shadowRoot.querySelector(
          "button.expand-collapse"
        );
        expect(expandBtn.textContent).toBe("Expand All");
        expandBtn.click();
        expect(publish).toHaveBeenCalled();
      })
      .then(() => {
        const expandBtn2 = element.shadowRoot.querySelector(
          "button.expand-collapse"
        );
        expect(expandBtn2.textContent).toBe("Collapse All");
      });
  });
});
