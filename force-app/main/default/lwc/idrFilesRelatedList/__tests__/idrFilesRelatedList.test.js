import { createElement } from "lwc";
import IdrFilesRelatedList from "c/idrFilesRelatedList";
import getCaseRelatedFiles from "@salesforce/apex/IDRFilesRelatedListController.getCaseRelatedFiles";
import searchFilesContent from "@salesforce/apex/IDRFilesRelatedListController.searchFilesContent";
import { ShowToastEventName } from "lightning/platformShowToastEvent";

const RECORD_ID = "a0c2O00000197sUQAD";
const mockGetCaseRelatedFiles = require("./data/getCaseRelatedFiles.json");
const mockGetCaseRelatedFilesError = require("./data/getCasesRelatedFilesError.json");
const mockSearchFilesContent = require("./data/searchFilesContent.json");
const mockSearchFilesContentError = require("./data/getCasesRelatedFilesError.json");

jest.mock(
  "@salesforce/apex/IDRFilesRelatedListController.getCaseRelatedFiles",
  () => {
    return {
      default: jest.fn()
    };
  },
  { virtual: true }
);

jest.mock(
  "@salesforce/apex/IDRFilesRelatedListController.searchFilesContent",
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
      expect(handler.mock.calls[0][0].detail.message).toBe(
        mockGetCaseRelatedFilesError.body.message
      );
    });
  });

  /************Jest testing for search functionlaity***************/
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
        expect(dataTableElement.data[0]).toStrictEqual(
          mockGetCaseRelatedFiles[0]
        );
      });
    });
  });

  it("search files from file type search", () => {
    getCaseRelatedFiles.mockResolvedValue(mockGetCaseRelatedFiles);
    const element = createElement("c-idr-files-related-list", {
      is: IdrFilesRelatedList
    });
    element.recordId = RECORD_ID;
    document.body.appendChild(element);

    return Promise.resolve().then(() => {
      const fileTypeSearchElement = element.shadowRoot.querySelector(
        ".fileTypeSearch"
      );
      fileTypeSearchElement.value = "png";
      fileTypeSearchElement.dispatchEvent(new CustomEvent("change"));
      return Promise.resolve().then(() => {
        const dataTableElement = element.shadowRoot.querySelector(
          "lightning-datatable"
        );
        expect(dataTableElement.data[0]).toStrictEqual(
          mockGetCaseRelatedFiles[0]
        );
      });
    });
  });

  it("search files from file owner search", () => {
    getCaseRelatedFiles.mockResolvedValue(mockGetCaseRelatedFiles);
    const element = createElement("c-idr-files-related-list", {
      is: IdrFilesRelatedList
    });
    element.recordId = RECORD_ID;
    document.body.appendChild(element);

    return Promise.resolve().then(() => {
      const fileOwnerSearchElement = element.shadowRoot.querySelector(
        ".fileOwnerSearch"
      );
      fileOwnerSearchElement.value = "User";
      fileOwnerSearchElement.dispatchEvent(new CustomEvent("change"));
      return Promise.resolve().then(() => {
        const dataTableElement = element.shadowRoot.querySelector(
          "lightning-datatable"
        );
        expect(dataTableElement.data).toStrictEqual(mockGetCaseRelatedFiles);
      });
    });
  });

  it("search files from file start date search", () => {
    getCaseRelatedFiles.mockResolvedValue(mockGetCaseRelatedFiles);
    const element = createElement("c-idr-files-related-list", {
      is: IdrFilesRelatedList
    });
    element.recordId = RECORD_ID;
    document.body.appendChild(element);

    return Promise.resolve().then(() => {
      const fileStartDateSearchElement = element.shadowRoot.querySelector(
        ".fileStartDateSearch"
      );
      fileStartDateSearchElement.value = "2021-08-30";
      fileStartDateSearchElement.dispatchEvent(new CustomEvent("change"));
      return Promise.resolve().then(() => {
        const dataTableElement = element.shadowRoot.querySelector(
          "lightning-datatable"
        );
        expect(dataTableElement.data[0]).toStrictEqual(
          mockGetCaseRelatedFiles[0]
        );
      });
    });
  });

  it("search files from file end date search", () => {
    getCaseRelatedFiles.mockResolvedValue(mockGetCaseRelatedFiles);
    const element = createElement("c-idr-files-related-list", {
      is: IdrFilesRelatedList
    });
    element.recordId = RECORD_ID;
    document.body.appendChild(element);

    return Promise.resolve().then(() => {
      const fileEndDateSearchElement = element.shadowRoot.querySelector(
        ".fileEndDateSearch"
      );
      fileEndDateSearchElement.value = "2021-08-30";
      fileEndDateSearchElement.dispatchEvent(new CustomEvent("change"));
      return Promise.resolve().then(() => {
        const dataTableElement = element.shadowRoot.querySelector(
          "lightning-datatable"
        );
        expect(dataTableElement.data).toStrictEqual(mockGetCaseRelatedFiles);
      });
    });
  });

  it("search files from contains search", () => {
    getCaseRelatedFiles.mockResolvedValue(mockGetCaseRelatedFiles);
    searchFilesContent.mockResolvedValue(mockSearchFilesContent);
    const element = createElement("c-idr-files-related-list", {
      is: IdrFilesRelatedList
    });
    element.recordId = RECORD_ID;
    document.body.appendChild(element);
    return Promise.resolve().then(() => {
      const fileContainsSearchElement = element.shadowRoot.querySelector(
        ".fileContainsSearch"
      );
      fileContainsSearchElement.value = "Screen";
      fileContainsSearchElement.dispatchEvent(new CustomEvent("change"));
      return new Promise(setImmediate).then(() => {
        const dataTableElement = element.shadowRoot.querySelector(
          "lightning-datatable"
        );
        expect(dataTableElement.data).toStrictEqual(mockGetCaseRelatedFiles);
      });
    });
  });

  it("search files from contains search error occured", () => {
    getCaseRelatedFiles.mockResolvedValue(mockGetCaseRelatedFiles);
    searchFilesContent.mockRejectedValue(mockSearchFilesContentError);
    const element = createElement("c-idr-files-related-list", {
      is: IdrFilesRelatedList
    });
    element.recordId = RECORD_ID;
    document.body.appendChild(element);

    return Promise.resolve().then(() => {
      const fileContainsSearchElement = element.shadowRoot.querySelector(
        ".fileContainsSearch"
      );
      fileContainsSearchElement.value = "Screen";
      fileContainsSearchElement.dispatchEvent(new CustomEvent("change"));
      const handler = jest.fn();
      element.addEventListener(ShowToastEventName, handler);
      return new Promise(setImmediate).then(() => {
        expect(handler).toHaveBeenCalled();
        expect(handler.mock.calls[0][0].detail.message).toBe(
          mockSearchFilesContentError.body.message
        );
      });
    });
  });

  it("render files related to case on file upload finished", () => {
    getCaseRelatedFiles.mockResolvedValue(mockGetCaseRelatedFiles);
    const element = createElement("c-idr-files-related-list", {
      is: IdrFilesRelatedList
    });
    element.recordId = RECORD_ID;
    document.body.appendChild(element);
    return new Promise(setImmediate).then(() => {
      const fileUploadElement = element.shadowRoot.querySelector(
        "c-file-Upload"
      );
      fileUploadElement.dispatchEvent(new CustomEvent("newfileupload"));
      return new Promise(setImmediate).then(() => {
        const dataTableElement = element.shadowRoot.querySelector(
          "lightning-datatable"
        );
        expect(dataTableElement.data).toStrictEqual(mockGetCaseRelatedFiles);
      });
    });
  });

  it("error occured when render files related to case on file upload finished", () => {
    getCaseRelatedFiles.mockRejectedValue(mockGetCaseRelatedFilesError);
    const element = createElement("c-idr-files-related-list", {
      is: IdrFilesRelatedList
    });
    element.recordId = RECORD_ID;
    document.body.appendChild(element);
    return new Promise(setImmediate).then(() => {
      const fileUploadElement = element.shadowRoot.querySelector(
        "c-file-Upload"
      );
      fileUploadElement.dispatchEvent(new CustomEvent("newfileupload"));
      const handler = jest.fn();
      element.addEventListener(ShowToastEventName, handler);
      return new Promise(setImmediate).then(() => {
        expect(handler).toHaveBeenCalled();
        expect(handler.mock.calls[0][0].detail.message).toBe(
          mockSearchFilesContentError.body.message
        );
      });
    });
  });

  it("sorting data check", () => {
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
      dataTableElement.dispatchEvent(
        new CustomEvent("sort", {
          detail: { fieldName: "fileUrl", sortDirection: "asc" }
        })
      );
      return Promise.resolve().then(() => {
        expect(dataTableElement.data).toStrictEqual(mockGetCaseRelatedFiles);
      });
    });
  });
});
