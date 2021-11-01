import TransactionHistoryRecord from "c/transactionHistoryRecord";
import { createElement } from "lwc";

import { publish, subscribe } from "lightning/messageService";
import ExpandCollapseAll from "@salesforce/messageChannel/ListCollapseExpandAll__c";

//Import transaction test data
const transRecord = require("./data/transactionRecord.json");
const transRecordWithoutWebsite = require("./data/transactionRecordNoWebsite.json");
const transRecordPartial = require("./data/transactionRecordPartial.json");

import { createTestWireAdapter } from "@salesforce/wire-service-jest-util";

const MessageContext = createTestWireAdapter();

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

    publish(MessageContext, ExpandCollapseAll, payload);

    return Promise.resolve().then(() => {
      const amount = element.shadowRoot.querySelector(
        'lightning-formatted-number[data-id="amount"]'
      );

      //We can't confirm that the value is formatted in Jest
      //so we confirm the format style of the amount plus the value
      expect(amount.formatStyle).toEqual("currency");
      expect(amount.value).toEqual(50);

      const descriptionDiv = element.shadowRoot.querySelector(
        "div.description-tooltip"
      );
      expect(descriptionDiv).not.toBeNull();
      expect(descriptionDiv.textContent).toBe("test Description");

      const transIdDiv = element.shadowRoot.querySelector(
        'div[data-id="transactionId"]'
      );
      expect(transIdDiv).not.toBeNull();
      expect(transIdDiv.textContent).toBe("4313ds-51d2-4ve2-ba7e-0b339p157da1");

      const errorDiv = element.shadowRoot.querySelector(
        'div[data-id="transError"]'
      );
      expect(errorDiv).not.toBeNull();
      expect(errorDiv.textContent).toBe("test error");
    });
  });

  it("test message without website value", () => {
    const element = createElement("c-transactionHistoryRecord", {
      is: TransactionHistoryRecord
    });
    element.transactionRecord = transRecordWithoutWebsite;
    document.body.appendChild(element);

    const payload = {
      expand: true
    };

    expect(subscribe).toHaveBeenCalled();

    publish(MessageContext, ExpandCollapseAll, payload);

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
      expect(transIdDiv.textContent).toBe("4313ds-51d2-4ve2-ba7e-0b339p157da1");

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

    publish(MessageContext, ExpandCollapseAll, payload);

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
      expect(transIdDiv.textContent).toBe("4313ds-51d2-4ve2-ba7e-0b339p157da1");

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

    publish(MessageContext, ExpandCollapseAll, payload);

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

  it("test button menu show menu items", () => {
    const element = createElement("c-transactionHistoryRecord", {
      is: TransactionHistoryRecord
    });
    element.transactionRecord = transRecord;
    element.expandAll = true;
    document.body.appendChild(element);

    const buttonMenu = element.shadowRoot.querySelector(
      "lightning-button-menu"
    );
    expect(buttonMenu).not.toBeNull();

    buttonMenu.click();
    const menuItems = element.shadowRoot.querySelectorAll(
      "lightning-menu-item"
    );
    expect(menuItems.length).toBe(2);
  });

  it("record type selection modal displayed if transaction type is unspecified", () => {
    const element = createElement("c-transactionHistoryRecord", {
      is: TransactionHistoryRecord
    });
    // Set the dispute record type to be empty to trigger the modal to display
    transRecord.disputeRecordTypeId = "";
    element.transactionRecord = transRecord;
    element.expandAll = true;
    document.body.appendChild(element);

    const buttonMenu = element.shadowRoot.querySelector(
      "lightning-button-menu"
    );
    expect(buttonMenu).not.toBeNull();

    buttonMenu.click();
    const menuItems = element.shadowRoot.querySelectorAll(
      "lightning-menu-item"
    );
    expect(menuItems.length).toBe(2);

    const raiseDisputeButton = menuItems[1];
    expect(raiseDisputeButton).not.toBeNull();
    raiseDisputeButton.click();

    return Promise.resolve().then(() => {
      // Check if modal is displayed
      const recordTypeSelectionModal = element.shadowRoot.querySelector(
        "div.slds-modal__container"
      );
      expect(recordTypeSelectionModal).not.toBeNull();
    });
  });
});
