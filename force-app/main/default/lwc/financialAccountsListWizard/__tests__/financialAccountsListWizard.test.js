import { createElement } from "lwc";
import FinancialAccountsListWizard from "c/financialAccountsListWizard";
import { getRecord } from "lightning/uiRecordApi";
import getFilteredFinancialAccounts from "@salesforce/apex/AccountClosureWizardController.getFilteredFinancialAccounts";
const getWiredRecord = require("./data/getWiredRecord.json");
const finAccountData = require("./data/finAccountData.json");

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
  beforeEach(() => {
    const element = createElement("c-financial-accounts-list-wizard", {
      is: FinancialAccountsListWizard
    });
    document.body.appendChild(element);
  });

  afterEach(() => {
    while (document.body.firstChild) {
      document.body.removeChild(document.body.firstChild);
    }
    jest.clearAllMocks();
  });

  it("spinner should not load when no financial accounts getting fetched", () => {
    const element = document.querySelector("c-financial-accounts-list-wizard");
    getFilteredFinancialAccounts.mockResolvedValue([]);

    return Promise.resolve().then(() => {
      const spinner = element.shadowRoot.querySelector(
        "lightning-spinner[data-id='loading']"
      );
      expect(spinner).toBeNull();
    });
  });

  it("spinner should load when financial accounts getting fetched", () => {
    getFilteredFinancialAccounts.mockResolvedValue(finAccountData);
    const element = document.querySelector("c-financial-accounts-list-wizard");
    getRecord.emit(getWiredRecord);

    return Promise.resolve().then(() => {
      const spinner = element.shadowRoot.querySelector(
        "lightning-spinner[data-id='loading']"
      );
      expect(spinner).not.toBeNull();
    });
  });

  it("financial accounts fetched from mock", () => {
    getFilteredFinancialAccounts.mockResolvedValue(finAccountData);
    document.querySelector("c-financial-accounts-list-wizard");
    getRecord.emit(getWiredRecord);

    return Promise.resolve().then(() => {
      expect(getFilteredFinancialAccounts).toHaveBeenCalled();
    });
  });
});
