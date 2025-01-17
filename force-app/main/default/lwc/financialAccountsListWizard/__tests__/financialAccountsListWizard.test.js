import { createElement } from "lwc";
import FinancialAccountsListWizard from "c/financialAccountsListWizard";
import getFilteredFinancialAccounts from "@salesforce/apex/AccountClosureWizardController.getFilteredFinancialAccounts";

jest.mock(
  "@salesforce/apex/AccountClosureWizardController.getFilteredFinancialAccounts",
  () => {
    return {
      default: jest.fn()
    };
  },
  { virtual: true }
);

describe("c-financial-accounts-list-wizard", () => {
  afterEach(() => {
    // The jsdom instance is shared across test cases in a single file so reset the DOM
    while (document.body.firstChild) {
      document.body.removeChild(document.body.firstChild);
    }
  });

  it("Test Case: No Financial Accounts are Available", () => {
    // Arrange
    getFilteredFinancialAccounts.mockResolvedValue([]);
    const element = createElement("c-financial-accounts-list-wizard", {
      is: FinancialAccountsListWizard
    });
    // Act
    document.body.appendChild(element);

    return Promise.resolve().then(() => {
      let heading = element.shadowRoot.querySelector(
        "h1[data-id='noaccounts']"
      );
      expect(heading.textContent).toBe(
        "No Available Financial Accounts to Close"
      );
    });
  });
});
