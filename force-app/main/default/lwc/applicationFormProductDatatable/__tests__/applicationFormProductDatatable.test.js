import { createElement } from "lwc";
import ApplicationFormProductDatatable from "c/applicationFormProductDatatable";
import mockData from "./data/applicationFormProducts.json";

describe("c-application-form-product-datatable", () => {
  let element;

  beforeEach(() => {
    element = createElement("c-application-form-product-datatable", {
      is: ApplicationFormProductDatatable
    });
    document.body.appendChild(element);
  });

  afterEach(() => {
    // Clean up the DOM after each test
    if (element) {
      element.remove();
    }
  });

  it("renders datatable with paginated data correctly when data is provided", () => {
    element.applicationFormProducts = mockData;

    return Promise.resolve().then(() => {
      // Verify that the datatable is rendered
      const datatable = element.shadowRoot.querySelector("lightning-datatable");
      expect(datatable).not.toBeNull();
      expect(datatable.data.length).toBe(3); // Based on the initial page size

      // Verify the presence of pagination controls
      const paginationControls =
        element.shadowRoot.querySelector(".slds-m-top_medium");
      expect(paginationControls).not.toBeNull();
    });
  });

  it("displays no data message when no data is provided", () => {
    element.applicationFormProducts = [];

    return Promise.resolve().then(() => {
      const noDataMessage =
        element.shadowRoot.querySelector(".no-data-message");
      expect(noDataMessage).not.toBeNull();
      expect(noDataMessage.textContent).toContain(
        "No Application Form Products Found"
      );
    });
  });
});
