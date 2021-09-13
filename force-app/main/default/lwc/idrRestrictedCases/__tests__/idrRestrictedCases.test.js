import { createElement } from "lwc";
import IDRRestrictedCases from "c/idrRestrictedCases";
import getRestrictedCaseData from "@salesforce/apex/IDRRestrictedCasesController.getRestrictedCaseData";
import insertCaseComment from "@salesforce/apex/IDRRestrictedCasesController.insertCaseComment";
import linkFileToCase from "@salesforce/apex/IDRRestrictedCasesController.linkFileToCase";
import { ShowToastEventName } from "lightning/platformShowToastEvent";

const SUCCESS_TOAST_TITLE = "Success";
const ERROR_TOAST_TITLE_CASECOMMENTS = "Error while inserting case comment";
const ERROR_TOAST_TITLE_FILEUPLOAD = "Error while uploading the file";
const mockGetRestrictedCaseData = require("./data/getRestrictedCaseDataSuccess.json");
const mockErrorData = require("./data/apexCallError.json");

jest.mock(
  "@salesforce/apex/IDRRestrictedCasesController.getRestrictedCaseData",
  () => {
    return {
      default: jest.fn()
    };
  },
  { virtual: true }
);

jest.mock(
  "@salesforce/apex/IDRRestrictedCasesController.insertCaseComment",
  () => {
    return {
      default: jest.fn()
    };
  },
  { virtual: true }
);

jest.mock(
  "@salesforce/apex/IDRRestrictedCasesController.linkFileToCase",
  () => {
    return {
      default: jest.fn()
    };
  },
  { virtual: true }
);

