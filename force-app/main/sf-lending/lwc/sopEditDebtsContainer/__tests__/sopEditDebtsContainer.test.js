import { createElement } from "lwc";
import SopEditDebtsContainer from "c/sopEditDebtsContainer";

const DEBT_DATA = require("./data/debtData.json");
const PARTIES = require("./data/parties.json");

describe("c-sop-edit-debts-container", () => {
  afterEach(() => {
    // The jsdom instance is shared across test cases in a single file so reset the DOM
    while (document.body.firstChild) {
      document.body.removeChild(document.body.firstChild);
    }
  });

  async function flushPromises() {
    return Promise.resolve();
  }

  it("test edit debt is visible", async () => {
    const element = createElement("c-sop-edit-debts-container", {
      is: SopEditDebtsContainer
    });
    element.debtData = DEBT_DATA;
    element.debtType = "LIABILITY_TYPE_CREDIT_CARD";
    element.parties = PARTIES;
    document.body.appendChild(element);
    await flushPromises();
    let debt = element.shadowRoot.querySelector(
      "c-sop-add-edit-debts[data-id='debtItem']"
    );
    expect(debt).toBeTruthy();
  });
});
