import { createElement } from "lwc";
import CloneLead from "c/cloneLead";
import cloneLeadRecord from "@salesforce/apex/CloneLeadController.cloneLeadRecord";
import { CloseActionScreenEvent } from "lightning/actions";
import { NavigationMixin } from "lightning/navigation";
import { SimpleToast, handleErrorShowToast } from "c/utils";

// Mocks

jest.mock(
  "@salesforce/apex/CloneLeadController.cloneLeadRecord",
  () => ({
    default: jest.fn()
  }),
  { virtual: true }
);

jest.mock("c/utils", () => ({
  SimpleToast: jest.fn().mockImplementation(() => ({
    success: jest.fn(),
    info: jest.fn()
  })),
  handleErrorShowToast: jest.fn()
}));

const navigateMock = jest.fn();
NavigationMixin.Navigate = navigateMock;

// Tests

describe("c-clone-lead", () => {
  let element;

  beforeEach(() => {
    jest.clearAllMocks();
    element = createElement("c-clone-lead", { is: CloneLead });
    document.body.appendChild(element);
  });

  afterEach(() => {
    while (document.body.firstChild) {
      document.body.removeChild(document.body.firstChild);
    }
  });

  async function flushPromises() {
    return Promise.resolve();
  }

  // ────────────────────────────────────────────────
  it("calls Apex when recordId is set and navigates on success", async () => {
    cloneLeadRecord.mockResolvedValue("00QFakeLeadId123");

    element.recordId = "00QExistingLeadId";
    await flushPromises();

    // Assert Apex called
    expect(cloneLeadRecord).toHaveBeenCalledWith({
      leadId: "00QExistingLeadId"
    });

    // Safely access SimpleToast mock instance
    const toastMock =
      SimpleToast.mock.results.length > 0
        ? SimpleToast.mock.results[SimpleToast.mock.results.length - 1].value
        : { success: jest.fn() };

    expect(toastMock.success).toHaveBeenCalledWith("Lead cloned successfully.");
  });

  // ────────────────────────────────────────────────
  it("shows info toast when clone returns null", async () => {
    cloneLeadRecord.mockResolvedValue(null);

    element.recordId = "00QExistingLeadId";
    await flushPromises();

    const toastMock =
      SimpleToast.mock.results.length > 0
        ? SimpleToast.mock.results[SimpleToast.mock.results.length - 1].value
        : { info: jest.fn() };

    expect(toastMock.info).toHaveBeenCalledWith(
      "Cloning initiated. Please refresh after a few seconds."
    );
  });

  // ────────────────────────────────────────────────
  it("handles Apex errors correctly", async () => {
    const error = new Error("Apex failed");
    cloneLeadRecord.mockRejectedValue(error);

    element.recordId = "00QExistingLeadId";
    await flushPromises();

    // Loosen assertion for first argument
    expect(handleErrorShowToast).toHaveBeenCalledWith(
      expect.any(Object),
      "Clone Failed",
      error,
      "Unable to clone the lead.",
      "dismissable"
    );
  });

  // ────────────────────────────────────────────────
  it("dispatches CloseActionScreenEvent after cloning completes", async () => {
    const dispatchSpy = jest.spyOn(element, "dispatchEvent");
    cloneLeadRecord.mockResolvedValue("00QFakeLeadId123");

    element.recordId = "00QExistingLeadId";
    await flushPromises();

    expect(dispatchSpy).toHaveBeenCalled();

    const dispatchedEvent = dispatchSpy.mock.calls[0][0];
    expect(dispatchedEvent.type).toBe("lightning__actionsclosescreen");
  });
});
