import { createElement } from "@lwc/engine-dom";
import ExportFailedReferrels from "c/exportFailedReferrals";
import retryReferralExport from "@salesforce/apex/ExportFailedReferralsController.retryReferralExport";
import { ShowToastEventName } from "lightning/platformShowToastEvent";
import { notifyRecordUpdateAvailable } from "lightning/uiRecordApi";

jest.mock(
  "@salesforce/apex/ExportFailedReferralsController.retryReferralExport",
  () => ({ default: jest.fn() }),
  { virtual: true }
);

jest.mock(
  "lightning/uiRecordApi",
  () => ({ notifyRecordUpdateAvailable: jest.fn() }),
  { virtual: true }
);

describe("c-export-failed-referrals", () => {
  afterEach(() => {
    while (document.body.firstChild) {
      document.body.removeChild(document.body.firstChild);
    }
    jest.clearAllMocks();
  });

  async function flushPromises() {
    return Promise.resolve();
  }

  it("should show the specific error message when apex fails", async () => {
    const EXPECTED_ERROR =
      "Your Referral has failed to be sent, please check the details and try again.";

    // FIX: Mock the rejection to return the EXACT string you are testing for
    retryReferralExport.mockRejectedValue({
      body: { message: EXPECTED_ERROR }
    });

    const element = createElement("c-export-failed-referrals", {
      is: ExportFailedReferrels
    });
    document.body.appendChild(element);

    const toastHandler = jest.fn();
    element.addEventListener(ShowToastEventName, toastHandler);

    // Act
    await element.invoke();
    await flushPromises();

    // Assert
    expect(toastHandler).toHaveBeenCalled();
    const toastEvent = toastHandler.mock.calls[0][0];
    expect(toastEvent.detail.message).toBe(EXPECTED_ERROR);
    expect(toastEvent.detail.variant).toBe("error");
  });
});
