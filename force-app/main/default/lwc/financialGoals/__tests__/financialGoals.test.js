import financialGoals from "c/financialGoals";
import { createElement } from "lwc";
import getAccounts from "@salesforce/apex/GetAccountsAndGoals.getAccounts";

import { subscribe } from "lightning/messageService";

jest.mock(
  "@salesforce/apex/GetAccountsAndGoals.getAccounts",
  () => {
    return {
      default: jest.fn()
    };
  },
  { virtual: true }
);

const APEX_FGOALS_SUCCESS = [
  {
    Id: "a0c2O00000197sUQAQ",
    name: "Savings",
    accountNumber: "12312312",
    targetAmount: 50,
    currentBalance: 50,
    startDate: "2021-03-05T04:56:48.000+0000",
    targetDate: "2021-03-05T04:56:48.000+0000"
  }
];

const APEX_FGOALS_EMPTY_RECORD = [
  {
    Id: null,
    name: null,
    accountNumber: null,
    targetAmount: null,
    currentBalance: null,
    startDate: null,
    targetDate: null
  }
];

const APEX_FGOALS_ERROR = {
  body: { message: "An internal server error has occurred" },
  ok: false,
  status: 400,
  statusText: "Bad Request"
};

describe("c-financialGoals", () => {
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

  it("test loader", () => {
    const element = createElement("c-financialGoals", {
      is: financialGoals
    });
    document.body.appendChild(element);
    return flushPromises()
      .then(() => {})
      .then(() => {
        const mainEle = element.shadowRoot.querySelector("lightning-spinner");
        expect(mainEle).not.toBeNull();
      });
  });

  it("test subscribe is invoked", () => {
    getAccounts.mockResolvedValue(APEX_FGOALS_SUCCESS);
    const element = createElement("c-financialGoals", {
      is: financialGoals
    });
    document.body.appendChild(element);

    return Promise.resolve().then(() => {
      expect(subscribe).toHaveBeenCalled();
    });
  });

  it("test fetch account with Apex error", () => {
    getAccounts.mockRejectedValue(APEX_FGOALS_ERROR);
    const element = createElement("c-financialGoals", {
      is: financialGoals
    });
    document.body.appendChild(element);

    return Promise.resolve().catch(() => {
      const mainEle = element.shadowRoot.querySelector("article");
      expect(mainEle).not.toBeNull();
    });
  });

  it("test fetch with empty data", () => {
    getAccounts.mockResolvedValue(APEX_FGOALS_EMPTY_RECORD);
    const element = createElement("c-financialGoals", {
      is: financialGoals
    });
    document.body.appendChild(element);

    return Promise.resolve().catch(() => {
      const mainEle = element.shadowRoot.querySelector("article");
      expect(mainEle).not.toBeNull();
    });
  });
});
