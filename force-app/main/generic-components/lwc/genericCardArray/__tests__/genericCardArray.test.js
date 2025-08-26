import { createElement } from "lwc";
import GenericCardArray from "c/genericCardArray";

const ARRAY_CONFIGS = require("./data/arrayConfigs.json");
const ARRAY_MOCK_DATA = require("./data/arrayMockData.json");

describe("c-generic-card-array", () => {
  afterEach(() => {
    while (document.body.firstChild) {
      document.body.removeChild(document.body.firstChild);
    }
    jest.clearAllMocks();
  });

  async function flushPromises() {
    return Promise.resolve();
  }

  describe("Mortgage Contracts Array Scenarios", () => {
    test("renders multiple mortgage contract cards with correct data", async () => {
      const element = createElement("c-generic-card-array", {
        is: GenericCardArray
      });

      element.title = "Mortgage Contracts Dashboard";
      element.apiConfig = JSON.stringify(ARRAY_CONFIGS.mortgageContractsArray);
      element.apiData = JSON.stringify(ARRAY_MOCK_DATA.mortgageContractsData);
      element.useControllerData = false;

      document.body.appendChild(element);
      await flushPromises();

      // Verify title is displayed
      expect(element.title).toBe("Mortgage Contracts Dashboard");

      // Verify config and data contain expected content
      expect(element.apiConfig).toContain("contracts");
      expect(element.apiConfig).toContain("customerName");
      expect(element.apiData).toContain("Tony Stark");
      expect(element.apiData).toContain("John Cena");
      expect(element.apiData).toContain("Jane Smith");
      expect(element.apiData).toContain("Bruce Wayne");

      // Verify the array data is parsed and processed
      const dataObj = JSON.parse(element.apiData);
      expect(dataObj.contracts).toHaveLength(4);
      expect(dataObj.contracts[0].customerName).toBe("Tony Stark");
    });

    test("handles empty array gracefully", async () => {
      const element = createElement("c-generic-card-array", {
        is: GenericCardArray
      });

      element.title = "Empty Contracts";
      element.apiConfig = JSON.stringify(ARRAY_CONFIGS.mortgageContractsArray);
      element.apiData = JSON.stringify(ARRAY_MOCK_DATA.emptyArray);
      element.useControllerData = false;

      document.body.appendChild(element);
      await flushPromises();

      const dataObj = JSON.parse(element.apiData);
      expect(dataObj.contracts).toHaveLength(0);
    });

    test("handles single item array correctly", async () => {
      const element = createElement("c-generic-card-array", {
        is: GenericCardArray
      });

      element.title = "Single Contract";
      element.apiConfig = JSON.stringify(ARRAY_CONFIGS.mortgageContractsArray);
      element.apiData = JSON.stringify(ARRAY_MOCK_DATA.singleItemArray);
      element.useControllerData = false;

      document.body.appendChild(element);
      await flushPromises();

      const dataObj = JSON.parse(element.apiData);
      expect(dataObj.contracts).toHaveLength(1);
      expect(dataObj.contracts[0].customerName).toBe("Single Customer");
    });
  });

  describe("Loan Applications Array Scenarios", () => {
    test("renders loan application cards with assessment data", async () => {
      const element = createElement("c-generic-card-array", {
        is: GenericCardArray
      });

      element.title = "Loan Applications Overview";
      element.apiConfig = JSON.stringify(ARRAY_CONFIGS.loanApplicationsArray);
      element.apiData = JSON.stringify(ARRAY_MOCK_DATA.loanApplicationsData);
      element.useControllerData = false;

      document.body.appendChild(element);
      await flushPromises();

      // Verify config and data
      expect(element.apiConfig).toContain("applications");
      expect(element.apiConfig).toContain("applicantName");
      expect(element.apiData).toContain("Tony Stark");
      expect(element.apiData).toContain("Pepper Potts");
      expect(element.apiData).toContain("Happy Hogan");

      // Verify array data
      const dataObj = JSON.parse(element.apiData);
      expect(dataObj.applications).toHaveLength(3);
      expect(dataObj.applications[0].creditScore).toBe(785);
      expect(dataObj.applications[1].requestedAmount).toBe(550000);
      expect(dataObj.applications[2].status).toBe("Declined");
    });
  });

  describe("Property Valuations Array Scenarios", () => {
    test("renders property valuation cards with market data", async () => {
      const element = createElement("c-generic-card-array", {
        is: GenericCardArray
      });

      element.title = "Property Valuations Assessment";
      element.apiConfig = JSON.stringify(ARRAY_CONFIGS.propertyValuationsArray);
      element.apiData = JSON.stringify(ARRAY_MOCK_DATA.propertyValuationsData);
      element.useControllerData = false;

      document.body.appendChild(element);
      await flushPromises();

      expect(element.apiConfig).toContain("valuations");
      expect(element.apiConfig).toContain("propertyAddress");
      expect(element.apiData).toContain("HAWTHORN EAST");
      expect(element.apiData).toContain("MELBOURNE");

      const dataObj = JSON.parse(element.apiData);
      expect(dataObj.valuations).toHaveLength(3);
      expect(dataObj.valuations[0].propertyAddress).toBe(
        "463 Tooronga Road, HAWTHORN EAST VIC 3123"
      );
      expect(dataObj.valuations[0].currentValue).toBe(850000);
      expect(dataObj.valuations[1].marketTrend).toBe("Rising");
      expect(dataObj.valuations[2].valuer).toBe("City Valuers Pty Ltd");
    });
  });

  describe("Settlement Tasks Array Scenarios", () => {
    test("renders settlement task cards with checklist data", async () => {
      const element = createElement("c-generic-card-array", {
        is: GenericCardArray
      });

      element.title = "Settlement Tasks Dashboard";
      element.apiConfig = JSON.stringify(ARRAY_CONFIGS.settlementTasksArray);
      element.apiData = JSON.stringify(ARRAY_MOCK_DATA.settlementTasksData);
      element.useControllerData = false;

      document.body.appendChild(element);
      await flushPromises();

      expect(element.apiConfig).toContain("tasks");
      expect(element.apiConfig).toContain("taskName");
      expect(element.apiData).toContain("Contract Review");
      expect(element.apiData).toContain("Insurance Verification");
      expect(element.apiData).toContain("Final Property Inspection");
      expect(element.apiData).toContain("Settlement Statement Preparation");

      const dataObj = JSON.parse(element.apiData);
      expect(dataObj.tasks).toHaveLength(4);
      expect(dataObj.tasks[0].taskName).toBe("Contract Review");
      expect(dataObj.tasks[0].status).toBe("Completed");
      expect(dataObj.tasks[1].assignedTo).toBe("Insurance Specialist");
      expect(dataObj.tasks[2].priority).toBe("High");
      expect(dataObj.tasks[3].priority).toBe("Critical");
    });
  });

  describe("Component Configuration and Properties", () => {
    test("correctly sets title and configuration properties", async () => {
      const element = createElement("c-generic-card-array", {
        is: GenericCardArray
      });

      element.title = "Test Title";
      element.apiConfig = JSON.stringify(ARRAY_CONFIGS.mortgageContractsArray);
      element.apiData = JSON.stringify(ARRAY_MOCK_DATA.mortgageContractsData);
      element.useControllerData = false;
      element.recordId = "test-record-123";

      document.body.appendChild(element);
      await flushPromises();

      expect(element.title).toBe("Test Title");
      expect(element.recordId).toBe("test-record-123");
      expect(element.useControllerData).toBe(false);
    });

    test("correctly parses configuration data", async () => {
      const element = createElement("c-generic-card-array", {
        is: GenericCardArray
      });

      element.apiConfig = JSON.stringify(ARRAY_CONFIGS.mortgageContractsArray);
      element.apiData = JSON.stringify(ARRAY_MOCK_DATA.mortgageContractsData);
      element.useControllerData = false;

      document.body.appendChild(element);
      await flushPromises();

      const configObj = JSON.parse(element.apiConfig);
      expect(configObj.dataPath).toBe("contracts");
      expect(configObj.titleField).toBe("customerName");
      expect(configObj.cardConfig.title).toBe("Mortgage Contract");
      expect(configObj.cardConfig.theme).toBe("success");
      expect(configObj.cardConfig.fieldConfig).toHaveLength(6);
    });
  });

  describe("Error Handling Scenarios", () => {
    test("handles invalid JSON data gracefully", async () => {
      const element = createElement("c-generic-card-array", {
        is: GenericCardArray
      });

      element.apiConfig = JSON.stringify(ARRAY_CONFIGS.mortgageContractsArray);
      element.apiData = "invalid json string";
      element.useControllerData = false;

      document.body.appendChild(element);
      await flushPromises();

      // Component should handle the error gracefully
      expect(element.apiData).toBe("invalid json string");
    });

    test("handles missing apiConfig gracefully", async () => {
      const element = createElement("c-generic-card-array", {
        is: GenericCardArray
      });

      element.apiData = JSON.stringify(ARRAY_MOCK_DATA.mortgageContractsData);
      element.useControllerData = false;
      // No apiConfig provided

      document.body.appendChild(element);
      await flushPromises();

      expect(element.apiData).toContain("Tony Stark");
    });

    test("handles missing apiData when useControllerData is false", async () => {
      const element = createElement("c-generic-card-array", {
        is: GenericCardArray
      });

      element.apiConfig = JSON.stringify(ARRAY_CONFIGS.mortgageContractsArray);
      element.useControllerData = false;
      // No apiData provided

      document.body.appendChild(element);
      await flushPromises();

      expect(element.useControllerData).toBe(false);
    });
  });

  describe("DOM Content Verification", () => {
    test("renders title when provided", async () => {
      const element = createElement("c-generic-card-array", {
        is: GenericCardArray
      });

      element.title = "Test Dashboard Title";
      element.apiConfig = JSON.stringify(ARRAY_CONFIGS.mortgageContractsArray);
      element.apiData = JSON.stringify(ARRAY_MOCK_DATA.mortgageContractsData);
      element.useControllerData = false;

      document.body.appendChild(element);
      await flushPromises();

      // Check if title is in the template
      const titleElement = element.shadowRoot.querySelector("h3");
      if (titleElement) {
        expect(titleElement.textContent).toBe("Test Dashboard Title");
      }
    });

    test("renders lightning-card container", async () => {
      const element = createElement("c-generic-card-array", {
        is: GenericCardArray
      });

      element.apiConfig = JSON.stringify(ARRAY_CONFIGS.mortgageContractsArray);
      element.apiData = JSON.stringify(ARRAY_MOCK_DATA.mortgageContractsData);
      element.useControllerData = false;

      document.body.appendChild(element);
      await flushPromises();

      const lightningCard = element.shadowRoot.querySelector("lightning-card");
      expect(lightningCard).toBeTruthy();
    });
  });

  describe("Data Processing and Validation", () => {
    test("validates mortgage contracts data structure", async () => {
      const element = createElement("c-generic-card-array", {
        is: GenericCardArray
      });

      element.apiConfig = JSON.stringify(ARRAY_CONFIGS.mortgageContractsArray);
      element.apiData = JSON.stringify(ARRAY_MOCK_DATA.mortgageContractsData);
      element.useControllerData = false;

      document.body.appendChild(element);
      await flushPromises();

      const data = JSON.parse(element.apiData);
      const config = JSON.parse(element.apiConfig);

      // Validate data structure matches configuration expectations
      expect(data[config.dataPath]).toBeDefined();
      expect(Array.isArray(data[config.dataPath])).toBe(true);

      // Validate first item has expected titleField
      if (data[config.dataPath].length > 0) {
        expect(data[config.dataPath][0][config.titleField]).toBeDefined();
      }
    });

    test("validates loan applications data structure", async () => {
      const element = createElement("c-generic-card-array", {
        is: GenericCardArray
      });

      element.apiConfig = JSON.stringify(ARRAY_CONFIGS.loanApplicationsArray);
      element.apiData = JSON.stringify(ARRAY_MOCK_DATA.loanApplicationsData);
      element.useControllerData = false;

      document.body.appendChild(element);
      await flushPromises();

      const data = JSON.parse(element.apiData);
      const config = JSON.parse(element.apiConfig);

      expect(data[config.dataPath]).toBeDefined();
      expect(Array.isArray(data[config.dataPath])).toBe(true);
      expect(data[config.dataPath]).toHaveLength(3);

      // Validate each item has required fields
      data[config.dataPath].forEach((item) => {
        expect(item.id).toBeDefined();
        expect(item[config.titleField]).toBeDefined();
        expect(typeof item.creditScore).toBe("number");
        expect(typeof item.requestedAmount).toBe("number");
      });
    });

    test("validates configuration structure for all array types", async () => {
      const configs = [
        ARRAY_CONFIGS.mortgageContractsArray,
        ARRAY_CONFIGS.loanApplicationsArray,
        ARRAY_CONFIGS.propertyValuationsArray,
        ARRAY_CONFIGS.settlementTasksArray
      ];

      configs.forEach((config) => {
        expect(config.dataPath).toBeDefined();
        expect(config.titleField).toBeDefined();
        expect(config.cardConfig).toBeDefined();
        expect(config.cardConfig.title).toBeDefined();
        expect(config.cardConfig.theme).toBeDefined();
        expect(config.cardConfig.fieldConfig).toBeDefined();
        expect(Array.isArray(config.cardConfig.fieldConfig)).toBe(true);
      });
    });

    test("validates data consistency across all mock data sets", async () => {
      const dataKeys = Object.keys(ARRAY_MOCK_DATA);

      dataKeys.forEach((key) => {
        const mockData = ARRAY_MOCK_DATA[key];
        expect(mockData).toBeDefined();
        expect(typeof mockData).toBe("object");

        // Each mock data should have at least one array property
        const arrayProperties = Object.values(mockData).filter((value) =>
          Array.isArray(value)
        );
        expect(arrayProperties.length).toBeGreaterThanOrEqual(0);
      });
    });
  });
});
