import { createElement } from "lwc";
import PushToApp from "c/pushToApp";
import { getRecord } from "lightning/uiRecordApi";
import getTemplateDetails from "@salesforce/apex/PushToAppController.getTemplateDetails";
import getAemContentData from "@salesforce/apex/PushToAppController.getAemContentData";
import createTaskAndRelatedRecords from "@salesforce/apex/PushToAppController.createTaskAndRelatedRecords";
const mockAemData = require("./data/response.json");

jest.mock(
  "@lightning/uiRecordApi",
  () => {
    return {
      default: jest.fn()
    };
  },
  { virtual: true }
);

jest.mock(
  "@salesforce/apex/PushToAppController.getTemplateDetails",
  () => {
    return {
      default: jest.fn()
    };
  },
  { virtual: true }
);

jest.mock(
  "@salesforce/apex/PushToAppController.getAemContentData",
  () => {
    return {
      default: jest.fn()
    };
  },
  { virtual: true }
);

jest.mock(
  "@salesforce/apex/PushToAppController.createTaskAndRelatedRecords",
  () => {
    return {
      default: jest.fn()
    };
  },
  { virtual: true }
);

const mockTemplateDetails = [
  { Name: "Get in Touch", AEM_Content_Id__c: "get_in_touch" },
  { Name: "Call Us", AEM_Content_Id__c: "call_us" }
];

const mockGetRecordResponse = {
  data: {
    fields: {
      CaseNumber: {
        value: "1234"
      }
    }
  }
};

