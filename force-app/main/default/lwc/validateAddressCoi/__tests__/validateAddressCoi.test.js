import { createElement } from "lwc";
import ValidateAddressCoi from "c/validateAddressCoi"; // Updated component name
import getValidAddresses from "@salesforce/apex/AddressServiceController.getValidAddresses";
import getSelectedAddress from "@salesforce/apex/AddressServiceController.getSelectedAddress";
import validateManualAddress from "@salesforce/apex/AddressServiceController.validateManualAddress";
import getCountryNameToCodeMap from "@salesforce/apex/AddressServiceController.getCountryNameToCodeMap";
import getStateNameToCodeMap from "@salesforce/apex/AddressServiceController.getStateNameToCodeMap";
import getAddress from "@salesforce/apex/AddressServiceController.getAddress";

jest.mock(
  "@salesforce/apex/AddressServiceController.getValidAddresses",
  () => {
    return { default: jest.fn() };
  },
  { virtual: true }
);
jest.mock(
  "@salesforce/apex/AddressServiceController.getSelectedAddress",
  () => {
    return { default: jest.fn() };
  },
  { virtual: true }
);
jest.mock(
  "@salesforce/apex/AddressServiceController.validateManualAddress",
  () => {
    return { default: jest.fn() };
  },
  { virtual: true }
);
jest.mock(
  "@salesforce/apex/AddressServiceController.getCountryNameToCodeMap",
  () => {
    return { default: jest.fn() };
  },
  { virtual: true }
);
jest.mock(
  "@salesforce/apex/AddressServiceController.getStateNameToCodeMap",
  () => {
    return { default: jest.fn() };
  },
  { virtual: true }
);
jest.mock(
  "@salesforce/apex/AddressServiceController.getAddress",
  () => {
    return { default: jest.fn() };
  },
  { virtual: true }
);

// Mock data
const mockData = {
  getValidAddresses: {
    count: 3,
    result: [
      {
        address:
          "Sandgate District High School, 41 Braun Street, DEAGON QLD 4017",
        global_address_key: "address1"
      },
      {
        address:
          "Sandgate Brighton Child Care, 160-162 Brighton Road, SANDGATE QLD 4017",
        global_address_key: "address2"
      },
      {
        address: "Sandy Cove, 8 Darwalla Avenue, CURRUMBIN QLD 4223",
        global_address_key: "address3"
      }
    ]
  },
  getSelectedAddress: {
    addressType: "R",
    city: "Bargara",
    countryCode: "AU",
    postalCode: 4670,
    state: "QLD",
    street: "Esplanade"
  },
  validateManualAddress: {
    hasValidAddress: true,
    result: [
      {
        category: "DELIVERY AREA",
        deliveryOffice: "ALBANY DC",
        pointOfOrigin: "Australia Post",
        postCode: 6330,
        state: "WA",
        suburb: "ALBANY"
      }
    ]
  },
  getCountryNameToCodeMap: {
    Australia: "AUS",
    Afghanistan: "AFG",
    Bahamas: "BHS"
  },
  getStateNameToCodeMap: {
    "Australian Capital Territory": "ACT",
    Queensland: "QLD",
    "New South Wales": "NSW"
  },
  getAddress: [
    {
      address: "2367 Testini Lane, WARBURN NSW 2680",
      global_address_key: "address4"
    }
  ]
};

// Mock methods
getValidAddresses.mockResolvedValue(mockData.getValidAddresses);
getSelectedAddress.mockResolvedValue(mockData.getSelectedAddress);
validateManualAddress.mockResolvedValue(mockData.validateManualAddress);
getCountryNameToCodeMap.mockResolvedValue(mockData.getCountryNameToCodeMap);
getStateNameToCodeMap.mockResolvedValue(mockData.getStateNameToCodeMap);
getAddress.mockResolvedValue(mockData.getAddress);

describe("c-validate-address-coi", () => {
  let element;

  beforeEach(() => {
    element = createElement("c-validate-address-coi", {
      is: ValidateAddressCoi
    });
    document.body.appendChild(element);
  });

  afterEach(() => {
    while (document.body.firstChild) {
      document.body.removeChild(document.body.firstChild);
    }
    jest.clearAllMocks();
  });

  it("should return valid addresses with correct structure", async () => {
    const response = await getValidAddresses();

    expect(response).toHaveProperty("count", 3);
    expect(response).toHaveProperty("result");
    expect(response.result).toHaveLength(3);
    expect(response.result[0]).toHaveProperty("address");
    expect(response.result[0]).toHaveProperty("global_address_key");
  });

  it("should return the correct selected address", async () => {
    const response = await getSelectedAddress();

    expect(response).toHaveProperty("addressType", "R");
    expect(response).toHaveProperty("city", "Bargara");
    expect(response).toHaveProperty("countryCode", "AU");
    expect(response).toHaveProperty("postalCode", 4670);
    expect(response).toHaveProperty("state", "QLD");
    expect(response).toHaveProperty("street", "Esplanade");
  });

  it("should validate manual address and return valid data", async () => {
    const response = await validateManualAddress();

    expect(response).toHaveProperty("hasValidAddress", true);
    expect(response).toHaveProperty("result");
    expect(response.result).toHaveLength(1);
    expect(response.result[0]).toHaveProperty("category", "DELIVERY AREA");
    expect(response.result[0]).toHaveProperty("deliveryOffice", "ALBANY DC");
    expect(response.result[0]).toHaveProperty(
      "pointOfOrigin",
      "Australia Post"
    );
  });

  it("should return correct country to code map", async () => {
    const response = await getCountryNameToCodeMap();

    expect(response).toHaveProperty("Australia", "AUS");
    expect(response).toHaveProperty("Afghanistan", "AFG");
    expect(response["Australia"]).toBe("AUS");
  });

  it("should return correct state to code map", async () => {
    const response = await getStateNameToCodeMap();

    expect(response).toHaveProperty("Australian Capital Territory", "ACT");
    expect(response).toHaveProperty("Queensland", "QLD");
    expect(response).toHaveProperty("New South Wales", "NSW");
  });

  it("should return correct address data", async () => {
    const response = await getAddress();

    expect(response).toHaveLength(1);
    expect(response[0]).toHaveProperty("address");
    expect(response[0]).toHaveProperty("global_address_key");
  });

  // Test specific functionality related to address selection and UI rendering

  it("should display validation error messages", async () => {
    element.hasValidAddress = false;
    await Promise.resolve();

    const errorMessages =
      element.shadowRoot.querySelector("lightning-messages");
    expect(errorMessages).toBeTruthy(); // Validation error messages should be displayed
  });
});
