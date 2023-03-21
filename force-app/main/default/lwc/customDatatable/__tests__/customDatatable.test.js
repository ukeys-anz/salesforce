import { createElement } from "lwc";
import CustomDatatable from "c/customDatatable";

describe("c-custom-datatable", () => {
  // clean the dom and mocks in between test runs
  beforeEach(() => {
    const element = createElement("c-custom-datatable", {
      is: CustomDatatable
    });
    document.body.appendChild(element);
  });
  afterEach(() => {
    // The jsdom instance is shared across test cases in a single file so reset the DOM
    while (document.body.firstChild) {
      document.body.removeChild(document.body.firstChild);
    }
  });

  it("Render the custom datatable element", () => {
    const element = document.querySelector("c-custom-datatable");
    expect(element).not.toBeNull;
  });
});
