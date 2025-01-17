import { createElement } from "lwc";
import AccountClosureButton from "c/accountClosureButton";
import fetchChildCasesForClosure from "@salesforce/apex/AccountClosureController.fetchChildCasesForClosure";
import getPackageClosureAura from "@salesforce/apex/AccountClosureStravinskyController.getPackageClosureAura";

const MOCK_ELIGIBLE_CASES_FOR_CLOSURE = require("./data/mockSuccessResponse.json");
const MOCK_SUCCESS_PACKAGE_RESPONSE = require("./data/mockSuccessPackageResponse.json");
const MOCK_FAILURE_PACKAGE_RESPONSE = require("./data/mockFailurePackageResponse.json");

const RECORD_ID = "500AD00000K7EypYAF";

jest.mock(
  "@salesforce/apex/AccountClosureController.fetchChildCasesForClosure",
  () => {
    const { createApexTestWireAdapter } = require("@salesforce/sfdx-lwc-jest");
    return {
      default: createApexTestWireAdapter(jest.fn(() => Promise.resolve()))
    };
  },
  { virtual: true }
);

jest.mock(
  "@salesforce/apex/AccountClosureStravinskyController.getPackageClosureAura",
  () => {
    return {
      default: jest.fn()
    };
  },
  { virtual: true }
);

describe("c-account-closure-button", () => {
  beforeEach(() => {
    const element = createElement("c-account-closure-button", {
      is: AccountClosureButton
    });
    element.recordId = RECORD_ID;
    document.body.appendChild(element);
  });

  afterEach(() => {
    while (document.body.firstChild) {
      document.body.removeChild(document.body.firstChild);
    }
    jest.clearAllMocks();
  });

  async function flushPromises() {
    return Promise.resolve();
  }

  it("renders the button with the correct label and initial state", async () => {
    const element = document.querySelector("c-account-closure-button");
    fetchChildCasesForClosure.emit(MOCK_ELIGIBLE_CASES_FOR_CLOSURE);
    await flushPromises();
    const cancelButton = element.shadowRoot.querySelector(
      "lightning-button[data-id=cancel]"
    );
    const closeButton = element.shadowRoot.querySelector(
      "lightning-button[data-id=closeaccounts]"
    );
    const dataTable = element.shadowRoot.querySelector(
      "lightning-datatable[data-id=datatable]"
    );

    expect(dataTable.data.length).toBe(2);
    expect(cancelButton).toBeTruthy();
    expect(closeButton).toBeTruthy();
    expect(element.isAccountClosed).toBeFalsy();
  });

  it("displays success message when accounts are successfully closed", async () => {
    getPackageClosureAura.mockResolvedValue(MOCK_SUCCESS_PACKAGE_RESPONSE);
    const element = document.querySelector("c-account-closure-button");
    fetchChildCasesForClosure.emit(MOCK_ELIGIBLE_CASES_FOR_CLOSURE);
    await flushPromises();

    const closeButton = element.shadowRoot.querySelector(
      "lightning-button[data-id=closeaccounts]"
    );

    closeButton.click();
    await flushPromises();

    await flushPromises();
    const successIcon = element.shadowRoot.querySelector(
      "lightning-icon[data-id=success]"
    );

    const childComponent = element.shadowRoot.querySelector(
      "c-account-closure-records-table"
    );

    expect(successIcon).toBeTruthy();
    expect(childComponent).toBeTruthy();
  });

  it("displays failure message when accounts are fail to close", async () => {
    getPackageClosureAura.mockResolvedValue(MOCK_FAILURE_PACKAGE_RESPONSE);
    const element = document.querySelector("c-account-closure-button");
    fetchChildCasesForClosure.emit(MOCK_ELIGIBLE_CASES_FOR_CLOSURE);
    await flushPromises();

    const closeButton = element.shadowRoot.querySelector(
      "lightning-button[data-id=closeaccounts]"
    );
    closeButton.click();
    await flushPromises();

    await flushPromises();
    const failureIcon = element.shadowRoot.querySelector(
      "lightning-icon[data-id=failure]"
    );

    const childComponent = element.shadowRoot.querySelector(
      "c-account-closure-records-table"
    );

    expect(failureIcon).toBeTruthy();
    expect(childComponent).toBeTruthy();
  });
});
