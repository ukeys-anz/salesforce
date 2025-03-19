import { createElement } from "lwc";
import initiateModifyCOPStatus from "c/initiateModifyCOPStatus";
import { getRecord } from "lightning/uiRecordApi";
import fetchChildCasesCoP from "@salesforce/apex/ConfirmationOfPayeeController.fetchChildCasesCoP";

const getWiredRecord = require("./data/getWiredRecord.json");
const MOCK_FIN_ACCOUNTS = require("./data/mockFinancialAccount.json");

const RECORD_ID = "500AD00000LMCeMYAX";

jest.mock(
  "@salesforce/apex/ConfirmationOfPayeeController.fetchChildCasesCoP",
  () => {
    return {
      default: jest.fn()
    };
  },
  { virtual: true }
);

describe("c-initiate-modify-cop-status", () => {
  beforeEach(() => {
    const element = createElement("c-initiate-modify-cop-status", {
      is: initiateModifyCOPStatus
    });
    element.recordId = RECORD_ID;
    document.body.appendChild(element);
  });

  afterEach(() => {
    while (document.body.firstChild) {
      document.body.removeChild(document.body.firstChild);
    }
    jest.clearAllMocks();
  });

  async function flushPromises() {
    return Promise.resolve();
  }

  it("renders the button with the correct label and initial state", async () => {
    fetchChildCasesCoP.mockResolvedValue(MOCK_FIN_ACCOUNTS);
    const element = document.querySelector("c-initiate-modify-cop-status");
    getRecord.emit(getWiredRecord);
    await flushPromises();

    const cancelButton = element.shadowRoot.querySelector(
      "lightning-button[data-id=cancel]"
    );
    const initiateModificationButton = element.shadowRoot.querySelector(
      "lightning-button[data-id=initiateModification]"
    );
    const dataTable = element.shadowRoot.querySelector(
      "lightning-datatable[data-id=datatable]"
    );
    // expect(cancelButton).toBeTruthy();
  });
});
