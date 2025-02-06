import { createElement } from "lwc";
import OcrRelatedList from "c/ocrRelatedList";
import getOcrListForCustomer from "@salesforce/apex/OCRRelatedListController.getOcrListForCustomer";
const APEX_OCRLIST_SUCCESS = require("./data/ocrList.json");
const RECORD_ID = "0018s00000OdQ1fAAF";
jest.mock(
  "@salesforce/apex/OCRRelatedListController.getOcrListForCustomer",
  () => ({
    default: jest.fn()
  }),
  { virtual: true }
);
describe("c-ocr-related-list", () => {
  afterEach(() => {
    // The jsdom instance is shared across test cases in a single file so reset the DOM
    while (document.body.firstChild) {
      document.body.removeChild(document.body.firstChild);
    }
  });

  it("renders records returned from imperative call", async () => {
    getOcrListForCustomer.mockResolvedValue(APEX_OCRLIST_SUCCESS);
    const element = createElement("c-ocr-related-list", {
      is: OcrRelatedList
    });
    element.recordId = RECORD_ID;
    document.body.appendChild(element);
    await Promise.resolve();
    return Promise.resolve().then(() => {
      const datatable = element.shadowRoot.querySelector("lightning-datatable");
      expect(datatable.data.length).toBe(3);
    });
  });

  it("refreshes records", async () => {
    getOcrListForCustomer.mockResolvedValue(APEX_OCRLIST_SUCCESS);
    const element = createElement("c-ocr-related-list", {
      is: OcrRelatedList
    });
    element.recordId = RECORD_ID;
    document.body.appendChild(element);
    const button = element.shadowRoot.querySelector("lightning-button-icon");
    expect(button).not.toBe(null);
    button.click();
    await Promise.resolve();
    return Promise.resolve().then(() => {
      const datatable = element.shadowRoot.querySelector("lightning-datatable");
      expect(datatable.data.length).toBe(3);
    });
  });
});
