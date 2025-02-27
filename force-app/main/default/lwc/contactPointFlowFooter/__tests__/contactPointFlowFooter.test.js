import { createElement } from "lwc";
import ContactPointFlowFooter from "c/contactPointFlowFooter";

const RECORD_ID = "	0Ow9h0000003AqrCAE";

describe("c-contact-point-flow-footer", () => {
  afterEach(() => {
    // The jsdom instance is shared across test cases in a single file so reset the DOM
    while (document.body.firstChild) {
      document.body.removeChild(document.body.firstChild);
    }
  });

  it("Navigate to next page when Delete button is clicked", async () => {
    const element = createElement("c-contact-point-flow-footer", {
      is: ContactPointFlowFooter
    });

    document.body.appendChild(element);
    const deleteButton = element.shadowRoot.querySelector(
      'lightning-button[data-id="Delete"]'
    );
    expect(deleteButton).not.toBe(null);
    deleteButton.click();
    await Promise.resolve();
    return Promise.resolve().then(() => {
      expect(element.terminate).toBe(undefined);
    });
  });

  it("terminate when Cancel button is clicked", async () => {
    const element = createElement("c-contact-point-flow-footer", {
      is: ContactPointFlowFooter
    });

    document.body.appendChild(element);
    const deleteButton = element.shadowRoot.querySelector(
      'lightning-button[data-id="Cancel"]'
    );
    expect(deleteButton).not.toBe(null);
    deleteButton.click();
    await Promise.resolve();
    return Promise.resolve().then(() => {
      expect(element.terminate).toBe(true);
    });
  });
});
