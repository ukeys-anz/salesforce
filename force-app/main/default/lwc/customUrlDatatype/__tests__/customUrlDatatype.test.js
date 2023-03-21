import { createElement } from "lwc";
import CustomUrlDatatype from "c/customUrlDatatype";

describe("c-custom-url-datatype", () => {
  // clean the dom and mocks in between test runs
  beforeEach(() => {
    const element = createElement("c-custom-url-datatype", {
      is: CustomUrlDatatype
    });
    document.body.appendChild(element);
  });
  afterEach(() => {
    // The jsdom instance is shared across test cases in a single file so reset the DOM
    while (document.body.firstChild) {
      document.body.removeChild(document.body.firstChild);
    }
  });

  it("Render the customURL element", () => {
    const element = document.querySelector("c-custom-url-datatype");
    const urlElement = element.shadowRoot.querySelector(
      "lightning-formatted-url"
    );

    expect(urlElement).not.toBeNull;
  });
  it("Invoke the onclick event", () => {
    const element = document.querySelector("c-custom-url-datatype");
    const urlElement = element.shadowRoot.querySelector(
      "lightning-formatted-url"
    );

    const handler = jest.fn();
    urlElement.addEventListener("click", handler);
    urlElement.dispatchEvent(new CustomEvent("click", { bubbles: true }));

    return Promise.resolve().then(() => {
      expect(handler).toHaveBeenCalled();
    });
  });
});
