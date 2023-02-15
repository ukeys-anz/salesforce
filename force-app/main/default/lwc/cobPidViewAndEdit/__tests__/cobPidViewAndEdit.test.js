import CobPidViewAndEdit from "c/cobPidViewAndEdit";
import getDetokenizedData from "@salesforce/apex/COBPIDViewAndEditController.getDetokenizedData";
import { createElement } from "lwc";
import { setImmediate } from "timers";

jest.mock(
  "@salesforce/apex/COBPIDViewAndEditController.getDetokenizedData",
  () => {
    return {
      default: jest.fn()
    };
  },
  { virtual: true }
);

const mockDetokenizedDataSuccess = require("./data/getDetokenizedDataSuccess.json");

describe("c-cob-pid-view-and-edit", () => {
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

  it("test clicking Save button and get success response", () => {
    const element = createElement("c-cob-pid-view-and-edit", {
      is: CobPidViewAndEdit
    });
    document.body.appendChild(element);
    expect(element).toBeTruthy();

    getDetokenizedData.mockResolvedValue(mockDetokenizedDataSuccess);
    return flushPromises().then(() => {
      const FirstName__c = element.shadowRoot.querySelector(
        'lightning-input[data-id="FirstName__c"]'
      );
      const MiddleNames__c = element.shadowRoot.querySelector(
        'lightning-input[data-id="MiddleNames__c"]'
      );
      const LastName__c = element.shadowRoot.querySelector(
        'lightning-input[data-id="LastName__c"]'
      );
      const DateOfBirth__c = element.shadowRoot.querySelector(
        'lightning-input[data-id="DateOfBirth__c"]'
      );

      expect(FirstName__c).not.toBeNull();
      expect(MiddleNames__c).not.toBeNull();
      expect(LastName__c).not.toBeNull();
      expect(DateOfBirth__c).not.toBeNull();
    });
  });
});
