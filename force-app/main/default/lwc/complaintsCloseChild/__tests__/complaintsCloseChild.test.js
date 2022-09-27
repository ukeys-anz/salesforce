import { createElement } from "lwc";
import ComplaintsCloseChildComponent from "c/complaintsCloseChild";
import { getRecord, updateRecord } from "lightning/uiRecordApi";
import { registerLdsTestWireAdapter } from "@salesforce/sfdx-lwc-jest";

const DUMMY_RECORD_ID = "5002N00000Dwe1iQAB";
const DUMMY_RECORD_TYPE_ID = "0122N00000314ujQAA";

describe("c-complaints-close-child test suite", () => {
  beforeEach(() => {
    const element = createElement("c-complaints-close-child", {
      is: ComplaintsCloseChildComponent
    });
    //set record Id and record type Id
    element.recordId = DUMMY_RECORD_ID;
    element.recordTypeId = DUMMY_RECORD_TYPE_ID;
    document.body.appendChild(element);
  });

  it("Load close complaint child page", () => {
    const element = document.querySelector("c-complaints-close-child");
    //Load Record Edit Form
    const recordEditFormElement = element.shadowRoot.querySelectorAll(
      "lightning-record-edit-form"
    );
    expect(recordEditFormElement.length).toBe(1);
  });

  it("Fill in the details to close a complaint", () => {
    const element = document.querySelector("c-complaints-close-child");
    //Select Complaint Outcome
    const complaintOutcomeElement = element.shadowRoot.querySelector(
      "lightning-input-field[data-id=compOutCome-id]"
    );
    complaintOutcomeElement.dispatchEvent(
      new CustomEvent("change", { detail: { value: "1" } })
    );
    //Add Description of Outcome
    const descriptionOfOutcomeElement = element.shadowRoot.querySelector(
      "lightning-input-field[data-id=descOutcome-id]"
    );
    descriptionOfOutcomeElement.dispatchEvent(
      new CustomEvent("change", { detail: { value: "Test description" } })
    );
    //Select Complaint Remedy 1
    const complaintRemedy1Element = element.shadowRoot.querySelector(
      "lightning-input-field[data-id=compRemedy-id]"
    );
    complaintRemedy1Element.dispatchEvent(
      new CustomEvent("change", { detail: { value: "1" } })
    );
    return Promise.resolve().then(() => {
      //Select Complaint Sub Remedy 1
      const complaintSubRemedy1Element = element.shadowRoot.querySelector(
        "lightning-input-field[data-id=compSubRemedy-id]"
      );
      complaintSubRemedy1Element.dispatchEvent(
        new CustomEvent("change", { detail: { value: "2" } })
      );
      //Add Financial Amount
      const financialAmountElement = element.shadowRoot.querySelector(
        "lightning-input[data-id=finAmount-id]"
      );
      financialAmountElement.value = "1000";
      financialAmountElement.dispatchEvent(new CustomEvent("change"));
    });
  });
  it("Verify complaint remedy 2 is loaded", () => {
    const element = document.querySelector("c-complaints-close-child");
    const secondCompRemToggleElement = element.shadowRoot.querySelector(
      "lightning-input[data-id=issue2-id]"
    );
    secondCompRemToggleElement.checked = true;
    secondCompRemToggleElement.dispatchEvent(new CustomEvent("change"));
    return Promise.resolve().then(() => {
      const complaintRemedy2Element = element.shadowRoot.querySelectorAll(
        "lightning-input-field[data-id=compRemedy2-id]"
      );
      expect(complaintRemedy2Element.length).toBe(1);
    });
  });

  it("Verify complaint remedy 3 is loaded", () => {
    const element = document.querySelector("c-complaints-close-child");
    const secondCompRemToggleElement = element.shadowRoot.querySelector(
      "lightning-input[data-id=issue2-id]"
    );
    secondCompRemToggleElement.checked = true;
    secondCompRemToggleElement.dispatchEvent(new CustomEvent("change"));
    return Promise.resolve().then(() => {
      const thirdCompRemToggleElement = element.shadowRoot.querySelector(
        "lightning-input[data-id=issue3-id]"
      );
      thirdCompRemToggleElement.checked = true;
      thirdCompRemToggleElement.dispatchEvent(new CustomEvent("change"));
      return Promise.resolve().then(() => {
        const complaintRemedy3Element = element.shadowRoot.querySelectorAll(
          "lightning-input-field[data-id=compRemedy3-id]"
        );
        expect(complaintRemedy3Element.length).toBe(1);
      });
    });
  });

  it("Verify product manufacturer selection", () => {
    const element = document.querySelector("c-complaints-close-child");
    const complaintRemedy1Element = element.shadowRoot.querySelector(
      "lightning-input-field[data-id=compRemedy-id]"
    );
    complaintRemedy1Element.dispatchEvent(
      new CustomEvent("change", { detail: { value: "3" } })
    );
    return Promise.resolve().then(() => {
      const prodManufCheckboxElement = element.shadowRoot.querySelectorAll(
        "lightning-input[data-id=thirdPartyIsDetailsProvidedToProductManufacturer-id]"
      );
      expect(prodManufCheckboxElement.length).toBe(1);
    });
  });
});
