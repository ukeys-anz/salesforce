import { createElement } from "lwc";
import CustomerInfoComponent from "c/customerInformation";
import { getRecord } from "lightning/uiRecordApi";
import getCustomerData from "@salesforce/apex/IDRAPIRepository.getCustomerInfoLWC";
import { ShowToastEventName } from "lightning/platformShowToastEvent";
import { setImmediate } from "timers";

const SUCCESS_TOAST_TITLE = "Success";
const mockGetCustomerData = require("./data/getRecord.json");
const mockOCVCustomerDataResponse = require("./data/getCustomerData.json");
const mockGetCustomerDataUpdate = require("./data/getRecordCustomerUpdate.json");
const mockGetCustomerDataError = require("./data/getCustomerInfoError.json");

jest.mock(
  "@salesforce/apex/IDRAPIRepository.getCustomerInfoLWC",
  () => {
    return {
      default: jest.fn()
    };
  },
  { virtual: true }
);

describe("c-customer-information", () => {
  // Disconnect the component to reset the adapter. It is also
  // a best practice to clean up after each test.
  afterEach(() => {
    while (document.body.firstChild) {
      document.body.removeChild(document.body.firstChild);
    }

    jest.clearAllMocks();
  });

  function flushPromises() {
    // eslint-disable-next-line no-undef
    return new Promise((resolve) => setImmediate(resolve));
  }

  it("Display stored customer data", () => {
    const element = createElement("c-customer-information", {
      is: CustomerInfoComponent
    });
    document.body.appendChild(element);
    getRecord.emit(mockGetCustomerData);

    // Resolve a promise to wait for a rerender of the new content.
    return flushPromises().then(() => {
      //const content = element.querySelector('li');
      const customerdataElements = element.shadowRoot.querySelectorAll("li");
      expect(customerdataElements).not.toBeNull();
      expect(customerdataElements.length).toBe(5);
      const firstName = mockGetCustomerData.fields.IDR_NC_First_Name__c.value;
      const middleName =
        mockGetCustomerData.fields.IDR_NC_Middle_Names__c.value;
      const lastName = mockGetCustomerData.fields.IDR_NC_Last_Name__c.value;
      const rmComplaint =
        mockGetCustomerData.fields.Relationship_Managed_Complaint__c.value ==
        true
          ? "YES"
          : "NO";
      expect(customerdataElements[1].textContent).toBe(
        "First Name : " + firstName
      );
      expect(customerdataElements[2].textContent).toBe(
        "Middle Names : " + middleName
      );
      expect(customerdataElements[3].textContent).toBe(
        "Last Name : " + lastName
      );
      expect(customerdataElements[4].textContent).toBe(
        "RM Complaint :" + rmComplaint
      );

      const showMoreButton = element.shadowRoot.querySelector("button");
      expect(showMoreButton).not.toBeNull();
    });
  });

  it("Show More Data", () => {
    const element = createElement("c-customer-information", {
      is: CustomerInfoComponent
    });

    document.body.appendChild(element);
    element.showMore = false;
    getCustomerData.mockResolvedValue(mockOCVCustomerDataResponse);

    getRecord.emit(mockGetCustomerData);

    // Resolve a promise to wait for a rerender of the new content.
    return flushPromises().then(() => {
      const customerdataElements = element.shadowRoot.querySelectorAll("li");
      expect(customerdataElements).not.toBeNull();
      expect(customerdataElements.length).toBe(5);
      const firstName = mockGetCustomerData.fields.IDR_NC_First_Name__c.value;
      const middleName =
        mockGetCustomerData.fields.IDR_NC_Middle_Names__c.value;
      const lastName = mockGetCustomerData.fields.IDR_NC_Last_Name__c.value;
      const rmComplaint =
        mockGetCustomerData.fields.Relationship_Managed_Complaint__c.value ==
        true
          ? "YES"
          : "NO";
      expect(customerdataElements[1].textContent).toBe(
        "First Name : " + firstName
      );
      expect(customerdataElements[2].textContent).toBe(
        "Middle Names : " + middleName
      );
      expect(customerdataElements[3].textContent).toBe(
        "Last Name : " + lastName
      );
      expect(customerdataElements[4].textContent).toBe(
        "RM Complaint :" + rmComplaint
      );

      const showMoreButton = element.shadowRoot.querySelector("button");
      expect(showMoreButton).not.toBeNull();
      element.showMore = true;
      const customerdataElements1 = element.shadowRoot.querySelectorAll("li");
      showMoreButton.click();

      return flushPromises().then(() => {
        const customerdataElements1 = element.shadowRoot.querySelectorAll("li");
        expect(customerdataElements1).not.toBeNull();
      });
    });
  });

  it("Display stored customer data along with customer update", () => {
    const element = createElement("c-customer-information", {
      is: CustomerInfoComponent
    });

    document.body.appendChild(element);
    element.showMore = false;
    getCustomerData.mockResolvedValue(mockOCVCustomerDataResponse);

    getRecord.emit(mockGetCustomerDataUpdate);
    const handler = jest.fn();
    element.addEventListener(ShowToastEventName, handler);
    // Resolve a promise to wait for a rerender of the new content.
    return flushPromises().then(() => {
      const customerdataElements = element.shadowRoot.querySelectorAll("li");
      expect(customerdataElements).not.toBeNull();
      element.customerId = "4021733054";
      element.custIdentifier = "Customer/Business CAP ID";
      return flushPromises().then(() => {
        return new Promise(setImmediate).then(() => {});
      });
    });
  });

  it("Error occured while fetching customer data", () => {
    const element = createElement("c-customer-information", {
      is: CustomerInfoComponent
    });
    document.body.appendChild(element);
    getCustomerData.mockRejectedValue(mockGetCustomerDataError);
    element.customerId = "1234567890";
    element.custIdentifier = "Customer/Business CAP ID";
    return flushPromises().then(() => {
      expect(element.error).not.toBeNull();
    });
  });
});
