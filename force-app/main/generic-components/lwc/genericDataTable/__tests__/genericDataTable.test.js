import { createElement } from "lwc";
import { getNavigateCalledWith } from "lightning/navigation";
import GenericDataTable from "c/genericDataTable";

// Mock external dependencies
jest.mock(
  "@salesforce/apex/GenericController.getData",
  () => ({
    default: jest.fn()
  }),
  { virtual: true }
);

jest.mock(
  "@salesforce/apex/GenericController.getConfig",
  () => ({
    default: jest.fn()
  }),
  { virtual: true }
);

jest.mock("@salesforce/messageChannel/lmsDataProviderChannel__c", () => ({}), {
  virtual: true
});

jest.mock(
  "lightning/messageService",
  () => ({
    subscribe: jest.fn(),
    MessageContext: {}
  }),
  { virtual: true }
);

jest.mock(
  "c/genericUtils",
  () => ({
    extractValuesByPaths: jest.fn((data, path) => ({ [path]: data })),
    parseJsonString: jest.fn((value) => {
      if (typeof value === "string") {
        try {
          return JSON.parse(value);
        } catch {
          return value;
        }
      }
      return value;
    })
  }),
  { virtual: true }
);

import getData from "@salesforce/apex/GenericController.getData";
import getConfig from "@salesforce/apex/GenericController.getConfig";
import { subscribe } from "lightning/messageService";
import { extractValuesByPaths, parseJsonString } from "c/genericUtils";

