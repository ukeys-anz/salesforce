import { createElement } from "lwc";
import ContactPointRelatedList from "c/contactPointRelatedList";
import getContactPointObjectRecords from "@salesforce/apex/ContactPointObjectsController.getContactPointObjectRecords";

const mockContactAddressRecords = require("./data/contactPointAddressRecords.json");
const mockContactEmailRecords = require("./data/contactPointEmailRecords.json");
const mockContactPhoneRecords = require("./data/contactPointPhoneRecords.json");

const OBJ_CONTACTPOINTADDRESS = "ContactPointAddress";
const OBJ_CONTACTPOINTEMAIL = "ContactPointEmail";
const OBJ_CONTACTPOINTPHONE = "ContactPointPhone";

const RECORD_ID = "0018s00000OdQ1fAAF";
// mock getContactPointObjectRecords Apex method
jest.mock(
  "@salesforce/apex/ContactPointObjectsController.getContactPointObjectRecords",
  () => {
    const { createApexTestWireAdapter } = require("@salesforce/sfdx-lwc-jest");
    return {
      default: createApexTestWireAdapter(jest.fn(() => Promise.resolve()))
    };
  },
  { virtual: true }
);

describe("c-contact-point-related-list", () => {
  // clean the dom and mocks in between test runs
  beforeEach(() => {
    const element = createElement("c-contact-point-related-list", {
      is: ContactPointRelatedList
    });
    element.recordId = RECORD_ID;
    document.body.appendChild(element);
  });
  afterEach(() => {
    // The jsdom instance is shared across test cases in a single file so reset the DOM
    while (document.body.firstChild) {
      document.body.removeChild(document.body.firstChild);
    }
    jest.restoreAllMocks();
  });

  // Helper function to wait until the microtask queue is empty. This is needed for promise
  // timing when calling imperative Apex.
  async function flushPromises() {
    return Promise.resolve();
  }

  describe("ContactPointAddress Related List", () => {
    it("retrieve contactpointaddress records from apex", async () => {
      // Get the element
      const element = document.querySelector("c-contact-point-related-list");
      element.contactPointObjectApiName = OBJ_CONTACTPOINTADDRESS;

      // Emit data from @wire
      getContactPointObjectRecords.emit(mockContactAddressRecords);

      // Wait for any asynchronous DOM updates
      await flushPromises();
      const dataTableElement = element.shadowRoot.querySelector(
        "lightning-datatable"
      );

      //check data
      expect(dataTableElement.data).toStrictEqual(mockContactAddressRecords);
    });

    it("show contactpointaddress properties values accordingly", async () => {
      // Get the element
      const element = document.querySelector("c-contact-point-related-list");
      element.contactPointObjectApiName = OBJ_CONTACTPOINTADDRESS;

      // Emit data from @wire
      getContactPointObjectRecords.emit(mockContactAddressRecords);

      // Wait for any asynchronous DOM updates
      await flushPromises();

      const cardSection = element.shadowRoot.querySelector("lightning-card");
      //check the property values
      expect(cardSection.title).toEqual("Addresses");
      expect(cardSection.iconName).toEqual("standard:address");

      const dataTableElement = element.shadowRoot.querySelector(
        "lightning-datatable"
      );
      //check datatable element
      expect(dataTableElement.data).not.toBeNull();
      //check columns
      expect(
        dataTableElement.columns.find(
          (col) => col.fieldName === "Persona_Type__c"
        ).fieldName
      ).not.toBeNull();
      expect(
        dataTableElement.columns.find((col) => col.fieldName === "FullAddress")
          .fieldName
      ).not.toBeNull();
      expect(
        dataTableElement.columns.find((col) => col.fieldName === "AddressType")
          .fieldName
      ).not.toBeNull();
      expect(
        dataTableElement.columns.find((col) => col.fieldName === "IsPreferred")
          .fieldName
      ).not.toBeNull();
    });
  });

  describe("ContactPointEmail Related List", () => {
    it("retrieve contactpointemail records from apex", async () => {
      // Get the element
      const element = document.querySelector("c-contact-point-related-list");
      element.contactPointObjectApiName = OBJ_CONTACTPOINTEMAIL;

      // Emit data from @wire
      getContactPointObjectRecords.emit(mockContactEmailRecords);

      // Wait for any asynchronous DOM updates
      await flushPromises();
      const dataTableElement = element.shadowRoot.querySelector(
        "lightning-datatable"
      );

      //check data
      expect(dataTableElement.data).toStrictEqual(mockContactEmailRecords);
    });

    it("show contactpointemail properties values accordingly", async () => {
      // Get the element
      const element = document.querySelector("c-contact-point-related-list");
      element.contactPointObjectApiName = OBJ_CONTACTPOINTEMAIL;

      // Emit data from @wire
      getContactPointObjectRecords.emit(mockContactEmailRecords);

      // Wait for any asynchronous DOM updates
      await flushPromises();

      const cardSection = element.shadowRoot.querySelector("lightning-card");
      //check the property values
      expect(cardSection.title).toEqual("Email Addresses");
      expect(cardSection.iconName).toEqual("custom:custom105");

      const dataTableElement = element.shadowRoot.querySelector(
        "lightning-datatable"
      );
      //check datatable element
      expect(dataTableElement.data).not.toBeNull();
      //check columns
      expect(
        dataTableElement.columns.find(
          (col) => col.fieldName === "Persona_Type__c"
        ).fieldName
      ).not.toBeNull();
      expect(
        dataTableElement.columns.find((col) => col.fieldName === "EmailAddress")
          .fieldName
      ).not.toBeNull();
      expect(
        dataTableElement.columns.find(
          (col) => col.fieldName === "Preferred_Indicator__c"
        ).fieldName
      ).not.toBeNull();
    });
  });

  describe("ContactPointPhone Related List", () => {
    it("retrieve contactpointphone records from apex", async () => {
      // Get the element
      const element = document.querySelector("c-contact-point-related-list");
      element.contactPointObjectApiName = OBJ_CONTACTPOINTPHONE;

      // Emit data from @wire
      getContactPointObjectRecords.emit(mockContactPhoneRecords);

      // Wait for any asynchronous DOM updates
      await flushPromises();
      const dataTableElement = element.shadowRoot.querySelector(
        "lightning-datatable"
      );

      //check data
      expect(dataTableElement.data).toStrictEqual(mockContactPhoneRecords);
    });

    it("show contactpointphone properties values accordingly", async () => {
      // Get the element
      const element = document.querySelector("c-contact-point-related-list");
      element.contactPointObjectApiName = OBJ_CONTACTPOINTPHONE;

      // Emit data from @wire
      getContactPointObjectRecords.emit(mockContactPhoneRecords);

      // Wait for any asynchronous DOM updates
      await flushPromises();

      const cardSection = element.shadowRoot.querySelector("lightning-card");
      //check the property values
      expect(cardSection.title).toEqual("Phone Numbers");
      expect(cardSection.iconName).toEqual("standard:log_a_call");

      const dataTableElement = element.shadowRoot.querySelector(
        "lightning-datatable"
      );
      //check datatable element
      expect(dataTableElement.data).not.toBeNull();
      //check columns
      expect(
        dataTableElement.columns.find(
          (col) => col.fieldName === "Persona_Type__c"
        ).fieldName
      ).not.toBeNull();
      expect(
        dataTableElement.columns.find(
          (col) => col.fieldName === "TelephoneNumber"
        ).fieldName
      ).not.toBeNull();
      expect(
        dataTableElement.columns.find((col) => col.fieldName === "PhoneType")
          .fieldName
      ).not.toBeNull();
      expect(
        dataTableElement.columns.find(
          (col) => col.fieldName === "Preferred_Indicator__c"
        ).fieldName
      ).not.toBeNull();
    });
  });

  describe("Error Panel", () => {
    it("shows error panel element when error returned", async () => {
      // Get the element
      const element = document.querySelector("c-contact-point-related-list");

      // Emit error from @wire
      getContactPointObjectRecords.error();

      // Wait for any asynchronous DOM updates
      await flushPromises();

      const errorPanel = element.shadowRoot.querySelector("c-error");
      //check error panel
      expect(errorPanel).not.toBeNull();
    });
  });
});
