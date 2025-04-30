import { createElement } from "lwc";
import SopFinanceIncomes from "c/sopFinanceIncomes";
import { getRecord } from "lightning/uiRecordApi";

const INCOME_DATA = require("./data/incomeData.json");
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

jest.mock(
  "@salesforce/customPermission/SOP_Delete",
  () => ({
    __esModule: true,
    default: true
  }),
  { virtual: true }
);

describe("c-sop-finance-incomes", () => {
  afterEach(() => {
    // Clean up the DOM after each test
    while (document.body.firstChild) {
      document.body.removeChild(document.body.firstChild);
    }
    jest.clearAllMocks();
  });

  async function flushPromises() {
    return Promise.resolve();
  }

  it("renders the component", async () => {
    const element = createElement("c-sop-finance-incomes", {
      is: SopFinanceIncomes
    });
    await flushPromises();
    element.sopIncomeData = INCOME_DATA;
    document.body.appendChild(element);
    getRecord.emit(WIRE_MOCK);

    await flushPromises();

    let incomes = element.shadowRoot.querySelector(
      "lightning-formatted-number[data-id='totalIncome']"
    );
    expect(incomes).toBeTruthy();

    let addBtn = element.shadowRoot.querySelector(
      "lightning-button[data-jest-id='addBtn']"
    );
    expect(addBtn).toBeTruthy();

    let editBtn = element.shadowRoot.querySelector(
      "lightning-button[data-jest-id='editBtn']"
    );
    expect(editBtn).toBeTruthy();

    let deleteBtn = element.shadowRoot.querySelector(
      "lightning-button[data-jest-id='deleteBtn']"
    );
    expect(deleteBtn).toBeTruthy();
  });
});
