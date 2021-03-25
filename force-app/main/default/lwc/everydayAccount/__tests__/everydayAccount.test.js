import everydayAccount from "c/everydayAccount";
import { createElement } from "lwc";
import getFinancialAccounts from "@salesforce/apex/FinancialAccountController.getFinancialAccounts";

import { publish, subscribe, MessageContext } from "lightning/messageService";
import {
  registerLdsTestWireAdapter,
  registerTestWireAdapter
} from "@salesforce/sfdx-lwc-jest";
import UpdateAccounts from "@salesforce/messageChannel/FinancialAccountsUpdate__c";
import TriggerLoading from "@salesforce/messageChannel/FinancialAccountsTriggerLoading__c";

jest.mock(
  "@salesforce/apex/FinancialAccountController.getFinancialAccounts",
  () => {
    return {
      default: jest.fn()
    };
  },
  { virtual: true }
);

const APEX_FACCOUNTS_SUCCESS = [
  {
    Id: "a0c2O00000197sUQAA",
    FinServ__Balance__c: 50,
    FinServ__CurrentPostedBalance__c: 50,
    FinServ__Status__c: "Closed",
    LastModifiedDate: "2021-01-05T04:56:48.000+0000"
  },
  {
    Id: "a0c2O00000197sUQAB",
    FinServ__Balance__c: 50,
    FinServ__CurrentPostedBalance__c: 50,
    FinServ__Status__c: "Open",
    LastModifiedDate: "2021-01-05T04:56:48.000+0000"
  },
  {
    Id: "a0c2O00000197sUQAC",
    FinServ__Balance__c: 50,
    FinServ__CurrentPostedBalance__c: 50,
    LastModifiedDate: "2021-01-05T04:56:48.000+0000"
  },
  {
    Id: "a0c2O00000197sUQAD",
    FinServ__Balance__c: 50,
    FinServ__CurrentPostedBalance__c: 50,
    LastModifiedDate: "2021-01-05T04:56:48.000+0000"
  }
];

const APEX_FACCOUNTS_EMPTY = [
  {
    Id: "",
    FinServ__Balance__c: null,
    FinServ__CurrentPostedBalance__c: null,
    FinServ__Status__c: null,
    LastModifiedDate: null
  }
];

const APEX_FACCOUNTS_NO_RECORD = [];

const APEX_FACCOUNTS_ERROR = {
  body: { message: "An internal server error has occurred" },
  ok: false,
  status: 400,
  statusText: "Bad Request"
};

const messageContextWireAdapter = registerTestWireAdapter(MessageContext);

describe("c-everydayAccount", () => {
  //clean the dom and mocks in between test runs
  afterEach(() => {
    while (document.body.firstChild) {
      document.body.removeChild(document.body.firstChild);
    }
    jest.clearAllMocks();
  });

  it("test loading section", () => {
    getFinancialAccounts.mockResolvedValue(APEX_FACCOUNTS_SUCCESS);
    const element = createElement("c-everydayAccount", {
      is: everydayAccount
    });
    element.accountType = "Checking";
    document.body.appendChild(element);
    const loadingEle = element.shadowRoot.querySelector("lightning-spinner");

    return Promise.resolve().then(() => {
      expect(loadingEle).not.toBeNull();
    });
  });

  it("test loading triggering", () => {
    getFinancialAccounts.mockResolvedValue(APEX_FACCOUNTS_SUCCESS);
    const element = createElement("c-everydayAccount", {
      is: everydayAccount
    });
    element.accountType = "Savings";
    document.body.appendChild(element);

    const payload = {
      update: true
    };
    publish(messageContextWireAdapter, TriggerLoading, payload);

    const loadingEle = element.shadowRoot.querySelector("lightning-spinner");

    return Promise.resolve().then(() => {
      expect(loadingEle).not.toBeNull();
    });
  });

  it("test subscribe is invoked", () => {
    getFinancialAccounts.mockResolvedValue(APEX_FACCOUNTS_SUCCESS);
    const element = createElement("c-everydayAccount", {
      is: everydayAccount
    });
    element.accountType = "Savings";
    document.body.appendChild(element);
    const loadingEle = element.shadowRoot.querySelector("lightning-spinner");

    return Promise.resolve().then(() => {
      expect(subscribe).toHaveBeenCalled();
    });
  });

  it("test UpdateAccountsAndGoals triggering", () => {
    getFinancialAccounts.mockResolvedValue(APEX_FACCOUNTS_SUCCESS);
    const element = createElement("c-everydayAccount", {
      is: everydayAccount
    });
    element.accountType = "Checking";
    document.body.appendChild(element);

    const payload = {
      update: true
    };
    publish(messageContextWireAdapter, UpdateAccounts, payload);

    return Promise.resolve().then(() => {
      const mainEle = element.shadowRoot.querySelector("article");
      expect(mainEle).not.toBeNull();
    });
  });

  it("test UpdateAccountsAndGoals Apex failure", () => {
    getFinancialAccounts.mockRejectedValue(APEX_FACCOUNTS_ERROR);
    const element = createElement("c-everydayAccount", {
      is: everydayAccount
    });
    element.accountType = "Checking";
    document.body.appendChild(element);

    const payload = {
      update: true
    };
    publish(messageContextWireAdapter, UpdateAccounts, payload);

    return Promise.resolve().catch(() => {
      const mainEle = element.shadowRoot.querySelector("article");
      expect(mainEle).not.toBeNull();
    });
  });

  it("test UpdateAccountsAndGoals failed", () => {
    getFinancialAccounts.mockResolvedValue(APEX_FACCOUNTS_SUCCESS);
    const element = createElement("c-everydayAccount", {
      is: everydayAccount
    });
    element.accountType = "Checking";
    document.body.appendChild(element);

    const payload = {
      message: "test message"
    };
    publish(messageContextWireAdapter, UpdateAccounts, payload);

    return Promise.resolve()
      .then(() => {})
      .then(() => {
        const mainEle = element.shadowRoot.querySelector("article");
        expect(mainEle).not.toBeNull();
      });
  });

  it("test UpdateAccountsAndGoals with empty record", () => {
    getFinancialAccounts.mockResolvedValue(APEX_FACCOUNTS_EMPTY);
    const element = createElement("c-everydayAccount", {
      is: everydayAccount
    });
    element.accountType = "Savings";
    document.body.appendChild(element);

    const payload = {
      update: true
    };
    publish(messageContextWireAdapter, UpdateAccounts, payload);

    return Promise.resolve()
      .then(() => {})
      .then(() => {
        const mainEle = element.shadowRoot.querySelector("article");
        expect(mainEle).not.toBeNull();
      });
  });

  it("test UpdateAccountsAndGoals with no record", () => {
    getFinancialAccounts.mockResolvedValue(APEX_FACCOUNTS_NO_RECORD);
    const element = createElement("c-everydayAccount", {
      is: everydayAccount
    });
    element.accountType = "Checking";
    document.body.appendChild(element);

    const payload = {
      update: true
    };
    publish(messageContextWireAdapter, UpdateAccounts, payload);

    return Promise.resolve()
      .then(() => {})
      .then(() => {
        const mainEle = element.shadowRoot.querySelector("article");
        expect(mainEle).not.toBeNull();
      });
  });
});
