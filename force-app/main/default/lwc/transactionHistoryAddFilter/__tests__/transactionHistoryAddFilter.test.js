import TransactionHistoryAddFilter from "c/transactionHistoryAddFilter";
import { createElement } from "lwc";

describe("c-transactionHistoryAddFilter", () => {
  afterEach(() => {
    // The jsdom instance is shared across test cases in a single file so reset the DOM
    while (document.body.firstChild) {
      document.body.removeChild(document.body.firstChild);
    }
  });

  it("test text field is correct when relatedList is Amount", () => {
    const element = createElement("c-transactionHistoryAddFilter", {
      is: TransactionHistoryAddFilter
    });

    element.relatedField = "Amount";
    document.body.appendChild(element);

    return Promise.resolve().then(() => {
      const textInput = element.shadowRoot.querySelector("input[type='text']");
      expect(textInput).not.toBeNull();
    });
  });

  it("test event is of correct information", () => {
    const element = createElement("c-transactionHistoryAddFilter", {
      is: TransactionHistoryAddFilter
    });

    element.relatedField = "Amount";
    document.body.appendChild(element);

    const handler = jest.fn();
    element.addEventListener("applyaddfilter", handler);

    return Promise.resolve()
      .then(() => {
        const textInput = element.shadowRoot.querySelector(
          "input[type='text']"
        );
        textInput.value = "test input";
        textInput.dispatchEvent(new CustomEvent("change"));

        const operatorSelect = element.shadowRoot.querySelector(
          "lightning-combobox"
        );
        operatorSelect.value = "equals";
        operatorSelect.dispatchEvent(
          new CustomEvent("change", {
            detail: { value: operatorSelect.value }
          })
        );

        const applyBtn = element.shadowRoot.querySelector(
          "button.slds-button_brand"
        );
        applyBtn.click();
      })
      .then(() => {
        expect(handler).toHaveBeenCalled();
      });
  });

  it("test event is of correct date information", () => {
    const element = createElement("c-transactionHistoryAddFilter", {
      is: TransactionHistoryAddFilter
    });

    element.relatedField = "TransactionDate";
    document.body.appendChild(element);

    const handler = jest.fn();
    element.addEventListener("applyaddfilter", handler);

    return Promise.resolve()
      .then(() => {
        const dateInput = element.shadowRoot.querySelector("lightning-input");
        dateInput.value = new Date().toISOString().slice(0, 10);
        dateInput.dispatchEvent(new CustomEvent("change"));

        const applyBtn = element.shadowRoot.querySelector(
          "button.slds-button_brand"
        );
        applyBtn.click();
      })
      .then(() => {
        expect(handler).toHaveBeenCalled();
      });
  });

  it("test cancel event is fired correctly", () => {
    const element = createElement("c-transactionHistoryAddFilter", {
      is: TransactionHistoryAddFilter
    });

    element.relatedField = "Amount";
    document.body.appendChild(element);

    const handler = jest.fn();
    element.addEventListener("addfiltercancel", handler);

    return Promise.resolve()
      .then(() => {
        const textInput = element.shadowRoot.querySelector(
          "input[type='text']"
        );
        textInput.value = "test input";
        textInput.dispatchEvent(new CustomEvent("change"));

        const cancleBtn = element.shadowRoot.querySelector(
          "button.slds-m-right_medium"
        );
        cancleBtn.click();
      })
      .then(() => {
        expect(handler).toHaveBeenCalled();
      });
  });
});
