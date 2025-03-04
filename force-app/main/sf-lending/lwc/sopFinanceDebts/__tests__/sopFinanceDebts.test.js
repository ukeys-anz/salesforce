import { createElement } from "lwc";
import SopFinanceDebts from "c/sopFinanceDebts";
import { getRecord } from "lightning/uiRecordApi";

const DEBT_DATA = require("./data/debtData.json");
const PARTIES = require("./data/parties.json");
const WIRE_MOCK = require("./data/wireMock.json");

jest.mock(
  "@salesforce/customPermission/SOP_Add",
  () => ({
    __esModule: true,
    default: true
  }),
  { virtual: true }
);

jest.mock(
  "@salesforce/customPermission/SOP_Edit",
  () => ({
    __esModule: true,
    default: true
  }),
  { virtual: true }
);

describe("c-sop-finance-debts", () => {
  afterEach(() => {
    // The jsdom instance is shared across test cases in a single file so reset the DOM
    while (document.body.firstChild) {
      document.body.removeChild(document.body.firstChild);
    }
  });

  async function flushPromises() {
    return Promise.resolve();
  }

  it("test debts are visible", async () => {
    const element = createElement("c-sop-finance-debts", {
      is: SopFinanceDebts
    });
    await flushPromises();
    element.sopDebtsData = DEBT_DATA;
    element.sopPartiesData = PARTIES;
    document.body.appendChild(element);

    await flushPromises();
    let debts = element.shadowRoot.querySelector(
      "lightning-formatted-text[data-id='debtSummaryHeading']"
    );
    expect(debts).toBeTruthy();
  });

  it("test add debt button is visible", async () => {
    const element = createElement("c-sop-finance-debts", {
      is: SopFinanceDebts
    });
    await flushPromises();
    element.sopDebtsData = DEBT_DATA;
    element.sopPartiesData = PARTIES;
    document.body.appendChild(element);
    getRecord.emit(WIRE_MOCK);

    await flushPromises();
    let debts = element.shadowRoot.querySelector(
      "lightning-formatted-text[data-id='debtSummaryHeading']"
    );
    expect(debts).toBeTruthy();

    let addBtn = element.shadowRoot.querySelector(
      "lightning-button[data-id='addBtn']"
    );
    expect(addBtn).toBeTruthy();
  });

  it("test edit debt button is visible", async () => {
    const element = createElement("c-sop-finance-debts", {
      is: SopFinanceDebts
    });
    await flushPromises();
    element.sopDebtsData = DEBT_DATA;
    element.sopPartiesData = PARTIES;
    document.body.appendChild(element);
    getRecord.emit(WIRE_MOCK);

    await flushPromises();
    let debts = element.shadowRoot.querySelector(
      "lightning-formatted-text[data-id='debtSummaryHeading']"
    );
    expect(debts).toBeTruthy();

    let editBtn = element.shadowRoot.querySelector(
      "lightning-button[data-jest-id='editBtn']"
    );
    expect(editBtn).toBeTruthy();
  });
});
