import PageBackgroundModal from "c/pageBackgroundModal";
import { createElement } from "lwc";
import getSessionIdToken from "@salesforce/apex/AuthTokenCacheUtil.getSessionIdToken";

jest.mock(
  "@salesforce/apex/AuthTokenCacheUtil.getSessionIdToken",
  () => {
    return {
      default: jest.fn()
    };
  },
  { virtual: true }
);

const REJECTED_VALUE = {
  body: { message: "An internal server error has occurred" },
  ok: false,
  status: 400,
  statusText: "Bad Request"
};

describe("c-pageBackgroundModal", () => {
  //clean the dom and mocks in between test runs
  afterEach(() => {
    while (document.body.firstChild) {
      document.body.removeChild(document.body.firstChild);
    }
    jest.clearAllMocks();
  });

  // required for imperative apex calls
  function flushPromises() {
    // eslint-disable-next-line no-undef
    return new Promise((resolve) => setImmediate(resolve));
  }

  describe("message text initializes correctly", () => {
    it("test the modal loads in the correct scenario", () => {
      getSessionIdToken.mockRejectedValue(REJECTED_VALUE);

      const element = createElement("page-background-modal", {
        is: PageBackgroundModal
      });
      document.body.appendChild(element);

      return flushPromises().then(() => {
        const div = element.shadowRoot.querySelector(
          "div[data-id='modal-message']"
        );
        expect(div.textContent).toBe("An internal server error has occurred");
      });
    });

    it("test the modal closes on cancel", () => {
      getSessionIdToken.mockRejectedValue(REJECTED_VALUE);

      const element = createElement("page-background-modal", {
        is: PageBackgroundModal
      });
      document.body.appendChild(element);

      return flushPromises()
        .then(() => {
          // assert the modal is rendered
          const modal = element.shadowRoot.querySelector("section");
          expect(modal).not.toBeNull();
          const closeButton = element.shadowRoot.querySelector(
            "lightning-button[data-id='close-button']"
          );
          closeButton.click();
        })
        .then(() => {
          // assert the modal is no longer rendered
          const modal = element.shadowRoot.querySelector("section");
          expect(modal).toBeNull();
        });
    });

    it("test the modal closes on X", () => {
      getSessionIdToken.mockRejectedValue(REJECTED_VALUE);

      const element = createElement("page-background-modal", {
        is: PageBackgroundModal
      });
      document.body.appendChild(element);

      return flushPromises()
        .then(() => {
          // assert the modal is rendered
          const modal = element.shadowRoot.querySelector("section");
          expect(modal).not.toBeNull();
          const closeButton = element.shadowRoot.querySelector(
            "lightning-button-icon"
          );
          closeButton.click();
        })
        .then(() => {
          // assert the modal is no longer rendered
          const modal = element.shadowRoot.querySelector("section");
          expect(modal).toBeNull();
        });
    });

    it("test the modal does not open, when token exists", () => {
      getSessionIdToken.mockResolvedValue("AZURE_SESSION_ID_TOKEN");

      const element = createElement("page-background-modal", {
        is: PageBackgroundModal
      });
      document.body.appendChild(element);

      return flushPromises().then(() => {
        // assert the modal is no longer rendered
        const modal = element.shadowRoot.querySelector("section");
        expect(modal).toBeNull();
      });
    });
  });
});