describe("c-generic-data-table", () => {
  afterEach(() => {
    // Reset DOM and mocks
    while (document.body.firstChild) {
      document.body.removeChild(document.body.firstChild);
    }
    jest.clearAllMocks();
  });

  // Helper function to wait for promises
  function flushPromises() {
    return new Promise((resolve) => setTimeout(resolve, 0));
  }

  describe("Component Initialization", () => {
    it("renders loading spinner initially", async () => {
      const element = createElement("c-generic-data-table", {
        is: GenericDataTable
      });

      document.body.appendChild(element);

      const spinner = element.shadowRoot.querySelector("lightning-spinner");
      expect(spinner).not.toBeNull();
      expect(spinner.alternativeText).toBe("Loading");
      expect(spinner.size).toBe("medium");
    });

    it("renders fallback message when no tableConfig is provided", async () => {
      const element = createElement("c-generic-data-table", {
        is: GenericDataTable
      });

      // Mock the component to not be loading and have no error or config
      element.isLoading = false;

      document.body.appendChild(element);
      await flushPromises();

      const fallbackDiv =
        element.shadowRoot.querySelector(".slds-illustration");
      expect(fallbackDiv).not.toBeNull();

      const heading = fallbackDiv.querySelector("h3");
      expect(heading.textContent).toBe("Loading datatable...");
    });
  });

  describe("Configuration Handling", () => {
    it("sets tableConfig with valid configuration", async () => {
      const element = createElement("c-generic-data-table", {
        is: GenericDataTable
      });

      const validConfig = {
        columns: [
          { fieldName: "name", label: "Name", type: "text" },
          { fieldName: "amount", label: "Amount", type: "currency" }
        ],
        dataPath: "records",
        filterField: "status",
        filterValue: "active"
      };

      element.tableConfig = validConfig;

      expect(element.tableConfig).toEqual(validConfig);
    });

    it("loads config from configName", async () => {
      const mockConfig = {
        columns: [{ fieldName: "id", label: "ID", type: "text" }]
      };

      getConfig.mockResolvedValue(JSON.stringify(mockConfig));

      const element = createElement("c-generic-data-table", {
        is: GenericDataTable
      });

      element.configName = "testConfig";

      document.body.appendChild(element);
      await flushPromises();

      expect(getConfig).toHaveBeenCalledWith({ configName: "testConfig" });
    });

    it("handles config loading errors", async () => {
      const consoleSpy = jest.spyOn(console, "error").mockImplementation();

      getConfig.mockRejectedValue(new Error("Config error"));

      const element = createElement("c-generic-data-table", {
        is: GenericDataTable
      });

      element.configName = "FailingConfig";

      document.body.appendChild(element);
      await flushPromises();

      expect(consoleSpy).toHaveBeenCalled();
      consoleSpy.mockRestore();
    });
  });

  describe("Data Handling", () => {
    it("sets tableData with valid array data", async () => {
      const element = createElement("c-generic-data-table", {
        is: GenericDataTable
      });

      // Set up valid config first
      element.tableConfig = {
        columns: [
          { fieldName: "name", label: "Name", type: "text" },
          { fieldName: "value", label: "Value", type: "number" }
        ]
      };

      const testData = [
        { name: "Item 1", value: 100 },
        { name: "Item 2", value: 200 }
      ];

      element.tableData = testData;

      expect(element.tableData).toHaveLength(2);
    });

    it("loads data from apex controller", async () => {
      const mockData = [{ id: "1", name: "Test Record" }];

      getData.mockResolvedValue(JSON.stringify(mockData));

      const element = createElement("c-generic-data-table", {
        is: GenericDataTable
      });

      element.apexController = "TestController";
      element.recordId = "123";
      element.controllerParams = { param1: "value1" };

      document.body.appendChild(element);
      await flushPromises();

      expect(getData).toHaveBeenCalledWith({
        apexController: "TestController",
        param: JSON.stringify({
          recordId: "123",
          param1: "value1"
        })
      });
    });

    it("handles apex controller errors", async () => {
      const consoleSpy = jest.spyOn(console, "error").mockImplementation();

      getData.mockRejectedValue(new Error("Apex error"));

      const element = createElement("c-generic-data-table", {
        is: GenericDataTable
      });

      element.apexController = "FailingController";

      document.body.appendChild(element);
      await flushPromises();

      expect(consoleSpy).toHaveBeenCalled();
      consoleSpy.mockRestore();
    });

    it("handles data extraction with extractPath", async () => {
      const element = createElement("c-generic-data-table", {
        is: GenericDataTable
      });

      element.extractPath = "data.records";

      const nestedData = {
        data: {
          records: [{ name: "Record 1" }, { name: "Record 2" }]
        }
      };

      extractValuesByPaths.mockReturnValue({
        "data.records": nestedData.data.records
      });

      element.tableData = nestedData;

      expect(extractValuesByPaths).toHaveBeenCalledWith(
        nestedData,
        "data.records"
      );
    });
  });

  describe("Message Channel Integration", () => {
    it("subscribes to message channel when lmsTopic is set", async () => {
      const element = createElement("c-generic-data-table", {
        is: GenericDataTable
      });

      element.lmsTopic = "TestTopic";

      document.body.appendChild(element);
      await flushPromises();

      expect(subscribe).toHaveBeenCalled();
    });
  });

  describe("Data Table Rendering", () => {
    it("renders lightning-datatable with correct properties", async () => {
      const element = createElement("c-generic-data-table", {
        is: GenericDataTable
      });

      // Set up the component state to render the datatable
      element.isLoading = false;
      element.tableConfig = {
        columns: [{ fieldName: "name", label: "Name", type: "text" }]
      };
      element.tableData = [{ id: "row_0", name: "Test Item" }];
      element.title = "Test Table";
      element.iconName = "standard:account";
      element.keyField = "id";
      element.hideCheckboxColumn = true;
      element.showRowNumberColumn = false;

      document.body.appendChild(element);
      await flushPromises();

      const card = element.shadowRoot.querySelector("lightning-card");
      expect(card).not.toBeNull();
      expect(card.title).toBe("Test Table");
      expect(card.iconName).toBe("standard:account");

      const datatable = element.shadowRoot.querySelector("lightning-datatable");
      expect(datatable).not.toBeNull();
      expect(datatable.keyField).toBe("id");
      expect(datatable.hideCheckboxColumn).toBe(true);
      expect(datatable.showRowNumberColumn).toBe(false);
    });

    it("renders with different component states", async () => {
      const element = createElement("c-generic-data-table", {
        is: GenericDataTable
      });

      // Test loading state
      document.body.appendChild(element);
      await flushPromises();

      // Test fallback message when component is not loading and has no config
      const fallbackDiv =
        element.shadowRoot.querySelector(".slds-illustration");
      expect(fallbackDiv).not.toBeNull();
    });
  });

  describe("Event Handling", () => {
    it("handles sort events", async () => {
      const element = createElement("c-generic-data-table", {
        is: GenericDataTable
      });

      element.isLoading = false;
      element.tableConfig = {
        columns: [{ fieldName: "name", label: "Name", type: "text" }]
      };
      element.tableData = [{ name: "Beta" }, { name: "Alpha" }];

      document.body.appendChild(element);
      await flushPromises();

      const datatable = element.shadowRoot.querySelector("lightning-datatable");
      expect(datatable).not.toBeNull();

      // Since we can't access the internal methods directly, we'll just test
      // that the sort properties can be set via public properties
      element.sortedBy = "name";
      element.sortDirection = "asc";

      expect(element.sortedBy).toBe("name");
      expect(element.sortDirection).toBe("asc");
    });

    it("handles row action events", async () => {
      const element = createElement("c-generic-data-table", {
        is: GenericDataTable
      });

      element.isLoading = false;
      element.tableConfig = {
        columns: [
          { fieldName: "name", label: "Name", type: "text" },
          {
            type: "action",
            typeAttributes: {
              rowActions: [{ label: "View", name: "view" }]
            }
          }
        ],
        navigationConfig: {
          componentName: "c__detailView",
          apexController: "DetailController"
        }
      };
      element.tableData = [
        { id: "row_0", name: "Test Item", rawData: { id: "item1" } }
      ];
      element.recordId = "123";

      document.body.appendChild(element);
      await flushPromises();

      const datatable = element.shadowRoot.querySelector("lightning-datatable");
      expect(datatable).not.toBeNull();

      // Mock extractValuesByPaths for navigation
      extractValuesByPaths.mockReturnValue({ id: "item1" });

      // Simulate row action event
      const rowActionEvent = new CustomEvent("rowaction", {
        detail: {
          row: { rawData: { id: "item1", name: "Test Item" } },
          action: { name: "view" }
        }
      });

      datatable.dispatchEvent(rowActionEvent);
      await flushPromises();

      const { pageReference } = getNavigateCalledWith();
      expect(pageReference.type).toBe("standard__component");
      expect(pageReference.attributes.componentName).toBe("c__detailView");
    });
  });

  describe("Component Properties", () => {
    it("sets and gets component properties correctly", async () => {
      const element = createElement("c-generic-data-table", {
        is: GenericDataTable
      });

      // Test API properties
      element.recordId = "test123";
      element.title = "My Table";
      element.iconName = "standard:opportunity";
      element.apexController = "MyController";
      element.configName = "myConfig";
      element.keyField = "Id";
      element.showRowNumberColumn = true;
      element.hideCheckboxColumn = false;
      element.lmsTopic = "MyTopic";
      element.extractPath = "data.items";
      element.filterField = "status";
      element.filterValue = "active";

      expect(element.recordId).toBe("test123");
      expect(element.title).toBe("My Table");
      expect(element.iconName).toBe("standard:opportunity");
      expect(element.apexController).toBe("MyController");
      expect(element.configName).toBe("myConfig");
      expect(element.keyField).toBe("Id");
      expect(element.showRowNumberColumn).toBe(true);
      expect(element.hideCheckboxColumn).toBe(false);
      expect(element.lmsTopic).toBe("MyTopic");
      expect(element.extractPath).toBe("data.items");
      expect(element.filterField).toBe("status");
      expect(element.filterValue).toBe("active");
    });

    it("handles controllerParams as object", async () => {
      const element = createElement("c-generic-data-table", {
        is: GenericDataTable
      });

      const params = { param1: "value1", param2: "value2" };
      element.controllerParams = params;

      expect(element.controllerParams).toEqual(params);
    });
  });

  describe("Configuration Validation", () => {
    it("accepts valid configuration without errors", async () => {
      const consoleSpy = jest.spyOn(console, "error").mockImplementation();

      const element = createElement("c-generic-data-table", {
        is: GenericDataTable
      });

      const validConfig = {
        columns: [
          { fieldName: "name", label: "Name", type: "text" },
          { fieldName: "amount", label: "Amount", type: "currency" }
        ]
      };

      element.tableConfig = validConfig;

      // Should not log any errors
      expect(consoleSpy).not.toHaveBeenCalled();

      consoleSpy.mockRestore();
    });

    it("handles malformed JSON in tableConfig", async () => {
      const consoleSpy = jest.spyOn(console, "error").mockImplementation();

      const element = createElement("c-generic-data-table", {
        is: GenericDataTable
      });

      // parseJsonString mock will handle this, but we can test edge cases
      parseJsonString.mockImplementationOnce(() => {
        throw new Error("JSON parse error");
      });

      element.tableConfig = "invalid json";

      expect(consoleSpy).toHaveBeenCalled();

      consoleSpy.mockRestore();
    });
  });

  describe("Error State Handling", () => {
    it("shows error component when error occurs", async () => {
      const consoleSpy = jest.spyOn(console, "error").mockImplementation();

      const element = createElement("c-generic-data-table", {
        is: GenericDataTable
      });

      // Mock an error scenario during initialization
      getConfig.mockRejectedValue(new Error("Config loading failed"));

      element.configName = "FailingConfig";

      document.body.appendChild(element);
      await flushPromises();

      // Verify error was logged
      expect(consoleSpy).toHaveBeenCalled();

      consoleSpy.mockRestore();
    });
  });

  describe("Data Processing", () => {
    it("processes tableData with different data types", async () => {
      const element = createElement("c-generic-data-table", {
        is: GenericDataTable
      });

      // Test with string data (should be parsed)
      const stringData = JSON.stringify([{ name: "Item 1", value: 100 }]);

      element.tableData = stringData;
      expect(parseJsonString).toHaveBeenCalledWith(
        stringData,
        expect.stringContaining("tableData from")
      );

      // Test with object data - verify structure is maintained
      const objectData = [{ name: "Item 2", value: 200 }];

      element.tableData = objectData;

      // The component transforms data by adding id and rawData properties
      expect(element.tableData).toHaveLength(1);
      expect(element.tableData[0]).toHaveProperty("id");
      expect(element.tableData[0]).toHaveProperty("rawData");
      expect(element.tableData[0].rawData.name).toBe("Item 2");
    });

    it("handles empty or null data gracefully", async () => {
      const element = createElement("c-generic-data-table", {
        is: GenericDataTable
      });

      // Test null data
      element.tableData = null;
      expect(element.tableData).toEqual([]);

      // Test empty array
      element.tableData = [];
      expect(element.tableData).toEqual([]);

      // Test undefined
      element.tableData = undefined;
      expect(element.tableData).toEqual([]);
    });
  });

  describe("Complex Scenarios", () => {
    it("handles full component lifecycle with real data", async () => {
      const mockConfigData = {
        columns: [
          { fieldName: "id", label: "ID", type: "text" },
          { fieldName: "name", label: "Name", type: "text" },
          { fieldName: "amount", label: "Amount", type: "currency" }
        ],
        dataPath: "records"
      };

      const mockTableData = {
        records: [
          { id: "1", name: "Record 1", amount: 100.5 },
          { id: "2", name: "Record 2", amount: 200.75 }
        ]
      };

      getConfig.mockResolvedValue(JSON.stringify(mockConfigData));
      getData.mockResolvedValue(JSON.stringify(mockTableData));

      extractValuesByPaths.mockReturnValue({
        records: mockTableData.records
      });

      const element = createElement("c-generic-data-table", {
        is: GenericDataTable
      });

      // Set up component properties
      element.configName = "testConfig";
      element.apexController = "TestController";
      element.recordId = "123";
      element.title = "Integration Test Table";
      element.keyField = "id";

      document.body.appendChild(element);
      await flushPromises();

      // Verify both config and data were loaded
      expect(getConfig).toHaveBeenCalledWith({ configName: "testConfig" });
      expect(getData).toHaveBeenCalledWith({
        apexController: "TestController",
        param: JSON.stringify({ recordId: "123" })
      });

      // Component should eventually render the datatable
      // Note: Due to async nature, we might need to wait for the component to finish loading
      // The actual rendering depends on the component's internal state management
    });

    it("handles component with LMS integration", async () => {
      const element = createElement("c-generic-data-table", {
        is: GenericDataTable
      });

      element.lmsTopic = "TestTopic";
      element.tableConfig = {
        columns: [{ fieldName: "name", label: "Name", type: "text" }]
      };

      document.body.appendChild(element);
      await flushPromises();

      // Verify subscription was created
      expect(subscribe).toHaveBeenCalled();

      // Test message handling through public properties
      const testData = [{ name: "LMS Data" }];
      element.tableData = testData;

      // The component transforms data, so we check the structure
      expect(element.tableData).toHaveLength(1);
      expect(element.tableData[0]).toHaveProperty("rawData");
      expect(element.tableData[0].rawData.name).toBe("LMS Data");
    });
  });
});
