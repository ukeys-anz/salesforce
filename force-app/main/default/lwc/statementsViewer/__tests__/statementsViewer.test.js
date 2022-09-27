import { createElement } from "lwc";
import statementsViewer from "c/statementsViewer";
import getStatements from "@salesforce/apex/StatementAPIRepository.getStatementsAura";
import { getRecord } from "lightning/uiRecordApi";
import { registerLdsTestWireAdapter } from "@salesforce/sfdx-lwc-jest";

const wireAdapter = registerLdsTestWireAdapter(getRecord);

const RECORD_ID = "a0c2O000002XttOQAS";

const APEX_GET_STATEMENTS_SUCCESS = require("./data/statements.json");
const STATEMENTS_SORTED = require("./data/statementsSorted.json");
const APEX_CALLOUT_ERROR = require("./data/apexError.json");
const WIRED_FINANCIAL_ACCOUNT = require("./data/wiredFinancialAccount.json");

jest.mock(
  "@salesforce/apex/StatementAPIRepository.getStatementsAura",
  () => {
    return {
      default: jest.fn()
    };
  },
  { virtual: true }
);

jest.mock(
  "@salesforce/apex/StatementAPIRepository.getStatementsUrlAura",
  () => {
    return {
      default: jest.fn()
    };
  },
  { virtual: true }
);

describe("c-statements-viewer", () => {
  //clean the dom and mocks in between test runs
  afterEach(() => {
    while (document.body.firstChild) {
      document.body.removeChild(document.body.firstChild);
    }
    jest.clearAllMocks();
  });

  function flushPromises() {
    return new Promise((resolve) => setImmediate(resolve));
  }

  it("test error when access viewStatements component", async () => {
    getStatements.mockRejectedValue(APEX_CALLOUT_ERROR);

    const element = createElement("c-statements-viewer", {
      is: statementsViewer
    });

    element.recordId = RECORD_ID;
    document.body.appendChild(element);

    wireAdapter.emit(WIRED_FINANCIAL_ACCOUNT);

    // Wait for any asynchronous DOM updates
    await flushPromises();

    const error = element.shadowRoot.querySelector("c-error");
    expect(error).toBeTruthy();
  });

  it("test statement table", async () => {
    getStatements.mockResolvedValue(APEX_GET_STATEMENTS_SUCCESS);

    const element = createElement("c-statements-viewer", {
      is: statementsViewer
    });

    element.recordId = RECORD_ID;
    document.body.appendChild(element);

    wireAdapter.emit(WIRED_FINANCIAL_ACCOUNT);

    // Wait for any asynchronous DOM updates
    await flushPromises();

    let dataTableEl = element.shadowRoot.querySelector(
      "[data-id='statements_table']"
    );
    expect(dataTableEl).toBeTruthy();
  });

  it("test load more button", async () => {
    getStatements.mockResolvedValue(APEX_GET_STATEMENTS_SUCCESS);

    const element = createElement("c-statements-viewer", {
      is: statementsViewer
    });

    element.recordId = RECORD_ID;
    document.body.appendChild(element);

    wireAdapter.emit(WIRED_FINANCIAL_ACCOUNT);

    // Wait for any asynchronous DOM updates
    await flushPromises();

    let loadBtnEl = element.shadowRoot.querySelector(
      "[data-id='load_more_button']"
    );

    expect(loadBtnEl).toBeTruthy();

    loadBtnEl.click();

    await flushPromises();

    let dataTableEl = element.shadowRoot.querySelector(
      "[data-id='statements_table']"
    );
    expect(dataTableEl).toBeTruthy();
  });

  it("test sort statement table", async () => {
    getStatements.mockResolvedValue(APEX_GET_STATEMENTS_SUCCESS);

    const element = createElement("c-statements-viewer", {
      is: statementsViewer
    });

    element.recordId = RECORD_ID;
    document.body.appendChild(element);

    wireAdapter.emit(WIRED_FINANCIAL_ACCOUNT);

    // Wait for any asynchronous DOM updates
    await flushPromises();

    let dataTableEl = element.shadowRoot.querySelector(
      "[data-id='statements_table']"
    );

    dataTableEl.dispatchEvent(
      new CustomEvent("sort", {
        detail: { fieldName: "startDate", sortDirection: "desc" }
      })
    );

    // Wait for any asynchronous DOM updates
    await flushPromises();

    expect(dataTableEl.data).toStrictEqual(STATEMENTS_SORTED);
  });
});
