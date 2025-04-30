import { createElement } from "lwc";
import CreateChildCasesWizard from "c/createChildCasesWizard";
import { getRecord } from "lightning/uiRecordApi";
import getDataForDatatable from "@salesforce/apex/CaseGroupController.getDataForDatatable";
const getWiredRecord = require("./data/getWiredRecord.json");
const finAccountData = require("./data/finAccountData.json");

jest.mock(
  "@salesforce/apex/CaseGroupController.getDataForDatatable",
  () => {
    return {
      default: jest.fn()
    };
  },
  { virtual: true }
);

describe("c-create-child-cases-wizard", () => {
  beforeEach(() => {
    const element = createElement("c-create-child-cases-wizard", {
      is: CreateChildCasesWizard
    });
    document.body.appendChild(element);
  });

  afterEach(() => {
    while (document.body.firstChild) {
      document.body.removeChild(document.body.firstChild);
    }
    jest.clearAllMocks();
  });

  it("test spinner loading when no accounts", () => {
    const element = document.querySelector("c-create-child-cases-wizard");
    getDataForDatatable.mockResolvedValue([]);
    return Promise.resolve().then(() => {
      const spinner = element.shadowRoot.querySelector(
        "lightning-spinner[data-id='loading']"
      );
      expect(spinner.hidden).toBe(false);
      expect(spinner.style.display).toBe("");
    });
  });

  it("test spinner load when financial accounts getting fetched", () => {
    getDataForDatatable.mockResolvedValue(finAccountData);
    const element = document.querySelector("c-create-child-cases-wizard");
    getRecord.emit(getWiredRecord);

    return Promise.resolve().then(() => {
      const spinner = element.shadowRoot.querySelector(
        "lightning-spinner[data-id='loading']"
      );
      expect(spinner).not.toBeNull();
    });
  });

  it("test financial accounts fetched from mock", () => {
    getDataForDatatable.mockResolvedValue(finAccountData);
    document.querySelector("c-create-child-cases-wizard");
    getRecord.emit(getWiredRecord);
    return Promise.resolve().then(() => {
      expect(getDataForDatatable).toHaveBeenCalled();
    });
  });
});
