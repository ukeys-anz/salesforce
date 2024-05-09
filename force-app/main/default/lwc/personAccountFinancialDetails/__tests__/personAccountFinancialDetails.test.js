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
    element.objectApiName = "FinServ__FinancialAccount__c";
    document.body.appendChild(element);

    let checkingAccount = element.shadowRoot.querySelector(
      "c-financial-account[data-id='checking-account']"
    );
    let savingsAccount = element.shadowRoot.querySelector(
      "c-financial-account[data-id='savings-account']"
    );

    let homeAccount = element.shadowRoot.querySelector(
      "c-home-loan-account[data-id='home-account']"
    );

    expect(checkingAccount).toBeTruthy();
    expect(savingsAccount).toBeTruthy();
    expect(homeAccount).toBeTruthy();
  });
});
