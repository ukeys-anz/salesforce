import { createElement } from "lwc";
import HomeLoanAccount from "c/homeLoanAccount";
import getHomeLoanFinancialAccountId from "@salesforce/apex/HomeLoanController.getLinkedHomeLoanFinancialAccountRole";
import getAccountOwnerIds from "@salesforce/apex/HomeLoanController.getAccountOwnerIds";
import { setImmediate } from "timers";

const Loan_Data = require("./data/mock_homeloanaccounts.json").accounts;
const FIN_ACCOUNT_ROLE = require("./data/finAccountRole.json");
const Offset_Data = require("./data/mock_viewOffset.json");
const ACCOUNT_OWNERS = require("./data/accountOwners.json");

jest.mock(
  "@salesforce/apex/HomeLoanController.getLinkedHomeLoanFinancialAccountRole",
  () => {
    return {
      default: jest.fn()
    };
  },
  { virtual: true }
);

jest.mock(
  "@salesforce/apex/HomeLoanController.getAccountOwnerIds",
  () => {
    return {
      default: jest.fn()
    };
  },
  { virtual: true }
);

describe("c-home-loan-account", () => {
  //clean the dom and mocks in between test runs
  beforeEach(() => {
    jest.resetAllMocks();
    while (document.body.firstChild) {
      document.body.removeChild(document.body.firstChild);
    }
  });
  afterEach(() => {
    while (document.body.firstChild) {
      document.body.removeChild(document.body.firstChild);
    }
    jest.clearAllMocks();
  });

  function flushPromises() {
    return new Promise((resolve) => setImmediate(resolve));
  }

  it("test home loan is visible on account", () => {
    getHomeLoanFinancialAccountId.mockResolvedValue(FIN_ACCOUNT_ROLE);
    const element = createElement("c-home-loan-account", {
      is: HomeLoanAccount
    });

    element.objectApiName = "Account";
    element.accountDetails = JSON.stringify(Loan_Data);
    document.body.appendChild(element);

    return flushPromises().then(() => {
      let loanCard = element.shadowRoot.querySelector(
        "div[data-id='fin-account']"
      );
      expect(loanCard).toBeTruthy();
    });
  });

  it("test showing home loan account details", () => {
    getHomeLoanFinancialAccountId.mockResolvedValue(FIN_ACCOUNT_ROLE);
    getAccountOwnerIds.mockResolvedValue(ACCOUNT_OWNERS);
    const element = createElement("c-home-loan-account", {
      is: HomeLoanAccount
    });

    element.objectApiName = "FinServ__FinancialAccount__c";
    element.accountDetails = JSON.stringify(Loan_Data);
    document.body.appendChild(element);

    return flushPromises().then(() => {
      let loanDetails = element.shadowRoot.querySelector(
        "div[data-id='fin-details']"
      );
      expect(loanDetails).toBeTruthy();
    });
  });

  it("test showing offset loan account details", () => {
    getHomeLoanFinancialAccountId.mockResolvedValue(FIN_ACCOUNT_ROLE);
    getAccountOwnerIds.mockResolvedValue(ACCOUNT_OWNERS);
    const element = createElement("c-home-loan-account", {
      is: HomeLoanAccount
    });

    element.objectApiName = "Account";
    element.accountDetails = JSON.stringify(Loan_Data);
    element.offsetDetails = Offset_Data;
    document.body.appendChild(element);

    return flushPromises().then(() => {
      let offsetCard = element.shadowRoot.querySelector(
        "div[data-id='offsetAccountDetails']"
      );
      expect(offsetCard).toBeTruthy();
    });
  });

  it("test showing offset financial account details", () => {
    getHomeLoanFinancialAccountId.mockResolvedValue(FIN_ACCOUNT_ROLE);
    getAccountOwnerIds.mockResolvedValue(ACCOUNT_OWNERS);
    const element = createElement("c-home-loan-account", {
      is: HomeLoanAccount
    });

    element.objectApiName = "FinServ__FinancialAccount__c";
    element.accountDetails = JSON.stringify(Loan_Data);
    element.offsetDetails = Offset_Data;
    document.body.appendChild(element);

    return flushPromises().then(() => {
      let offsetCard = element.shadowRoot.querySelector(
        "div[data-id='offsetAccounts']"
      );
      expect(offsetCard).toBeTruthy();
    });
  });
});
