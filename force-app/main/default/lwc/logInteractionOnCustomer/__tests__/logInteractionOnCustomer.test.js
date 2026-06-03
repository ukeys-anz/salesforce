import { createElement } from "lwc";
import { CloseScreenEventName } from "lightning/actions";
import LogInteractionOnCustomer from "c/logInteractionOnCustomer";
import { getRecord } from "lightning/uiRecordApi";
import { getObjectInfo } from "lightning/uiObjectInfoApi";
import { setImmediate } from "timers";
import getCommentTypeMapping from "@salesforce/apex/CCRMLogInteractionController.getCommentTypeMapping";

const mockGetObjectInfo = require("./data/getObjectInfo.json");
const mockGetRecord = require("./data/getRecord.json");
const mockGetCapDiaryRecord = require("./data/getCapDiaryRecord.json");
const mockCommentType = require("./data/getCommentType.json");

jest.mock(
  "@salesforce/apex/CCRMLogInteractionController.getCommentTypeMapping",
  () => {
    return {
      default: jest.fn()
    };
  },
  { virtual: true }
);

jest.mock(
  "@salesforce/customPermission/logCAPNote",
  () => {
    return { default: false };
  },
  { virtual: true }
);

// Mock SimpleToast utility
const mockToast = {
  success: jest.fn(),
  error: jest.fn(),
  info: jest.fn(),
  warning: jest.fn()
};

jest.mock(
  "c/utils",
  () => {
    return {
      SimpleToast: jest.fn().mockImplementation(() => mockToast)
    };
  },
  { virtual: true }
);

const flushPromises = () => new Promise(setImmediate);

