import { createElement } from "lwc";
import OpportunityCreateAnzPlusLoanapp from "c/opportunityCreateAnzPlusLoanapp";
import getOpportunityDetails from "@salesforce/apex/OpportunityCreateOpenLoanappController.getOpportunityDetails";
import getUserTerritory from "@salesforce/apex/OpportunityCreateOpenLoanappController.getUserTerritory";
import createANZPlusLoanapp from "@salesforce/apex/OpportunityCreateOpenLoanappController.createANZPlusLoanapp";
const APEX_OPP_SUCCESS = require("./data/oppDetailsSuccess.json");
const USER_TERRITORY_DATA = require("./data/userTerritoryData.json");
const RECORD_ID = "0069h00000Dyn3CAAR";
jest.mock(
  "@salesforce/apex/OpportunityCreateOpenLoanappController.getOpportunityDetails",
  () => ({
    default: jest.fn()
  }),
  { virtual: true }
);
jest.mock(
  "@salesforce/apex/OpportunityCreateOpenLoanappController.createANZPlusLoanapp",
  () => ({
    default: jest.fn()
  }),
  { virtual: true }
);
jest.mock(
  "@salesforce/apex/OpportunityCreateOpenLoanappController.getUserTerritory",
  () => ({
    default: jest.fn()
  }),
  { virtual: true }
);
describe("c-opportunity-create-anz-plus-loanapp", () => {
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
    getUserTerritory.mockResolvedValue(USER_TERRITORY_DATA);
    createANZPlusLoanapp.mockResolvedValue(
      JSON.stringify({ status: "success", applicationId: "213355301" })
    );
    const element = createElement("c-opportunity-create-anz-plus-loanapp", {
      is: OpportunityCreateAnzPlusLoanapp
    });
    element.recordId = RECORD_ID;
    //element.wiredRecordId = RECORD_ID;
    document.body.appendChild(element);
    await Promise.resolve();
    await Promise.resolve();
    return Promise.resolve().then(() => {
      const progressBar = element.shadowRoot.querySelector(
        "lightning-progress-bar"
      );
      expect(progressBar).not.toBeNull();
    });
  });
});
