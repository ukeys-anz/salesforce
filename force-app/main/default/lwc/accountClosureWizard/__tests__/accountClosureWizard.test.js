import { createElement } from "lwc";
import AccountClosureWizard from "c/accountClosureWizard";
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

describe("c-account-closure-wizard", () => {
  afterEach(() => {
    // The jsdom instance is shared across test cases in a single file so reset the DOM
    while (document.body.firstChild) {
      document.body.removeChild(document.body.firstChild);
    }
    jest.clearAllMocks();
  });

  it("Test Case: No Financial Accounts are Available", () => {
    // Arrange
    getFilteredFinancialAccounts.mockResolvedValue([]);
    const element = createElement("c-account-closure-wizard", {
      is: AccountClosureWizard
    });
    // Act
    document.body.appendChild(element);

    return Promise.resolve().then(() => {
      // Assert that the message is rendered
      const heading = element.shadowRoot.querySelector(
        "h1.slds-text-color_weak"
      );
      expect(heading.textContent).toBe(
        "No Available Financial Accounts to Close"
      );
    });
  });
});
