import { createElement } from "lwc";
import AcceptReferral from "c/acceptReferral";
import { CloseScreenEventName } from "lightning/actions";
import getAvailableRecordTypes from "@salesforce/apex/CommercialAcceptReferralController.getAvailableRecordTypes";
import { setImmediate } from "timers";

const RECORD_ID = "00Q9p00000HyWMcEAN";

jest.mock(
  "@salesforce/apex/CommercialAcceptReferralController.getAvailableRecordTypes",
  () => {
    return {
      default: jest.fn()
    };
  },
  { virtual: true }
);

const mockRecordTypes = [
  {
    Id: "0122P0000004RegQAE",
    Name: "Commercial CRM Lead",
    DeveloperName: "CCRM_Lead"
  }
];

describe("c-accept-referral", () => {
  //Prepare data before each test method
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

  it("Test banker clicks on accept button", async () => {
    getAvailableRecordTypes.mockResolvedValue(mockRecordTypes);

    const element = createElement("c-accept-referral", {
      is: AcceptReferral
    });
    document.body.appendChild(element);

    return flushPromises().then(() => {
      const closeScreenHandler = jest.fn();
      element.addEventListener(CloseScreenEventName, closeScreenHandler);
      const cancelBtn = element.shadowRoot.querySelector(".btnCancel");
      cancelBtn.dispatchEvent(new CustomEvent("click"));
      expect(closeScreenHandler).toHaveBeenCalledTimes(1);
    });
  });
});
