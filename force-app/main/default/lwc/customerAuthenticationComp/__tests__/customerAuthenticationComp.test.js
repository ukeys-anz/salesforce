import { createElement } from "lwc";
import customerAuthenticationComp from "c/customerAuthenticationComp";
import confirmationModal from "c/confirmationModal";
import getSecurityCode from "@salesforce/apex/CustomerAuthController.getSecurityCode";
import createDiaryComment from "@salesforce/apex/CustomerAuthController.createDiaryComment";
import { setImmediate } from "timers";
const GET_SECURITY_CODE = require("./data/getSecurityCode.json");
const CREATE_DIARY_COMMENT = require("./data/createDiaryComment.json");

jest.mock(
  "@salesforce/apex/CustomerAuthController.getSecurityCode",
  () => {
    return {
      default: jest.fn()
    };
  },
  { virtual: true }
);

jest.mock(
  "@salesforce/apex/CustomerAuthController.createDiaryComment",
  () => {
    return {
      default: jest.fn()
    };
  },
  { virtual: true }
);

describe("c-customer-authentication-comp", () => {
  afterEach(() => {
    while (document.body.firstChild) {
      document.body.removeChild(document.body.firstChild);
    }
    jest.clearAllMocks();
  });

  function flushPromises() {
    return new Promise((resolve) => setImmediate(resolve));
  }

  it("Get Security Code", async () => {
    getSecurityCode.mockResolvedValue(GET_SECURITY_CODE);
    const element = createElement("c-customer-authentication-comp", {
      is: customerAuthenticationComp
    });
    document.body.appendChild(element);
    const buttonElement = element.shadowRoot.querySelector(
      "lightning-button[data-id=authenticate-id]"
    );
    buttonElement.click();
    await flushPromises();
    const pElement = element.shadowRoot.querySelectorAll("lightning-input");
    expect(pElement[0].value.securityCode).toBe("AU");
  });

  it("Security code is branch to load", async () => {
    createDiaryComment.mockResolvedValue(CREATE_DIARY_COMMENT);
    const element = createElement("c-customer-authentication-comp", {
      is: customerAuthenticationComp
    });
    document.body.appendChild(element);
    const buttonElement = element.shadowRoot.querySelector(
      "lightning-button[data-id=authenticate-id]"
    );
    buttonElement.click();
    await flushPromises();
    const btnElement = element.shadowRoot.querySelector(
      "lightning-button[data-id=code-id]"
    );
    btnElement.click();
    await flushPromises();
    const childElement = createElement("c-confirmation-modal", {
      is: confirmationModal
    });
    document.body.appendChild(childElement);
    childElement.open = jest.fn().mockResolvedValue("option1");
    const pElement = childElement.shadowRoot.querySelector(
      "lightning-button[data-name=confirm]"
    );
    pElement.click();
    expect(
      childElement.modalFooter$$("button, [data-name=confirm]").length
    ).toBe(1);
  });
});
