import { createElement } from "lwc";
import GenericRecordLink from "c/genericRecordLink";
import getData from "@salesforce/apex/GenericController.getData";
import mockData from "./data/mockData.json";

// Mock getData Apex method
jest.mock(
  "@salesforce/apex/GenericController.getData",
  () => {
    return {
      default: jest.fn()
    };
  },
  { virtual: true }
);

// Mock NavigationMixin (no assertions, just a stub)
jest.mock("lightning/navigation", () => {
  return {
    NavigationMixin: (Base) =>
      class extends Base {
        get [Symbol.for("LightningNavigationMixin.Navigate")]() {
          return () => {};
        }
      }
  };
});

function flushPromises() {
  return new Promise((resolve) => setTimeout(resolve, 0));
}

const OBJECT_NAME = "Account";
const FIELDS = ["Id", "Name"];
const APEX_CONTROLLER = "GenericController";
const RECORD_NAME = "Name";
const PARAMS = { Id: "001xx000003DGbYAAW" };

describe("c-generic-record-link", () => {
  beforeEach(() => {
    while (document.body.firstChild) {
      document.body.removeChild(document.body.firstChild);
    }
    jest.clearAllMocks();
  });

  it("fetches record details on connectedCallback and renders recordNameValue", async () => {
    getData.mockResolvedValue(mockData);

    const element = createElement("c-generic-record-link", {
      is: GenericRecordLink
    });
    element.objectName = OBJECT_NAME;
    element.fields = FIELDS;
    element.apexController = APEX_CONTROLLER;
    element.recordName = RECORD_NAME;
    element.params = PARAMS;

    document.body.appendChild(element);
    await flushPromises();

    // Check that getData was called with correct params
    expect(getData).toHaveBeenCalledWith({
      apexController: APEX_CONTROLLER,
      param: JSON.stringify(PARAMS)
    });

    // Check that the anchor displays the record name
    const anchor = element.shadowRoot.querySelector(
      "a.fieldContent, a.fieldContentStacked"
    );
    expect(anchor).not.toBeNull();
    expect(anchor.textContent).toBe("Test Account");
  });

  it("renders popover when showPopover is true", async () => {
    getData.mockResolvedValue({ Id: "001xx000003DGbYAAW", Name: "Test" });

    const element = createElement("c-generic-record-link", {
      is: GenericRecordLink
    });
    element.objectName = OBJECT_NAME;
    element.fields = FIELDS;
    element.apexController = APEX_CONTROLLER;
    element.recordName = RECORD_NAME;
    element.params = PARAMS;

    document.body.appendChild(element);
    await flushPromises();

    // Simulate mouseover to show popover
    const anchor = element.shadowRoot.querySelector(
      "a.fieldContent, a.fieldContentStacked"
    );
    anchor.dispatchEvent(new MouseEvent("mouseover"));
    await flushPromises();
    let popover = element.shadowRoot.querySelector(".popoverContainer");
    expect(popover).not.toBeNull();

    anchor.dispatchEvent(new MouseEvent("mouseout"));
    await flushPromises();
    popover = element.shadowRoot.querySelector(".popoverContainer");
    expect(popover).toBeNull();
  });

  it("does not render popover by default", async () => {
    getData.mockResolvedValue({ Id: "001xx000003DGbYAAW", Name: "Test" });

    const element = createElement("c-generic-record-link", {
      is: GenericRecordLink
    });
    element.objectName = OBJECT_NAME;
    element.fields = FIELDS;
    element.apexController = APEX_CONTROLLER;
    element.recordName = RECORD_NAME;
    element.params = PARAMS;

    document.body.appendChild(element);
    await flushPromises();

    expect(element.shadowRoot.querySelector(".popoverContainer")).toBeNull();
  });

  it("does not render anchor while loading", async () => {
    // Simulate a slow getData
    getData.mockImplementation(() => new Promise(() => {}));

    const element = createElement("c-generic-record-link", {
      is: GenericRecordLink
    });
    element.objectName = OBJECT_NAME;
    element.fields = FIELDS;
    element.apexController = APEX_CONTROLLER;
    element.recordName = RECORD_NAME;
    element.params = PARAMS;

    document.body.appendChild(element);

    // Anchor should not be present while loading
    expect(
      element.shadowRoot.querySelector("a.fieldContent, a.fieldContentStacked")
    ).toBeNull();
  });

  it("renders anchor with no text if recordNameValue is null", async () => {
    getData.mockResolvedValue({ Id: "001xx000003DGbYAAW" }); // No Name field

    const element = createElement("c-generic-record-link", {
      is: GenericRecordLink
    });
    element.objectName = OBJECT_NAME;
    element.fields = FIELDS;
    element.apexController = APEX_CONTROLLER;
    element.recordName = RECORD_NAME;
    element.params = PARAMS;

    document.body.appendChild(element);
    await flushPromises();

    const anchor = element.shadowRoot.querySelector(
      "a.fieldContent, a.fieldContentStacked"
    );
    expect(anchor).not.toBeNull();
    expect(anchor.textContent).toBe("");
  });

  it("toggles popover on repeated mouseover/mouseout", async () => {
    getData.mockResolvedValue({ Id: "001xx000003DGbYAAW", Name: "Test" });

    const element = createElement("c-generic-record-link", {
      is: GenericRecordLink
    });
    element.objectName = OBJECT_NAME;
    element.fields = FIELDS;
    element.apexController = APEX_CONTROLLER;
    element.recordName = RECORD_NAME;
    element.params = PARAMS;

    document.body.appendChild(element);
    await flushPromises();

    const anchor = element.shadowRoot.querySelector(
      "a.fieldContent, a.fieldContentStacked"
    );
    // First mouseover: show popover
    anchor.dispatchEvent(new MouseEvent("mouseover"));
    await flushPromises();
    expect(
      element.shadowRoot.querySelector(".popoverContainer")
    ).not.toBeNull();

    // Mouseout: hide popover
    anchor.dispatchEvent(new MouseEvent("mouseout"));
    await flushPromises();
    expect(element.shadowRoot.querySelector(".popoverContainer")).toBeNull();

    // Mouseover again: show popover
    anchor.dispatchEvent(new MouseEvent("mouseover"));
    await flushPromises();
    expect(
      element.shadowRoot.querySelector(".popoverContainer")
    ).not.toBeNull();
  });
});
