import { createElement } from "lwc";
import GenericField from "c/genericField";
import { getNavigateCalledWith } from "lightning/navigation";
import testData from "./data/testdata.json";

const { isRecordUrlTestScenarios, basicFieldData } = testData;

describe("c-generic-field", () => {
  afterEach(() => {
    // The jsdom instance is shared across test cases in a single file so reset the DOM
    while (document.body.firstChild) {
      document.body.removeChild(document.body.firstChild);
    }
    jest.clearAllMocks();
  });

  // Helper function to wait for promises
  function flushPromises() {
    return new Promise((resolve) => setTimeout(resolve, 0));
  }

  describe("Field Type Tests - Maximum Code Coverage", () => {
    it("renders error state when _hasError is true", async () => {
      const element = createElement("c-generic-field", {
        is: GenericField
      });

      // Create a field that will trigger an error in the paddingSize setter
      element.field = {
        fieldLabel: "Error Field",
        fieldtype: "text",
        isStacked: true // This will trigger the error handling logic
      };
      element.value = "Test Value";

      // Set paddingSize to null to trigger error
      element.paddingSize = null;

      document.body.appendChild(element);
      await flushPromises();

      // Check if the component rendered normally (error handling doesn't prevent rendering)
      const fieldRow = element.shadowRoot.querySelector(".fieldRow");
      expect(fieldRow).not.toBeNull();
    });

    it("renders lightning-formatted-number for number field type without attributes", async () => {
      const element = createElement("c-generic-field", {
        is: GenericField
      });

      element.field = {
        fieldLabel: "Number Field",
        fieldtype: "lightning-formatted-number"
        // No attributes - isNumber now returns true regardless of attributes
      };
      element.value = 1234.56;
      element.paddingSize = { fieldLabel: "3", fieldValue: "9" };

      document.body.appendChild(element);
      await flushPromises();

      const numberField = element.shadowRoot.querySelector(
        "lightning-formatted-number"
      );
      expect(numberField).not.toBeNull();
      expect(numberField.value).toBe(1234.56);
      expect(numberField.formatStyle).toBeUndefined(); // Should not have currency formatting
    });

    it("renders lightning-formatted-number with currency formatting using lwc:spread", async () => {
      const element = createElement("c-generic-field", {
        is: GenericField
      });

      element.field = {
        fieldLabel: "Currency Field",
        fieldtype: "lightning-formatted-number",
        attributes: {
          formatStyle: "currency",
          currencyCode: "AUD"
        }
      };
      element.value = 1234.56;
      element.paddingSize = { fieldLabel: "3", fieldValue: "9" };

      document.body.appendChild(element);
      await flushPromises();

      const currencyField = element.shadowRoot.querySelector(
        "lightning-formatted-number"
      );
      expect(currencyField).not.toBeNull();
      expect(currencyField.value).toBe(1234.56);
      expect(currencyField.formatStyle).toBe("currency");
      expect(currencyField.currencyCode).toBe("AUD");
    });

    it("renders lightning-formatted-number with attributes using lwc:spread", async () => {
      const element = createElement("c-generic-field", {
        is: GenericField
      });

      element.field = {
        fieldLabel: "Number with Attributes",
        fieldtype: "lightning-formatted-number",
        attributes: {
          minimumFractionDigits: 2,
          maximumFractionDigits: 2
        }
      };
      element.value = 1234.56;
      element.paddingSize = { fieldLabel: "3", fieldValue: "9" };

      document.body.appendChild(element);
      await flushPromises();

      // Now that isNumber handles all lightning-formatted-number fields,
      // this should render with the attributes spread
      const numberField = element.shadowRoot.querySelector(
        "lightning-formatted-number"
      );
      expect(numberField).not.toBeNull();
      expect(numberField.value).toBe(1234.56);
      expect(numberField.minimumFractionDigits).toBe(2);
      expect(numberField.maximumFractionDigits).toBe(2);
    });

    it("renders lightning-formatted-number without currency formatting when formatStyle not specified", async () => {
      const element = createElement("c-generic-field", {
        is: GenericField
      });

      element.field = {
        fieldLabel: "Non-Currency Field",
        fieldtype: "lightning-formatted-number",
        attributes: {
          minimumFractionDigits: 2,
          maximumFractionDigits: 2
          // No formatStyle: "currency"
        }
      };
      element.value = 1234.56;
      element.paddingSize = { fieldLabel: "3", fieldValue: "9" };

      document.body.appendChild(element);
      await flushPromises();

      const numberField = element.shadowRoot.querySelector(
        "lightning-formatted-number"
      );
      expect(numberField).not.toBeNull();
      expect(numberField.value).toBe(1234.56);
      expect(numberField.formatStyle).toBeUndefined();
      expect(numberField.minimumFractionDigits).toBe(2);
      expect(numberField.maximumFractionDigits).toBe(2);
    });

    it("renders lightning-formatted-text with attributes using lwc:spread", async () => {
      const element = createElement("c-generic-field", {
        is: GenericField
      });

      element.field = {
        fieldLabel: "Field with Attributes",
        fieldtype: "lightning-formatted-text",
        attributes: {
          someOtherProperty: "value"
        }
      };
      element.value = "Test value";
      element.paddingSize = { fieldLabel: "3", fieldValue: "9" };

      document.body.appendChild(element);
      await flushPromises();

      const textField = element.shadowRoot.querySelector(
        "lightning-formatted-text"
      );
      expect(textField).not.toBeNull();
      expect(textField.value).toBe("Test value");
      expect(textField.someOtherProperty).toBe("value");
    });

    it("renders field without attributes correctly", async () => {
      const element = createElement("c-generic-field", {
        is: GenericField
      });

      element.field = {
        fieldLabel: "No Attributes Field",
        fieldtype: "lightning-formatted-text"
        // No attributes property
      };
      element.value = "Test value";
      element.paddingSize = { fieldLabel: "3", fieldValue: "9" };

      document.body.appendChild(element);
      await flushPromises();

      const textField = element.shadowRoot.querySelector(
        "lightning-formatted-text"
      );
      expect(textField).not.toBeNull();
      expect(textField.value).toBe("Test value");
    });

    it("renders lightning-formatted-email for email field type", async () => {
      const element = createElement("c-generic-field", {
        is: GenericField
      });

      element.field = {
        fieldLabel: "Email Field",
        fieldtype: "lightning-formatted-email"
      };
      element.value = "test@example.com";
      element.paddingSize = { fieldLabel: "3", fieldValue: "9" };

      document.body.appendChild(element);
      await flushPromises();

      const emailField = element.shadowRoot.querySelector(
        "lightning-formatted-email"
      );
      expect(emailField).not.toBeNull();
      expect(emailField.value).toBe("test@example.com");
    });

    it("renders lightning-formatted-url for url field type", async () => {
      const element = createElement("c-generic-field", {
        is: GenericField
      });

      element.field = {
        fieldLabel: "URL Field",
        fieldtype: "lightning-formatted-url"
      };
      element.value = "https://www.example.com";
      element.paddingSize = { fieldLabel: "3", fieldValue: "9" };

      document.body.appendChild(element);
      await flushPromises();

      const urlField = element.shadowRoot.querySelector(
        "lightning-formatted-url"
      );
      expect(urlField).not.toBeNull();
      expect(urlField.value).toBe("https://www.example.com");
    });

    it("renders c-generic-date-handler for date field type", async () => {
      const element = createElement("c-generic-field", {
        is: GenericField
      });

      element.field = {
        fieldLabel: "Date Field",
        fieldtype: "date",
        isDate: true
      };
      element.value = "2024-01-15";
      element.paddingSize = { fieldLabel: "3", fieldValue: "9" };

      document.body.appendChild(element);
      await flushPromises();

      const dateField = element.shadowRoot.querySelector(
        "c-generic-date-handler"
      );
      expect(dateField).not.toBeNull();
      // The date handler processes the value, so we just check it exists and has a field
      expect(dateField.field).toEqual(element.field);
    });

    it("renders lightning-formatted-text for text field type", async () => {
      const element = createElement("c-generic-field", {
        is: GenericField
      });

      element.field = {
        fieldLabel: "Text Field",
        fieldtype: "lightning-formatted-text"
      };
      element.value = "Sample text content";
      element.paddingSize = { fieldLabel: "3", fieldValue: "9" };

      document.body.appendChild(element);
      await flushPromises();

      const textField = element.shadowRoot.querySelector(
        "lightning-formatted-text"
      );
      expect(textField).not.toBeNull();
      expect(textField.value).toBe("Sample text content");
    });

    it("renders lightning-input checkbox for checkbox field type", async () => {
      const element = createElement("c-generic-field", {
        is: GenericField
      });

      element.field = {
        fieldLabel: "Checkbox Field",
        fieldtype: "checkbox"
      };
      element.value = true;
      element.paddingSize = { fieldLabel: "3", fieldValue: "9" };

      document.body.appendChild(element);
      await flushPromises();

      const checkboxField = element.shadowRoot.querySelector("lightning-input");
      expect(checkboxField).not.toBeNull();
      expect(checkboxField.type).toBe("checkbox");
      expect(checkboxField.checked).toBe(true);
      expect(checkboxField.disabled).toBe(true);
    });

    it("renders c-generic-record-link for record link field type", async () => {
      const element = createElement("c-generic-field", {
        is: GenericField
      });

      element.field = {
        fieldLabel: "Record Link Field",
        fieldtype: "link",
        isRecordLink: true,
        attributes: {
          recordId: "001XX000003TEST",
          objectName: "Account"
        }
      };
      element.value = "Link Text";
      element.paddingSize = { fieldLabel: "3", fieldValue: "9" };

      document.body.appendChild(element);
      await flushPromises();

      const recordLinkField = element.shadowRoot.querySelector(
        "c-generic-record-link"
      );
      expect(recordLinkField).not.toBeNull();
      expect(recordLinkField.recordId).toBe("001XX000003TEST");
    });

    it("renders field with help text when provided", async () => {
      const element = createElement("c-generic-field", {
        is: GenericField
      });

      element.field = {
        fieldLabel: "Field With Help",
        fieldtype: "lightning-formatted-text",
        helpText: "This is helpful information"
      };
      element.value = "Test value";
      element.paddingSize = { fieldLabel: "3", fieldValue: "9" };

      document.body.appendChild(element);
      await flushPromises();

      const helpText = element.shadowRoot.querySelector("lightning-helptext");
      expect(helpText).not.toBeNull();
      expect(helpText.content).toBe("This is helpful information");
    });

    it("renders field without label when not provided", async () => {
      const element = createElement("c-generic-field", {
        is: GenericField
      });

      element.field = {
        fieldtype: "lightning-formatted-text"
      };
      element.value = "No label field";
      element.paddingSize = { fieldLabel: "3", fieldValue: "9" };

      document.body.appendChild(element);
      await flushPromises();

      const label = element.shadowRoot.querySelector(".fieldLabel");
      expect(label).toBeNull();

      const textField = element.shadowRoot.querySelector(
        "lightning-formatted-text"
      );
      expect(textField).not.toBeNull();
    });

    it("renders stacked layout when isStacked is true", async () => {
      const element = createElement("c-generic-field", {
        is: GenericField
      });

      element.field = {
        fieldLabel: "Stacked Field",
        fieldtype: "lightning-formatted-text",
        isStacked: true
      };
      element.value = "Stacked content";
      element.paddingSize = { fieldLabel: "3", fieldValue: "9" };

      document.body.appendChild(element);
      await flushPromises();

      const textField = element.shadowRoot.querySelector(
        "lightning-formatted-text"
      );
      expect(textField).not.toBeNull();
      expect(textField.className).toContain("fieldContentStacked");
    });

    it("handles stringify option for complex values", async () => {
      const element = createElement("c-generic-field", {
        is: GenericField
      });

      const complexValue = { name: "Test", id: 123 };
      element.field = {
        fieldLabel: "JSON Field",
        fieldtype: "lightning-formatted-text",
        stringify: true
      };
      element.value = complexValue;
      element.paddingSize = { fieldLabel: "3", fieldValue: "9" };

      document.body.appendChild(element);
      await flushPromises();

      const textField = element.shadowRoot.querySelector(
        "lightning-formatted-text"
      );
      expect(textField).not.toBeNull();
      expect(textField.value).toBe(JSON.stringify(complexValue));
    });

    it("falls back to placeholder template for unknown field types", async () => {
      const element = createElement("c-generic-field", {
        is: GenericField
      });

      element.field = {
        fieldLabel: "Unknown Field",
        fieldtype: "unknown-type"
      };
      element.value = "Unknown value";
      element.paddingSize = { fieldLabel: "3", fieldValue: "9" };

      document.body.appendChild(element);
      await flushPromises();

      // Should not render any of the specific field types
      expect(
        element.shadowRoot.querySelector("lightning-formatted-number")
      ).toBeNull();
      expect(
        element.shadowRoot.querySelector("lightning-formatted-email")
      ).toBeNull();
      expect(
        element.shadowRoot.querySelector("lightning-formatted-url")
      ).toBeNull();
      expect(
        element.shadowRoot.querySelector("lightning-formatted-text")
      ).toBeNull();
      expect(element.shadowRoot.querySelector("lightning-input")).toBeNull();
      expect(
        element.shadowRoot.querySelector("c-generic-date-handler")
      ).toBeNull();
      expect(
        element.shadowRoot.querySelector("c-generic-record-link")
      ).toBeNull();

      // Should still render the layout structure
      const fieldRow = element.shadowRoot.querySelector(".fieldRow");
      expect(fieldRow).not.toBeNull();
    });

    it("renders isRecordUrl button when isRecordUrl is true", async () => {
      const element = createElement("c-generic-field", {
        is: GenericField
      });

      element.field = {
        fieldLabel: "Record URL Field",
        fieldtype: "button",
        isRecordUrl: true,
        attributes: {
          componentName: "c__testComponent"
        }
      };
      element.value = "Navigate Button";
      element.recordId = "001XX000003DHPYYA4";

      document.body.appendChild(element);
      await flushPromises();

      const button = element.shadowRoot.querySelector("lightning-button");
      expect(button).not.toBeNull();
      expect(button.label).toBe("Navigate Button");
      expect(button.variant).toBe("base");
    });
  });

  describe("isRecordUrl Tests", () => {
    it("renders lightning-button when isRecordUrl is true", async () => {
      const element = createElement("c-generic-field", {
        is: GenericField
      });

      // Test data for isRecordUrl scenario
      element.field = basicFieldData.basic;
      element.value = "View Details";
      element.recordId = "001XX000003DHPYYA4";

      document.body.appendChild(element);
      await flushPromises();

      // Verify button is rendered
      const button = element.shadowRoot.querySelector("lightning-button");
      expect(button).not.toBeNull();
      expect(button.label).toBe("View Details");
      expect(button.variant).toBe("base");
    });

    it("handles button click navigation with all required parameters", async () => {
      const element = createElement("c-generic-field", {
        is: GenericField
      });

      // Complete test data with all navigation parameters
      element.field = basicFieldData.complete;
      element.value = "Loan #12345";
      element.recordId = "001XX000003DHPYYA4";

      document.body.appendChild(element);
      await flushPromises();

      const button = element.shadowRoot.querySelector("lightning-button");
      button.click();

      const { pageReference } = getNavigateCalledWith();
      expect(pageReference).toEqual({
        type: "standard__component",
        attributes: {
          componentName: "c__loanDetailView"
        },
        state: {
          c__apexController: "LoanController",
          c__configName: "loanDetails",
          c__defaultOpen: true,
          c__filterValue: "Loan #12345",
          c__dataPath: "loan.details",
          c__useControllerData: "true",
          c__controllerParams: { recordId: "001XX000003DHPYYA4" },
          c__filterField: "loanId",
          c__tabName: "Loan #12345"
        }
      });
    });
  });

  // Test data scenarios for different use cases
  describe("isRecordUrl Test Data Scenarios", () => {
    isRecordUrlTestScenarios.forEach((scenario) => {
      it(`handles ${scenario.name} scenario correctly`, async () => {
        const element = createElement("c-generic-field", {
          is: GenericField
        });

        element.field = scenario.field;
        element.value = scenario.value;
        element.recordId = scenario.recordId;

        document.body.appendChild(element);
        await flushPromises();

        const button = element.shadowRoot.querySelector("lightning-button");
        expect(button).not.toBeNull();
        expect(button.label).toBe(scenario.value);

        button.click();

        const { pageReference } = getNavigateCalledWith();
        expect(pageReference).toEqual(
          expect.objectContaining({
            type: "standard__component",
            attributes: {
              componentName: scenario.field.attributes.componentName
            },
            state: expect.objectContaining({
              c__filterValue: scenario.value,
              c__tabName: scenario.value,
              c__controllerParams: { recordId: scenario.recordId }
            })
          })
        );
      });
    });
  });
});
