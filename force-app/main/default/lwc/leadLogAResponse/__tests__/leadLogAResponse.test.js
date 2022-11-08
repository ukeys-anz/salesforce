import { createElement } from "lwc";
import LeadLogAResponse from "c/leadLogAResponse";
import responseStatusDependentValues from "@salesforce/apex/CCRMLogAResponseController.responseStatusDependentValues";
import createResponseRecord from "@salesforce/apex/CCRMLogAResponseController.createResponseRecord";
import { updateRecord, getRecord } from "lightning/uiRecordApi";
import { registerLdsTestWireAdapter } from "@salesforce/sfdx-lwc-jest";
import { getPicklistValues } from "lightning/uiObjectInfoApi";
import { ShowToastEventName } from "lightning/platformShowToastEvent";
import { setImmediate } from "timers";
import { handleErrors } from "c/utils";

const mockGetPicklistValues = require("./data/getLeadQualityWireResponse.json");
const getPicklistWireAdapter = registerLdsTestWireAdapter(getPicklistValues);
const mockGetRecord = require("./data/getRecord.json");
const getRecordWireAdapter = registerLdsTestWireAdapter(getRecord);
const mockGetResponseStatusDependentValues = require("./data/getResponseStatusDependentValues.json");
const getResponseStatusWireAdapter = registerLdsTestWireAdapter(
  responseStatusDependentValues
);

const mockCreateResponseRecord = require("./data/createResponseRecord.json");
const mockErrorCreateResponseRecord = require("./data/errorCreateResponseRecord.json");

// Mocking imperative Apex method call
jest.mock(
  "@salesforce/apex/CCRMLogAResponseController.responseStatusDependentValues",
  () => {
    return {
      default: jest.fn()
    };
  },
  { virtual: true }
);

jest.mock(
  "@salesforce/apex/CCRMLogAResponseController.createResponseRecord",
  () => {
    return {
      default: jest.fn()
    };
  },
  { virtual: true }
);

