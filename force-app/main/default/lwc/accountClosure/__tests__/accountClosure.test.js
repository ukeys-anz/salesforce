import { createElement } from "lwc";
import AccountClosure from "c/accountClosure";
import getPackageClosureAuraFlex from "@salesforce/apex/StravinskyController.getPackageClosureAuraFlex";
import fetchFinancialAccounts from "@salesforce/apex/StravinskyController.fetchFinancialAccounts";
import { setImmediate } from "timers";

jest.mock(
  "@salesforce/apex/StravinskyController.getPackageClosureAuraFlex",
  () => ({
    default: jest.fn()
  }),
  { virtual: true }
);

jest.mock(
  "@salesforce/apex/StravinskyController.fetchFinancialAccounts",
  () => ({
    default: jest.fn()
  }),
  { virtual: true }
);

const ACCOUNT_CLOSURE_RESPONSE = require("./data/response.json");
const FETCH_FINANCIAL_ACCOUNTS = require("./data/financialaccounts.json");

describe("c-account-closure", () => {
  afterEach(() => {
    // DOM instance is shared across tests so reset after each test.
    while (document.body.firstChild) {
      document.body.removeChild(document.body.firstChild);
    }
  });

  function flushPromises() {
    return new Promise((resolve) => setImmediate(resolve));
  }

  it("Check Close Package button visible", async () => {
    fetchFinancialAccounts.mockResolvedValue(FETCH_FINANCIAL_ACCOUNTS);
    getPackageClosureAuraFlex.mockResolvedValue(ACCOUNT_CLOSURE_RESPONSE);
    const element = createElement("c-account-closure", {
      is: AccountClosure
    });
    // element.goalData = ACCOUNT_CLOSURE_RESPONSE;
    document.body.appendChild(element);
    expect(element);
    let closeButton = element.shadowRoot.querySelector(
      "lightning-button[data-id='close-account-button']"
    );
    expect(closeButton).toBeTruthy();
    closeButton.click();
    await flushPromises();

    let combobox = element.shadowRoot.querySelector(
      "lightning-combobox[data-id='combobox']"
    );
    expect(combobox).toBeTruthy();
    combobox.value = "391074663";
    combobox.dispatchEvent(
      new CustomEvent("change", { detail: { value: "391074663" } })
    );

    let nextButton = element.shadowRoot.querySelector(
      "button[data-id='next-button']"
    );
    expect(nextButton).toBeTruthy();
    nextButton.click();
    await flushPromises();

    closeButton = element.shadowRoot.querySelector(
      "button[data-id='close-button']"
    );
    expect(closeButton).toBeTruthy();
    closeButton.click();
    await flushPromises();

    let anzPlusValue = element.shadowRoot.querySelector(
      "p[data-id='anz-plus-value']"
    );
    let anzSaveValue = element.shadowRoot.querySelector(
      "p[data-id='anz-save-value']"
    );
    let cardValue = element.shadowRoot.querySelector("p[data-id='card-value']");
    let packageValue = element.shadowRoot.querySelector(
      "p[data-id='package-value']"
    );

    expect(anzPlusValue.textContent).toBe("Success");
    expect(anzSaveValue.textContent).toBe("Success");
    expect(cardValue.textContent).toBe("Success");
    expect(packageValue.textContent).toBe("Success");
  });
});
