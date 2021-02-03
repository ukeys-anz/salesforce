import TransactionHistoryBoard from "c/transactionHistoryBoard";
import { createElement } from "lwc";
import getTransactions from "@salesforce/apex/TransactionHistoryController.getTransactions";
import { getRecord } from "lightning/uiRecordApi";

import { publish, MessageContext } from "lightning/messageService";
import ExpandCollapseAll from "@salesforce/messageChannel/ListCollapseExpandAll__c";

import {
  registerApexTestWireAdapter,
  registerTestWireAdapter,
  registerLdsTestWireAdapter
} from "@salesforce/sfdx-lwc-jest";

const messageContextWireAdapter = registerTestWireAdapter(MessageContext);
const mockGetRecord = require("./data/getRecord.json");
const getRecordAdapter = registerLdsTestWireAdapter(getRecord);

jest.mock(
  "@salesforce/apex/TransactionHistoryController.getTransactions",
  () => {
    return {
      default: jest.fn()
    };
  },
  { virtual: true }
);

const APEX_TRANSACTIONS_SUCCESS =
  '{"total":{},"transactions":[{"TransactionID":"123","amount":{"charged":{"value":"50.00"}},"type":"TRANSACTION_TYPE_CARD","status":"TRANSACTION_STATUS_PENDING","card":{"scheme":"CARD_SCHEME_VISA"},"date":"2020-01-01d18:19","tags":[{"name":"test"},{"name":"testsuperlooooooooongStr"}],"merchant":{"name":"test","chain_name":{"value":"test"},"address":{"line_one":{"value":"test street"},"suburb":{"value":"test suburb"},"state":{"value":"test state"},"postcode":{"value":"4000"},"coordinates":{"latitude":51,"longitude":47}},"image_details":{"light_url":{"value":"test url"}},"email":{"value":"test@test.com"}}}],"links":{"next":{"href":"www.google.com"}}}';
const APEX_TRANSACTIONS_SUCCESS_SECOND =
  '{"total":{},"transactions":[{"TransactionID":"124","amount":{"charged":{"value":"50.00"}},"type":"TRANSACTION_TYPE_CARD","status":"TRANSACTION_STATUS_PENDING","card":{"scheme":"CARD_SCHEME_VISA"},"date":"2020-01-01d18:19","tags":[{"name":"test"},{"name":"testsuperlooooooooongStr"}],"merchant":{"name":"test","chain_name":{"value":"test"},"address":{"line_one":{"value":"test street"},"suburb":{"value":"test suburb"},"state":{"value":"test state"},"postcode":{"value":"4000"},"coordinates":{"latitude":51,"longitude":47}},"image_details":{"light_url":{"value":"test url"}},"email":{"value":"test@test.com"}}}],"links":{"next":{"href":"www.google.com"}}}';
const APEX_TRANSACTIONS_SUCCESS_PARTIAL =
  '{"total":{},"transactions":[{"TransactionID":"123","amount":{"charged":{"value":"50.00"}},"type":"TRANSACTION_TYPE_CARD"}]}';
const APEX_TRANSACTIONS_FAILURE = {
  body: { message: "An internal server error has occurred" },
  ok: false,
  status: 400,
  statusText: "Bad Request"
};

describe("c-transactionHistoryBoard", () => {
  afterEach(() => {
    // The jsdom instance is shared across test cases in a single file so reset the DOM
    while (document.body.firstChild) {
      document.body.removeChild(document.body.firstChild);
    }
  });

  function flushPromises() {
    // eslint-disable-next-line no-undef
    return new Promise((resolve) => setImmediate(resolve));
  }

  it("test default scenario", () => {
    getTransactions.mockResolvedValue(APEX_TRANSACTIONS_SUCCESS);
    const element = createElement("c-transactionHistoryBoard", {
      is: TransactionHistoryBoard
    });
    document.body.appendChild(element);

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
    getTransactions.mockResolvedValue(APEX_TRANSACTIONS_SUCCESS_PARTIAL);
    const element = createElement("c-transactionHistoryBoard", {
      is: TransactionHistoryBoard
    });
    document.body.appendChild(element);

    // Emit data from @wire
    getRecordAdapter.emit(mockGetRecord);

    return flushPromises().then(() => {
      const titleDiv = element.shadowRoot.querySelector(
        "div.slds-text-title_bold"
      );
      expect(titleDiv).toBeNull();
    });
  });

  it("test end date change", () => {
    getTransactions.mockResolvedValue(APEX_TRANSACTIONS_SUCCESS);
    const element = createElement("c-transactionHistoryBoard", {
      is: TransactionHistoryBoard
    });
    document.body.appendChild(element);

    // Emit data from @wire
    getRecordAdapter.emit(mockGetRecord);

    return Promise.resolve()
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
        getTransactions.mockResolvedValue(APEX_TRANSACTIONS_SUCCESS_SECOND);
        const searchBtn = element.shadowRoot.querySelector("lightning-button");
        searchBtn.click();
      })
      .then(() => {})
      .then(() => {
        const titleDiv = element.shadowRoot.querySelector(
          "div.slds-text-title_bold"
        );
        expect(titleDiv).not.toBeNull();
        expect(titleDiv.textContent).toBe("Transaction History");
      });
  });

  it("test error handling", () => {
    getTransactions.mockRejectedValue(APEX_TRANSACTIONS_FAILURE);
    const element = createElement("c-transactionHistoryBoard", {
      is: TransactionHistoryBoard
    });
    document.body.appendChild(element);

    // Emit data from @wire
    getRecordAdapter.emit(mockGetRecord);

    return flushPromises().then(() => {
      const errorCmp = element.shadowRoot.querySelector("c-error");
      expect(errorCmp).not.toBeNull();
    });
  });

  it("test expand and load more button", () => {
    getTransactions.mockResolvedValue(APEX_TRANSACTIONS_SUCCESS);
    const element = createElement("c-transactionHistoryBoard", {
      is: TransactionHistoryBoard
    });
    document.body.appendChild(element);

    // Emit data from @wire
    getRecordAdapter.emit(mockGetRecord);

    return Promise.resolve()
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
