import { createElement } from "lwc";
import IDRRestrictedCases from "c/idrRestrictedCases";
import getRestrictedCaseData from "@salesforce/apex/IDRRestrictedCasesController.getRestrictedCaseData";

const mockGetRestrictedCaseData = require("./data/getRestrictedCaseDataSuccess.json");

jest.mock(
  "@salesforce/apex/IDRRestrictedCasesController.getRestrictedCaseData",
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
});
