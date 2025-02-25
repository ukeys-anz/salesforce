import { createElement } from "lwc";
import SopAddEditDebts from "c/sopAddEditDebts";

const DEBT_DATA = require("./data/debtData.json");
const PARTIES = require("./data/parties.json");

describe("c-sop-add-edit-debts", () => {
  afterEach(() => {
    // The jsdom instance is shared across test cases in a single file so reset the DOM
    while (document.body.firstChild) {
      document.body.removeChild(document.body.firstChild);
    }
  });

  async function flushPromises() {
    return Promise.resolve();
  }

  it("test add debt visible", async () => {
    const element = createElement("c-sop-add-edit-debts", {
      is: SopAddEditDebts
    });
    element.actionType = "Add";
    element.debtType = "LIABILITY_TYPE_CREDIT_CARD";
    element.parties = PARTIES;
    document.body.appendChild(element);
    await flushPromises();
    let debtSection = element.shadowRoot.querySelector(
      "lightning-accordion-section[data-id='debtDetails']"
    );
    expect(debtSection).toBeTruthy();

    let debtAmountSection = element.shadowRoot.querySelector(
      "lightning-accordion-section[data-id='debtAmounts']"
    );
    expect(debtAmountSection).toBeTruthy();

    let closeDebtSection = element.shadowRoot.querySelector(
      "lightning-accordion-section[data-id='closeDebt']"
    );
    expect(closeDebtSection).toBeTruthy();
  });

  it("test edit debt visible", async () => {
    const element = createElement("c-sop-add-edit-debts", {
      is: SopAddEditDebts
    });
    element.actionType = "Edit";
    element.debtType = "LIABILITY_TYPE_CREDIT_CARD";
    element.debtData = DEBT_DATA;
    element.parties = PARTIES;
    document.body.appendChild(element);
    await flushPromises();
    let debtSection = element.shadowRoot.querySelector(
      "lightning-accordion-section[data-id='debtDetails']"
    );
    expect(debtSection).toBeTruthy();

    let debtAmountSection = element.shadowRoot.querySelector(
      "lightning-accordion-section[data-id='debtAmounts']"
    );
    expect(debtAmountSection).toBeTruthy();

    let closeDebtSection = element.shadowRoot.querySelector(
      "lightning-accordion-section[data-id='closeDebt']"
    );
    expect(closeDebtSection).toBeTruthy();
    await flushPromises();
    let debtSource = element.shadowRoot.querySelector(
      "lightning-input[data-id='debtSource']"
    );
    expect(debtSource).toBeTruthy();
    expect(debtSource.value).toBe(DEBT_DATA.readableSourceType);
  });
});
