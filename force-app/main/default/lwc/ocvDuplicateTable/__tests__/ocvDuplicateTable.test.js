import { createElement } from "@lwc/engine-dom";
import OcvDuplicateTable from "c/ocvDuplicateTable";
import getAllCustomersByOCVId from "@salesforce/apex/OCVDuplicateTableController.getAllCustomersByOCVId";
const APEX_LIST_SUCCESS = require("./data/customerList.json");
const RECORD_ID = "0018s00000OdQ1fAAF";
jest.mock(
  "@salesforce/apex/OCVDuplicateTableController.getAllCustomersByOCVId",
  () => ({
    default: jest.fn()
  }),
  { virtual: true }
);
describe("c-ocv-duplicate-table", () => {
  afterEach(() => {
    // The jsdom instance is shared across test cases in a single file so reset the DOM
    while (document.body.firstChild) {
      document.body.removeChild(document.body.firstChild);
    }
  });

  it("renders records returned from imperative call", async () => {
    getAllCustomersByOCVId.mockResolvedValue(APEX_LIST_SUCCESS);
    const element = createElement("c-ocv-duplicate-table", {
      is: OcvDuplicateTable
    });
    element.recordId = RECORD_ID;
    document.body.appendChild(element);
    await Promise.resolve();
    return Promise.resolve().then(() => {
      const datatable = element.shadowRoot.querySelector("lightning-datatable");
      expect(datatable.data.length).toBe(3);
    });
  });
});
