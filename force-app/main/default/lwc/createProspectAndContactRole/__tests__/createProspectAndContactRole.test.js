import { createElement } from "lwc";
import CreateProspectAndContactRole from "c/createProspectAndContactRole";

describe("c-create-prospect-and-contact-role", () => {
  beforeEach(() => {
    const element = createElement("c-create-prospect-and-contact-role", {
      is: CreateProspectAndContactRole
    });
    document.body.appendChild(element);
  });

  it("check quick panel load", () => {
    const element = document.querySelector(
      "c-create-prospect-and-contact-role"
    );
    const loadingEle = element.shadowRoot.querySelector(
      "lightning-quick-action-panel"
    );

    return Promise.resolve().then(() => {
      expect(loadingEle).not.toBeNull();
    });
  });

  it("test onchange combo box", () => {
    const element = document.querySelector(
      "c-create-prospect-and-contact-role"
    );

    const inputElement = element.shadowRoot.querySelector(
      "lightning-combobox.responseStatus"
    );
    inputElement.value = "Mr.";

    inputElement.dispatchEvent(
      new CustomEvent("change", {
        detail: { value: inputElement.value }
      })
    );

    const salutationInput = element.shadowRoot.querySelector(".responseStatus");

    return Promise.resolve().then(() => {
      expect(salutationInput).not.toBeNull();
    });
  });

  it("test Role picklist onload value", () => {
    const element = document.querySelector(
      "c-create-prospect-and-contact-role"
    );

    const inputElement = element.shadowRoot.querySelector(
      "lightning-combobox.role"
    );

    return Promise.resolve().then(() => {
      expect(inputElement.value).toBe("Applicant");
    });
  });
});