//Test Suite for Log a Response LWC
describe("c-lead-log-a-response test suite", () => {
  //Prepare data before each test method
  beforeEach(() => {
    const element = createElement("c-lead-log-a-response", {
      is: LeadLogAResponse
    });
    document.body.appendChild(element);

    // Emit data from @wire
    getPicklistWireAdapter.emit(mockGetPicklistValues);
    getRecordWireAdapter.emit(mockGetRecord);
    getResponseStatusWireAdapter.emit(
      JSON.stringify(mockGetResponseStatusDependentValues)
    );
  });

  //clean the dom and mocks in between test runs
  afterEach(() => {
    while (document.body.firstChild) {
      document.body.removeChild(document.body.firstChild);
    }
    jest.clearAllMocks();
  });

  it("Load lead log a response page", () => {
    const element = document.querySelector("c-lead-log-a-response");
    const loadingEle = element.shadowRoot.querySelector("lightning-card");

    return Promise.resolve().then(() => {
      expect(loadingEle).not.toBeNull();
    });
  });

  it("Test outcome reason for response status", () => {
    const element = document.querySelector("c-lead-log-a-response");

    const inputElement = element.shadowRoot.querySelector(
      "lightning-combobox.responseStatus"
    );
    inputElement.value = "Accepted";

    inputElement.dispatchEvent(
      new CustomEvent("change", {
        detail: { value: inputElement.value }
      })
    );

    const outcomereason = element.shadowRoot.querySelector(".outcomeReason");

    return Promise.resolve().then(() => {
      expect(outcomereason).not.toBeNull();
    });
  });

  it("Load outcome reasons", () => {
    const element = document.querySelector("c-lead-log-a-response");
    const inputElement = element.shadowRoot.querySelector(
      "lightning-combobox.outcomeReason"
    );
    inputElement.value = "Happy with the offer";

    inputElement.dispatchEvent(
      new CustomEvent("change", {
        detail: { value: inputElement.value }
      })
    );

    const outcomereason = element.shadowRoot.querySelector(".outcomeReason");

    return Promise.resolve().then(() => {
      expect(outcomereason).not.toBeNull();
    });
  });

  it("Enable Follow up date", () => {
    const element = document.querySelector("c-lead-log-a-response");

    const status = element.shadowRoot.querySelector(
      "lightning-combobox.responseStatus"
    );
    status.value = "Call back";

    status.dispatchEvent(
      new CustomEvent("change", {
        detail: { value: status.value }
      })
    );

    const outcome = element.shadowRoot.querySelector(
      "lightning-combobox.outcomeReason"
    );
    outcome.value = "Lead is currently busy or cannot be contacted";

    outcome.dispatchEvent(
      new CustomEvent("change", {
        detail: { value: outcome.value }
      })
    );

    return flushPromises().then(() => {
      const inputElement = element.shadowRoot.querySelector(".followUpDate");
      expect(inputElement.disabled).toEqual(false);
    });
  });

  it("Disable Follow up date", () => {
    const element = document.querySelector("c-lead-log-a-response");

    const status = element.shadowRoot.querySelector(
      "lightning-combobox.responseStatus"
    );
    status.value = "Accepted";

    status.dispatchEvent(
      new CustomEvent("change", {
        detail: { value: status.value }
      })
    );

    const outcome = element.shadowRoot.querySelector(
      "lightning-combobox.outcomeReason"
    );
    outcome.value = "Happy with the offer";

    outcome.dispatchEvent(
      new CustomEvent("change", {
        detail: { value: outcome.value }
      })
    );

    return flushPromises().then(() => {
      const followUpDate = element.shadowRoot.querySelector(".followUpDate");
      expect(followUpDate.disabled).toEqual(true);
    });
  });

  it("Create Response Log Succussfully", () => {
    const element = document.querySelector("c-lead-log-a-response");

    createResponseRecord.mockResolvedValue(
      JSON.stringify(mockCreateResponseRecord)
    );
    const TOAST_TITLE = "SUCCESS!";
    const TOAST_MESSAGE = "Response Logged Successfully.";
    const TOAST_VARIANT = "success";
    //Response Status
    const status = element.shadowRoot.querySelector(
      "lightning-combobox.responseStatus"
    );
    status.value = "Call back";
    status.dispatchEvent(
      new CustomEvent("change", {
        detail: { value: status.value }
      })
    );

    //Outcome Reasons
    const outcome = element.shadowRoot.querySelector(
      "lightning-combobox.outcomeReason"
    );
    outcome.value = "Lead is currently busy or cannot be contacted";
    outcome.dispatchEvent(
      new CustomEvent("change", {
        detail: { value: outcome.value }
      })
    );

    //Lead Quality
    const quality = element.shadowRoot.querySelector(
      "lightning-combobox.leadQuality"
    );
    quality.value = "Good";
    quality.dispatchEvent(
      new CustomEvent("change", {
        detail: { value: quality.value }
      })
    );

    //Follow up date
    const followUpDate = element.shadowRoot.querySelector(".followUpDate");
    followUpDate.value = formatDate(new Date());
    followUpDate.min = formatDate(new Date());
    followUpDate.dispatchEvent(
      new CustomEvent("change", {
        detail: { value: followUpDate.value }
      })
    );

    //Comment
    const commentElement = element.shadowRoot.querySelector(".comment");
    commentElement.value = "This response log is for testing.";
    commentElement.dispatchEvent(
      new CustomEvent("change", {
        detail: { value: commentElement.value }
      })
    );

    const handler = jest.fn();
    element.addEventListener(ShowToastEventName, handler);

    let submitButton = element.shadowRoot.querySelector(
      "lightning-button[data-id='get-submit-button']"
    );

    submitButton.click();

    return Promise.resolve().then(() => {
      expect(handler).toHaveBeenCalled();
      const handlerObject = handler.mock.calls[0][0];
      expect(handlerObject.detail.title).toBe(TOAST_TITLE);
      expect(handlerObject.detail.message).toBe(TOAST_MESSAGE);
      expect(handlerObject.detail.variant).toBe(TOAST_VARIANT);
    });
  });

  it("Create Response Log Error occurred", () => {
    const element = document.querySelector("c-lead-log-a-response");
    createResponseRecord.mockResolvedValue(
      JSON.stringify(mockErrorCreateResponseRecord)
    );
    const TOAST_TITLE = "ERROR!";
    const TOAST_MESSAGE = "Error Message: Internal server error occurred.";
    const TOAST_VARIANT = "error";

    const hiddenDueDate = element.shadowRoot.querySelector(
      '[data-id="get-due-date"]'
    );
    expect(hiddenDueDate).toBeNull();

    const status = element.shadowRoot.querySelector(
      "lightning-combobox.responseStatus"
    );
    status.value = "Accepted";

    status.dispatchEvent(
      new CustomEvent("change", {
        detail: { value: status.value }
      })
    );

    const outcome = element.shadowRoot.querySelector(
      "lightning-combobox.outcomeReason"
    );
    outcome.value = "Happy with the offer";

    outcome.dispatchEvent(
      new CustomEvent("change", {
        detail: { value: outcome.value }
      })
    );

    //Follow up date
    const followUpDate = element.shadowRoot.querySelector(".followUpDate");
    followUpDate.value = formatDate(new Date());
    followUpDate.min = formatDate(new Date());
    followUpDate.dispatchEvent(
      new CustomEvent("change", {
        detail: { value: followUpDate.value }
      })
    );

    const handler = jest.fn();
    element.addEventListener(ShowToastEventName, handler);

    let submitButton = element.shadowRoot.querySelector(
      "lightning-button[data-id='get-submit-button']"
    );

    submitButton.click();

    return Promise.resolve().then(() => {
      expect(handler).toHaveBeenCalled();
      const handlerObject = handler.mock.calls[0][0];
      let obj = JSON.parse(handlerObject.detail.message);
      expect(handlerObject.detail.title).toBe(TOAST_TITLE);
      expect(obj.body.error).toBe(TOAST_MESSAGE);
      expect(handlerObject.detail.variant).toBe(TOAST_VARIANT);
    });
  });

  it("Due Date should display", () => {
    const element = document.querySelector("c-lead-log-a-response");

    const status = element.shadowRoot.querySelector(
      "lightning-combobox.responseStatus"
    );
    status.value = "Accepted";

    status.dispatchEvent(
      new CustomEvent("change", {
        detail: { value: status.value }
      })
    );

    const outcome = element.shadowRoot.querySelector(
      "lightning-combobox.outcomeReason"
    );
    outcome.value = "Happy with the offer";

    outcome.dispatchEvent(
      new CustomEvent("change", {
        detail: { value: outcome.value }
      })
    );

    return flushPromises().then(() => {
      const inputElement = element.shadowRoot.querySelector(
        '[data-id="get-due-date"]'
      );
      expect(inputElement).not.toBeNull();
    });
  });

  it("Due Date should NOT display", () => {
    const element = document.querySelector("c-lead-log-a-response");

    const status = element.shadowRoot.querySelector(
      "lightning-combobox.responseStatus"
    );
    status.value = "Call back";

    status.dispatchEvent(
      new CustomEvent("change", {
        detail: { value: status.value }
      })
    );

    const outcome = element.shadowRoot.querySelector(
      "lightning-combobox.outcomeReason"
    );
    outcome.value = "Lead is currently busy or cannot be contacted";

    outcome.dispatchEvent(
      new CustomEvent("change", {
        detail: { value: outcome.value }
      })
    );

    return Promise.resolve().then(() => {
      const inputElement = element.shadowRoot.querySelector(
        '[data-id="get-due-date"]'
      );
      expect(inputElement).toBeNull();
    });
  });

  function flushPromises() {
    return new Promise((resolve) => setImmediate(resolve));
  }

  function padTo2Digits(num) {
    return num.toString().padStart(2, "0");
  }

  function formatDate(date) {
    return [
      padTo2Digits(date.getDate()),
      padTo2Digits(date.getMonth() + 1),
      date.getFullYear()
    ].join("/");
  }
});
