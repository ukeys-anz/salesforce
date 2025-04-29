import financialAccount from "c/financialAccount";
import { createElement } from "lwc";
const accountData = require("./data/accountData.json");

describe("c-financialAccount", () => {
  //clean the dom and mocks in between test runs
  afterEach(() => {
    while (document.body.firstChild) {
      document.body.removeChild(document.body.firstChild);
    }
    jest.clearAllMocks();
  });

  it("test fin account success", () => {
    const element = createElement("c-financialAccount", {
      is: financialAccount
    });
    element.accountDetails = accountData;
    document.body.appendChild(element);
    let accountName = element.shadowRoot.querySelector(
      "span[data-id='account-name']"
    );
    let finAccount = element.shadowRoot.querySelector(
      "div[data-id='fin-account']"
    );
    expect(accountName.textContent).toMatch("Joe Root");
    expect(finAccount).toBeTruthy();
  });

  it("tests fin accounts not displayed", () => {
    const element = createElement("c-financialAccount", {
      is: financialAccount
    });
    element.accountType = "Savings";
    element.accountDetails = [];
    document.body.appendChild(element);
    let finAccount = element.shadowRoot.querySelector(
      "div[data-id='fin-account']"
    );
    expect(finAccount.textContent).toMatch(
      "All accounts closed - no longer a customer"
    );
  });
});
