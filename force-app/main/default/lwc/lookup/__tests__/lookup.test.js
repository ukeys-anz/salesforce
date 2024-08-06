import { createElement } from "lwc";
import Lookup from "c/lookup";
import { setImmediate } from "timers";

const flushPromises = () => new Promise(setImmediate);

describe("c-lookup", () => {
  afterEach(() => {
    // The jsdom instance is shared across test cases in a single file so reset the DOM
    while (document.body.firstChild) {
      document.body.removeChild(document.body.firstChild);
    }
  });

  it("Test No Record found", async () => {
    const lwcCmp = createElement("c-lookup", {
      is: Lookup
    });
    document.body.appendChild(lwcCmp);
    await flushPromises();
    const inputElement = lwcCmp.shadowRoot.querySelectorAll("lightning-input");
    inputElement[0].value = "450";
    inputElement[0].dispatchEvent(
      new CustomEvent("change", {
        detail: { searchKey: inputElement[0].value }
      })
    );
    lwcCmp.searchResults = [];
    await flushPromises();
    const dropDownElement = lwcCmp.shadowRoot.querySelectorAll(
      ".slds-listbox__item"
    );
    expect(dropDownElement[0].textContent).toBe("No Records Found....");
  });

  it("Test search and select an item", async () => {
    const mockSearchResults = [
      {
        iconName: "custom:custom16",
        id: "a0F9p000001lqgvEAA",
        label: "PCA-4509490251600285",
        subLabel: "4509490251600285",
        uniqueId: "a0D9p000003ApdqEAC"
      }
    ];
    const lwcCmp = createElement("c-lookup", {
      is: Lookup
    });
    lwcCmp.searchResults = mockSearchResults;
    lwcCmp._searchResults = mockSearchResults;
    document.body.appendChild(lwcCmp);
    await flushPromises();
    const inputElement = lwcCmp.shadowRoot.querySelectorAll("lightning-input");
    inputElement[0].value = "450";
    inputElement[0].dispatchEvent(
      new CustomEvent("change", {
        detail: { searchKey: inputElement[0].value }
      })
    );
    lwcCmp.searchResults = mockSearchResults;
    lwcCmp._searchResults = mockSearchResults;
    await flushPromises();
    const dropDownElement = lwcCmp.shadowRoot.querySelectorAll(
      "div.hasOptions"
    );
    expect(dropDownElement).toHaveLength(1);
    dropDownElement[0].dispatchEvent(new CustomEvent("click"));
    await flushPromises();
  });
});
