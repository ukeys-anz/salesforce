import detokenizeCOBTaxResidencyData from "@salesforce/apex/COBTaxResidencyViewController.detokenizeCOBTaxResidencyData";
import { setImmediate } from "timers";
import { createElement } from "lwc";
import CobTinView from "c/cobTinView";

jest.mock(
  "@salesforce/apex/COBTaxResidencyViewController.detokenizeCOBTaxResidencyData",
  () => {
    return {
      default: jest.fn()
    };
  },
  { virtual: true }
);

const mockDetokenizedDataSuccess = require("./data/detokenizeCOBTaxResidencyDataSuccess.json");

describe("c-cob-tin-view", () => {
  //clean the dom and mocks in between test runs
  beforeEach(() => {
    jest.resetAllMocks();
    while (document.body.firstChild) {
      document.body.removeChild(document.body.firstChild);
    }
  });
  afterEach(() => {
    while (document.body.firstChild) {
      document.body.removeChild(document.body.firstChild);
    }
    jest.clearAllMocks();
  });

  function flushPromises() {
    return new Promise((resolve) => setImmediate(resolve));
  }

  it("test modal rendered with the required data", () => {
    // Arrange
    const element = createElement("c-cob-tin-view", {
      is: CobTinView
    });

    // Act
    document.body.appendChild(element);

    // Assert
    expect(element).toBeTruthy();

    detokenizeCOBTaxResidencyData.mockResolvedValue(mockDetokenizedDataSuccess);
    return flushPromises().then(() => {
      const taxIdentificationNumber = element.shadowRoot.querySelector(
        'lightning-formatted-text[data-id="TaxIdentificationNumber__c"]'
      );

      expect(taxIdentificationNumber).not.toBeNull();
    });
  });
});
