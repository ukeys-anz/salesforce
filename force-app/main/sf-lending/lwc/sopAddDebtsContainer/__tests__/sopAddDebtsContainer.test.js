import { createElement } from "lwc";
import SopAddDebtsContainer from "c/sopAddDebtsContainer";

const DEBT_OPTIONS = [
  { label: "Credit Card", value: "LIABILITY_TYPE_CREDIT_CARD" },
  { label: "Personal Loan", value: "LIABILITY_TYPE_PERSONAL_LOAN" },
  { label: "Vehicle Loan", value: "LIABILITY_TYPE_VEHICLE_LOAN" },
  { label: "Buy Now Pay Later", value: "BNPL" }, //BNPL has its own selection form
  {
    label: "Vehicle Lease / Hire Purchase",
    value: "LIABILITY_TYPE_LEASE_HIRE_PURCHASE"
  },
  { label: "HECS - HELP", value: "LIABILITY_TYPE_STUDENT_LOAN" },
  { label: "Overdraft", value: "LIABILITY_TYPE_OVERDRAFT" },
  { label: "Margin Loan", value: "LIABILITY_TYPE_MARGIN_LOAN" },
  { label: "Other Loan", value: "LIABILITY_TYPE_OTHER_LOAN" }
];
describe("c-sop-add-debts-container", () => {
  afterEach(() => {
    // The jsdom instance is shared across test cases in a single file so reset the DOM
    while (document.body.firstChild) {
      document.body.removeChild(document.body.firstChild);
    }
  });

  async function flushPromises() {
    return Promise.resolve();
  }

  it("test debt selection is visible", async () => {
    const element = createElement("c-sop-add-debts-container", {
      is: SopAddDebtsContainer
    });

    document.body.appendChild(element);
    await flushPromises();
    let radioGroup = element.shadowRoot.querySelector(
      "lightning-radio-group[data-id='debtSelection']"
    );
    expect(radioGroup).toBeTruthy();
    expect(radioGroup.options).toEqual(DEBT_OPTIONS);
  });
});
