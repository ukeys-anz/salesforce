import { createElement } from "lwc";
import SopAddEditIncome from "c/sopAddEditIncome";

const SOP_DATA = require("./data/incomeDetails.json");

describe("c-sop-add-edit-income", () => {
  afterEach(() => {
    // Clean up the DOM after each test
    while (document.body.firstChild) {
      document.body.removeChild(document.body.firstChild);
    }
    jest.clearAllMocks();
  });

  async function flushPromises() {
    return Promise.resolve();
  }

  it("renders the component", async () => {
    const element = createElement("c-sop-add-edit-income", {
      is: SopAddEditIncome
    });
    element.incomeDetails = SOP_DATA;
    document.body.appendChild(element);
    await flushPromises();

    let base = element.shadowRoot.querySelector(
      "lightning-formatted-text[data-jest-id='baseSalary']"
    );
    expect(base).toBeTruthy();
    let overtime = element.shadowRoot.querySelector(
      "lightning-formatted-text[data-jest-id='overtime']"
    );
    expect(overtime).toBeTruthy();
    let commission = element.shadowRoot.querySelector(
      "lightning-formatted-text[data-jest-id='commission']"
    );
    expect(commission).toBeTruthy();
  });
});
