import { createElement } from "lwc";
import ChangeRecordTypeDefaultValue from "c/changeRecordTypeDefaultValue";

const DUMMY_RECORD_ID = "5002N00000Dwe1iQAB";
const DUMMY_RECORD_TYPE_ID = "0122N00000314ujQAA";
const DUMMY_RECORD_TYPE_NAME = "General_Inquiry";
const DUMMY_GENERAL_ENQUIRY_DEFAULT_VALUES =
  '{"AccountId":"", "IDR_Product_Category__c":"Not product related","Description":"Test Desc","Priority":"","Type":"","Sub_Type__c" : ""}';

describe("c-change-record-type-default-value", () => {
  beforeEach(() => {
    const element = createElement("c-change-record-type-default-value", {
      is: ChangeRecordTypeDefaultValue
    });
    //set record Id and record type Id
    element.recordId = DUMMY_RECORD_ID;
    element.updatedRT = DUMMY_RECORD_TYPE_ID;
    element.updatedRTName = DUMMY_RECORD_TYPE_NAME;
    element.defaultValues = DUMMY_GENERAL_ENQUIRY_DEFAULT_VALUES;
    document.body.appendChild(element);
  });

  it("Load change record type default value page before load the form", () => {
    const element = document.querySelector(
      "c-change-record-type-default-value"
    );

    const recordEditFormElement = element.shadowRoot.querySelectorAll(
      "lightning-record-edit-form"
    );
    expect(recordEditFormElement.length).toBe(2);
  });

  it("Load change record type default value page after load the form", () => {
    const element = document.querySelector(
      "c-change-record-type-default-value"
    );
    setTimeout(() => {
      const recordEditFormElement = element.shadowRoot.querySelectorAll(
        "lightning-record-edit-form"
      );
      expect(recordEditFormElement.length).toBe(2);

      const lightningSpinner = element.shadowRoot.querySelector(
        "lightning-spinner"
      );
      expect(lightningSpinner).toBeFalsy();
    }, 1000);
  });

  it("All the input fields should be shown", () => {
    setTimeout(() => {
      const element = document.querySelector(
        "c-change-record-type-default-value"
      );
      const inputFields = element.shadowRoot.querySelectorAll(
        "lightning-input-field"
      );
      expect(inputFields.length > 0).toBeTruthy();
    }, 1000);
  });

  it("Expected input field should be there", () => {
    setTimeout(() => {
      const element = document.querySelector(
        "c-change-record-type-default-value"
      );
      let inputField = element.shadowRoot.querySelector(
        "lightning-input-field[data-id='Type']"
      );
      expect(inputField).toBeTruthy();

      inputField = element.shadowRoot.querySelector(
        "lightning-input-field[data-id='Sub_Type__c']"
      );
      expect(inputField).toBeTruthy();

      inputField = element.shadowRoot.querySelector(
        "lightning-input-field[data-id='AccountId']"
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
    }, 1000);
  });

  it("Change the default values on form", () => {
    setTimeout(() => {
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
        "lightning-input-field[data-id='AccountId']"
      );
      inputField.dispatchEvent(
        new CustomEvent("change", {
          detail: { name: "AccountId", value: "0019h000009QUdBAAW" }
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
    }, 1000);
  });
});
