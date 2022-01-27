import totalBalance from "c/totalBalance";
import { createElement } from "lwc";

const TOTAL_BALANCE = "123.21";
const TOTAL_SAVED = "288.22";

describe("c-totalBalance", () => {
  //clean the dom and mocks in between test runs
  afterEach(() => {
    while (document.body.firstChild) {
      document.body.removeChild(document.body.firstChild);
    }
    jest.clearAllMocks();
  });

  it("test balances are displayed", () => {
    const element = createElement("c-totalBalance", {
      is: totalBalance
    });
    element.totalBalance = TOTAL_BALANCE;
    element.totalSaved = TOTAL_SAVED;
    document.body.appendChild(element);

    let balance = element.shadowRoot.querySelector(
      "lightning-formatted-number[data-id='total-balance']"
    );
    let totalSaved = element.shadowRoot.querySelector(
      "lightning-formatted-number[data-id='amount-saved']"
    );

    expect(balance).toBeTruthy();
    expect(balance).toHaveProperty("value", "123.21");
    expect(totalSaved).toBeTruthy();
    expect(totalSaved).toHaveProperty("value", "288.22");
  });

  it("test error is displayed", () => {
    const element = createElement("c-totalBalance", {
      is: totalBalance
    });
    element.error = "An error has occurred";
    document.body.appendChild(element);

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

  it("test total financial position modal", () => {
    const element = createElement("c-totalBalance", {
      is: totalBalance
    });
    element.totalBalance = TOTAL_BALANCE;
    element.totalSaved = TOTAL_SAVED;

    document.body.appendChild(element);

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

  it("test total saved modal", () => {
    const element = createElement("c-totalBalance", {
      is: totalBalance
    });
    element.totalBalance = TOTAL_BALANCE;
    element.totalSaved = TOTAL_SAVED;

    document.body.appendChild(element);

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
