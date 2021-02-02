import totalBalance from "c/totalBalance";
import { createElement } from "lwc";
import getTotalBalance from "@salesforce/apex/TotalBalanceController.getTotalBalance";
import getTotalSaved from "@salesforce/apex/TotalBalanceController.getTotalSaved";

import { publish, subscribe, MessageContext } from "lightning/messageService";

import {
  registerLdsTestWireAdapter,
  registerTestWireAdapter
} from "@salesforce/sfdx-lwc-jest";
import UpdateAccountsAndGoals from "@salesforce/messageChannel/FinancialAccountsGoalsUpdate__c";
import UpdateAccountsGoalsTimed from "@salesforce/messageChannel/FinancialAccountGoalsTimedUpdate__c";
import TriggerLoading from "@salesforce/messageChannel/FinancialAccountsTriggerLoading__c";

jest.mock(
  "@salesforce/apex/TotalBalanceController.getTotalBalance",
  () => {
    return {
      default: jest.fn()
    };
  },
  { virtual: true }
);

jest.mock(
  "@salesforce/apex/TotalBalanceController.getTotalSaved",
  () => {
    return {
      default: jest.fn()
    };
  },
  { virtual: true }
);

const APEX_TOTAL_BALANCE_SUCCESS = {
  totalBalance: 123.21
};

const APEX_TOTAL_BALANCE_NULL = {
  totalBalance: null
};

const APEX_TOTAL_SAVED_SUCCESS = {
  totalSaved: 123.21
};

const APEX_TOTAL_SAVED_NULL = {
  totalSaved: null
};

const APEX_TOTAL_BALANCE_ERROR = {
  body: { message: "An internal server error has occurred" },
  ok: false,
  status: 400,
  statusText: "Bad Request"
};

const messageContextWireAdapter = registerTestWireAdapter(MessageContext);

describe("c-totalBalance", () => {
  //clean the dom and mocks in between test runs
  afterEach(() => {
    while (document.body.firstChild) {
      document.body.removeChild(document.body.firstChild);
    }
    jest.clearAllMocks();
  });

  it("test loading section", () => {
    getTotalBalance.mockResolvedValue(APEX_TOTAL_BALANCE_SUCCESS);
    getTotalSaved.mockResolvedValue(APEX_TOTAL_SAVED_SUCCESS);
    const element = createElement("c-totalBalance", {
      is: totalBalance
    });
    document.body.appendChild(element);
    const loadingEle = element.shadowRoot.querySelector("lightning-spinner");

    return Promise.resolve().then(() => {
      expect(loadingEle).not.toBeNull();
    });
  });

  it("test loading triggering", () => {
    getTotalBalance.mockResolvedValue(APEX_TOTAL_BALANCE_SUCCESS);
    getTotalSaved.mockResolvedValue(APEX_TOTAL_SAVED_SUCCESS);
    const element = createElement("c-totalBalance", {
      is: totalBalance
    });
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
    getTotalBalance.mockResolvedValue(APEX_TOTAL_BALANCE_SUCCESS);
    getTotalSaved.mockResolvedValue(APEX_TOTAL_SAVED_SUCCESS);
    const element = createElement("c-totalBalance", {
      is: totalBalance
    });
    document.body.appendChild(element);
    const loadingEle = element.shadowRoot.querySelector("lightning-spinner");

    return Promise.resolve().then(() => {
      expect(subscribe).toHaveBeenCalled();
    });
  });

  it("test UpdateAccountsAndGoals triggering", () => {
    getTotalBalance.mockResolvedValue(APEX_TOTAL_BALANCE_SUCCESS);
    getTotalSaved.mockResolvedValue(APEX_TOTAL_SAVED_SUCCESS);
    const element = createElement("c-totalBalance", {
      is: totalBalance
    });
    document.body.appendChild(element);

    const payload = {
      update: true
    };
    publish(messageContextWireAdapter, UpdateAccountsAndGoals, payload);

    return Promise.resolve()
      .then(() => {})
      .then(() => {
        const mainEle = element.shadowRoot.querySelector("article");
        expect(mainEle).not.toBeNull();
        const paraEle = element.shadowRoot.querySelector("p");
        expect(paraEle).not.toBeNull();
      });
  });

  it("test UpdateAccountsAndGoals failed", () => {
    getTotalBalance.mockResolvedValue(APEX_TOTAL_BALANCE_SUCCESS);
    getTotalSaved.mockResolvedValue(APEX_TOTAL_SAVED_SUCCESS);
    const element = createElement("c-totalBalance", {
      is: totalBalance
    });
    document.body.appendChild(element);

    const payload = {
      message: "test message"
    };
    publish(messageContextWireAdapter, UpdateAccountsAndGoals, payload);

    return Promise.resolve()
      .then(() => {})
      .then(() => {
        const mainEle = element.shadowRoot.querySelector("article");
        expect(mainEle).not.toBeNull();
      });
  });

  it("test UpdateAccountsAndGoals with apex failures", () => {
    getTotalBalance.mockRejectedValue(APEX_TOTAL_BALANCE_ERROR);
    getTotalSaved.mockRejectedValue(APEX_TOTAL_BALANCE_ERROR);
    const element = createElement("c-totalBalance", {
      is: totalBalance
    });
    document.body.appendChild(element);

    const payload = {
      message: "test message"
    };
    publish(messageContextWireAdapter, UpdateAccountsAndGoals, payload);

    return Promise.resolve().catch(() => {
      const mainEle = element.shadowRoot.querySelector("article");
      expect(mainEle).not.toBeNull();

      const paraEle = element.shadowRoot.querySelector("p");
      expect(paraEle).toBeNull();
    });
  });

  it("test UpdateAccountsAndGoals triggering with null result", () => {
    getTotalBalance.mockResolvedValue(APEX_TOTAL_BALANCE_NULL);
    getTotalSaved.mockResolvedValue(APEX_TOTAL_SAVED_NULL);
    const element = createElement("c-totalBalance", {
      is: totalBalance
    });
    document.body.appendChild(element);

    const payload = {
      update: true
    };
    publish(messageContextWireAdapter, UpdateAccountsAndGoals, payload);

    return Promise.resolve()
      .then(() => {})
      .then(() => {
        const mainEle = element.shadowRoot.querySelector("article");
        expect(mainEle).not.toBeNull();
        const paraEle = element.shadowRoot.querySelector("p");
        expect(paraEle).not.toBeNull();
      });
  });
});
