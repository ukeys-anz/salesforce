import { createElement } from "lwc";
import GenericCard from "c/genericCard";

const CONFIGS = require("./data/configs.json");
const MOCK_DATA = require("./data/mockData.json");
const FIELD_CONFIGS = require("./data/fieldConfigs.json");
const TABLE_CONFIGS = require("./data/tableConfigs.json");

describe("c-generic-card", () => {
  afterEach(() => {
    while (document.body.firstChild) {
      document.body.removeChild(document.body.firstChild);
    }
    jest.clearAllMocks();
  });

  describe("Mortgage Contract Management Scenarios", () => {
    test("configures mortgage contract summary card with settlement data", () => {
      const element = createElement("c-generic-card", {
        is: GenericCard
      });

      element.apiConfig = JSON.stringify(CONFIGS.mortgageContractSummary);
      element.apiData = JSON.stringify(MOCK_DATA.mortgageContractData);
      element.fieldConfig = JSON.stringify(FIELD_CONFIGS.mortgageFields);

      expect(element.apiConfig).toContain("Mortgage Contract Summary");
      expect(element.apiData).toContain("2ede02f4-8e35-4396-8f84-1f62631426fe");
      expect(element.fieldConfig).toContain("Contract ID");
      expect(JSON.parse(element.apiConfig).theme).toBe("success");
      expect(JSON.parse(element.apiData).financials.loanAmount).toBe(680000);
    });
  });

  describe("Loan Application Processing Scenarios", () => {
    test("configures loan application overview card with assessment data", () => {
      const element = createElement("c-generic-card", {
        is: GenericCard
      });

      element.apiConfig = JSON.stringify(CONFIGS.loanApplicationOverview);
      element.apiData = JSON.stringify(MOCK_DATA.loanApplicationData);
      element.fieldConfig = JSON.stringify(FIELD_CONFIGS.loanFields);

      expect(element.apiConfig).toContain("Loan Application Overview");
      expect(element.apiData).toContain("Tony Stark");
      expect(element.fieldConfig).toContain("Primary Applicant");
      expect(JSON.parse(element.apiConfig).theme).toBe("warning");
      expect(JSON.parse(element.apiData).assessment.creditScore).toBe(785);
    });
  });

  describe("Property Valuation Assessment Scenarios", () => {
    test("configures property valuation card with market analysis data", () => {
      const element = createElement("c-generic-card", {
        is: GenericCard
      });

      element.apiConfig = JSON.stringify(CONFIGS.propertyValuationCard);
      element.apiData = JSON.stringify(MOCK_DATA.propertyValuationData);
      element.fieldConfig = JSON.stringify(FIELD_CONFIGS.valuationFields);

      expect(element.apiConfig).toContain("Property Valuation Assessment");
      expect(element.apiData).toContain("HAWTHORN EAST");
      expect(element.fieldConfig).toContain("Current Valuation");
      expect(JSON.parse(element.apiConfig).theme).toBe("info");
      expect(JSON.parse(element.apiData).valuation.currentValue).toBe(850000.6);
    });
  });

  describe("Settlement Status Management Scenarios", () => {
    test("configures settlement status dashboard with checklist data", () => {
      const element = createElement("c-generic-card", {
        is: GenericCard
      });

      element.apiConfig = JSON.stringify(CONFIGS.settlementStatusCard);
      element.apiData = JSON.stringify(MOCK_DATA.settlementStatusData);
      element.fieldConfig = JSON.stringify(FIELD_CONFIGS.settlementFields);

      expect(element.apiConfig).toContain("Settlement Status Dashboard");
      expect(element.apiData).toContain("ANZ Settlement Centre");
      expect(element.fieldConfig).toContain("Settlement Date");
      expect(JSON.parse(element.apiConfig).theme).toBe("error");
      expect(JSON.parse(element.apiData).checklist.contractSigned).toBe(true);
    });
  });

  describe("Complex Mortgage Data Structure Scenarios", () => {
    test("validates complex nested mortgage contract data parsing", () => {
      const element = createElement("c-generic-card", {
        is: GenericCard
      });

      const complexMortgageData = {
        contracts: [
          {
            id: "2ede02f4-8e35-4396-8f84-1f62631426fe",
            state: "STATE_ACCEPTED",
            documents: [
              {
                documentType: "TYPE_MORTGAGE",
                documentSubtype: "SUBTYPE_SIGNED"
              }
            ],
            fees: [
              {
                code: "CODE_REGISTRATION_OF_MORTGAGE",
                feeAmount: {
                  currencyCode: "AUD",
                  units: "122",
                  nanos: 100000000
                }
              }
            ]
          }
        ],
        assets: [
          {
            assetName: "463 Tooronga Road, HAWTHORN EAST VIC 3123",
            estimatedValue: 850000.6,
            type: "ASSET_TYPE_PROPERTY"
          }
        ]
      };

      element.apiConfig = JSON.stringify(CONFIGS.mortgageContractSummary);
      element.apiData = JSON.stringify(complexMortgageData);

      expect(element.apiData).toContain("STATE_ACCEPTED");
      expect(element.apiData).toContain("TYPE_MORTGAGE");
      expect(element.apiData).toContain("ASSET_TYPE_PROPERTY");
      expect(
        JSON.parse(element.apiData).contracts[0].fees[0].feeAmount.units
      ).toBe("122");
      expect(JSON.parse(element.apiData).assets[0].estimatedValue).toBe(
        850000.6
      );
    });
  });

  describe("Data Table Only Scenarios", () => {
    test("configures card with data table only - no field container", () => {
      const element = createElement("c-generic-card", {
        is: GenericCard
      });

      element.apiConfig = JSON.stringify(CONFIGS.dataTableCard);
      element.apiData = JSON.stringify(MOCK_DATA.contractsTableData);
      element.tableConfig = JSON.stringify(TABLE_CONFIGS.contractsTableConfig);
      // Explicitly no fieldConfig to test table-only scenario

      expect(element.apiConfig).toContain("Mortgage Contracts List");
      expect(element.apiData).toContain("Tony Stark");
      expect(element.apiData).toContain("John Cena");
      expect(element.apiData).toContain("Jane Smith");
      expect(element.tableConfig).toContain("Contract ID");
      expect(element.tableConfig).toContain("customerName");
      expect(JSON.parse(element.apiConfig).theme).toBe("info");
      expect(JSON.parse(element.apiData).contracts).toHaveLength(3);
      expect(element.fieldConfig).toBeUndefined();
    });
  });

  describe("Combined Field Container and Data Table Scenarios", () => {
    test("configures card with both field container and data table", () => {
      const element = createElement("c-generic-card", {
        is: GenericCard
      });

      element.apiConfig = JSON.stringify(CONFIGS.combinedCard);
      element.apiData = JSON.stringify(MOCK_DATA.combinedData);
      element.fieldConfig = JSON.stringify(FIELD_CONFIGS.summaryFields);
      element.tableConfig = JSON.stringify(TABLE_CONFIGS.summaryTableConfig);

      expect(element.apiConfig).toContain("Comprehensive Mortgage Overview");
      expect(element.apiData).toContain("totalContracts");
      expect(element.apiData).toContain("contracts");
      expect(element.fieldConfig).toContain("Total Contracts");
      expect(element.tableConfig).toContain("Contract ID");
      expect(JSON.parse(element.apiConfig).theme).toBe("warning");
      expect(JSON.parse(element.apiData).summary.totalContracts).toBe(3);
      expect(JSON.parse(element.apiData).contracts).toHaveLength(2);

      // Verify both field and table configurations are present
      const fieldConfig = JSON.parse(element.fieldConfig);
      const tableConfig = JSON.parse(element.tableConfig);
      expect(fieldConfig).toHaveLength(4); // 4 summary fields
      expect(tableConfig.columns).toHaveLength(4); // 4 table columns
    });
  });

  describe("Field Container Only Scenarios", () => {
    test("configures card with field container only - no data table", () => {
      const element = createElement("c-generic-card", {
        is: GenericCard
      });

      element.apiConfig = JSON.stringify(CONFIGS.mortgageContractSummary);
      element.apiData = JSON.stringify(MOCK_DATA.mortgageContractData);
      element.fieldConfig = JSON.stringify(FIELD_CONFIGS.mortgageFields);
      // Explicitly no tableConfig to test field-only scenario

      expect(element.apiConfig).toContain("Mortgage Contract Summary");
      expect(element.apiData).toContain("2ede02f4-8e35-4396-8f84-1f62631426fe");
      expect(element.fieldConfig).toContain("Contract ID");
      expect(JSON.parse(element.apiConfig).theme).toBe("success");
      expect(JSON.parse(element.fieldConfig)).toHaveLength(4);
      expect(element.tableConfig).toBeUndefined();
    });
  });
});
