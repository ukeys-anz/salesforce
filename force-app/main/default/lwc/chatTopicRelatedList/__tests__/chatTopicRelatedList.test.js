import { createElement } from "lwc";
import { getRecord } from "lightning/uiRecordApi";
import { registerLdsTestWireAdapter } from "@salesforce/sfdx-lwc-jest";
import ChatTopicRelatedList from "c/chatTopicRelatedList";
import getChatTopicsOnAccount from "@salesforce/apex/ChatTopicRelatedListController.getChatTopicsOnAccount";
import getChatTopicInfoOnCase from "@salesforce/apex/ChatTopicRelatedListController.getChatTopicInfoOnCase";

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

const getRecordAdapter = registerLdsTestWireAdapter(getRecord);
const MOCK_ACCOUNT_RECORD = require("./data/getAccountRecord.json");
const MOCK_CASE_RECORD = require("./data/getCaseRecord.json");

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
    getRecordAdapter.emit(MOCK_ACCOUNT_RECORD);
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
    getRecordAdapter.emit(MOCK_ACCOUNT_RECORD);
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
    getRecordAdapter.emit(MOCK_CASE_RECORD);
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
    getRecordAdapter.emit(MOCK_CASE_RECORD);
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
});
