import CobCaseStatusPath from "c/cobCaseStatusPath";
import { createElement } from "lwc";
import { setImmediate } from "timers";
import { getRecord } from "lightning/uiRecordApi";
import { getPicklistValues } from "lightning/uiObjectInfoApi";

const mockGetRecord = require("./data/getRecord.json");
const mockGetStatusFieldInfo = require("./data/getStatusFieldInfo.json");
const mockGetFailedReasonFieldInfo = require("./data/getFailedReasonFieldInfo.json");

describe("c-cob-case-status-path", () => {
  //clean the dom and mocks in between test runs
  beforeEach(() => {
    jest.resetAllMocks();
    while (document.body.firstChild) {
      document.body.removeChild(document.body.firstChild);
    }

    // Emit data from @wire
    getRecord.emit(mockGetRecord);
    getPicklistValues.emit(mockGetStatusFieldInfo);
    getPicklistValues.emit(mockGetFailedReasonFieldInfo);
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

  it("test clicking Update Status button and modal rendered", async () => {
    const element = createElement("c-cob-case-status-path", {
      is: CobCaseStatusPath
    });

    document.body.appendChild(element);

    const button = element.shadowRoot.querySelector("lightning-button");
    expect(button).toBeTruthy();
    button.click();
    await flushPromises();

    const modal = element.shadowRoot.querySelector(".slds-modal__container");
    expect(modal).toBeTruthy();
  });

  it("test Failed OK status and dependent picklist is present and selectable", async () => {
    const element = createElement("c-cob-case-status-path", {
      is: CobCaseStatusPath
    });

    document.body.appendChild(element);

    const button = element.shadowRoot.querySelector("lightning-button");
    button.click();
    await flushPromises();

    const statusElement = element.shadowRoot.querySelector(
      "lightning-combobox.status"
    );
    statusElement.value = "Failed";
    statusElement.dispatchEvent(
      new CustomEvent("change", {
        detail: { value: statusElement.value }
      })
    );

    const failedReasonElement = element.shadowRoot.querySelector(
      "lightning-combobox.failedReason"
    );
    expect(failedReasonElement).toBeTruthy;
  });
});