describe("c-idr-restricted-cases suite", () => {
  beforeEach(() => {
    const element = createElement("c-idr-restricted-cases", {
      is: IDRRestrictedCases
    });
    document.body.appendChild(element);
  });
  afterEach(() => {
    while (document.body.firstChild) {
      document.body.removeChild(document.body.firstChild);
    }
    jest.clearAllMocks();
  });

  it("Cases should be rendered on search", () => {
    getRestrictedCaseData.mockResolvedValue(mockGetRestrictedCaseData);
    const element = document.body.querySelector("c-idr-restricted-cases");
    const inputElement = element.shadowRoot.querySelector("lightning-input");
    inputElement.value = "test";
    const event = new KeyboardEvent("keyup", { keyCode: 13 });
    inputElement.dispatchEvent(event);
    return new Promise(setImmediate).then(() => {
      const dataTableElement = element.shadowRoot.querySelector(
        "lightning-datatable"
      );
      expect(dataTableElement.data).toStrictEqual(mockGetRestrictedCaseData);
    });
  });

  it("No records found should be rendered if there is no data fetched from search", () => {
    getRestrictedCaseData.mockResolvedValue([]);
    const element = document.body.querySelector("c-idr-restricted-cases");
    const inputElement = element.shadowRoot.querySelector("lightning-input");
    inputElement.value = "dksjfisdjf";
    const event = new KeyboardEvent("keyup", { keyCode: 13 });
    inputElement.dispatchEvent(event);
    return new Promise(setImmediate).then(() => {
      const noRecFoundElement = element.shadowRoot.querySelector(
        ".noDataFound>h1>span"
      );
      expect(noRecFoundElement.textContent).toBe("No Records Found!");
    });
  });

  it("Comments box should be rendered", () => {
    getRestrictedCaseData.mockResolvedValue(mockGetRestrictedCaseData);
    const element = document.body.querySelector("c-idr-restricted-cases");
    const inputElement = element.shadowRoot.querySelector("lightning-input");
    inputElement.value = "test";
    const event = new KeyboardEvent("keyup", { keyCode: 13 });
    inputElement.dispatchEvent(event);
    return new Promise(setImmediate).then(() => {
      const dataTableElement = element.shadowRoot.querySelector(
        "lightning-datatable"
      );
      dataTableElement.dispatchEvent(
        new CustomEvent("rowaction", {
          detail: {
            row: {
              caseId: "5002O000008uAc2QAE",
              caseNumber: "00001041",
              caseOwner: "User User",
              customerType: "Individual",
              firstName: "Test",
              lastName: "Test",
              status: "Closed"
            },
            action: { label: "Add Case Comment", name: "add_case_comment" }
          }
        })
      );
      return new Promise(setImmediate).then(() => {
        const headingElement = element.shadowRoot.querySelector(
          ".caseCommentsHeading"
        );
        expect(headingElement.textContent).toBe("Create Case Comment");
      });
    });
  });

  it("Case comments should be added successfully", () => {
    getRestrictedCaseData.mockResolvedValue(mockGetRestrictedCaseData);
    insertCaseComment.mockResolvedValue();
    const element = document.body.querySelector("c-idr-restricted-cases");
    const handler = jest.fn();
    element.addEventListener(ShowToastEventName, handler);
    const inputElement = element.shadowRoot.querySelector("lightning-input");
    inputElement.value = "test";
    const event = new KeyboardEvent("keyup", { keyCode: 13 });
    inputElement.dispatchEvent(event);
    return new Promise(setImmediate).then(() => {
      const dataTableElement = element.shadowRoot.querySelector(
        "lightning-datatable"
      );
      dataTableElement.dispatchEvent(
        new CustomEvent("rowaction", {
          detail: {
            row: {
              caseId: "5002O000008uAc2QAE",
              caseNumber: "00001041",
              caseOwner: "User User",
              customerType: "Individual",
              firstName: "Test",
              lastName: "Test",
              status: "Closed"
            },
            action: { label: "Add Case Comment", name: "add_case_comment" }
          }
        })
      );
      return new Promise(setImmediate).then(() => {
        const commentBodyElement = element.shadowRoot.querySelector(
          ".commentInput"
        );
        commentBodyElement.value = "Test Comment Input";
        commentBodyElement.dispatchEvent(
          new CustomEvent("change", {
            detail: {
              value: "Test Comment Input"
            }
          })
        );
        return Promise.resolve().then(() => {
          const commentSaveBtn = element.shadowRoot.querySelector(
            ".commentSaveBtn"
          );
          commentSaveBtn.dispatchEvent(new CustomEvent("click"));
          return new Promise(setImmediate).then(() => {
            expect(handler).toHaveBeenCalled();
            expect(handler.mock.calls[0][0].detail.title).toBe(
              SUCCESS_TOAST_TITLE
            );
          });
        });
      });
    });
  });

  it("Error while adding case comments", () => {
    getRestrictedCaseData.mockResolvedValue(mockGetRestrictedCaseData);
    insertCaseComment.mockRejectedValue(mockErrorData);
    const element = document.body.querySelector("c-idr-restricted-cases");
    const handler = jest.fn();
    element.addEventListener(ShowToastEventName, handler);
    const inputElement = element.shadowRoot.querySelector("lightning-input");
    inputElement.value = "test";
    const event = new KeyboardEvent("keyup", { keyCode: 13 });
    inputElement.dispatchEvent(event);
    return new Promise(setImmediate).then(() => {
      const dataTableElement = element.shadowRoot.querySelector(
        "lightning-datatable"
      );
      dataTableElement.dispatchEvent(
        new CustomEvent("rowaction", {
          detail: {
            row: {
              caseId: "5002O000008uAc2QAE",
              caseNumber: "00001041",
              caseOwner: "User User",
              customerType: "Individual",
              firstName: "Test",
              lastName: "Test",
              status: "Closed"
            },
            action: { label: "Add Case Comment", name: "add_case_comment" }
          }
        })
      );
      return new Promise(setImmediate).then(() => {
        const commentBodyElement = element.shadowRoot.querySelector(
          ".commentInput"
        );
        commentBodyElement.value = "Test Comment Input";
        commentBodyElement.dispatchEvent(
          new CustomEvent("change", {
            detail: {
              value: "Test Comment Input"
            }
          })
        );
        return Promise.resolve().then(() => {
          const commentSaveBtn = element.shadowRoot.querySelector(
            ".commentSaveBtn"
          );
          commentSaveBtn.dispatchEvent(new CustomEvent("click"));
          return new Promise(setImmediate).then(() => {
            expect(handler).toHaveBeenCalled();
            expect(handler.mock.calls[0][0].detail.title).toBe(
              ERROR_TOAST_TITLE_CASECOMMENTS
            );
          });
        });
      });
    });
  });

  it("Upload files box should be rendered", () => {
    getRestrictedCaseData.mockResolvedValue(mockGetRestrictedCaseData);
    linkFileToCase.mockResolvedValue();
    const element = document.body.querySelector("c-idr-restricted-cases");
    const handler = jest.fn();
    element.addEventListener(ShowToastEventName, handler);
    const inputElement = element.shadowRoot.querySelector("lightning-input");
    inputElement.value = "test";
    const event = new KeyboardEvent("keyup", { keyCode: 13 });
    inputElement.dispatchEvent(event);
    return new Promise(setImmediate).then(() => {
      const dataTableElement = element.shadowRoot.querySelector(
        "lightning-datatable"
      );
      dataTableElement.dispatchEvent(
        new CustomEvent("rowaction", {
          detail: {
            row: {
              caseId: "5002O000008uAc2QAE",
              caseNumber: "00001041",
              caseOwner: "User User",
              customerType: "Individual",
              firstName: "Test",
              lastName: "Test",
              status: "Closed"
            },
            action: { label: "Upload Files", name: "update_files" }
          }
        })
      );
      return new Promise(setImmediate).then(() => {
        const headingElement = element.shadowRoot.querySelector(
          ".uploadFilesHeading"
        );
        expect(headingElement.textContent).toBe("Upload Files");
      });
    });
  });

  it("Files should be uploaded successfully", () => {
    getRestrictedCaseData.mockResolvedValue(mockGetRestrictedCaseData);
    linkFileToCase.mockResolvedValue();
    const element = document.body.querySelector("c-idr-restricted-cases");
    const handler = jest.fn();
    element.addEventListener(ShowToastEventName, handler);
    const inputElement = element.shadowRoot.querySelector("lightning-input");
    inputElement.value = "test";
    const event = new KeyboardEvent("keyup", { keyCode: 13 });
    inputElement.dispatchEvent(event);
    return new Promise(setImmediate).then(() => {
      const dataTableElement = element.shadowRoot.querySelector(
        "lightning-datatable"
      );
      dataTableElement.dispatchEvent(
        new CustomEvent("rowaction", {
          detail: {
            row: {
              caseId: "5002O000008uAc2QAE",
              caseNumber: "00001041",
              caseOwner: "User User",
              customerType: "Individual",
              firstName: "Test",
              lastName: "Test",
              status: "Closed"
            },
            action: { label: "Upload Files", name: "update_files" }
          }
        })
      );
      return new Promise(setImmediate).then(() => {
        const fileUploadElement = element.shadowRoot.querySelector(
          "lightning-file-upload"
        );
        fileUploadElement.dispatchEvent(
          new CustomEvent("uploadfinished", {
            detail: {
              files: [
                {
                  name: "Screen Shot 2021-08-30 at 11.54.32 am.png",
                  documentId: "0692O000000hQ6hQAE",
                  contentVersionId: "0682O000000hmhuQAA"
                }
              ]
            }
          })
        );
        return Promise.resolve().then(() => {
          expect(handler).toHaveBeenCalled();
          expect(handler.mock.calls[0][0].detail.title).toBe(
            SUCCESS_TOAST_TITLE
          );
        });
      });
    });
  });

  it("Error while uploading files", () => {
    getRestrictedCaseData.mockResolvedValue(mockGetRestrictedCaseData);
    linkFileToCase.mockRejectedValue(mockErrorData);
    const element = document.body.querySelector("c-idr-restricted-cases");
    const handler = jest.fn();
    element.addEventListener(ShowToastEventName, handler);
    const inputElement = element.shadowRoot.querySelector("lightning-input");
    inputElement.value = "test";
    const event = new KeyboardEvent("keyup", { keyCode: 13 });
    inputElement.dispatchEvent(event);
    return new Promise(setImmediate).then(() => {
      const dataTableElement = element.shadowRoot.querySelector(
        "lightning-datatable"
      );
      dataTableElement.dispatchEvent(
        new CustomEvent("rowaction", {
          detail: {
            row: {
              caseId: "5002O000008uAc2QAE",
              caseNumber: "00001041",
              caseOwner: "User User",
              customerType: "Individual",
              firstName: "Test",
              lastName: "Test",
              status: "Closed"
            },
            action: { label: "Upload Files", name: "update_files" }
          }
        })
      );
      return new Promise(setImmediate).then(() => {
        const fileUploadElement = element.shadowRoot.querySelector(
          "lightning-file-upload"
        );
        fileUploadElement.dispatchEvent(
          new CustomEvent("uploadfinished", {
            detail: {
              files: [
                {
                  name: "Screen Shot 2021-08-30 at 11.54.32 am.png",
                  documentId: "0692O000000hQ6hQAE",
                  contentVersionId: "0682O000000hmhuQAA"
                }
              ]
            }
          })
        );
        return new Promise(setImmediate).then(() => {
          expect(handler).toHaveBeenCalled();
          expect(handler.mock.calls[0][0].detail.title).toBe(
            ERROR_TOAST_TITLE_FILEUPLOAD
          );
        });
      });
    });
  });

  it("sorting data check", () => {
    getRestrictedCaseData.mockResolvedValue(mockGetRestrictedCaseData);
    const element = document.body.querySelector("c-idr-restricted-cases");
    const inputElement = element.shadowRoot.querySelector("lightning-input");
    inputElement.value = "test";
    const event = new KeyboardEvent("keyup", { keyCode: 13 });
    inputElement.dispatchEvent(event);
    return new Promise(setImmediate).then(() => {
      const dataTableElement = element.shadowRoot.querySelector(
        "lightning-datatable"
      );
      dataTableElement.dispatchEvent(
        new CustomEvent("sort", {
          detail: { fieldName: "firstName", sortDirection: "asc" }
        })
      );
      return Promise.resolve().then(() => {
        expect(dataTableElement.data).toStrictEqual(mockGetRestrictedCaseData);
      });  
    });
  });

});