describe("c-log-interaction-on-customer - General functionality", () => {
  beforeEach(async () => {
    // Clear all mock calls
    jest.clearAllMocks();
    mockToast.success.mockClear();
    mockToast.error.mockClear();
    mockToast.info.mockClear();
    mockToast.warning.mockClear();

    getCommentTypeMapping.mockResolvedValue(mockCommentType);
    const element = createElement("c-log-interaction-on-customer", {
      is: LogInteractionOnCustomer
    });
    document.body.appendChild(element);
    // Wait for connectedCallback to complete
    await flushPromises();
  });

  afterEach(() => {
    // The jsdom instance is shared across test cases in a single file so reset the DOM
    while (document.body.firstChild) {
      document.body.removeChild(document.body.firstChild);
    }
    jest.clearAllMocks();
  });

  it("Test banker close the form", () => {
    const lwcCmp = document.querySelector("c-log-interaction-on-customer");
    const closeScreenHandler = jest.fn();

    lwcCmp.addEventListener(CloseScreenEventName, closeScreenHandler);

    lwcCmp.shadowRoot
      .querySelector(".btnCancel")
      .dispatchEvent(new CustomEvent("click"));

    return flushPromises().then(() => {
      expect(closeScreenHandler).toHaveBeenCalled();
    });
  });

  it("Test banker save the form", async () => {
    getObjectInfo.emit(mockGetObjectInfo);
    getRecord.emit(mockGetRecord);

    await flushPromises();
    const lwcCmp = document.querySelector("c-log-interaction-on-customer");
    const form = lwcCmp.shadowRoot.querySelector("lightning-record-edit-form");
    form.submit = jest.fn();
    form.dispatchEvent(new CustomEvent("submit", { detail: { fields: {} } }));
  });

  it("Test save CAP Diary Comments", async () => {
    getObjectInfo.emit(mockGetObjectInfo);
    getRecord.emit(mockGetCapDiaryRecord);

    await flushPromises();
    const lwcCmp = document.querySelector("c-log-interaction-on-customer");
    const inputElement = lwcCmp.shadowRoot.querySelectorAll(
      "lightning-input-field"
    );
    inputElement[0].value = "CAP Diary Comments";
    inputElement[0].dispatchEvent(
      new CustomEvent("change", { detail: { value: "CAP Diary Comments" } })
    );
    await flushPromises();
    const lookupEle = lwcCmp.shadowRoot.querySelector("c-lookup");
    lookupEle.dispatchEvent(
      new CustomEvent("select", {
        detail: { selected: { id: "a0F9h000001GMjxEAG" } }
      })
    );
    const form = lwcCmp.shadowRoot.querySelector("lightning-record-edit-form");
    form.submit = jest.fn();
    form.dispatchEvent(new CustomEvent("submit", { detail: { fields: {} } }));
  });

  it("Test Financial Account lookup search", async () => {
    getObjectInfo.emit(mockGetObjectInfo);

    await flushPromises();
    const lwcCmp = document.querySelector("c-log-interaction-on-customer");

    const inputElement = lwcCmp.shadowRoot.querySelectorAll(
      "lightning-input-field"
    );
    inputElement[0].value = "CAP Diary Comments";
    inputElement[0].dispatchEvent(
      new CustomEvent("change", { detail: { value: "CAP Diary Comments" } })
    );

    await flushPromises();
    const lookupEle = lwcCmp.shadowRoot.querySelector("c-lookup");

    expect(lookupEle).not.toBeNull();

    lookupEle.dispatchEvent(
      new CustomEvent("search", {
        detail: { searchKey: "test account" }
      })
    );

    await flushPromises();
    expect(lwcCmp.searchKey).toBe("test account");
  });

  it("Test Financial Account selection", async () => {
    getObjectInfo.emit(mockGetObjectInfo);

    await flushPromises();
    const lwcCmp = document.querySelector("c-log-interaction-on-customer");

    const inputElement = lwcCmp.shadowRoot.querySelectorAll(
      "lightning-input-field"
    );
    inputElement[0].value = "CAP Diary Comments";
    inputElement[0].dispatchEvent(
      new CustomEvent("change", { detail: { value: "CAP Diary Comments" } })
    );

    await flushPromises();
    const lookupEle = lwcCmp.shadowRoot.querySelector("c-lookup");

    const testFinancialAccountId = "a0F9h000001GMjxEAG";
    lookupEle.dispatchEvent(
      new CustomEvent("select", {
        detail: { selected: { id: testFinancialAccountId } }
      })
    );

    await flushPromises();
    expect(lwcCmp.financialAccountValue).toBe(testFinancialAccountId);
  });

  it("Test interaction fields are hidden when CAP Diary Comments selected", async () => {
    getObjectInfo.emit(mockGetObjectInfo);

    await flushPromises();
    const lwcCmp = document.querySelector("c-log-interaction-on-customer");

    // Manually trigger category change to show diary fields
    const inputElement = lwcCmp.shadowRoot.querySelectorAll(
      "lightning-input-field"
    );
    inputElement[0].value = "CAP Diary Comments";
    inputElement[0].dispatchEvent(
      new CustomEvent("change", { detail: { value: "CAP Diary Comments" } })
    );

    await flushPromises();

    // Verify interaction fields are not visible
    const interactionTypeField = lwcCmp.shadowRoot.querySelector(
      'lightning-input-field[field-name="Interaction_Type__c"]'
    );
    const nameField = lwcCmp.shadowRoot.querySelector(
      'lightning-input-field[field-name="Name"]'
    );

    expect(interactionTypeField).toBeNull();
    expect(nameField).toBeNull();
  });
});

