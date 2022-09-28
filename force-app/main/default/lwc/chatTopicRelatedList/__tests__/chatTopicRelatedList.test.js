import { createElement } from "lwc";
import { getRecord } from "lightning/uiRecordApi";
import ChatTopicRelatedList from "c/chatTopicRelatedList";
import getChatTopicsOnAccount from "@salesforce/apex/ChatTopicRelatedListController.getChatTopicsOnAccount";
import getChatTopicInfoOnCase from "@salesforce/apex/ChatTopicRelatedListController.getChatTopicInfoOnCase";
import { setImmediate } from "timers";

jest.mock(
  "@salesforce/apex/ChatTopicRelatedListController.getChatTopicsOnAccount",
  () => {
    return {
      default: jest.fn()
    };
  },
  { virtual: true }
);

jest.mock(
  "@salesforce/apex/ChatTopicRelatedListController.getChatTopicInfoOnCase",
  () => {
    return {
      default: jest.fn()
    };
  },
  { virtual: true }
);

const CHAT_TOPIC_EMPTY = [];
const CHAT_TOPIC_EMPTY_CASE = {};
const CHAT_TOPIC_MULTIPLE = require("./data/chatChannelsSuccess.json");
const CHAT_TOPIC_SINGLE = require("./data/singleChatChannel.json");

const MOCK_ACCOUNT_RECORD = require("./data/getAccountRecord.json");
const MOCK_CASE_RECORD = require("./data/getCaseRecord.json");

//This record also includes some account data as we are unable
//to make multiple mock wire calls in one test
const MOCK_QA_USER_RECORD = require("./data/getQAUserRecord.json");
const MOCK_COACH_USER_RECORD = require("./data/getCoachUserRecord.json");

describe("c-chat-topic-related-list", () => {
  afterEach(() => {
    // The jsdom instance is shared across test cases in a single file so reset the DOM
    while (document.body.firstChild) {
      document.body.removeChild(document.body.firstChild);
    }
    jest.clearAllMocks();
  });

  function flushPromises() {
    return new Promise((resolve) => setImmediate(resolve));
  }

  it("tests account empty response", () => {
    getChatTopicsOnAccount.mockResolvedValue(CHAT_TOPIC_EMPTY);
    const element = createElement("c-chat-topic-related-list", {
      is: ChatTopicRelatedList
    });

    element.objectName = "Account";
    element.recordId = "08737HU6";
    getRecord.emit(MOCK_ACCOUNT_RECORD);
    document.body.appendChild(element);

    return flushPromises().then(() => {
      let header = element.shadowRoot.querySelector(
        "span[data-id='component-header']"
      );
      expect(header.textContent).toBe("Chat Topics (0)");
    });
  });

  it("tests account response", () => {
    getChatTopicsOnAccount.mockResolvedValue(CHAT_TOPIC_MULTIPLE);
    const element = createElement("c-chat-topic-related-list", {
      is: ChatTopicRelatedList
    });

    element.objectName = "Account";
    element.recordId = "08737HU6";
    getRecord.emit(MOCK_ACCOUNT_RECORD);
    document.body.appendChild(element);

    return flushPromises().then(() => {
      let header = element.shadowRoot.querySelector(
        "span[data-id='component-header']"
      );
      let topicName = element.shadowRoot.querySelector(
        "div[data-id='topic-name']"
      );

      expect(header.textContent).toBe("Chat Topics (2)");
      expect(topicName.textContent).toBe("Demo1");
    });
  });

  it("tests case empty response", () => {
    getChatTopicInfoOnCase.mockResolvedValue(CHAT_TOPIC_EMPTY_CASE);
    const element = createElement("c-chat-topic-related-list", {
      is: ChatTopicRelatedList
    });

    element.objectName = "Case";
    element.recordId = "08737HU6";
    getRecord.emit(MOCK_CASE_RECORD);
    document.body.appendChild(element);

    return flushPromises().then(() => {
      let header = element.shadowRoot.querySelector(
        "span[data-id='component-header']"
      );

      expect(header.textContent).toBe("Chat Topics (0)");
    });
  });

  it("tests case response", () => {
    getChatTopicInfoOnCase.mockResolvedValue(CHAT_TOPIC_SINGLE);
    const element = createElement("c-chat-topic-related-list", {
      is: ChatTopicRelatedList
    });

    element.objectName = "Case";
    element.recordId = "08737HU6";
    getRecord.emit(MOCK_CASE_RECORD);
    document.body.appendChild(element);

    return flushPromises().then(() => {
      let header = element.shadowRoot.querySelector(
        "span[data-id='component-header']"
      );
      let topicName = element.shadowRoot.querySelector(
        "div[data-id='topic-name']"
      );

      expect(header.textContent).toBe("Chat Topics (1)");
      expect(topicName.textContent).toBe("April2021");
    });
  });

  it("tests re-initiate is visible", () => {
    getChatTopicsOnAccount.mockResolvedValue(CHAT_TOPIC_MULTIPLE);
    const element = createElement("c-chat-topic-related-list", {
      is: ChatTopicRelatedList
    });

    element.objectName = "Account";
    element.recordId = "0031700000pHcf8AAC";
    getRecord.emit(MOCK_COACH_USER_RECORD);
    document.body.appendChild(element);

    return flushPromises().then(() => {
      let reInitiateButton = element.shadowRoot.querySelector(
        "lightning-menu-item[data-id='re_initiate']"
      );
      expect(reInitiateButton).toBeTruthy();
    });
  });

  it("tests re-initiate is hidden for QA", () => {
    getChatTopicsOnAccount.mockResolvedValue(CHAT_TOPIC_MULTIPLE);
    const element = createElement("c-chat-topic-related-list", {
      is: ChatTopicRelatedList
    });

    element.objectName = "Account";
    element.recordId = "0031700000pHcf8AAC";
    getRecord.emit(MOCK_QA_USER_RECORD);
    document.body.appendChild(element);

    return flushPromises().then(() => {
      let reInitiateButton = element.shadowRoot.querySelector(
        "lightning-menu-item[data-id='re_initiate']"
      );
      expect(reInitiateButton).toBeFalsy();
    });
  });
});
