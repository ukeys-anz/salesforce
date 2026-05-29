import { createElement } from "lwc";
import { setImmediate } from "timers";
import CddStatus from "c/ocddStatus";
import { getRecord } from "lightning/uiRecordApi";
import fetchOCDDStatus from "@salesforce/apex/ocddController.getOCDDKycReviewStatus";

const WIRED_ACCOUNT = require("./data/getRecord.json");

jest.mock(
  "@salesforce/apex/ocddController.getOCDDKycReviewStatus",
  () => {
    return {
      default: jest.fn()
    };
  },
  { virtual: true }
);

const flushPromises = () => new Promise((resolve) => setImmediate(resolve));

describe("c-ocdd-status", () => {
  afterEach(() => {
    while (document.body.firstChild) {
      document.body.removeChild(document.body.firstChild);
    }
    jest.clearAllMocks();
  });

  it("renders OCDD status when callout succeeds", async () => {
    fetchOCDDStatus.mockResolvedValue("Complaint");

    const element = createElement("c-ocdd-status", {
      is: CddStatus
    });
    element.recordId = "001000000000001";
    document.body.appendChild(element);

    getRecord.emit(WIRED_ACCOUNT);
    await flushPromises();

    const content = element.shadowRoot.textContent;
    expect(content).toContain("OCDD Status");
    expect(content).toContain("Complaint");
  });

  it("renders error message when callout fails", async () => {
    fetchOCDDStatus.mockRejectedValue({
      body: { message: "Unable to load OCDD status" }
    });

    const element = createElement("c-ocdd-status", {
      is: CddStatus
    });
    element.recordId = "001000000000002";
    document.body.appendChild(element);

    getRecord.emit(WIRED_ACCOUNT);
    await flushPromises();

    const content = element.shadowRoot.textContent;
    expect(content).toContain("Unable to load OCDD status");
  });
});
