import accountBalances from "c/accountBalances";
import { createElement } from "lwc";
import getBalances from "@salesforce/apex/AccountBalancesController.getBalances";
import { publish, subscribe } from "lightning/messageService";
import { createTestWireAdapter } from "@salesforce/wire-service-jest-util";
import { setImmediate } from "timers";

import UpdateAccountsBalance from "@salesforce/messageChannel/FinancialAccountsBalanceUpdate__c";
import TriggerBalanceLoading from "@salesforce/messageChannel/FinancialAccountsTriggerBalanceLoading__c";

jest.mock(
  "@salesforce/apex/AccountBalancesController.getBalances",
  () => {
    return {
      default: jest.fn()
    };
  },
  { virtual: true }
);

const APEX_FACCOUNTS_SUCCESS = [
  {
    Id: "a0c2O00000197sUQAQ",
    FinServ__Balance__c: 50,
    LastModifiedDate: "2021-01-05T04:56:48.000+0000"
  }
];

const APEX_FACCOUNTS_EMPTY = [
  {
    Id: "",
    FinServ__Balance__c: null,
    LastModifiedDate: null
  }
];

const APEX_FACCOUNTS_NO_RECORD = [];

// Sample error for imperative Apex call
const APEX_FACCOUNTS_ERROR = {
  body: { message: "An internal server error has occurred" },
  ok: false,
  status: 400,
  statusText: "Bad Request"
};

const MessageContext = createTestWireAdapter();

describe("c-accountsBalances", () => {
  //clean the dom and mocks in between test runs
  afterEach(() => {
    while (document.body.firstChild) {
      document.body.removeChild(document.body.firstChild);
    }
    jest.clearAllMocks();
  });

  function flushPromises() {
    return new Promise((resolve) => setImmediate(resolve));
  }

  it("test default section", () => {
    getBalances.mockResolvedValue(APEX_FACCOUNTS_SUCCESS);

    const element = createElement("c-account-balances", {
      is: accountBalances
    });
    document.body.appendChild(element);

    const loadingEle = element.shadowRoot.querySelector("lightning-spinner");

    return Promise.resolve().then(() => {
      expect(loadingEle).not.toBeNull();
    });
  });

  it("test loading secenario", () => {
    getBalances.mockResolvedValue(APEX_FACCOUNTS_SUCCESS);

    const element = createElement("c-account-balances", {
      is: accountBalances
    });
    document.body.appendChild(element);

    const payload = {
      update: true
    };
    publish(MessageContext, TriggerBalanceLoading, payload);

    return Promise.resolve().then(() => {
      const loadingEle = element.shadowRoot.querySelector("lightning-spinner");
      expect(loadingEle).not.toBeNull();
    });
  });

  it("registers the LMS subscriber during the component lifecycle", () => {
    getBalances.mockResolvedValue(APEX_FACCOUNTS_SUCCESS);

    const element = createElement("c-account-balances", {
      is: accountBalances
    });
    document.body.appendChild(element);

    return Promise.resolve().then(() => {
      expect(subscribe).toHaveBeenCalled();
    });
  });

  it("test update accounts and goals secenario", () => {
    getBalances.mockResolvedValue(APEX_FACCOUNTS_SUCCESS);

    const element = createElement("c-account-balances", {
      is: accountBalances
    });
    document.body.appendChild(element);

    const payload = {
      update: true
    };

    publish(MessageContext, UpdateAccountsBalance, payload);

    return flushPromises().then(() => {
      const balanceEle = element.shadowRoot.querySelector("article");
      expect(balanceEle).not.toBeNull();
    });
  });

  it("test update accounts and goals secenario with error message", () => {
    getBalances.mockResolvedValue(APEX_FACCOUNTS_SUCCESS);

    const element = createElement("c-account-balances", {
      is: accountBalances
    });
    document.body.appendChild(element);

    const payload = {
      message: "test error message"
    };

    publish(MessageContext, UpdateAccountsBalance, payload);

    return flushPromises().then(() => {
      const balanceEle = element.shadowRoot.querySelector("article");
      expect(balanceEle).not.toBeNull();
    });
  });

  it("test update accounts and goals secenario with Apex failures", () => {
    getBalances.mockRejectedValue(APEX_FACCOUNTS_ERROR);

    const element = createElement("c-account-balances", {
      is: accountBalances
    });
    document.body.appendChild(element);

    const payload = {
      message: "test error message"
    };

    publish(MessageContext, UpdateAccountsBalance, payload);

    return flushPromises().then(() => {
      let div = element.shadowRoot.querySelector(
        "div[data-id='balance-container']"
      );
      expect(div).toBeNull();
    });
  });

  it("test update accounts and goals secenario with empty values", () => {
    getBalances.mockResolvedValue(APEX_FACCOUNTS_EMPTY);

    const element = createElement("c-account-balances", {
      is: accountBalances
    });
    document.body.appendChild(element);

    const payload = {
      message: "test error message"
    };

    publish(MessageContext, UpdateAccountsBalance, payload);

    return flushPromises().then(() => {
      const balanceEle = element.shadowRoot.querySelector("article");
      expect(balanceEle).not.toBeNull();
    });
  });

  it("test update accounts and goals secenario with no record", () => {
    getBalances.mockResolvedValue(APEX_FACCOUNTS_NO_RECORD);

    const element = createElement("c-account-balances", {
      is: accountBalances
    });
    document.body.appendChild(element);

    const payload = {
      message: "test error message"
    };

    publish(MessageContext, UpdateAccountsBalance, payload);

    return flushPromises().then(() => {
      const balanceEle = element.shadowRoot.querySelector("article");
      expect(balanceEle).not.toBeNull();
    });
  });
});
