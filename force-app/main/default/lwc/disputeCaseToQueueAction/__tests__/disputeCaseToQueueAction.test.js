import { createElement } from "lwc";
import { ShowToastEventName } from "lightning/platformShowToastEvent";
import assignCaseToOriginalQueue from "@salesforce/apex/DisputeExternalCaseStatusController.assignCaseToOriginalQueue";
import DisputeCaseToQueueAction from "c/disputeCaseToQueueAction";

// Mocking the imported Apex method
jest.mock(
  "@salesforce/apex/DisputeExternalCaseStatusController.assignCaseToOriginalQueue",
  () => {
    return {
      default: jest.fn()
    };
  },
  { virtual: true }
);

describe("c-dispute-case-to-queue-action", () => {
  beforeEach(() => {
    const element = createElement("c-dispute-case-to-queue-action", {
      is: DisputeCaseToQueueAction
    });
    document.body.appendChild(element);
  });

  afterEach(() => {
    while (document.body.firstChild) {
      document.body.removeChild(document.body.firstChild);
    }
    jest.restoreAllMocks();
  });

  it("calls assignCaseToOriginalQueue on invoke", async () => {
    const element = document.querySelector("c-dispute-case-to-queue-action");

    // Call invoke method
    await element.invoke();

    // Validate if apex function got called
    expect(assignCaseToOriginalQueue).toHaveBeenCalledWith({
      caseId: element.recordId
    });
  });

  it("displays a success toast on successful invocation", async () => {
    const element = document.querySelector("c-dispute-case-to-queue-action");

    // Mock successful Apex method
    assignCaseToOriginalQueue.mockResolvedValue();

    // Mock handler for toast event
    const handler = jest.fn();
    element.addEventListener(ShowToastEventName, handler);

    // Call invoke method
    await element.invoke();

    // Validate if toast event has been fired
    expect(handler).toHaveBeenCalled();
    expect(handler.mock.calls[0][0].detail.variant).toBe("success");
  });

  it("displays an error toast on error", async () => {
    const element = document.querySelector("c-dispute-case-to-queue-action");

    // Mock failing Apex method
    assignCaseToOriginalQueue.mockRejectedValue(new Error("Test error"));

    // Mock handler for toast event
    const handler = jest.fn();
    element.addEventListener(ShowToastEventName, handler);

    // Call invoke method
    await element.invoke();

    // Validate if toast event has been fired
    expect(handler).toHaveBeenCalled();
    expect(handler.mock.calls[0][0].detail.variant).toBe("error");
  });
});
