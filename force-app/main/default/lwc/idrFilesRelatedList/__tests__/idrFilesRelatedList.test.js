import { createElement } from "lwc";
import IdrFilesRelatedList from "c/idrFilesRelatedList";
import getCaseRelatedFiles from "@salesforce/apex/IDRFilesRelatedListController.getCaseRelatedFiles";
import { ShowToastEventName } from "lightning/platformShowToastEvent";

const RECORD_ID = "a0c2O00000197sUQAD";
const mockGetCaseRelatedFiles = require("./data/getCaseRelatedFiles.json");
const mockGetCaseRelatedFilesError = require("./data/getCasesRelatedFilesError.json");

jest.mock(
  "@salesforce/apex/IDRFilesRelatedListController.getCaseRelatedFiles",
  () => {
    return {
      default: jest.fn()
    };
  },
  { virtual: true }
);

describe("c-idr-files-related-list suite", () => {
  beforeEach(() => {});
  //clean the dom and mocks in between test runs
  afterEach(() => {
    while (document.body.firstChild) {
      document.body.removeChild(document.body.firstChild);
    }
    jest.clearAllMocks();
  });

  it("render file upload child component", () => {
    getCaseRelatedFiles.mockResolvedValue(mockGetCaseRelatedFiles);
    const element = createElement("c-idr-files-related-list", {
      is: IdrFilesRelatedList
    });
    element.recordId = RECORD_ID;
    document.body.appendChild(element);
    const fileUploadCompElement = element.shadowRoot.querySelectorAll(
      "c-file-upload"
    );
    expect(fileUploadCompElement.length).toBe(1);
  });

  it("set record id property correctly", () => {
    getCaseRelatedFiles.mockResolvedValue(mockGetCaseRelatedFiles);
    const element = createElement("c-idr-files-related-list", {
      is: IdrFilesRelatedList
    });
    element.recordId = RECORD_ID;
    document.body.appendChild(element);
    const fileUploadCompElement = element.shadowRoot.querySelector(
      "c-file-upload"
    );
    expect(fileUploadCompElement.recordId).toBe(RECORD_ID);
  });

  it("render files related to case on load of component", () => {
    getCaseRelatedFiles.mockResolvedValue(mockGetCaseRelatedFiles);
    const element = createElement("c-idr-files-related-list", {
      is: IdrFilesRelatedList
    });
    element.recordId = RECORD_ID;
    document.body.appendChild(element);
    return new Promise(setImmediate).then(() => {
      expect(element.files).not.toBe(null);
      const dataTableElement = element.shadowRoot.querySelector(
        "lightning-datatable"
      );
      expect(dataTableElement).not.toBe(null);
    });
  });

  it("On onload error while fetching files", () => {
    getCaseRelatedFiles.mockRejectedValue(mockGetCaseRelatedFilesError);
    const element = createElement("c-idr-files-related-list", {
      is: IdrFilesRelatedList
    });
    element.recordId = RECORD_ID;
    document.body.appendChild(element);
    const handler = jest.fn();
    element.addEventListener(ShowToastEventName, handler);
    return new Promise(setImmediate).then(() => {
      expect(handler).toHaveBeenCalled();
      //expect(handler.mock.calls[0][0].detail.title).toBe(mockGetCaseRelatedFilesError.title);
      expect(handler.mock.calls[0][0].detail.message).toBe(
        mockGetCaseRelatedFilesError.body.message
      );
      //expect(handler.mock.calls[0][0].detail.variant).toBe(mockGetCaseRelatedFilesError.variant);
    });
  });

  /************Jest testing for search functionlaity***************/

  /******************Positive/Happy scenario*******************/
  it("search files from file name search", () => {
    getCaseRelatedFiles.mockResolvedValue(mockGetCaseRelatedFiles);
    const element = createElement("c-idr-files-related-list", {
      is: IdrFilesRelatedList
    });
    element.recordId = RECORD_ID;
    document.body.appendChild(element);

    return Promise.resolve().then(() => {
      const fileNameSearchElement = element.shadowRoot.querySelector(
        ".fileNameSearch"
      );
      fileNameSearchElement.value = "Screen";
      fileNameSearchElement.dispatchEvent(new CustomEvent("change"));
      return Promise.resolve().then(() => {
        const dataTableElement = element.shadowRoot.querySelector(
          "lightning-datatable"
        );
        expect(dataTableElement.data[0]).toStrictEqual(mockGetCaseRelatedFiles[0]);
      });
    });
  });

  /******************Negative scenario*************************/
});
