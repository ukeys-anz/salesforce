import { createElement } from "lwc";
import { CloseScreenEventName } from "lightning/actions";
import LaunchAppOnOpp from "c/launchAppOnOpp";
import getOpportunityLineItems from "@salesforce/apex/LaunchAppOnOppController.getOpportunityLineItems";
import populateRecordTypeWrapper from "@salesforce/apex/LaunchAppOnOppController.populateRecordTypeWrapper";

const RECORD_ID = "0069p00000Dt6enAAB";

jest.mock(
  "@salesforce/apex/LaunchAppOnOppController.populateRecordTypeWrapper",
  () => {
    return {
      default: jest.fn()
    };
  },
  { virtual: true }
);

jest.mock(
  "@salesforce/apex/LaunchAppOnOppController.getOpportunityLineItems",
  () => {
    return {
      default: jest.fn()
    };
  },
  { virtual: true }
);

const mockRecordTypes = [
  {
    Id: "0129p000001J8irAAC",
    Name: "Internal Application"
  }
];

const mockOppLineItems = [
  {
    Id: "00k9p000003LFYbAAO",
    OpportunityId: "0069p00000Dt6enAAB",
    Product2Id: "01t9p000005Z6NpAAK",
    Funding_purpose__c: "Working Capital",
    UnitPrice: 2,
    Product2: { Name: "ANZ Test Product", Id: "01t9p000005Z6NpAAK" }
  }
];

describe("c-launch-app-on-opp", () => {
  //Prepare data before each test method
  beforeEach(() => {
    const element = createElement("c-launch-app-on-opp", {
      is: LaunchAppOnOpp
    });
    element._recordId = RECORD_ID;
    document.body.appendChild(element);
  });

  afterEach(() => {
    // The jsdom instance is shared across test cases in a single file so reset the DOM
    while (document.body.firstChild) {
      document.body.removeChild(document.body.firstChild);
    }
    jest.clearAllMocks();
  });

  // Helper function to wait until the microtask queue is empty. This is needed for promise
  // timing when calling imperative Apex.
  async function flushPromises() {
    return Promise.resolve();
  }

  it("Test banker clicks on launch application", () => {
    const lwcCmp = document.querySelector("c-launch-app-on-opp");
    let buttonGroup = lwcCmp.shadowRoot.querySelector(".btnGrp");
    expect(buttonGroup).toBeTruthy();
  });
});
