import { createElement } from "lwc";
import AccountClosure from "c/accountClosure";
import getPackageClosureAura from "@salesforce/apex/StravinskyController.getPackageClosureAura";

jest.mock(
  "@salesforce/apex/StravinskyController.getPackageClosureAura",
  () => ({
    default: jest.fn()
  }),
  { virtual: true }
);

const ACCOUNT_CLOSURE_RESPONSE = require("./data/response.json");

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
    getPackageClosureAura.mockResolvedValue(ACCOUNT_CLOSURE_RESPONSE);
    const element = createElement("c-account-closure", {
      is: AccountClosure
    });
    // element.goalData = ACCOUNT_CLOSURE_RESPONSE;
    document.body.appendChild(element);

    let closeButton = element.shadowRoot.querySelector(
      "lightning-button[data-id='close-account-button']"
    );
    expect(closeButton).toBeTruthy();
    closeButton.click();
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
