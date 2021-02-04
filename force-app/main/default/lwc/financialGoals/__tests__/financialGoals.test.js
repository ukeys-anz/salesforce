import financialGoals from "c/financialGoals";
import { createElement } from "lwc";
import getFinancialGoals from "@salesforce/apex/FinancialGoalsComponentController.getFinancialGoals";

import { publish, subscribe, MessageContext } from "lightning/messageService";
import {
  registerLdsTestWireAdapter,
  registerTestWireAdapter
} from "@salesforce/sfdx-lwc-jest";
import UpdateAccountsAndGoals from "@salesforce/messageChannel/FinancialAccountsGoalsUpdate__c";
import UpdateAccountsGoalsTimed from "@salesforce/messageChannel/FinancialAccountGoalsTimedUpdate__c";
import TriggerLoading from "@salesforce/messageChannel/FinancialAccountsTriggerLoading__c";

jest.mock(
  "@salesforce/apex/FinancialGoalsComponentController.getFinancialGoals",
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
    FinServ__TargetValue__c: 50,
    FinServ__ActualValue__c: 50,
    FinServ__TargetDate__c: "2021-03-05T04:56:48.000+0000",
    Recommended_Savings_Amount__c: 200,
    FinServ__CompletionDate__c: "2021-04-05T04:56:48.000+0000",
    LastModifiedDate: "2021-01-05T04:56:48.000+0000"
  }
];

const APEX_FGOALS_EMPTY_RECORD = [
  {
    Id: "",
    FinServ__TargetValue__c: null,
    FinServ__ActualValue__c: null,
    FinServ__TargetDate__c: null,
    Recommended_Savings_Amount__c: null,
    FinServ__CompletionDate__c: null,
    LastModifiedDate: null
  }
];

const APEX_FGOALS_NO_RECORD = [];

const APEX_FGOALS_ERROR = {
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

  function flushPromises() {
    return new Promise((resolve) => setImmediate(resolve));
  }

  it("test default section", () => {
    getFinancialGoals.mockResolvedValue(APEX_FGOALS_SUCCESS);
    const element = createElement("c-financialGoals", {
      is: financialGoals
    });
    document.body.appendChild(element);

    return flushPromises().then(() => {
      const mainEle = element.shadowRoot.querySelector("article");
      expect(mainEle).not.toBeNull();
    });
  });

  it("test subscribe is invoked", () => {
    getFinancialGoals.mockResolvedValue(APEX_FGOALS_SUCCESS);
    const element = createElement("c-financialGoals", {
      is: financialGoals
    });
    document.body.appendChild(element);

    return Promise.resolve().then(() => {
      expect(subscribe).toHaveBeenCalled();
    });
  });

  it("test UpdateAccountsAndGoals triggering", () => {
    getFinancialGoals.mockResolvedValue(APEX_FGOALS_SUCCESS);
    const element = createElement("c-financialGoals", {
      is: financialGoals
    });
    document.body.appendChild(element);

    const payload = {
      update: true
    };
    publish(messageContextWireAdapter, UpdateAccountsAndGoals, payload);

    return flushPromises().then(() => {
      const mainEle = element.shadowRoot.querySelector("article");
      expect(mainEle).not.toBeNull();
    });
  });

  it("test UpdateAccountsAndGoals triggering with error message", () => {
    getFinancialGoals.mockResolvedValue(APEX_FGOALS_SUCCESS);
    const element = createElement("c-financialGoals", {
      is: financialGoals
    });
    document.body.appendChild(element);

    const payload = {
      message: "test error message"
    };
    publish(messageContextWireAdapter, UpdateAccountsAndGoals, payload);

    return flushPromises().then(() => {
      const mainEle = element.shadowRoot.querySelector("article");
      expect(mainEle).not.toBeNull();
    });
  });

  it("test UpdateAccountsAndGoals triggering with Apex error", () => {
    getFinancialGoals.mockRejectedValue(APEX_FGOALS_ERROR);
    const element = createElement("c-financialGoals", {
      is: financialGoals
    });
    document.body.appendChild(element);

    const payload = {
      message: "test error message"
    };
    publish(messageContextWireAdapter, UpdateAccountsAndGoals, payload);

    return Promise.resolve().catch(() => {
      const mainEle = element.shadowRoot.querySelector("article");
      expect(mainEle).not.toBeNull();
    });
  });

  it("test UpdateAccountsAndGoals triggering with empty record", () => {
    getFinancialGoals.mockResolvedValue(APEX_FGOALS_EMPTY_RECORD);
    const element = createElement("c-financialGoals", {
      is: financialGoals
    });
    document.body.appendChild(element);

    const payload = {
      update: true
    };
    publish(messageContextWireAdapter, UpdateAccountsAndGoals, payload);

    return flushPromises().then(() => {
      const mainEle = element.shadowRoot.querySelector("article");
      expect(mainEle).not.toBeNull();
    });
  });

  it("test UpdateAccountsAndGoals triggering with no record", () => {
    getFinancialGoals.mockResolvedValue(APEX_FGOALS_NO_RECORD);
    const element = createElement("c-financialGoals", {
      is: financialGoals
    });
    document.body.appendChild(element);

    const payload = {
      update: true
    };
    publish(messageContextWireAdapter, UpdateAccountsAndGoals, payload);

    return flushPromises().then(() => {
      const mainEle = element.shadowRoot.querySelector("article");
      expect(mainEle).not.toBeNull();
    });
  });
});
