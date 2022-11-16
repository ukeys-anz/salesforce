import { createElement } from "lwc";
import ProspectDeleteContact from "c/prospectDeleteContact";
import deleteProspectContact from "@salesforce/apex/CCRMCustomerProfileUpdateHelper.deleteProspectContact";
import { CloseScreenEventName } from "lightning/actions";
import { ShowToastEventName } from "lightning/platformShowToastEvent";
import { setImmediate } from "timers";

const flushPromises = () => new Promise(setImmediate);

// Mocking imperative Apex method call
jest.mock(
  "@salesforce/apex/CCRMCustomerProfileUpdateHelper.deleteProspectContact",
  () => {
    return {
      default: jest.fn()
    };
  },
  { virtual: true }
);

describe("c-prospect-delete-contact", () => {
  //Prepare data before each test method
  beforeEach(() => {
    const element = createElement("c-prospect-delete-contact", {
      is: ProspectDeleteContact
    });
    document.body.appendChild(element);
  });

  afterEach(() => {
    // The jsdom instance is shared across test cases in a single file so reset the DOM
    while (document.body.firstChild) {
      document.body.removeChild(document.body.firstChild);
    }
  });

  it("Test banker cancel action", () => {
    const lwcCmp = document.querySelector("c-prospect-delete-contact");
    const handler = jest.fn();
    lwcCmp.addEventListener(CloseScreenEventName, handler);

    const btnCancel = lwcCmp.shadowRoot.querySelector(".btnCancel");
    btnCancel.dispatchEvent(new CustomEvent("click"));

    return Promise.resolve().then(() => {
      expect(handler).toHaveBeenCalled();
    });
  });

  it("Test banker confirm action", () => {
    deleteProspectContact.mockResolvedValue({});

    const lwcCmp = document.querySelector("c-prospect-delete-contact");
    const handler = jest.fn();
    lwcCmp.addEventListener(CloseScreenEventName, handler);

    const btnDelete = lwcCmp.shadowRoot.querySelector(".btnDelete");
    btnDelete.dispatchEvent(new CustomEvent("click"));

    return flushPromises().then(() => {
      expect(handler).toHaveBeenCalled();
    });
  });

  it("Test delete error", () => {
    const ERROR_MESSAGE = "failed to delete contact";
    deleteProspectContact.mockRejectedValue({
      body: { message: ERROR_MESSAGE }
    });

    const lwcCmp = document.querySelector("c-prospect-delete-contact");
    const showToastHandler = jest.fn();
    lwcCmp.addEventListener(ShowToastEventName, showToastHandler);

    const btnDelete = lwcCmp.shadowRoot.querySelector(".btnDelete");
    btnDelete.dispatchEvent(new CustomEvent("click"));

    return flushPromises().then(() => {
      expect(showToastHandler).toHaveBeenCalled();
      const toastMessage = showToastHandler.mock.calls[0][0];
      expect(toastMessage.detail.message).toBe(ERROR_MESSAGE);
      expect(toastMessage.detail.variant).toBe("error");
    });
  });
});
