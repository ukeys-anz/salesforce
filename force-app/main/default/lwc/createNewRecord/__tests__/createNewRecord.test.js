import { createElement } from "lwc";
import CreateNewRecord from "c/createNewRecord";
import { getObjectInfo } from "lightning/uiObjectInfoApi";
import { getNavigateCalledWith } from "lightning/navigation";
import { encodeDefaultFieldValues } from "lightning/pageReferenceUtils";
import { ShowToastEventName } from "lightning/platformShowToastEvent";

const mockGetObjectInfo = require("./data/getObjectInfo.json");
const objectApiName = "Case";
const recordTypeName = "General Enquiry";
const buttonLabel = "Create New Case";
const defaultFieldValues = {
  Transaction_Id__c: "2597d849-6b74-4310-9824-bc0030551ab3",
  Type: "Profile",
  Sub_Type__c: "Suspect ConnectID Fraud",
  Priority: "High",
  Description:
    "ConnectID Provider: BWS\nConnectID Transaction Reference: 2597d849-6b74-4310-9824-bc0030551ab3"
};

describe("c-create-new-record", () => {
  beforeEach(() => {
    const element = createElement("c-create-new-record", {
      is: CreateNewRecord
    });
    document.body.appendChild(element);
  });

  afterEach(() => {
    // The jsdom instance is shared across test cases in a single file so reset the DOM
    while (document.body.firstChild) {
      document.body.removeChild(document.body.firstChild);
    }

    // Reset the navigation mock between tests
    jest.clearAllMocks();
  });

  // Helper function to wait until the microtask queue is empty.
  async function flushPromises() {
    return Promise.resolve();
  }

  it("element is accessible", async () => {
    const element = document.querySelector("c-create-new-record");

    element.objectApiName = objectApiName;
    element.recordTypeName = recordTypeName;

    // Emit data from @wire
    getObjectInfo.emit(mockGetObjectInfo);

    await flushPromises();

    // Check accessibility
    await expect(element).toBeAccessible();
  });

  it("shows error toast on @wire objectInfo error", async () => {
    const element = document.querySelector("c-create-new-record");
    const showToastHandler = jest.fn();

    element.addEventListener(ShowToastEventName, showToastHandler);

    // Emit error from @wire
    getObjectInfo.error();

    // Verify if toast message appeared
    await flushPromises().then(() => {
      expect(showToastHandler).toHaveBeenCalled();
      const toastMessage = showToastHandler.mock.calls[0][0];
      expect(toastMessage.detail.variant).toBe("error");
      expect(toastMessage.detail.title).toBe("Error");
    });
  });

  it("navigates to new record page with all state attributes available", async () => {
    const element = document.querySelector("c-create-new-record");

    element.objectApiName = objectApiName;
    element.recordTypeName = recordTypeName;
    element.defaultFieldValues = defaultFieldValues;
    element.buttonLabel = buttonLabel;

    // Wait for any asynchronous DOM updates
    await flushPromises();

    // Get handle to button and invoke click
    const buttonEl = element.shadowRoot.querySelector("lightning-button");
    buttonEl.click();

    const { pageReference } = getNavigateCalledWith();

    // Verify component called with correct event type and params
    expect(pageReference.type).toBe("standard__objectPage");
    expect(pageReference.attributes.objectApiName).toBe(objectApiName);
    expect(pageReference.attributes.actionName).toBe("new");
    expect(pageReference.state.defaultFieldValues).toBe(
      encodeDefaultFieldValues(defaultFieldValues)
    );
    expect(pageReference.state.recordTypeId).not.toBeNull;
  });

  it("navigates to new record page with no default field values", async () => {
    const element = document.querySelector("c-create-new-record");

    element.objectApiName = objectApiName;
    element.defaultFieldValues = null;

    // Wait for any asynchronous DOM updates
    await flushPromises();

    // Get handle to button and invoke click
    const buttonEl = element.shadowRoot.querySelector("lightning-button");
    buttonEl.click();

    const { pageReference } = getNavigateCalledWith();

    // Verify component called with correct event type and params
    expect(pageReference.type).toBe("standard__objectPage");
    expect(pageReference.attributes.objectApiName).toBe(objectApiName);
    expect(pageReference.attributes.actionName).toBe("new");
    expect(pageReference.state.defaultFieldValues).toBeNull;
  });

  it("navigates to new record page with no default record type", async () => {
    const element = document.querySelector("c-create-new-record");

    element.objectApiName = objectApiName;
    element.recordTypeName = null;

    // Wait for any asynchronous DOM updates
    await flushPromises();

    // Get handle to button and invoke click
    const buttonEl = element.shadowRoot.querySelector("lightning-button");
    buttonEl.click();

    const { pageReference } = getNavigateCalledWith();

    // Verify component called with correct event type and params
    expect(pageReference.type).toBe("standard__objectPage");
    expect(pageReference.attributes.objectApiName).toBe(objectApiName);
    expect(pageReference.attributes.actionName).toBe("new");
    expect(pageReference.state.recordTypeId).toBeNull;
  });

  it("navigates to new record page with no default button label", async () => {
    const element = document.querySelector("c-create-new-record");

    element.objectApiName = objectApiName;
    element.buttonLabel = null;

    // Wait for any asynchronous DOM updates
    await flushPromises();

    // Get handle to button and invoke click
    const buttonEl = element.shadowRoot.querySelector("lightning-button");

    // Verify component called with correct event type and params
    expect(buttonEl.label).toBe("Create New Record");
  });
});
