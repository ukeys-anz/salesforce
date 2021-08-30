import { createElement } from "lwc";
import FileUpload from "c/fileUpload";

const RECORD_ID = "a0c2O00000197sUQAD";

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
});
