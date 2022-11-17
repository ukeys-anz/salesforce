import { createElement } from "lwc";
import { setImmediate } from "timers";
import AddressLookupUtil from "c/addressLookupUtil";

import getValidAddresses from "@salesforce/apex/CCRMAPIRepository.getAddressesLwcV2";
import getSelectedAddress from "@salesforce/apex/CCRMAPIRepository.getSelectedAddressLwcV2";

const mockGetValidAddresses = require("./data/mock_ccrmQasSuccessResponseV2.json");
const mockGetSelectedAddress = require("./data/mock_ccrmQasSelectedAddressResponseV2.json");

const flushPromises = () => new Promise(setImmediate);

jest.mock(
  "@salesforce/apex/CCRMAPIRepository.getAddressesLwcV2",
  () => {
    return {
      default: jest.fn()
    };
  },
  { virtual: true }
);

jest.mock(
  "@salesforce/apex/CCRMAPIRepository.getSelectedAddressLwcV2",
  () => {
    return {
      default: jest.fn()
    };
  },
  { virtual: true }
);

jest.useFakeTimers();

describe("c-address-lookup-util", () => {
  beforeEach(() => {
    const element = createElement("c-address-lookup-util", {
      is: AddressLookupUtil
    });
    document.body.appendChild(element);
  });

  afterEach(() => {
    while (document.body.firstChild) {
      document.body.removeChild(document.body.firstChild);
    }
  });

  it("Test search and select addresses", async () => {
    getValidAddresses.mockResolvedValue(mockGetValidAddresses);
    getSelectedAddress.mockResolvedValue(mockGetSelectedAddress);

    const lwcCmp = document.querySelector("c-address-lookup-util");
    const inputSearch = lwcCmp.shadowRoot.querySelector(".inputBox");
    inputSearch.dispatchEvent(
      new CustomEvent("change", {
        detail: { value: "242 pitt st" }
      })
    );
    jest.runOnlyPendingTimers();
    await flushPromises();
    const pnlSearchResult = lwcCmp.shadowRoot.querySelector(".pnlSearchResult");
    expect(pnlSearchResult).toBeDefined();

    const addressItem = lwcCmp.shadowRoot.querySelector(".pnlSearchResult li");
    addressItem.dispatchEvent(new CustomEvent("mousedown"));

    await flushPromises();
    expect(lwcCmp.shadowRoot.querySelector(".pnlSearchResult")).toBeNull();
  });
});
