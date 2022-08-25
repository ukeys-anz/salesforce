import { createElement } from "lwc";
import InitiateInteraction from "c/initiateInteraction";
import getPhoneNumber from "@salesforce/apex/InitiateInteractionController.getPhoneNumber";
import createInteraction from "@salesforce/apex/InitiateInteractionController.createInteraction";
import { handleErrorShowToast } from "c/utils";
import { publish } from "lightning/messageService";
import { createTestWireAdapter } from "@salesforce/wire-service-jest-util";
import voiceChannel from "@salesforce/messageChannel/InitiateOutboundCall__c";

jest.mock(
  "@salesforce/apex/InitiateInteractionController.getPhoneNumber",
  () => {
    return {
      default: jest.fn()
    };
  },
  { virtual: true }
);

jest.mock(
  "@salesforce/apex/InitiateInteractionController.createInteraction",
  () => {
    return {
      default: jest.fn()
    };
  },
  { virtual: true }
);
const MessageContext = createTestWireAdapter();
const APEX_LOG_SUCCESS = {
  Id: "0kz5P0000001AMHQA2",
  Interaction_External_Id__c: "IR-00000225"
};
const APEX_LOG_ERROR =
  "Please check you have the permissions to create an Interaction";
const LMS_MESSAGE = {
  recordId: "0kz5P0000001AMHQA2",
  externalId: "IR-00000225",
  phone: "12345678"
};
const TOAST_ERROR_VARIANT = "error";
const TOAST_CREATE_ERROR =
  "Uh-oh, there was an error and we couldn't automatically create the interaction. Please manually create a call interaction";
const TOAST_LMS_ERROR =
  "Oops, we couldn't connect your call. Please try again.";

describe("c-initiate-interaction", () => {
  afterEach(() => {
    // The jsdom instance is shared across test cases in a single file so reset the DOM
    while (document.body.firstChild) {
      document.body.removeChild(document.body.firstChild);
    }
    jest.clearAllMocks();
  });

  function flushPromises() {
    return new Promise((resolve) => setImmediate(resolve));
  }

  it("1. clicktocall visible if number on record", () => {
    getPhoneNumber.mockResolvedValue("12345678");
    const element = createElement("c-initiate-interaction", {
      is: InitiateInteraction
    });
    document.body.appendChild(element);
    return flushPromises().then(() => {
      let callCustomer = element.shadowRoot.querySelector(
        "lightning-button[data-id='call-customer']"
      );
      expect(callCustomer).toBeTruthy();
    });
  });

  it("2. clicktocall hidden if number not on record", () => {
    getPhoneNumber.mockResolvedValue();
    const element = createElement("c-initiate-interaction", {
      is: InitiateInteraction
    });
    document.body.appendChild(element);
    return flushPromises().then(() => {
      let callCustomer = element.shadowRoot.querySelector(
        "lightning-button[data-id='call-customer']"
      );
      expect(callCustomer).toBeFalsy();
    });
  });

  it("3. test toast message when unable to create interaction", () => {
    getPhoneNumber.mockResolvedValue("12345678");
    createInteraction.mockResolvedValue(APEX_LOG_ERROR);
    const element = createElement("c-initiate-interaction", {
      is: InitiateInteraction
    });
    document.body.appendChild(element);
    const handler = jest.fn();
    element.addEventListener(handleErrorShowToast, handler);
    return flushPromises()
      .then(() => {
        const callCustomer = element.shadowRoot.querySelector(
          'lightning-button[data-id="call-customer"]'
        );
        callCustomer.click();
      })
      .catch(() => {
        expect(handler).toHaveBeenCalled();
        const handlerObject = handler.mock.calls[0][0];
        expect(handlerObject.detail.variant).toBe(TOAST_ERROR_VARIANT);
        expect(handlerObject.detail.errorMessage).toBe(APEX_LOG_ERROR);
        expect(handlerObject.detail.errorText).toBe(TOAST_CREATE_ERROR);
      });
  });

  it("4. test success calling publish to LMS", () => {
    getPhoneNumber.mockResolvedValue("12345678");
    createInteraction.mockResolvedValue(APEX_LOG_SUCCESS);
    const element = createElement("c-initiate-interaction", {
      is: InitiateInteraction
    });
    document.body.appendChild(element);
    publish(MessageContext, voiceChannel, LMS_MESSAGE);
    return flushPromises()
      .then(() => {
        const callCustomer = element.shadowRoot.querySelector(
          'lightning-button[data-id="call-customer"]'
        );
        callCustomer.click();
      })
      .catch(() => {
        expect(publish).toHaveBeenCalled();
        const publishObject = publish.mock.calls[0][3];
        expect(publishObject.recordId).toBe("0kz5P0000001AMHQA2");
        expect(publishObject.externalId).toBe("IR-00000225");
        expect(publishObject.phone).toBe("12345678");
      });
  });

  it("5. test toast message when unable to publish to LMS", () => {
    getPhoneNumber.mockResolvedValue("12345678");
    createInteraction.mockResolvedValue(APEX_LOG_SUCCESS);
    const element = createElement("c-initiate-interaction", {
      is: InitiateInteraction
    });
    document.body.appendChild(element);
    publish(MessageContext, voiceChannel, LMS_MESSAGE);
    const handler = jest.fn();
    element.addEventListener(handleErrorShowToast, handler);

    return flushPromises()
      .then(() => {
        const callCustomer = element.shadowRoot.querySelector(
          'lightning-button[data-id="call-customer"]'
        );
        callCustomer.click();
      })
      .catch(() => {
        expect(handler).toHaveBeenCalled();
        const handlerObject = handler.mock.calls[0][0];
        expect(handlerObject.detail.variant).toBe(TOAST_ERROR_VARIANT);
        expect(handlerObject.detail.errorMessage).toBe(TOAST_LMS_ERROR);
      });
  });
});
