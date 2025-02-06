import { createElement } from "lwc";
import OpportunityCreateOpenLoanapp from "c/opportunityCreateOpenLoanapp";
import getOpportunityDetails from "@salesforce/apex/OpportunityCreateOpenLoanappController.getOpportunityDetails";
import createOpenLoanApp from "@salesforce/apex/OpportunityCreateOpenLoanappController.createOpenLoanApp";
const APEX_OPP_SUCCESS = require("./data/oppDetailsSuccess.json");
const RECORD_ID = "0069h00000Dyn3CAAR";
jest.mock(
  "@salesforce/apex/OpportunityCreateOpenLoanappController.getOpportunityDetails",
  () => ({
    default: jest.fn()
  }),
  { virtual: true }
);
jest.mock(
  "@salesforce/apex/OpportunityCreateOpenLoanappController.createOpenLoanApp",
  () => ({
    default: jest.fn()
  }),
  { virtual: true }
);
describe("c-opportunity-create-open-loanapp", () => {
  afterEach(() => {
    // The jsdom instance is shared across test cases in a single file so reset the DOM
    while (document.body.firstChild) {
      document.body.removeChild(document.body.firstChild);
    }
  });
  beforeAll(() => {
    window.open = jest.fn();
  });
  afterAll(() => {
    delete window.open;
  });

  it("renders records returned from imperative call", async () => {
    getOpportunityDetails.mockResolvedValue(JSON.stringify(APEX_OPP_SUCCESS));
    createOpenLoanApp.mockResolvedValue("test-123");
    const element = createElement("c-opportunity-create-open-loanapp", {
      is: OpportunityCreateOpenLoanapp
    });
    element.recordId = RECORD_ID;
    //element.wiredRecordId = RECORD_ID;
    document.body.appendChild(element);
    await Promise.resolve();
    return Promise.resolve().then(() => {
      const progressBar = element.shadowRoot.querySelector(
        "lightning-progress-bar"
      );
      expect(progressBar).not.toBeNull();
    });
  });
});