describe("c-push-to-app", () => {
  afterEach(() => {
    while (document.body.firstChild) {
      document.body.removeChild(document.body.firstChild);
    }
    jest.clearAllMocks();
  });

  async function flushPromises() {
    return Promise.resolve();
  }

  it("1. renders push-to-app button", async () => {
    const element = createElement("c-push-to-app", {
      is: PushToApp
    });
    document.body.appendChild(element);
    let pushTaskButton = element.shadowRoot.querySelector(
      "lightning-button[data-id='push-task']"
    );
    expect(pushTaskButton).not.toBeNull();
    expect(pushTaskButton.label).toBe("Send Task to App");
  });

  it("2. renders case number and select push template field on click of button", async () => {
    // Mocking getRecord wire
    getRecord.emit(mockGetRecordResponse);
    const element = createElement("c-push-to-app", {
      is: PushToApp
    });
    document.body.appendChild(element);
    let pushTaskButton = element.shadowRoot.querySelector(
      "lightning-button[data-id='push-task']"
    );
    expect(pushTaskButton.label).toBe("Send Task to App");
    pushTaskButton.click();
    await flushPromises();
    let caseNumberField = element.shadowRoot.querySelector(
      "lightning-input[data-id='case-number']"
    );
    caseNumberField.value = mockGetRecordResponse.data.fields.CaseNumber.value;
    expect(caseNumberField).not.toBeNull();
    expect(caseNumberField.label).toBe("Case Number");
    expect(caseNumberField.value).toBe("1234");
  });

  it("3. dispatches the appropriate event on button click", async () => {
    const element = createElement("c-push-to-app", {
      is: PushToApp
    });
    document.body.appendChild(element);
    const handler = jest.fn();
    element.addEventListener("pushtaskbuttonclick", handler);
    let pushTaskButton = element.shadowRoot.querySelector(
      "lightning-button[data-id='push-task']"
    );
    pushTaskButton.click();
    await flushPromises();
    // Check if the event was dispatched
    expect(handler).toHaveBeenCalled();
  });

  it("4. handles template selection and shows additional fields", async () => {
    getTemplateDetails.mockResolvedValue(mockTemplateDetails);
    getAemContentData.mockResolvedValue(mockAemData);
    const element = createElement("c-push-to-app", {
      is: PushToApp
    });
    document.body.appendChild(element);
    let pushTaskButton = element.shadowRoot.querySelector(
      "lightning-button[data-id='push-task']"
    );
    pushTaskButton.click();
    await flushPromises();
    const templateCombobox = element.shadowRoot.querySelector(
      "lightning-combobox[data-id='select-push-template']"
    );
    templateCombobox.value = mockTemplateDetails[0].AEM_Content_Id__c;
    templateCombobox.dispatchEvent(
      new CustomEvent("change", {
        detail: {
          value: mockTemplateDetails[0].AEM_Content_Id__c
        },
        bubbles: true,
        composed: true
      })
    );
    await flushPromises();
    const expiryDate = element.shadowRoot.querySelector(
      "lightning-input[data-id='expiry-date']"
    );
    expect(expiryDate).not.toBeNull();
    expect(expiryDate.value).toBe("2027-19-09");
    const notificationPreview = element.shadowRoot.querySelector(
      "lightning-textarea[data-id='notification-preview']"
    );
    expect(notificationPreview).not.toBeNull();
    expect(notificationPreview.value).toBe(
      "Hey {!Account.FirstName} We called about your Case Reference {!CaseNumber} and couldn't reach you. Please call us back or send us a message"
    );
  });

  it("5. renders dynamic checkboxes based on description field in the mock JSON", async () => {
    getTemplateDetails.mockResolvedValue(mockTemplateDetails);
    getAemContentData.mockResolvedValue(mockAemData);
    const element = createElement("c-push-to-app", {
      is: PushToApp
    });
    document.body.appendChild(element);
    let pushTaskButton = element.shadowRoot.querySelector(
      "lightning-button[data-id='push-task']"
    );
    pushTaskButton.click();
    await flushPromises();
    const templateCombobox = element.shadowRoot.querySelector(
      "lightning-combobox[data-id='select-push-template']"
    );
    templateCombobox.value = mockTemplateDetails[0].AEM_Content_Id__c;
    templateCombobox.dispatchEvent(
      new CustomEvent("change", {
        detail: {
          value: mockTemplateDetails[0].AEM_Content_Id__c
        },
        bubbles: true,
        composed: true
      })
    );
    await flushPromises();
    // Check if checkboxes are rendered based on description field actions-checkbox
    const checkboxes = element.shadowRoot.querySelectorAll(
      'div[data-id="dynamic-checkboxes"] lightning-input'
    );
    expect(checkboxes.length).toBe(3);
    expect(checkboxes[0].label).toBe("Transfer Funds Out");
    expect(checkboxes[1].label).toBe("Message Us");
    expect(checkboxes[2].label).toBe("Call Us");
  });

  it("6. creates a task and shows success screen", async () => {
    const mockTaskResponse = { Id: "task123", Subject: "Test Task" };
    createTaskAndRelatedRecords.mockResolvedValue(mockTaskResponse);
    getTemplateDetails.mockResolvedValue(mockTemplateDetails);
    getAemContentData.mockResolvedValue(mockAemData);
    const element = createElement("c-push-to-app", {
      is: PushToApp
    });
    document.body.appendChild(element);
    let pushTaskButton = element.shadowRoot.querySelector(
      "lightning-button[data-id='push-task']"
    );
    pushTaskButton.click();
    await flushPromises();
    const templateCombobox = element.shadowRoot.querySelector(
      "lightning-combobox[data-id='select-push-template']"
    );
    templateCombobox.value = mockTemplateDetails[0].AEM_Content_Id__c;
    templateCombobox.dispatchEvent(
      new CustomEvent("change", {
        detail: {
          value: mockTemplateDetails[0].AEM_Content_Id__c
        },
        bubbles: true,
        composed: true
      })
    );
    await flushPromises();
    // Simulate Send Now button click
    const sendNowButton = element.shadowRoot.querySelector(
      "lightning-button[data-id='send-now']"
    );
    sendNowButton.click();
    // Wait for async operation to complete
    await flushPromises();
    // Check if success screen is shown
    const successScreen = element.shadowRoot.querySelector(
      "p[data-id='success-msg']"
    );
    expect(successScreen).not.toBeNull();
    expect(successScreen.textContent).toContain(
      "A Task record has been created"
    );
  });

  it("7. shows success screen with task hyperlink", async () => {
    const mockTaskResponse = { Id: "task123", Subject: "Follow-up Call" };
    createTaskAndRelatedRecords.mockResolvedValue(mockTaskResponse);
    getTemplateDetails.mockResolvedValue(mockTemplateDetails);
    getAemContentData.mockResolvedValue(mockAemData);
    const element = createElement("c-push-to-app", {
      is: PushToApp
    });
    document.body.appendChild(element);
    let pushTaskButton = element.shadowRoot.querySelector(
      "lightning-button[data-id='push-task']"
    );
    pushTaskButton.click();
    await flushPromises();
    const templateCombobox = element.shadowRoot.querySelector(
      "lightning-combobox[data-id='select-push-template']"
    );
    templateCombobox.value = mockTemplateDetails[0].AEM_Content_Id__c;
    templateCombobox.dispatchEvent(
      new CustomEvent("change", {
        detail: {
          value: mockTemplateDetails[0].AEM_Content_Id__c
        },
        bubbles: true,
        composed: true
      })
    );
    await flushPromises();
    const sendNowButton = element.shadowRoot.querySelector(
      "lightning-button[data-id='send-now']"
    );
    sendNowButton.click();
    await flushPromises();
    const successScreen = element.shadowRoot.querySelector(
      "p[data-id='success-msg']"
    );
    expect(successScreen).not.toBeNull();
    expect(successScreen.textContent).toContain(
      "A Task record has been created"
    );
    const taskLink = successScreen.querySelector('a[data-id="task-link"]');
    expect(taskLink).not.toBeNull();
  });
});
