import { createElement } from "lwc";
import AccountClosureRecordsTable from "c/accountClosureRecordsTable";

const MOCK_RESPONSE_DATA = require("./data/mockResponseData.json");

describe("c-account-closure-records-table", () => {
  // clean the dom and mocks in between test runs
  beforeEach(() => {
    const element = createElement("c-account-closure-records-table", {
      is: AccountClosureRecordsTable
    });
    element.records = MOCK_RESPONSE_DATA;
    document.body.appendChild(element);
  });

  it("Checks if the data populates properly", () => {
    const element = document.querySelector("c-account-closure-records-table");
    const rows = element.shadowRoot.querySelectorAll("tr");
    expect(rows.length).toBe(MOCK_RESPONSE_DATA.length + 1);

    const firstRow = rows[1]; // The first row of data
    expect(firstRow.querySelector('td[data-label="Product"]').textContent).toBe(
      "40% Callable Term Deposit"
    );
    expect(
      firstRow.querySelector('td[data-label="Account Number"]').textContent
    ).toBe("390992614");
    expect(
      firstRow.querySelector('td[data-label="Account Type"]').textContent
    ).toBe("Sole");
    expect(firstRow.querySelector('td[data-label="Status"]').textContent).toBe(
      "Closed"
    );
  });

  it("success icon should load", () => {
    const element = document.querySelector("c-account-closure-records-table");

    const successIcon = element.shadowRoot.querySelector(
      "lightning-icon[data-id=success]"
    );
    expect(successIcon).toBeTruthy();
  });

  it("error icon should not load", () => {
    const element = document.querySelector("c-account-closure-records-table");

    const errorIcon = element.shadowRoot.querySelector(
      "lightning-icon[data-id=error]"
    );
    expect(errorIcon).toBeFalsy();
  });
});
