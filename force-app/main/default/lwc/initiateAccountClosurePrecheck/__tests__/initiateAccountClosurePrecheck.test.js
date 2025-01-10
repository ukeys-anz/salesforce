import { createElement } from 'lwc';
import InitiateAccountClosurePrecheck from 'c/initiateAccountClosurePrecheck';
import fetchEligibleCasesForPrecheck from "@salesforce/apex/AccountClosureController.fetchEligibleCasesForPrecheck";
import initiateAccountClosurePrecheck from "@salesforce/apex/AccountClosureController.initiateAccountClosurePrecheck";

const MOCK_ELIGIBLE_CASES_FOR_PRECHECK = require("./data/mockFetchCaseDataSuccess.json");
const MOCK_SUCCESS_PRECHECK_RESPONSE = require("./data/mockAccountClosurePrecheckSuccess.json");
const MOCK_SUCCESS_AND_FAILURE_PRECHECK_RESPONSE = require("./data/mockAccountClosurePrecheckSuccessAndFailure.json");
const MOCK_FAILURE_PRECHECK_RESPONSE = require("./data/mockAccountClosurePrecheckFailure.json");

const RECORD_ID = "500AD00000K7EyoYAF";

jest.mock(
    "@salesforce/apex/AccountClosureController.fetchEligibleCasesForPrecheck",
    () => {
      const { createApexTestWireAdapter } = require("@salesforce/sfdx-lwc-jest");
      return {
        default: createApexTestWireAdapter(jest.fn(() => Promise.resolve()))
      };
    },
    { virtual: true }
  );

jest.mock(
    "@salesforce/apex/AccountClosureController.initiateAccountClosurePrecheck",
    () => {
      return {
        default: jest.fn()
      };
    },
    { virtual: true }
  );


describe('c-initiate-account-closure-precheck', () => {
    beforeEach(() => {
        const element = createElement("c-initiate-account-closure-precheck", {
          is: InitiateAccountClosurePrecheck
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
        const element = document.querySelector("c-initiate-account-closure-precheck");
        fetchEligibleCasesForPrecheck.emit(MOCK_ELIGIBLE_CASES_FOR_PRECHECK);
        await flushPromises();
        const cancelButton = element.shadowRoot.querySelector(
          "lightning-button[data-id=cancel]"
        );
        const initiatePrecheckButton = element.shadowRoot.querySelector(
          "lightning-button[data-id=initiateprecheck]"
        );
        const dataTable = element.shadowRoot.querySelector(
          "lightning-datatable[data-id=datatable]"
        );
    
        expect(dataTable.data.length).toBe(3);
        expect(cancelButton).toBeTruthy();
        expect(initiatePrecheckButton).toBeTruthy();
      });
    
    it("displays success message when precheck was done successfully", async () => {
        initiateAccountClosurePrecheck.mockResolvedValue(MOCK_SUCCESS_PRECHECK_RESPONSE);
        const element = document.querySelector("c-initiate-account-closure-precheck");
        fetchEligibleCasesForPrecheck.emit(MOCK_ELIGIBLE_CASES_FOR_PRECHECK);
        await flushPromises();

        const initiatePrecheckButton = element.shadowRoot.querySelector(
            "lightning-button[data-id=initiateprecheck]"
        );

        initiatePrecheckButton.click();
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

    it("displays warning message when precheck was not done successfully", async () => {
        initiateAccountClosurePrecheck.mockResolvedValue(MOCK_FAILURE_PRECHECK_RESPONSE);
        const element = document.querySelector("c-initiate-account-closure-precheck");
        fetchEligibleCasesForPrecheck.emit(MOCK_ELIGIBLE_CASES_FOR_PRECHECK);
        await flushPromises();

        const initiatePrecheckButton = element.shadowRoot.querySelector(
            "lightning-button[data-id=initiateprecheck]"
        );

        initiatePrecheckButton.click();
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

    it("displays warning message when precheck was not done successfully", async () => {
        initiateAccountClosurePrecheck.mockResolvedValue(MOCK_SUCCESS_AND_FAILURE_PRECHECK_RESPONSE);
        const element = document.querySelector("c-initiate-account-closure-precheck");
        fetchEligibleCasesForPrecheck.emit(MOCK_ELIGIBLE_CASES_FOR_PRECHECK);
        await flushPromises();

        const initiatePrecheckButton = element.shadowRoot.querySelector(
            "lightning-button[data-id=initiateprecheck]"
        );

        initiatePrecheckButton.click();
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