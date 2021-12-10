import { createElement } from "lwc";
import PersonAccountFinancialDetails from "c/personAccountFinancialDetails";

describe("c-person-account-financial-details", () => {
  afterEach(() => {
    // The jsdom instance is shared across test cases in a single file so reset the DOM
    while (document.body.firstChild) {
      document.body.removeChild(document.body.firstChild);
    }
    jest.clearAllMocks();
  });

  it("tests the components are displayed", () => {
    const element = createElement("c-person-account-financial-details", {
      is: PersonAccountFinancialDetails
    });
    document.body.appendChild(element);
    let totalBalance = element.shadowRoot.querySelector(
      "c-total-balance[data-id='total-balance']"
    );
    let checkingAccount = element.shadowRoot.querySelector(
      "c-financial-account[data-id='checking-account']"
    );
    let savingsAccount = element.shadowRoot.querySelector(
      "c-financial-account[data-id='savings-account']"
    );
    let financialGoals = element.shadowRoot.querySelector(
      "c-financial-goals[data-id='financial-goals']"
    );

    expect(totalBalance).toBeTruthy();
    expect(checkingAccount).toBeTruthy();
    expect(savingsAccount).toBeTruthy();
    expect(financialGoals).toBeTruthy();
  });

  it("tests refresh button is clicked", () => {
    const element = createElement("c-person-account-financial-details", {
      is: PersonAccountFinancialDetails
    });
    document.body.appendChild(element);
    const totalBalance = element.shadowRoot.querySelector(
      "c-total-balance[data-id='total-balance']"
    );
    const checkingAccount = element.shadowRoot.querySelector(
      "c-financial-account[data-id='checking-account']"
    );
    const savingsAccount = element.shadowRoot.querySelector(
      "c-financial-account[data-id='savings-account']"
    );
    const financialGoals = element.shadowRoot.querySelector(
      "c-financial-goals[data-id='financial-goals']"
    );

    expect(totalBalance).toBeTruthy();
    expect(checkingAccount).toBeTruthy();
    expect(savingsAccount).toBeTruthy();
    expect(financialGoals).toBeTruthy();

    let refreshButton = element.shadowRoot.querySelector(
      "button[data-id='refresh']"
    );
    expect(refreshButton).toBeTruthy();
    refreshButton.click();

    return Promise.resolve()
      .then(() => {
        let loadingSpinner = element.shadowRoot.querySelector(
          "div[data-id='loading-spinner']"
        );
        expect(loadingSpinner).toBeTruthy();
      })
      .then(() => {
        expect(totalBalance).toBeTruthy();
        expect(checkingAccount).toBeTruthy();
        expect(savingsAccount).toBeTruthy();
        expect(financialGoals).toBeTruthy();
      });
  });
});
