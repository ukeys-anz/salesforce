import { createElement } from "lwc";
import TransactionLink from "c/transactionLink";
import getFinancialAccounts from "@salesforce/apex/TransactionLinkController.getFinancialAccounts";
import getTransactionHistoryAura from "@salesforce/apex/CoachBankingAPIRepository.getTransactionHistoryAuraV2";

jest.mock(
  "@salesforce/apex/TransactionLinkController.getFinancialAccounts",
  () => ({
    default: jest.fn()
  }),
  { virtual: true }
);

jest.mock(
  "@salesforce/apex/CoachBankingAPIRepository.getTransactionHistoryAuraV2",
  () => ({
    default: jest.fn()
  }),
  { virtual: true }
);

// Helper function to wait until the microtask queue is empty. This is needed for promise
// timing when calling imperative Apex.
async function flushPromises() {
  return Promise.resolve();
}

const helper = {
  init: async (payload) => {
    getFinancialAccounts.mockResolvedValue([
      {
        Account_Number__c: "account1",
        FinServ__FinancialAccount__r: { OCV_ID__c: "ocvId" },
        Ownership__c: "Ownership1"
      }
    ]);
    getTransactionHistoryAura.mockResolvedValue({
      embedded: {
        transactions: [
          {
            transaction_id: "txn1",
            status: "POSTED_PRIORDAY",
            amount: { value: 100 }
          },
          {
            transaction_id: "txn2",
            status: "POSTED_PRIORDAY",
            amount: { value: 200 }
          }
        ]
      }
    });

    const element = createElement("c-transaction-link", {
      is: TransactionLink
    });

    Object.assign(element, payload);
    document.body.appendChild(element);
    await flushPromises();
    return element.shadowRoot;
  },
  goNext: async (root) => {
    const nextButton = root.querySelector(".nextButton");
    nextButton.click();
    await flushPromises();
    return nextButton;
  },
  dispatchEvent: ({ root, selector, eventName, payload }) => {
    const elm = root.querySelector(selector);
    elm.dispatchEvent(new CustomEvent(eventName, { detail: payload }));
  }
};

