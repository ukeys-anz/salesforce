import { createElement } from "lwc";
import SopFinanceDeleteModal from "c/sopFinanceDeleteModal";

const RECORD_DATA = require("./data/recordData.json");

jest.mock(
  "@salesforce/customPermission/SOP_Add",
  () => ({
    __esModule: true,
    default: true
  }),
  { virtual: true }
);

async function flushPromises() {
  return Promise.resolve();
}

describe("c-sop-finance-delete-modal", () => {
  it("test modal is visible", async () => {
    const element = createElement("c-sop-finance-delete-modal", {
      is: SopFinanceDeleteModal
    });

    await flushPromises();
    element.isDeletionAllowed = true;
    element.sopType = "Income";
    element.recordId = "testId";
    element.recordDetails = RECORD_DATA;
    document.body.appendChild(element);

    await flushPromises();
    let deleteDetails = element.shadowRoot.querySelector(
      "lightning-formatted-text[data-id='deleteDetails']"
    );
    expect(deleteDetails).toBeTruthy();
  });

  it("test button is visible", async () => {
    const element = createElement("c-sop-finance-delete-modal", {
      is: SopFinanceDeleteModal
    });

    await flushPromises();
    element.isDeletionAllowed = true;
    element.sopType = "Income";
    element.recordId = "testId";
    element.recordDetails = RECORD_DATA;
    document.body.appendChild(element);

    await flushPromises();

    let submitBtn = element.shadowRoot.querySelector(
      "lightning-button[data-id='submitBtn']"
    );
    expect(submitBtn).toBeTruthy();
  });
});
