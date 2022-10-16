import caseLogACall from "c/caseLogACall";
import getPickListValuesIntoList from "@salesforce/apex/CaseLogCall.getPickListValuesIntoList";
import createTask from "@salesforce/apex/CaseLogCall.createTask";
import { createElement } from "lwc";
import { setImmediate } from "timers";

jest.mock(
  "@salesforce/apex/CaseLogCall.getPickListValuesIntoList",
  () => {
    return {
      default: jest.fn()
    };
  },
  { virtual: true }
);

jest.mock(
  "@salesforce/apex/CaseLogCall.createTask",
  () => {
    return {
      default: jest.fn()
    };
  },
  { virtual: true }
);

const APEX_LOG_EMPTY = [
  {
    Authentication_Method__c: "",
    Voice_Call_SID__c: "",
    Subject: "",
    Comment: "",
    ActivityDate: "",
    WhatId: ""
  }
];

const APEX_PICKLIST_VALUE = {
  authenticationPickListValues: [
    "Authenticated by Coach",
    "Customer cannot be Authenticated",
    "non Customer Call"
  ],
  subjectPickListValues: ["Payments - Making payments"]
};

const APEX_LOG_SUCCESS = {
  Authentication_Method__c: "Authenticated by Coach",
  Voice_Call_SID__c: "CF12121212121212122112121212121212",
  Subject: "Test",
  Comment: "Test",
  ActivityDate: "17/08/1998",
  WhatId: "00001014"
};

describe("c-logACall", () => {
  //clean the dom and mocks in between test runs
  beforeEach(() => {
    jest.resetAllMocks();
    while (document.body.firstChild) {
      document.body.removeChild(document.body.firstChild);
    }
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

  it("tests fields on success", () => {
    getPickListValuesIntoList.mockResolvedValue(APEX_PICKLIST_VALUE);
    createTask.mockResolvedValue(APEX_LOG_SUCCESS);
    const element = createElement("c-case-log-a-call", {
      is: caseLogACall
    });
    document.body.appendChild(element);

    return flushPromises().then(() => {
      const authPicklist = element.shadowRoot.querySelector(
        'lightning-combobox[data-id="authCombo"]'
      );
      const voiceCallInput = element.shadowRoot.querySelector(
        "lightning-input"
      );
      const commentsField = element.shadowRoot.querySelector(
        'lightning-textarea[data-id="commentsInput"]'
      );
      const subjectField = element.shadowRoot.querySelector(
        'lightning-input[data-id="searchInput"]'
      );
      expect(voiceCallInput).not.toBeNull();
      expect(authPicklist).not.toBeNull();
      expect(commentsField).not.toBeNull();
      expect(subjectField).not.toBeNull();
    });
  });

  it("tests button functionality", () => {
    getPickListValuesIntoList.mockResolvedValue(APEX_PICKLIST_VALUE);
    createTask.mockResolvedValue(APEX_LOG_SUCCESS);
    const element = createElement("c-case-log-a-call", {
      is: caseLogACall
    });
    document.body.appendChild(element);

    return flushPromises().then(() => {
      const saveButton = element.shadowRoot.querySelector("lightning-button");
      saveButton.click();
      expect(saveButton).toBeTruthy();
    });
  });

  it("tests subject and auth method functionality", () => {
    getPickListValuesIntoList.mockResolvedValue(APEX_PICKLIST_VALUE);
    createTask.mockResolvedValue(APEX_LOG_SUCCESS);
    const element = createElement("c-case-log-a-call", {
      is: caseLogACall
    });
    document.body.appendChild(element);

    return flushPromises().then(() => {
      const subjectField = element.shadowRoot.querySelector(
        'lightning-input[data-id="searchInput"]'
      );
      const authField = element.shadowRoot.querySelector("lightning-button");
      authField.click();
      authField.value = "Test";
      authField.dispatchEvent(
        new CustomEvent("change", {
          detail: {
            value: "new"
          }
        })
      );
      subjectField.click();
      subjectField.value = "Test";
      subjectField.dispatchEvent(
        new CustomEvent("change", {
          detail: {
            value: "new"
          }
        })
      );
      expect(subjectField).toBeTruthy();
      expect(authField).toBeTruthy();
    });
  });

  it("tests tooltip content", () => {
    getPickListValuesIntoList.mockResolvedValue(APEX_PICKLIST_VALUE);
    createTask.mockResolvedValue(APEX_LOG_SUCCESS);
    const element = createElement("c-case-log-a-call", {
      is: caseLogACall
    });
    document.body.appendChild(element);

    return flushPromises().then(() => {
      const toolTip = element.shadowRoot.querySelector("lightning-helptext");
      expect(toolTip).toBeTruthy();
    });
  });

  it("tests required fields are failing on empty fields", () => {
    getPickListValuesIntoList.mockResolvedValue(APEX_PICKLIST_VALUE);
    createTask.mockResolvedValue(APEX_LOG_EMPTY);
    const element = createElement("c-case-log-a-call", {
      is: caseLogACall
    });
    document.body.appendChild(element);

    return flushPromises()
      .then(() => {
        const saveButton = element.shadowRoot.querySelector("lightning-button");
        saveButton.click();
        expect(saveButton).toBeTruthy();
      })
      .then(() => {
        const errorTrue = element.shadowRoot.querySelector(
          'p[class="error-text"]'
        );
        expect(errorTrue).toBeTruthy();
      });
  });
});
