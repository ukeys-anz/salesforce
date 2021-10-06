import { createElement } from "lwc";
import FileUpload from "c/fileUpload";
import { ShowToastEventName } from "lightning/platformShowToastEvent";

const RECORD_ID = "a0c2O00000197sUQAD";
const TOAST_TITLE = "Success";

// mock file test harness
describe("Mock file for file upload testing", function () {
  beforeEach(() => {
    const element = createElement("c-file-upload", {
      is: FileUpload
    });
    element.recordId = RECORD_ID;
    document.body.appendChild(element);
  });
  //clean the dom and mocks in between test runs
  afterEach(() => {
    while (document.body.firstChild) {
      document.body.removeChild(document.body.firstChild);
    }
    jest.clearAllMocks();
  });

  it("File upload component should be rendered", () => {
    const element = document.querySelector("c-file-upload");
    const fileUploadElement = element.shadowRoot.querySelector(
      "lightning-file-upload"
    );
    expect(fileUploadElement).not.toBeNull();
  });

  it("Component should have record id", () => {
    const element = document.querySelector("c-file-upload");
    expect(element.recordId).toBe(RECORD_ID);
  });

  it("Test on file upload finished", () => {
    const element = document.querySelector("c-file-upload");
    const fileUploadElement = element.shadowRoot.querySelector(
      "lightning-file-upload"
    );
    const handler = jest.fn();
    element.addEventListener(ShowToastEventName, handler);
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
      expect(handler.mock.calls[0][0].detail.title).toBe(TOAST_TITLE);
    });
  });
});
