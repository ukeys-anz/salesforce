import TransactionHistoryRecord from "c/transactionHistoryRecord";
import { createElement } from "lwc";

import { publish, subscribe, MessageContext } from "lightning/messageService";
import ExpandCollapseAll from "@salesforce/messageChannel/ListCollapseExpandAll__c";

import {
  registerApexTestWireAdapter,
  registerTestWireAdapter,
  registerLdsTestWireAdapter
} from "@salesforce/sfdx-lwc-jest";

const messageContextWireAdapter = registerTestWireAdapter(MessageContext);

const transRecord = {
  transactionId: "123",
  amount: {
    charged: { value: "50.00" },
    converted: { value: "50.00" },
    exchangeRate: { value: "50.00" }
  },
  type: "Card",
  status: "Pending",
  card: { scheme: "Visa" },
  date: "2020-01-01d18:19",
  longDesc: "test Description",
  tags: [{ name: "test" }, { name: "testsuperloooo..." }],
  merchant: {
    name: "test",
    chain_name: { value: "test" },
    phone_number: { value: "123456" },
    website_url: { value: "wwww.test.com" },
    address: {
      line_one: {
        value: "test street"
      },
      suburb: {
        value: "test suburb"
      },
      state: {
        value: "test state"
      },
      postcode: {
        value: "4000"
      },
      coordinates: {
        latitude: 51,
        longitude: 47
      }
    },
    image_details: { light_url: [Object] },
    email: "test@test.com"
  },
  TransactionDate: "2020-01-01",
  TransactionTime: "18:19",
  showDateTitle: true,
  rowColour: "slds-card slds-m-bottom_small transaction-item even",
  tagList: ["test", "testsuperloooo..."],
  merchantDetails: true,
  name: "test",
  merchantLocation: "test street, test suburb test state 4000",
  logo: "test url",
  Error: "test error"
};

const transRecordPartial = {
  transactionId: "123",
  longDesc: "test Description",
  amount: {
    charged: { value: "50.00" },
    converted: { value: "50.00" },
    exchangeRate: { value: "50.00" }
  },
  type: "Card",
  date: "2020-01-01d18:19"
};

describe("c-transactionHistoryRecord", () => {
  afterEach(() => {
    // The jsdom instance is shared across test cases in a single file so reset the DOM
    while (document.body.firstChild) {
      document.body.removeChild(document.body.firstChild);
    }
  });

  it("test expand message", () => {
    const element = createElement("c-transactionHistoryRecord", {
      is: TransactionHistoryRecord
    });
    element.transactionRecord = transRecord;
    document.body.appendChild(element);

    const payload = {
      expand: true
    };

    expect(subscribe).toHaveBeenCalled();

    publish(messageContextWireAdapter, ExpandCollapseAll, payload);

    return Promise.resolve().then(() => {
      const descriptionDiv = element.shadowRoot.querySelector(
        "div.description-tooltip"
      );
      expect(descriptionDiv).not.toBeNull();
      expect(descriptionDiv.textContent).toBe("test Description");

      const transIdDiv = element.shadowRoot.querySelector(
        'div[data-id="transactionId"]'
      );
      expect(transIdDiv).not.toBeNull();
      expect(transIdDiv.textContent).toBe("123");

      const errorDiv = element.shadowRoot.querySelector(
        'div[data-id="transError"]'
      );
      expect(errorDiv).not.toBeNull();
      expect(errorDiv.textContent).toBe("test error");
    });
  });

  it("test expand message with partial values", () => {
    const element = createElement("c-transactionHistoryRecord", {
      is: TransactionHistoryRecord
    });
    element.transactionRecord = transRecordPartial;
    document.body.appendChild(element);

    const payload = {
      expand: true
    };

    expect(subscribe).toHaveBeenCalled();

    publish(messageContextWireAdapter, ExpandCollapseAll, payload);

    return Promise.resolve().then(() => {
      const descriptionDiv = element.shadowRoot.querySelector(
        "div.description-tooltip"
      );
      expect(descriptionDiv).not.toBeNull();
      expect(descriptionDiv.textContent).toBe("test Description");

      const transIdDiv = element.shadowRoot.querySelector(
        'div[data-id="transactionId"]'
      );
      expect(transIdDiv).not.toBeNull();
      expect(transIdDiv.textContent).toBe("123");

      const errorDiv = element.shadowRoot.querySelector(
        'div[data-id="transError"]'
      );
      expect(errorDiv).not.toBeNull();
      expect(errorDiv.textContent).toBe("");
    });
  });

  it("test collapse message", () => {
    const element = createElement("c-transactionHistoryRecord", {
      is: TransactionHistoryRecord
    });
    element.transactionRecord = transRecord;
    element.expandAll = true;
    document.body.appendChild(element);

    const payload = {
      expand: false
    };

    expect(subscribe).toHaveBeenCalled();

    publish(messageContextWireAdapter, ExpandCollapseAll, payload);

    return Promise.resolve().then(() => {
      const descriptionDiv = element.shadowRoot.querySelector(
        "div.description-tooltip"
      );
      expect(descriptionDiv).toBeNull();

      const transIdDiv = element.shadowRoot.querySelector(
        'div[data-id="transactionId"]'
      );
      expect(transIdDiv).toBeNull();

      const errorDiv = element.shadowRoot.querySelector(
        'div[data-id="transError"]'
      );
      expect(errorDiv).toBeNull();
    });
  });
});