describe("c-transaction-link", () => {
  afterEach(() => {
    // The jsdom instance is shared across test cases in a single file so reset the DOM
    while (document.body.firstChild) {
      document.body.removeChild(document.body.firstChild);
    }
  });

  it("Available Accounts: Back button should be disabled", async () => {
    const root = await helper.init({ originalTxnAccs: ["account1"] });
    const backButton = root.querySelector(".backButton");
    expect(backButton).toHaveProperty("disabled", true);
  });

  it("Available Accounts: No pre-disputed Accounts - Next button should be disabled", async () => {
    const element = createElement("c-transaction-link", {
      is: TransactionLink
    });
    document.body.appendChild(element);
    const nextButton = element.shadowRoot.querySelector(".nextButton");
    expect(nextButton).toHaveProperty("disabled", true);
  });

  it("Available Accounts: One pre-disputed Account (pre-selected) - Next button should be enabled", async () => {
    const root = await helper.init({ originalTxnAccs: ["account1"] });
    const nextButton = root.querySelector(".nextButton");
    expect(nextButton).toHaveProperty("disabled", false);
  });

  it("Available Accounts: Multiple pre-disputed Accounts (no pre-selected) - Next button should be disabled", async () => {
    const root = await helper.init({
      originalTxnAccs: ["account1", "account2"]
    });
    const nextButton = root.querySelector(".nextButton");
    expect(nextButton).toHaveProperty("disabled", true);
  });

  it("Searching transactions: No pre-disputed Transactions - No new selected/removed - Next button should be disabled", async () => {
    const root = await helper.init({
      originalTxnAccs: ["account1"],
      originalTxnIds: []
    });

    const nextButton = await helper.goNext(root);
    expect(nextButton).toHaveProperty("disabled", true);
  });

  it("Searching transactions: pre-disputed Transactions - No new selected/removed, Next button should be disabled", async () => {
    const root = await helper.init({
      originalTxnAccs: ["account1"],
      originalTxnIds: ["txn1", "txn2"]
    });

    const nextButton = await helper.goNext(root);
    expect(nextButton).toHaveProperty("disabled", true);
  });

  it("Searching transactions: pre-disputed Transactions - New selected - Next button should be enabled", async () => {
    const root = await helper.init({
      originalTxnAccs: ["account1"],
      originalTxnIds: ["txn2"]
    });

    const nextButton = await helper.goNext(root);
    expect(nextButton).toHaveProperty("disabled", true);

    helper.dispatchEvent({
      root,
      selector: ".tableTxn",
      eventName: "rowselection",
      payload: {
        selectedRows: [{ TransactionId: "txn1" }, { TransactionId: "txn2" }],
        config: { action: "select" }
      }
    });
    await flushPromises();
    expect(nextButton).toHaveProperty("disabled", false);
  });

  it("Searching transactions: Search button is disabled if date range is not selected", async () => {
    const root = await helper.init({
      originalTxnAccs: ["account1"]
    });
    await helper.goNext(root);

    const searchButton = root.querySelector(".searchButton");
    expect(searchButton).toHaveProperty("disabled", true);
  });

  it("Searching transactions: Search button is enabled if valid date range is selected", async () => {
    const root = await helper.init({
      originalTxnAccs: ["account1"]
    });
    await helper.goNext(root);

    helper.dispatchEvent({
      root,
      selector: ".startDate",
      eventName: "change",
      payload: {
        value: "2022-01-01"
      }
    });
    await flushPromises();

    helper.dispatchEvent({
      root,
      selector: ".endDate",
      eventName: "change",
      payload: {
        value: "2022-02-01"
      }
    });
    await flushPromises();

    const searchButton = root.querySelector(".searchButton");
    expect(searchButton).toHaveProperty("disabled", false);
  });

  it("Searching transactions: Search button is disabled if date range exceeds 3 months", async () => {
    const root = await helper.init({
      originalTxnAccs: ["account1"]
    });
    await helper.goNext(root);

    helper.dispatchEvent({
      root,
      selector: ".startDate",
      eventName: "change",
      payload: {
        value: "2022-01-01"
      }
    });
    await flushPromises();

    helper.dispatchEvent({
      root,
      selector: ".endDate",
      eventName: "change",
      payload: {
        value: "2022-12-01"
      }
    });
    await flushPromises();

    const searchButton = root.querySelector(".searchButton");
    expect(searchButton).toHaveProperty("disabled", true);
  });

  it("Searching transactions: Reset button is disabled if date range is not selected", async () => {
    const root = await helper.init({
      originalTxnAccs: ["account1"]
    });
    await helper.goNext(root);

    const resetButton = root.querySelector(".resetButton");
    expect(resetButton).toHaveProperty("disabled", true);
  });

  it("Searching transactions: Reset button is enabled if valid date range is selected", async () => {
    const root = await helper.init({
      originalTxnAccs: ["account1"]
    });
    await helper.goNext(root);

    helper.dispatchEvent({
      root,
      selector: ".startDate",
      eventName: "change",
      payload: {
        value: "2022-01-01"
      }
    });
    await flushPromises();

    helper.dispatchEvent({
      root,
      selector: ".endDate",
      eventName: "change",
      payload: {
        value: "2022-02-01"
      }
    });
    await flushPromises();

    const resetButton = root.querySelector(".resetButton");
    expect(resetButton).toHaveProperty("disabled", false);
  });

  it(`Review transactions: pre-disputed Transactions - New selected and existing removed - 
		Next button should be enabled - 2 tables for added and removed transactions should be shown`, async () => {
    const root = await helper.init({
      originalTxnAccs: ["account1"],
      originalTxnIds: ["txn2"]
    });

    const reviewButton = await helper.goNext(root);
    expect(reviewButton).toHaveProperty("disabled", true);

    helper.dispatchEvent({
      root,
      selector: ".tableTxn",
      eventName: "rowselection",
      payload: {
        selectedRows: [{ TransactionId: "txn1" }],
        config: { action: "select" }
      }
    });
    await flushPromises();
    expect(reviewButton).toHaveProperty("disabled", false);

    const saveButton = await helper.goNext(root);
    expect(saveButton).toHaveProperty("disabled", false);

    const reviewAddedTable = root.querySelector(".reviewAddedTable");
    expect(reviewAddedTable).toBeDefined();

    const reviewRemovedTable = root.querySelector(".reviewRemovedTable");
    expect(reviewRemovedTable).toBeDefined();
  });

  it("Review transactions: Click on Save, dispaches Submit event", async () => {
    const root = await helper.init({
      originalTxnAccs: ["account1"],
      originalTxnIds: ["txn2"]
    });
    const handlerSpy = jest.spyOn(root.host, "dispatchEvent");

    await helper.goNext(root);

    helper.dispatchEvent({
      root,
      selector: ".tableTxn",
      eventName: "rowselection",
      payload: {
        selectedRows: [{ TransactionId: "txn1" }, { TransactionId: "txn2" }],
        config: { action: "select" }
      }
    });
    await flushPromises();

    await helper.goNext(root);
    await helper.goNext(root);

    const submitEvent = handlerSpy.mock.calls[0][0];
    expect(submitEvent.type).toBe("submit");
    expect(submitEvent.detail.transactions.added.length).toBe(1);
    expect(submitEvent.detail.transactions.removed.length).toBe(0);
  });
});
