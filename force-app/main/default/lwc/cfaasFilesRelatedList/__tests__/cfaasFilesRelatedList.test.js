import { createElement } from "lwc";
import CfaasFilesRelatedList from "c/cfaasFilesRelatedList";
import { getRelatedListRecords } from "lightning/uiRelatedListApi";
import getCFaaSDocument from "@salesforce/apex/CFaaSController.getCFaaSDocument";

const mockGetRelatedListRecord = require("./data/getRelatedListRecords.json");

// mock getCFaasDocument Apex method
jest.mock(
  "@salesforce/apex/CFaaSController.getCFaaSDocument",
  () => {
    return {
      default: jest.fn(() => Promise.resolve())
    };
  },
  { virtual: true }
);

describe("c-cfaas-files-related-list", () => {
  // clean the dom and mocks in between test runs
  beforeEach(() => {
    const element = createElement("c-cfaas-files-related-list", {
      is: CfaasFilesRelatedList
    });
    document.body.appendChild(element);
  });
  afterEach(() => {
    while (document.body.firstChild) {
      document.body.removeChild(document.body.firstChild);
    }
    jest.restoreAllMocks();
  });

  async function flushPromises() {
    return Promise.resolve();
  }

  describe("component loading", () => {
    it("displays spinner when loading", async () => {
      const element = document.querySelector("c-cfaas-files-related-list");
      const spinner = element.shadowRoot.querySelector("lightning-spinner");

      await flushPromises();

      expect(spinner).not.toBeNull();
    });
  });

  describe("getRelatedListRecords @wire data in Customer Record Page", () => {
    it("renders the records in datatable in Customer Application Page", async () => {
      const element = document.querySelector("c-cfaas-files-related-list");
      element.objectApiName = "Account";
      element.records = mockGetRelatedListRecord;

      getRelatedListRecords.emit(mockGetRelatedListRecord);

      await flushPromises();

      const icon = element.shadowRoot.querySelector("lightning-icon");
      const divDatatable = element.shadowRoot.querySelector(".div-data-table");
      const datatable = element.shadowRoot.querySelector("c-custom-datatable");
      const viewAllLink = element.shadowRoot.querySelector("footer a");

      expect(icon).not.toBeNull();
      expect(element.title).toBe("Customer Files");
      expect(datatable).not.toBeNull();
      expect(datatable.data.length).toBe(5); //should display only 5 records
      expect(divDatatable.style.height).toBeNull; //no div height, should prevent lazy loading feature
      expect(viewAllLink).not.toBeNull();
      expect(viewAllLink.textContent).toContain("View All");

      viewAllLink.dispatchEvent(new CustomEvent("click"));
      await flushPromises();

      expect(viewAllLink).toBeTruthy();
    });
  });

  describe("getRelatedListRecords @wire data in Loan Application Record Page", () => {
    it("renders the records in datatable in Loan Application Page", async () => {
      const element = document.querySelector("c-cfaas-files-related-list");
      element.objectApiName = "ResidentialLoanApplication";

      getRelatedListRecords.emit(mockGetRelatedListRecord);

      await flushPromises();

      const icon = element.shadowRoot.querySelector("lightning-icon");
      const divDatatable = element.shadowRoot.querySelector(".div-data-table");
      const datatable = element.shadowRoot.querySelector("c-custom-datatable");
      const viewAllLink = element.shadowRoot.querySelector("footer a");

      expect(icon).not.toBeNull();
      expect(element.title).toBe("Loan Files");
      expect(datatable).not.toBeNull();
      expect(datatable.data.length).toBe(5); //should display only 5 records
      expect(divDatatable.style.height).toBeNull; //no div height, should prevent lazy loading feature
      expect(viewAllLink).not.toBeNull();
      expect(viewAllLink.textContent).toContain("View All");

      viewAllLink.dispatchEvent(new CustomEvent("click"));
      await flushPromises();

      expect(viewAllLink).toBeTruthy();
    });
  });

  describe("getRelatedListRecords @wire data in Subtab", () => {
    it("renders records as Subtab", async () => {
      const element = document.querySelector("c-cfaas-files-related-list");
      element.title = "Customer Files";
      element.recordId = "0012O00000Mt5K1QAJ"; //dummy record Id
      element.records = mockGetRelatedListRecord;
      element.objectApiName = null;

      getRelatedListRecords.emit(mockGetRelatedListRecord);

      await flushPromises();

      const icon = element.shadowRoot.querySelector("lightning-icon");
      const datatable = element.shadowRoot.querySelector("c-custom-datatable");
      const divDatatable = element.shadowRoot.querySelector(".div-data-table");
      const viewAllLink = element.shadowRoot.querySelector("footer a");

      expect(icon).not.toBeNull();
      expect(element.title).toBe("Customer Files");
      expect(datatable).not.toBeNull();
      expect(datatable.data.length).toBeGreaterThan(5); //should more than 5 records
      expect(divDatatable.style.height).not.toBeNull; //should have style for lazy loading purpose
      expect(viewAllLink).toBeNull(); // View All link should not be displayed
    });
  });

  describe("getRelatedListRecords @wire No Records", () => {
    it("shows no files available", async () => {
      const element = document.querySelector("c-cfaas-files-related-list");

      getRelatedListRecords.error(); // Emit error from @wire

      await flushPromises(); // Wait for any asynchronous DOM updates

      const noFilesDivElement = element.shadowRoot.querySelector(
        ".div-no-files"
      );

      expect(noFilesDivElement).not.toBeNull();
      expect(noFilesDivElement.textContent).toBe(
        "There are currently no files"
      );
    });
  });

  describe("files can be previewed", () => {
    it("getCFaaSDocument is called when file name is clicked for previewing", async () => {
      const element = document.querySelector("c-cfaas-files-related-list");

      element.objectApiName = "Account";
      element.records = mockGetRelatedListRecord;

      getRelatedListRecords.emit(mockGetRelatedListRecord);

      await flushPromises();

      const datatable = element.shadowRoot.querySelector("c-custom-datatable");
      const fileNameClickEvent = new CustomEvent("clickurl", {
        detail: {
          row: {
            id: "a1q2O0000008B9EQAU",
            documentId: "agmFVABxkNPrXqZzkcnWKBTOIGIwZkqxTIw",
            fileExtension: ".jpeg",
            securityClassification: "PROTECTED",
            ocvId: "VyUesOvuTe1"
          },
          action: {
            title: "Preview",
            alternativeText: "View",
            label: { fieldName: "fileName" },
            variant: "base"
          }
        }
      });

      datatable.dispatchEvent(fileNameClickEvent);

      await flushPromises();

      // Validate getCFaaSDocument was called
      expect(getCFaaSDocument).toHaveBeenCalled();
    });
  });
});
