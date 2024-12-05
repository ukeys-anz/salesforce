import { createElement } from "lwc";
import ProfileStagingRetry from "c/profileStagingRetry";
import { ShowToastEventName } from "lightning/platformShowToastEvent";
import profileStagingRetry from "@salesforce/apex/ProfileStagingController.profileStagingRetry";

// Mocking imperative Apex method call
jest.mock(
  "@salesforce/apex/ProfileStagingController.profileStagingRetry",
  () => ({
    default: jest.fn()
  }),
  { virtual: true }
);

const ERROR_MESSAGE = "Error occurred while re-triggering the request.";

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

describe("c-profile-staging-retry", () => {
  beforeEach(() => {
    const element = createElement("c-profile-staging-retry", {
      is: ProfileStagingRetry
    });
    element.recordId = "someRecordId";
    document.body.appendChild(element);
  });
  afterEach(() => {
    // The jsdom instance is shared across test cases in a single file so reset the DOM
    while (document.body.firstChild) {
      document.body.removeChild(document.body.firstChild);
    }
  });

  // Helper function to wait until the microtask queue is empty. This is needed for promise
  // timing when calling imperative Apex.
  async function flushPromises() {
    return Promise.resolve();
  }

  it("Dispatch the Action event successfully", async () => {
    const element = document.querySelector("c-profile-staging-retry");
    profileStagingRetry.mockResolvedValue(APEX_MOCK_SUCCESS);

    const handler = jest.fn();
    element.addEventListener(ShowToastEventName, handler);
    element.invoke();

    await flushPromises();

    expect(handler).toHaveBeenCalled();
    expect(handler.mock.calls[0][0].detail.message).toBe(
      "Request has been re-triggered successfully."
    );
  });

  it("Dispatch the Action event with failure", async () => {
    profileStagingRetry.mockRejectedValue(APEX_MOCK_ERROR);
    const element = document.querySelector("c-profile-staging-retry");

    const handler = jest.fn();
    element.addEventListener(ShowToastEventName, handler);
    element.invoke();

    await flushPromises().catch(() => {
      expect(handler).toHaveBeenCalled();
      expect(handler.mock.calls[0][0].detail.message).toBe(ERROR_MESSAGE);
    });
  });
});
