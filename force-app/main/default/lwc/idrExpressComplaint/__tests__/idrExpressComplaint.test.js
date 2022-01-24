import { createElement } from "lwc";
import IDRExpressComplaint from "c/idrExpressComplaint";
import { registerApexTestWireAdapter } from "@salesforce/sfdx-lwc-jest";
import getAllKnownIssues from "@salesforce/apex/IDRExpressComplaintController.getAllKnownIssues";
import { ShowToastEventName } from "lightning/platformShowToastEvent";

const mockGetAllKnownIssues = require("./data/getAllKnownIssues.json");
const mockGetAllKnownIssuesError = require("./data/getAllKnownIssuesError.json");

const getAllKnownIssuesAdapter = registerApexTestWireAdapter(getAllKnownIssues);

jest.mock(
  "@salesforce/apex/IDRExpressComplaintController.getAllKnownIssues",
  () => {
    return {
      default: jest.fn()
    };
  },
  { virtual: true }
);

describe("c-idr-express-complaint suite", () => {
  beforeEach(() => {});
  //clean the dom and mocks in between test runs
  afterEach(() => {
    while (document.body.firstChild) {
      document.body.removeChild(document.body.firstChild);
    }
    jest.clearAllMocks();
  });

  it("show known issue dropdown in UI", () => {
    getAllKnownIssues.mockResolvedValue(mockGetAllKnownIssues);
    const element = createElement("c-idr-express-complaint", {
      is: IDRExpressComplaint
    });
    document.body.appendChild(element);

    getAllKnownIssuesAdapter.emit(mockGetAllKnownIssues);
    return Promise.resolve().then(() => {
      const expressToggleElement = element.shadowRoot.querySelector(
        "lightning-input"
      );
      expect(expressToggleElement).not.toBe(null);
      expressToggleElement.dispatchEvent(
        new CustomEvent("change", {
          detail: { checked: true }
        })
      );
      return Promise.resolve().then(() => {
        const knownIssueSelectElement = element.shadowRoot.querySelector(
          "lightning-combobox"
        );
        expect(knownIssueSelectElement).not.toBe(null);
      });
    });
  });

  it("verify if all known issues are loaded", () => {
    getAllKnownIssues.mockResolvedValue(mockGetAllKnownIssues);
    const element = createElement("c-idr-express-complaint", {
      is: IDRExpressComplaint
    });
    document.body.appendChild(element);
    getAllKnownIssuesAdapter.emit(mockGetAllKnownIssues);
    return Promise.resolve().then(() => {
      const expressToggleElement = element.shadowRoot.querySelector(
        "lightning-input"
      );
      expressToggleElement.dispatchEvent(
        new CustomEvent("change", {
          detail: { checked: true }
        })
      );
      return Promise.resolve().then(() => {
        const knownIssueSelectElement = element.shadowRoot.querySelector(
          "lightning-combobox"
        );
        expect(knownIssueSelectElement.options.length).toBe(3);
        knownIssueSelectElement.dispatchEvent(
          new CustomEvent("change", {
            detail: { value: "Long Wait Times" }
          })
        );
      });
    });
  });

  /********************Negative Scenario Testing*********************/
  it("error occured while loading known issues", () => {
    getAllKnownIssues.mockRejectedValue(mockGetAllKnownIssuesError);
    const element = createElement("c-idr-express-complaint", {
      is: IDRExpressComplaint
    });
    document.body.appendChild(element);
    const handler = jest.fn();
    element.addEventListener(ShowToastEventName, handler);

    getAllKnownIssuesAdapter.error();

    return Promise.resolve().then(() => {
      expect(handler).toHaveBeenCalled();
      expect(handler.mock.calls[0][0].detail.message).toBe(
        mockGetAllKnownIssuesError.body.message
      );
    });
  });
});
