import { createElement } from "lwc";
import SopCreditBureauCheck from "c/sopCreditBureauCheck";

const BUREAU_DATA = require("./data/creditBureauData.json");

describe("c-sop-credit-bureau-check", () => {
  afterEach(() => {
    // The jsdom instance is shared across test cases in a single file so reset the DOM
    while (document.body.firstChild) {
      document.body.removeChild(document.body.firstChild);
    }
  });

  async function flushPromises() {
    return Promise.resolve();
  }

  it("test bureau check is visible", async () => {
    const element = createElement("c-sop-credit-bureau-check", {
      is: SopCreditBureauCheck
    });

    element.creditBureauData = BUREAU_DATA;
    element.partyConsent = true;
    document.body.appendChild(element);
    await flushPromises();
    let bureauItem = element.shadowRoot.querySelector(
      "lightning-layout-item[data-id='bureauCheck']"
    );
    expect(bureauItem).toBeTruthy();
  });

  it("test no consent message is visible", async () => {
    const element = createElement("c-sop-credit-bureau-check", {
      is: SopCreditBureauCheck
    });

    element.creditBureauData = BUREAU_DATA;
    element.partyConsent = false;
    document.body.appendChild(element);
    await flushPromises();
    let consentMessage = element.shadowRoot.querySelector(
      "lightning-formatted-text[data-id='noConsentMessage']"
    );
    expect(consentMessage).toBeTruthy();
    expect(consentMessage.value).toEqual(
      "Bureau check information will be shown as customer(s) confirm the bureau check in the app."
    );
  });

  it("test no consent message is visible", async () => {
    const element = createElement("c-sop-credit-bureau-check", {
      is: SopCreditBureauCheck
    });

    document.body.appendChild(element);
    await flushPromises();
    let connectMessage = element.shadowRoot.querySelector(
      "lightning-formatted-text[data-id='connectErrorMessage']"
    );
    expect(connectMessage).toBeTruthy();
    expect(connectMessage.value).toEqual(
      "The attempt to connect to the Bureau(s) was unsuccessful.  There is no bureau check information to display."
    );
  });
});
