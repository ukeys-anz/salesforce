import totalBalance from "c/totalBalance";
import { createElement } from "lwc";
import getFinancialTotalBalance from "@salesforce/apex/TotalBalanceController.getTotalBalance";
import getFinancialTotalSaved from "@salesforce/apex/TotalBalanceController.getTotalSaved";
import { setImmediate } from "timers";

const DUMMY_ACCOUNT_RECORD_ID = "001AD00000NmIfxYAF";

jest.mock(
  "@salesforce/apex/TotalBalanceController.getTotalBalance",
  () => ({
    default: jest.fn()
  }),
  { virtual: true }
);

jest.mock(
  "@salesforce/apex/TotalBalanceController.getTotalSaved",
  () => ({
    default: jest.fn()
  }),
  { virtual: true }
);

const TOTAL_BALANCE = require("./data/totalBalance.json");
const TOTAL_SAVE_BALANCE = require("./data/totalSave.json");
// Sample error for imperative Apex call
const TOTAL_BALANCE_ERROR = {
  body: { message: "An internal server error has occurred" },
  ok: false,
  status: 400,
  statusText: "Bad Request"
};

describe("c-totalBalance", () => {
  //clean the dom and mocks in between test runs
  afterEach(() => {
    while (document.body.firstChild) {
      document.body.removeChild(document.body.firstChild);
    }
  });

  function flushPromises() {
    return new Promise((resolve) => setImmediate(resolve));
  }

  function raiseEvent() {
    const event = new CustomEvent(
      "refreshFinances_" + DUMMY_ACCOUNT_RECORD_ID,
      { detail: "FetchBalance" }
    );
    window.dispatchEvent(event);
  }

  it("test balances are displayed", async () => {
    getFinancialTotalBalance.mockResolvedValue(TOTAL_BALANCE);
    getFinancialTotalSaved.mockResolvedValue(TOTAL_SAVE_BALANCE);
    const element = createElement("c-totalBalance", {
      is: totalBalance
    });
    element.recordId = DUMMY_ACCOUNT_RECORD_ID;
    document.body.appendChild(element);
    raiseEvent();
    await flushPromises();
    let balance = element.shadowRoot.querySelector(
      "lightning-formatted-number[data-id='total-balance']"
    );
    let totalSaved = element.shadowRoot.querySelector(
      "lightning-formatted-number[data-id='amount-saved']"
    );

    expect(balance).toBeTruthy();
    expect(balance).toHaveProperty("value", "123.21");
    expect(totalSaved).toBeTruthy();
    expect(totalSaved).toHaveProperty("value", "23.21");
  });

  it("test error is displayed", async () => {
    getFinancialTotalBalance.mockRejectedValue(TOTAL_BALANCE_ERROR);
    const element = createElement("c-totalBalance", {
      is: totalBalance
    });

    element.recordId = DUMMY_ACCOUNT_RECORD_ID;
    document.body.appendChild(element);
    raiseEvent();
    await flushPromises();
    let error = element.shadowRoot.querySelector("c-error[data-id='error']");
    let balance = element.shadowRoot.querySelector(
      "lightning-formatted-number[data-id='total-balance']"
    );
    let totalSaved = element.shadowRoot.querySelector(
      "lightning-formatted-number[data-id='amount-saved']"
    );

    expect(error).toBeTruthy();
    expect(balance).toBeFalsy();
    expect(totalSaved).toBeFalsy();
  });

  it("test total financial position modal", async () => {
    getFinancialTotalBalance.mockResolvedValue(TOTAL_BALANCE);
    getFinancialTotalSaved.mockResolvedValue(TOTAL_SAVE_BALANCE);
    const element = createElement("c-totalBalance", {
      is: totalBalance
    });
    element.recordId = DUMMY_ACCOUNT_RECORD_ID;
    document.body.appendChild(element);
    raiseEvent();
    await flushPromises();

    let balance = element.shadowRoot.querySelector(
      "lightning-formatted-number[data-id='total-balance']"
    );
    let infoButton = element.shadowRoot.querySelector(
      "lightning-icon[data-id='total-fin-position']"
    );

    expect(balance).toBeTruthy();
    expect(infoButton).toBeTruthy();
    infoButton.click();

    return Promise.resolve().then(() => {
      let finPositionModal = element.shadowRoot.querySelector(
        "section[data-id='fin-position-modal']"
      );
      expect(finPositionModal).toBeTruthy();
    });
  });

  it("test total saved modal", async () => {
    getFinancialTotalBalance.mockResolvedValue(TOTAL_BALANCE);
    getFinancialTotalSaved.mockResolvedValue(TOTAL_SAVE_BALANCE);
    const element = createElement("c-totalBalance", {
      is: totalBalance
    });

    element.recordId = DUMMY_ACCOUNT_RECORD_ID;
    document.body.appendChild(element);
    raiseEvent();
    await flushPromises();
    let totalSaved = element.shadowRoot.querySelector(
      "lightning-formatted-number[data-id='amount-saved']"
    );
    let infoButton = element.shadowRoot.querySelector(
      "lightning-icon[data-id='total-saved']"
    );

    expect(totalSaved).toBeTruthy();
    expect(infoButton).toBeTruthy();
    infoButton.click();

    return Promise.resolve().then(() => {
      let totalSavedModal = element.shadowRoot.querySelector(
        "section[data-id='total-saved-modal']"
      );
      expect(totalSavedModal).toBeTruthy();
    });
  });
});
