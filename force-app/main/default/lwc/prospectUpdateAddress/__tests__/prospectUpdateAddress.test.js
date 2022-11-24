import { createElement } from "lwc";
import { CloseScreenEventName } from "lightning/actions";
import ProspectUpdateAddress from "c/prospectUpdateAddress";
import { getRecord } from "lightning/uiRecordApi";
import { getObjectInfo } from "lightning/uiObjectInfoApi";
import { CurrentPageReference } from "lightning/navigation";
import { setImmediate } from "timers";

const flushPromises = () => new Promise(setImmediate);

const mockGetObjectInfo = require("./data/getObjectInfo.json");
const mockGetRecord = require("./data/getRecord.json");

describe("c-prospect-update-address", () => {
  //Prepare data before each test method
  beforeEach(() => {
    const element = createElement("c-prospect-update-address", {
      is: ProspectUpdateAddress
    });
    document.body.appendChild(element);
  });

  afterEach(() => {
    // The jsdom instance is shared across test cases in a single file so reset the DOM
    while (document.body.firstChild) {
      document.body.removeChild(document.body.firstChild);
    }
  });

  it("Test banker close the form", () => {
    const lwcCmp = document.querySelector("c-prospect-update-address");
    const closeScreenHandler = jest.fn();
    const closeTabHanlder = jest.fn();

    lwcCmp.addEventListener(CloseScreenEventName, closeScreenHandler);
    lwcCmp.addEventListener("close", closeTabHanlder);

    lwcCmp.shadowRoot
      .querySelector(".btnCancel")
      .dispatchEvent(new CustomEvent("click"));

    return flushPromises().then(() => {
      expect(closeTabHanlder).toHaveBeenCalled();
      expect(closeScreenHandler).toHaveBeenCalled();
    });
  });

  it("Test banker save the form", async () => {
    getObjectInfo.emit(mockGetObjectInfo);
    getRecord.emit(mockGetRecord);

    await flushPromises();
    const lwcCmp = document.querySelector("c-prospect-update-address");
    const form = lwcCmp.shadowRoot.querySelector("lightning-record-edit-form");
    form.submit = jest.fn();
    form.dispatchEvent(new CustomEvent("submit", { detail: { fields: {} } }));

    await flushPromises();
    expect(form.submit).toHaveBeenCalled();
    expect(form.submit.mock.calls[0][0].Global_Address_Key__c).toBe(
      mockGetRecord.fields.Global_Address_Key__c.value
    );
  });
});
