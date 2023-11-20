import { createElement } from "lwc";
import FilteredRelatedList from "c/filteredRelatedList";

const mockData1 = require("./data/mockTestData-1.json");
const mockData2 = require("./data/mockTestData-2.json");
const mockData3 = require("./data/mockTestData-3.json");

// Mocking all required @api variables
const ICON = "standard:contact";

describe("filtered-related-list | No records", () => {
  // clean the dom and mocks in between test runs
  beforeEach(() => {
    const element = createElement("c-filtered-related-list", {
      is: FilteredRelatedList
    });

    element.iconName = ICON;
    element.records = mockData3.records;

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

  it("displays spinner when loading", async () => {
    const element = document.querySelector("c-filtered-related-list");
    const spinner = element.shadowRoot.querySelector("lightning-spinner");
    await flushPromises();
    expect(spinner).not.toBeNull();
  });

  it("Icon, record list, next button, and previous button should not be visible", async () => {
    const element = document.querySelector("c-filtered-related-list");
    await flushPromises();

    const icon = element.shadowRoot.querySelector("lightning-icon");
    const relatedListContainer = element.shadowRoot.querySelector(
      ".related-list-container"
    );
    const listTitle = element.shadowRoot.querySelector("lightning-tile");
    const allListTitle = element.shadowRoot.querySelectorAll("lightning-tile");
    const nextButton = element.shadowRoot.querySelector("lightning-button");
    const modalFooter = element.shadowRoot.querySelector(
      "lightning-modal-footer"
    );

    expect(icon).toBeFalsy();
    expect(listTitle).toBeFalsy();
    expect(allListTitle.length).toBe(0);
    expect(relatedListContainer).toBeFalsy();
    expect(nextButton).toBeFalsy();
    expect(modalFooter).toBeFalsy();
  });
});

describe("filtered-related-list | More than 3 records", () => {
  // clean the dom and mocks in between test runs
  beforeEach(() => {
    const element = createElement("c-filtered-related-list", {
      is: FilteredRelatedList
    });

    element.iconName = ICON;
    element.records = mockData1.records;

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

  it("Icon, record list, next button, and previous button should be visible", async () => {
    const element = document.querySelector("c-filtered-related-list");
    await flushPromises();

    const icon = element.shadowRoot.querySelector("lightning-icon");
    const relatedListContainer = element.shadowRoot.querySelector(
      ".related-list-container"
    );
    const listTitle = element.shadowRoot.querySelector("lightning-tile");
    const allListTitle = element.shadowRoot.querySelectorAll("lightning-tile");
    const nextButton = element.shadowRoot.querySelector("lightning-button");
    const modalFooter = element.shadowRoot.querySelector(
      "lightning-modal-footer"
    );

    expect(icon).not.toBeNull();
    expect(listTitle).not.toBeNull();
    expect(allListTitle.length).toBe(3);
    expect(relatedListContainer).not.toBeNull();
    expect(relatedListContainer.style.height).not.toBeNull();
    expect(nextButton).not.toBeNull();
    expect(modalFooter).not.toBeNull;

    modalFooter.dispatchEvent(new CustomEvent("click"));
    await flushPromises();

    expect(modalFooter).toBeTruthy();
    const previousButton = element.shadowRoot.querySelector("lightning-button");
    expect(previousButton).not.toBeNull();
  });
});

describe("filtered-related-list | Less than 3 records", () => {
  // clean the dom and mocks in between test runs
  beforeEach(() => {
    const element = createElement("c-filtered-related-list", {
      is: FilteredRelatedList
    });

    element.iconName = ICON;
    element.records = mockData2.records;

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

  it("Footer and Next button should not be visible, if we just have 3 or less records.", async () => {
    const element = document.querySelector("c-filtered-related-list");

    await flushPromises();

    const icon = element.shadowRoot.querySelector("lightning-icon");
    const relatedListContainer = element.shadowRoot.querySelector(
      ".related-list-container"
    );
    const listTitle = element.shadowRoot.querySelector("lightning-tile");
    const allListTitle = element.shadowRoot.querySelectorAll("lightning-tile");
    const nextButton = element.shadowRoot.querySelector(
      "lightning-button[label='Next']"
    );
    const modalFooter = element.shadowRoot.querySelector(
      "lightning-modal-footer"
    );

    expect(icon).not.toBeNull();
    expect(listTitle).not.toBeNull();
    expect(allListTitle.length).toBe(2);
    expect(relatedListContainer).not.toBeNull();
    expect(relatedListContainer.style.height).not.toBeNull();
    expect(nextButton).toBeFalsy();
    expect(modalFooter).toBeFalsy;
  });
});
