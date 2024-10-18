import { createElement } from "lwc";
import OpportunityRelatedApplications from "c/opportunityRelatedApplications";
import getApplicationFormsWithProducts from "@salesforce/apex/RelatedAppOnOppController.getApplicationFormsWithProducts";
import getTotalApplicationFormsCount from "@salesforce/apex/RelatedAppOnOppControllerRepository.getTotalRecords";
import { registerApexTestWireAdapter } from "@salesforce/sfdx-lwc-jest";

const mockGetObjectInfo = require("./data/getApplicationFormProducts.json");
const getApplicationFormWithProductAdapter = registerApexTestWireAdapter(
  getApplicationFormsWithProducts
);
const getTotalApplicationFormAdapter = registerApexTestWireAdapter(
  getTotalApplicationFormsCount
);

describe("c-opportunity-related-applications", () => {
  beforeEach(() => {
    const element = createElement("c-opportunity-related-applications", {
      is: OpportunityRelatedApplications
    });
    document.body.appendChild(element);
  });

  afterEach(() => {
    // Clean up the DOM after each test
    const elements = document.querySelectorAll(
      "c-opportunity-related-applications"
    );
    elements.forEach((element) => {
      element.remove();
    });
  });

  it("renders application forms and formatted numbers correctly when data is provided", () => {
    const element = document.querySelector(
      "c-opportunity-related-applications"
    );

    getApplicationFormWithProductAdapter.emit(mockGetObjectInfo);
    getTotalApplicationFormAdapter.emit(3);

    return Promise.resolve().then(() => {
      const formLinks = element.shadowRoot.querySelectorAll("a.form-link");
      expect(formLinks.length).toBe(3); // Check if there are 3 application forms rendered

      const firstLink = formLinks[0];
      expect(firstLink.textContent).toBe("AF-00000031");

      // Verify the formatted number for the first application form
      const amounts = element.shadowRoot.querySelectorAll(
        "lightning-formatted-number"
      );
      expect(amounts.length).toBe(3); // Check if there are 3 application forms rendered

      // Check the value of the first formatted number
      const amount = amounts[0];
      expect(amount.value).toBe(5000);
    });
  });

  it("displays a no data message when no application forms are provided", () => {
    const element = document.querySelector(
      "c-opportunity-related-applications"
    );

    getApplicationFormWithProductAdapter.emit([]);
    getTotalApplicationFormAdapter.emit(0);

    return Promise.resolve().then(() => {
      const noDataMessage = element.shadowRoot.querySelector(
        ".no-data-message"
      );
      expect(noDataMessage).not.toBeNull();
      expect(noDataMessage.textContent).toContain("No Application Forms Found");
    });
  });

  it("handles errors correctly when data fails to load", () => {
    const element = document.querySelector(
      "c-opportunity-related-applications"
    );

    getApplicationFormWithProductAdapter.error(
      new Error("Failed to load data")
    );
    getTotalApplicationFormAdapter.error(
      new Error("Failed to load total count")
    );

    return Promise.resolve().then(() => {
      const errorMessage = element.shadowRoot.querySelector(".centered-text");
      expect(errorMessage).not.toBeNull();
      expect(errorMessage.textContent).toContain("Error loading data.");
    });
  });

  it("renders application form products correctly", () => {
    const element = document.querySelector(
      "c-opportunity-related-applications"
    );

    getApplicationFormWithProductAdapter.emit(mockGetObjectInfo);
    getTotalApplicationFormAdapter.emit(3);

    return Promise.resolve().then(() => {
      const productRows = element.shadowRoot.querySelectorAll(
        "c-application-form-product-datatable"
      );
      expect(productRows.length).toBe(3); // One product datatable per form

      // Verify details for the first product datatable
      const firstProductDatatable = productRows[0];
      const productDetails = firstProductDatatable.shadowRoot.querySelectorAll(
        "lightning-datatable"
      );
      expect(productDetails.length).toBe(1); // Ensure there is one datatable rendered
    });
  });
});
