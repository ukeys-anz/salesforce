import { createElement } from "lwc";
import CaseSendCommunication from "c/caseSendCommunication";
import { ShowToastEventName } from "lightning/platformShowToastEvent";
import sendCommunication from "@salesforce/apex/CaseSendCommunicationController.sendCommunication";
import { setImmediate } from "timers";

jest.mock(
  "@salesforce/apex/CaseSendCommunicationController.sendCommunication",
  () => {
    return {
      default: jest.fn()
    };
  },
  { virtual: true }
);

// Sample error for imperative Apex call
const APEX_MOCK_ERROR = {
  body: { message: "An internal server error has occurred" },
  ok: false,
  status: 400,
  statusText: "Bad Request"
};

const APEX_MOCK_SUCCESS = {
  body: { data: true }
};

describe("c-case-send-communication", () => {
  afterEach(() => {
    while (document.body.firstChild) {
      document.body.removeChild(document.body.firstChild);
    }
    jest.clearAllMocks();
  });

  // Helper function to wait until the microtask queue is empty. This is needed for promise
  // timing when calling imperative Apex.
  function flushPromises() {
    // eslint-disable-next-line no-undef
    return new Promise((resolve) => setImmediate(resolve));
  }
  it("1. Dispatches CloseActionScreenEvent on handleConfirmSend success", () => {
    sendCommunication.mockResolvedValue(APEX_MOCK_SUCCESS);

    const element = createElement("c-case-send-communication", {
      is: CaseSendCommunication
    });
    element.recordId = "someRecordId";
    document.body.appendChild(element);

    const handler = jest.fn();
    element.addEventListener(ShowToastEventName, handler);

    return flushPromises()
      .then(() => {
        const confirmButton = element.shadowRoot.querySelector(
          'lightning-button[data-id="confirm-button"]'
        );
        confirmButton.click();
      })
      .then(() => {
        expect(handler).toHaveBeenCalled();
        const handlerObject = handler.mock.calls[0][0];
        expect(handlerObject.detail.message).toBe(
          "Request for email notification has been successfully sent."
        );
      });
  });

  it("2. Dispatches CloseActionScreenEvent on handleConfirmSend error", () => {
    sendCommunication.mockRejectedValue(APEX_MOCK_ERROR);

    const element = createElement("c-case-send-communication", {
      is: CaseSendCommunication
    });
    element.recordId = "someRecordId";
    document.body.appendChild(element);

    const handler = jest.fn();
    element.addEventListener(ShowToastEventName, handler);

    return flushPromises()
      .then(() => {
        const confirmButton = element.shadowRoot.querySelector(
          'lightning-button[data-id="confirm-button"]'
        );
        confirmButton.click();
      })
      .catch(() => {
        expect(handler).toHaveBeenCalled();
        const handlerObject = handler.mock.calls[0][0];
        expect(handlerObject.detail.message).toBe(
          "Email notification request could not be sent. Please try again by clicking the 'Send Communication' button."
        );
      });
  });
});
