import { createElement } from "lwc";
import OcrRelatedListViewAllContainer from "c/ocrRelatedListViewAllContainer";
describe("c-ocr-related-list-view-all-container", () => {
  afterEach(() => {
    // The jsdom instance is shared across test cases in a single file so reset the DOM
    while (document.body.firstChild) {
      document.body.removeChild(document.body.firstChild);
    }
  });

  it("checks whether child component is rendered", () => {
    // Arrange
    const element = createElement("c-ocr-related-list-view-all-container", {
      is: OcrRelatedListViewAllContainer
    });
    // Act
    document.body.appendChild(element);
    const childComponent =
      element.shadowRoot.querySelector("c-ocr-related-list");
    expect(childComponent).not.toBe(null);
  });
});
