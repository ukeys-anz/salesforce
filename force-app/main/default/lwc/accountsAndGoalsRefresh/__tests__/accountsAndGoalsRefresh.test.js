import accountsAndGoalsRefresh from "c/accountsAndGoalsRefresh";
import { createElement } from "lwc";
import getAccounts from "@salesforce/apex/GetAccountsAndGoals.getAccounts";
import updateAccounts from "@salesforce/apex/UpdateFinancialAccounts.updateAccounts";
import { getRecord } from "lightning/uiRecordApi";
import { publish, MessageContext } from "lightning/messageService";
import {
  registerLdsTestWireAdapter,
  registerTestWireAdapter
} from "@salesforce/sfdx-lwc-jest";
import UpdateAccounts from "@salesforce/messageChannel/FinancialAccountsUpdate__c";
import UpdateAccountsGoalsTimed from "@salesforce/messageChannel/FinancialAccountGoalsTimedUpdate__c";
import TriggerLoading from "@salesforce/messageChannel/FinancialAccountsTriggerLoading__c";

jest.mock(
  "@salesforce/apex/GetAccountsAndGoals.getAccounts",
  () => {
    return {
      default: jest.fn()
    };
  },
  { virtual: true }
);

jest.mock(
  "@salesforce/apex/UpdateFinancialAccounts.updateAccounts",
  () => {
    return {
      default: jest.fn()
    };
  },
  { virtual: true }
);

const mockGetRecord = require("./data/getRecord.json");

const APEX_ACCOUNTS_SUCCESS =
  '{"accountList":[{"name":"test acc","balance":{"value":"50"},"currentBalance":{"value":"50"},"accountType":"Savings","goal":{"name":"test goal","accountNumber":"test 123","targetAmount":{"value":"100"},"iconId":"icon123","startDate":"2020-01-01","targetDate":"2020-12-30"}}]}';

const APEX_UPDATE_ACCOUNTS_SUCCESS = [
  {
    Id: "a0c2O00000197sUQAA",
    FinServ__Balance__c: 50,
    FinServ__CurrentPostedBalance__c: 50,
    FinServ__Status__c: "Closed",
    LastModifiedDate: "2021-01-05T04:56:48.000+0000"
  }
];

// Sample error for imperative Apex call
const APEX_ACCOUNTS_ERROR = {
  body: { message: "An internal server error has occurred" },
  ok: false,
  status: 400,
  statusText: "Bad Request"
};

const messageContextWireAdapter = registerTestWireAdapter(MessageContext);
const getRecordAdapter = registerLdsTestWireAdapter(getRecord);

describe("c-accountsAndGoalsRefresh", () => {
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

  it("test button text", () => {
    const element = createElement("c-accountsAndGoalsRefresh", {
      is: accountsAndGoalsRefresh
    });
    document.body.appendChild(element);
    const btnEle = element.shadowRoot.querySelector("button");

    return Promise.resolve().then(() => {
      expect(btnEle.textContent).toBe("Refresh Balances");
    });
  });

  it("test normal value", () => {
    getAccounts.mockResolvedValue(APEX_ACCOUNTS_SUCCESS);
    updateAccounts.mockResolvedValue(APEX_UPDATE_ACCOUNTS_SUCCESS);
    const element = createElement("c-accountsAndGoalsRefresh", {
      is: accountsAndGoalsRefresh
    });

    element.recordId = "0031700000pHcf8AAC";
    element.objectName = "Account";
    document.body.appendChild(element);

    getRecordAdapter.emit(mockGetRecord);

    const payload = {
      update: true
    };
    publish(messageContextWireAdapter, UpdateAccountsGoalsTimed, payload);

    return flushPromises().then(() => {
      const mainEle = element.shadowRoot.querySelector("article");
      expect(mainEle).not.toBeNull();
    });
  });

  it("test update failures", () => {
    getAccounts.mockResolvedValue(APEX_ACCOUNTS_SUCCESS);
    updateAccounts.mockRejectedValue(APEX_ACCOUNTS_ERROR);
    const element = createElement("c-accountsAndGoalsRefresh", {
      is: accountsAndGoalsRefresh
    });

    element.recordId = "0031700000pHcf8AAC";
    element.objectName = "Account";
    document.body.appendChild(element);

    getRecordAdapter.emit(mockGetRecord);

    const payload = {
      update: true
    };
    publish(messageContextWireAdapter, UpdateAccountsGoalsTimed, payload);

    return flushPromises().then(() => {
      const mainEle = element.shadowRoot.querySelector("article");
      expect(mainEle).not.toBeNull();
    });
  });

  it("test get account failures", () => {
    getAccounts.mockRejectedValue(APEX_ACCOUNTS_ERROR);
    updateAccounts.mockRejectedValue(APEX_ACCOUNTS_ERROR);
    const element = createElement("c-accountsAndGoalsRefresh", {
      is: accountsAndGoalsRefresh
    });

    element.recordId = "0031700000pHcf8AAC";
    element.objectName = "Account";
    document.body.appendChild(element);

    getRecordAdapter.emit(mockGetRecord);

    const payload = {
      update: true
    };
    publish(messageContextWireAdapter, UpdateAccountsGoalsTimed, payload);

    return flushPromises().then(() => {
      const mainEle = element.shadowRoot.querySelector("article");
      expect(mainEle).not.toBeNull();
    });
  });

  it("test get account return empty value", () => {
    getAccounts.mockResolvedValue(null);
    updateAccounts.mockRejectedValue(APEX_ACCOUNTS_ERROR);
    const element = createElement("c-accountsAndGoalsRefresh", {
      is: accountsAndGoalsRefresh
    });

    element.recordId = "0031700000pHcf8AAC";
    element.objectName = "Account";
    document.body.appendChild(element);

    getRecordAdapter.emit(mockGetRecord);

    const payload = {
      update: true
    };
    publish(messageContextWireAdapter, UpdateAccountsGoalsTimed, payload);

    return flushPromises().then(() => {
      const mainEle = element.shadowRoot.querySelector("article");
      expect(mainEle).not.toBeNull();
    });
  });
});