describe("c-log-interaction-on-customer with retailLogCAPNote = false", () => {
  beforeEach(async () => {
    // Clear all mock calls
    jest.clearAllMocks();
    mockToast.success.mockClear();
    mockToast.error.mockClear();
    mockToast.info.mockClear();
    mockToast.warning.mockClear();

    getCommentTypeMapping.mockResolvedValue(mockCommentType);
    const element = createElement("c-log-interaction-on-customer", {
      is: LogInteractionOnCustomer
    });
    document.body.appendChild(element);
    // Wait for connectedCallback to complete
    await flushPromises();
  });

  afterEach(() => {
    while (document.body.firstChild) {
      document.body.removeChild(document.body.firstChild);
    }
    jest.clearAllMocks();
  });

  it("Test record type is CCRM Interaction when retailLogCAPNote is false", async () => {
    getObjectInfo.emit(mockGetObjectInfo);

    await flushPromises();
    const lwcCmp = document.querySelector("c-log-interaction-on-customer");
    lwcCmp.retailLogCAPNote = false;

    // Wait for objectData to be populated
    await flushPromises();

    // Verify the form has the correct record-type-id attribute
    const form = lwcCmp.shadowRoot.querySelector("lightning-record-edit-form");
    expect(form.recordTypeId).toBe("012Oa000000di2oIAA");
  });

  it("Test header is 'Log Interaction' when retailLogCAPNote is false", async () => {
    getObjectInfo.emit(mockGetObjectInfo);

    await flushPromises();
    const lwcCmp = document.querySelector("c-log-interaction-on-customer");
    lwcCmp.retailLogCAPNote = false;

    // Wait for component to render
    await flushPromises();

    // Verify the header is displayed in the quick action panel
    const panel = lwcCmp.shadowRoot.querySelector(
      "lightning-quick-action-panel"
    );
    expect(panel.header).toBe("Log Interaction");
  });

  it("Test success toast shows 'Interaction Created Successfully' when retailLogCAPNote is false", async () => {
    getObjectInfo.emit(mockGetObjectInfo);
    getRecord.emit(mockGetRecord);

    await flushPromises();
    const lwcCmp = document.querySelector("c-log-interaction-on-customer");
    lwcCmp.retailLogCAPNote = false;

    // Trigger form success event
    const form = lwcCmp.shadowRoot.querySelector("lightning-record-edit-form");
    form.dispatchEvent(new CustomEvent("success"));

    await flushPromises();

    // Verify toast.success was called
    expect(mockToast.success).toHaveBeenCalledWith(
      "Interaction Created Successfully."
    );
  });

  it("Test permanent note warning is not displayed when retailLogCAPNote is false", async () => {
    getObjectInfo.emit(mockGetObjectInfo);

    await flushPromises();
    const lwcCmp = document.querySelector("c-log-interaction-on-customer");
    lwcCmp.retailLogCAPNote = false;

    await flushPromises();

    // Verify the permanent note warning notification is not displayed
    const notification = lwcCmp.shadowRoot.querySelector(
      ".slds-scoped-notification"
    );
    expect(notification).toBeNull();
  });
});

