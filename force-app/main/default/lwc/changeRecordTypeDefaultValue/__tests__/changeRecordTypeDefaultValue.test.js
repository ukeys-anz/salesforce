import { createElement } from "lwc";
import ChangeRecordTypeDefaultValue from "c/changeRecordTypeDefaultValue";
// import { getRecord } from "lightning/uiRecordApi";

const DUMMY_RECORD_ID = "5002N00000Dwe1iQAB";
const DUMMY_RECORD_TYPE_ID = "0122N00000314ujQAA";
const DUMMY_GENERAL_ENQUIRY_DEFAULT_VALUES =
  '{"IDR_Product_Category__c":"Not product related","Description":"Test Desc","Priority":"","Type":""}';
// const mockGetCaseRecord = require("./data/getCaseRecord.json");

describe("c-change-record-type-default-value", () => {
  beforeEach(() => {
    const element = createElement("c-change-record-type-default-value", {
      is: ChangeRecordTypeDefaultValue
    });
    //set record Id and record type Id
    element.recordId = DUMMY_RECORD_ID;
    element.updatedRT = DUMMY_RECORD_TYPE_ID;
    element.defaultValues = DUMMY_GENERAL_ENQUIRY_DEFAULT_VALUES;
    document.body.appendChild(element);
  });

  it("Load change record type default value page", () => {
    const element = document.querySelector(
      "c-change-record-type-default-value"
    );
    //Load Record Edit Form
    const recordEditFormElement = element.shadowRoot.querySelectorAll(
      "lightning-record-edit-form"
    );
    expect(recordEditFormElement.length).toBe(2);
  });

  it("All the input fields should be shown", () => {
    const element = document.querySelector(
      "c-change-record-type-default-value"
    );
    const inputFields = element.shadowRoot.querySelectorAll(
      "lightning-input-field"
    );
    expect(inputFields.length > 0).toBeTruthy();
  });

  it("Expected input field should be there", () => {
    const element = document.querySelector(
      "c-change-record-type-default-value"
    );
    let inputField = element.shadowRoot.querySelector(
      "lightning-input-field[data-id='Type']"
    );
    expect(inputField).toBeTruthy();

    inputField = element.shadowRoot.querySelector(
      "lightning-input-field[data-id='IDR_Product_Category__c']"
    );
    expect(inputField).toBeTruthy();

    inputField = element.shadowRoot.querySelector(
      "lightning-input-field[data-id='Description']"
    );
    expect(inputField).toBeTruthy();

    inputField = element.shadowRoot.querySelector(
      "lightning-input-field[data-id='Priority']"
    );
    expect(inputField).toBeTruthy();
  });

  it("Change the default values on form", () => {
    const element = document.querySelector(
      "c-change-record-type-default-value"
    );

    let inputField = element.shadowRoot.querySelector(
      "lightning-input-field[data-id='Type']"
    );
    inputField.dispatchEvent(
      new CustomEvent("change", { detail: { name: "Type", value: "Fraud" } })
    );
    expect(inputField).toBeTruthy();

    inputField = element.shadowRoot.querySelector(
      "lightning-input-field[data-id='Priority']"
    );
    inputField.dispatchEvent(
      new CustomEvent("change", {
        detail: { name: "Priority", value: "Critical" }
      })
    );
    expect(inputField).toBeTruthy();

    inputField = element.shadowRoot.querySelector(
      "lightning-input-field[data-id='IDR_Product_Category__c']"
    );
    inputField.dispatchEvent(
      new CustomEvent("change", {
        detail: { name: "IDR_Product_Category__c", value: "Credit card" }
      })
    );
    expect(inputField).toBeTruthy();

    inputField = element.shadowRoot.querySelector(
      "lightning-input-field[data-id='Description']"
    );
    inputField.dispatchEvent(
      new CustomEvent("change", {
        detail: { name: "Description", value: "Changed Desc" }
      })
    );
    expect(inputField).toBeTruthy();
  });
});
