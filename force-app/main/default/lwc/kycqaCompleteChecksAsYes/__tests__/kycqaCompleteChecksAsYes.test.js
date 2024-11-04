import { createElement } from "lwc";
import { ShowToastEventName } from "lightning/platformShowToastEvent";
import KycqaCompleteChecksAsYes from "c/kycqaCompleteChecksAsYes";
import completeChecksAsYes from "@salesforce/apex/AutoKYCQACaseActions.completeChecksAsYes";

// Mocking imperative Apex method call
jest.mock(
  "@salesforce/apex/AutoKYCQACaseActions.completeChecksAsYes",
  () => ({
    default: jest.fn()
  }),
  { virtual: true }
);
// Mocking custom permission
jest.mock(
  "@salesforce/customPermission/compleKYCQAChecksPermission",
  () => ({
    __esModule: true,
    default: true
  }),
  { virtual: true }
);
const ERROR_MESSAGE =
  "Error performing the completion. Please contact your System Administrator.";

// Sample data for imperative Apex call
const APEX_MOCK_SUCCESS = {
  body: { data: true }
};

// Sample error for imperative Apex call
const APEX_MOCK_ERROR = {
  body: {
    message: ERROR_MESSAGE
  },
  ok: false,
  status: 400,
  statusText: "Bad Request"
};

describe("c-kycqa-complete-checks-as-yes", () => {
  beforeEach(() => {
    const element = createElement("c-kycqa-complete-checks-as-yes", {
      is: KycqaCompleteChecksAsYes
    });
    element.recordId = "someRecordId";
    document.body.appendChild(element);
  });
  afterEach(() => {
    // The jsdom instance is shared across test cases in a single file so reset the DOM
    while (document.body.firstChild) {
      document.body.removeChild(document.body.firstChild);
    }
    // Prevent data saved on mocks from leaking between tests
    jest.clearAllMocks();
  });

  // Helper function to wait until the microtask queue is empty. This is needed for promise
  // timing when calling imperative Apex.
  async function flushPromises() {
    return Promise.resolve();
  }

  it("Dispatch the Action event successfully", async () => {
    const element = document.querySelector("c-kycqa-complete-checks-as-yes");
    completeChecksAsYes.mockResolvedValue(APEX_MOCK_SUCCESS);

    const handler = jest.fn();
    element.addEventListener(ShowToastEventName, handler);
    element.invoke();

    await flushPromises();

    expect(handler).toHaveBeenCalled();
    expect(handler.mock.calls[0][0].detail.message).toBe(
      "All the KYC QA checks are completed successfully."
    );
  });

  it("Dispatch the Action event with failure", async () => {
    completeChecksAsYes.mockRejectedValue(APEX_MOCK_ERROR);
    const element = document.querySelector("c-kycqa-complete-checks-as-yes");

    const handler = jest.fn();
    element.addEventListener(ShowToastEventName, handler);
    element.invoke();

    await flushPromises().catch(() => {
      expect(handler).toHaveBeenCalled();
      expect(handler.mock.calls[0][0].detail.message).toBe(ERROR_MESSAGE);
    });
  });

  it("Dispatch the Action event without permission", async () => {
    const element = document.querySelector("c-kycqa-complete-checks-as-yes");
    const handler = jest.fn();
    element.addEventListener(ShowToastEventName, handler);
    element.invoke();

    await flushPromises().catch(() => {
      expect(handler).toHaveBeenCalled();
      expect(handler.mock.calls[0][0].detail.message).toBe(
        "You do not have enough permission to perform the KYC QA Check completion."
      );
    });
  });
});