describe("c-log-interaction-on-customer with retailLogCAPNote = true", () => {
  beforeEach(async () => {
    // Clear all mock calls
    jest.clearAllMocks();
    mockToast.success.mockClear();
    mockToast.error.mockClear();
    mockToast.info.mockClear();
    mockToast.warning.mockClear();

    // Mock the custom permission to return true
    jest.resetModules();
    jest.doMock(
      "@salesforce/customPermission/logCAPNote",
      () => {
        return { default: true };
      },
      { virtual: true }
    );

    getCommentTypeMapping.mockResolvedValue(mockCommentType);

    const element = createElement("c-log-interaction-on-customer", {
      is: LogInteractionOnCustomer
    });
    document.body.appendChild(element);
    // Wait for connectedCallback to complete
    await flushPromises();
  });

  afterEach(() => {
    while (document.body.firstChild) {
      document.body.removeChild(document.body.firstChild);
    }
    jest.clearAllMocks();
  });

  it("Test record type is Retail Interaction when retailLogCAPNote is true", async () => {
    getObjectInfo.emit(mockGetObjectInfo);

    await flushPromises();
    const lwcCmp = document.querySelector("c-log-interaction-on-customer");
    lwcCmp.retailLogCAPNote = true;

    // Wait for objectData to be populated
    await flushPromises();

    // Verify the form has the correct record-type-id attribute
    const form = lwcCmp.shadowRoot.querySelector("lightning-record-edit-form");
    expect(form.recordTypeId).toBe("012Oa000000di2qIAA");
  });

  it("Test header is 'Log CAP Note' when retailLogCAPNote is true", async () => {
    getObjectInfo.emit(mockGetObjectInfo);

    await flushPromises();
    const lwcCmp = document.querySelector("c-log-interaction-on-customer");
    lwcCmp.retailLogCAPNote = true;

    // Wait for component to render
    await flushPromises();

    // Verify the header is displayed in the quick action panel
    const panel = lwcCmp.shadowRoot.querySelector(
      "lightning-quick-action-panel"
    );
    expect(panel.header).toBe("Log CAP Note");
  });

  it("Test CAP Diary Comments category shows diary fields when retailLogCAPNote is true", async () => {
    getObjectInfo.emit(mockGetObjectInfo);

    await flushPromises();
    const lwcCmp = document.querySelector("c-log-interaction-on-customer");
    lwcCmp.retailLogCAPNote = true;

    // Manually trigger category change to show diary fields
    const inputElement = lwcCmp.shadowRoot.querySelectorAll(
      "lightning-input-field"
    );
    inputElement[0].value = "CAP Diary Comments";
    inputElement[0].dispatchEvent(
      new CustomEvent("change", { detail: { value: "CAP Diary Comments" } })
    );

    await flushPromises();

    // Verify diary fields are visible
    const lookupEle = lwcCmp.shadowRoot.querySelector("c-lookup");
    expect(lookupEle).not.toBeNull();

    // Verify interaction fields are hidden
    const interactionTypeField = lwcCmp.shadowRoot.querySelector(
      'lightning-input-field[field-name="Interaction_Type__c"]'
    );
    expect(interactionTypeField).toBeNull();
  });

  it("Test info toast shows CAP note submission message when retailLogCAPNote is true", async () => {
    getObjectInfo.emit(mockGetObjectInfo);
    getRecord.emit(mockGetRecord);

    await flushPromises();
    const lwcCmp = document.querySelector("c-log-interaction-on-customer");
    lwcCmp.retailLogCAPNote = true;

    // Trigger form success event
    const form = lwcCmp.shadowRoot.querySelector("lightning-record-edit-form");
    form.dispatchEvent(new CustomEvent("success"));

    await flushPromises();

    // Verify toast.info was called with the correct message
    expect(mockToast.info).toHaveBeenCalledWith(
      "Notes have been submitted to CAP, but we cannot confirm whether it has been saved successfully. Please check the CAP Diary Comments table to verify."
    );
  });

  it("Test default comment type is 'Other' when retailLogCAPNote is true", async () => {
    getObjectInfo.emit(mockGetObjectInfo);

    await flushPromises();
    const lwcCmp = document.querySelector("c-log-interaction-on-customer");

    // Verify comment type is set to "Other" by default for retail users
    expect(lwcCmp.commentTypeValue).toBe("Other");
  });

  it("Test permanent note warning is displayed when retailLogCAPNote is true", async () => {
    getObjectInfo.emit(mockGetObjectInfo);

    await flushPromises();
    const lwcCmp = document.querySelector("c-log-interaction-on-customer");

    // Manually trigger category change to CAP Diary Comments to show permanent note warning
    const inputElement = lwcCmp.shadowRoot.querySelectorAll(
      "lightning-input-field"
    );
    inputElement[0].value = "CAP Diary Comments";
    inputElement[0].dispatchEvent(
      new CustomEvent("change", { detail: { value: "CAP Diary Comments" } })
    );

    await flushPromises();

    // Verify the permanent note warning notification is displayed
    const notification = lwcCmp.shadowRoot.querySelector(
      ".slds-scoped-notification"
    );
    expect(notification).not.toBeNull();

    const notificationText = notification.textContent;
    expect(notificationText).toContain(
      "Only 1 permanent note is allowed per customer profile or account record"
    );
  });

  it("Test error toast is shown for CACHE customer CAP diary comment", async () => {
    const mockCacheRecord = {
      ...mockGetRecord,
      data: {
        ...mockGetRecord.data,
        fields: {
          Source_System_Name__c: { value: "CACHE" }
        }
      }
    };

    getObjectInfo.emit(mockGetObjectInfo);
    getRecord.emit(mockCacheRecord);

    await flushPromises();
    const lwcCmp = document.querySelector("c-log-interaction-on-customer");

    // Change category to CAP Diary Comments
    const inputElement = lwcCmp.shadowRoot.querySelectorAll(
      "lightning-input-field"
    );
    inputElement[0].value = "CAP Diary Comments";
    inputElement[0].dispatchEvent(
      new CustomEvent("change", { detail: { value: "CAP Diary Comments" } })
    );

    await flushPromises();

    // Trigger form submit event
    const form = lwcCmp.shadowRoot.querySelector("lightning-record-edit-form");
    form.dispatchEvent(
      new CustomEvent("submit", {
        detail: { fields: { Category__c: "CAP Diary Comments" } }
      })
    );

    await flushPromises();

    // Verify toast.error was called with the correct message
    expect(mockToast.error).toHaveBeenCalledWith(
      "You can't create CAP diary comment for cache customer."
    );
  });
});
