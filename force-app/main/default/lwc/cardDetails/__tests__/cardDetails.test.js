import { createElement } from "lwc";
import CardDetails from "c/cardDetails";
import getCardDetails from "@salesforce/apex/CardDetailsController.getCardDetails";
import faker from "faker";

// Mocking imperative Apex method call
jest.mock(
  "@salesforce/apex/CardDetailsController.getCardDetails",
  () => {
    return {
      default: jest.fn()
    };
  },
  { virtual: true }
);

const accountHolder = faker.name.findName();
const MOCK_SUCCESS_RESPONSE = [
  {
    AccountHolder: accountHolder,
    Available_Balance__c: faker.random.number(10000),
    Card_Activation_Status__c: faker.random.arrayElement([
      "Activated",
      "Not Activated"
    ]),
    Card_Number__c: "4444444444444444",
    Card_Status_Reason__c: faker.random.arrayElement([
      "With PIN or Account Related",
      "Without PIN",
      "Damaged",
      "Last Prime debit linkage deleted",
      "Closed(OZ only)",
      "Fraud (OZ only)"
    ]),
    Card_Status__c: faker.random.arrayElement([
      "Closed",
      "Delinquent (Return)",
      "Delinquent (Retain)",
      "Issued",
      "Lost",
      "Stolen",
      "Unissued (N&D ICI Cards)",
      "Temporary (OZ Only)",
      "Block ATM",
      "Block ATM & POS (Exclude CNP)",
      "Block ATM, POS, CNP & BCH",
      "Block ATM, POS & CNP",
      "Block CNP",
      "Block POS (exclude CNP)"
    ]),
    Closed_Date__c: faker.date.future(),
    Daily_Limit__c: faker.random.number(10000),
    Expiry_Date__c: faker.date.soon,
    FinServ__AccountHolder__r: {
      Name: accountHolder
    },
    Last_Transaction_Processed__c: faker.date.past(),
    Limit_Type__c: faker.random.arrayElement(["ATM", "POS", "Overseas"]),
    Number_of_Card_Replacements__c: faker.random.number(5),
    Number_of_PIN_Changes__c: faker.random.number(5),
    Number_of_PIN_Failures__c: faker.random.number(3),
    Pin_Set__c: faker.random.boolean(),
    Temporary_Lock__c: "ATM withdrawal;Online"
  }
];

// Sample error for imperative Apex call
const MOCK_ERROR_RESPONSE = {
  body: { message: "An internal server error has occurred" },
  ok: false,
  status: 400,
  statusText: "Bad Request"
};

describe("c-card-details", () => {
  afterEach(() => {
    // The jsdom instance is shared across test cases in a single file so reset the DOM
    while (document.body.firstChild) {
      document.body.removeChild(document.body.firstChild);
    }
  });

  // Helper function to wait until the microtask queue is empty. This is needed for promise
  // timing when calling imperative Apex.
  function flushPromises() {
    // eslint-disable-next-line no-undef
    return new Promise((resolve) => setImmediate(resolve));
  }

  it("displays card details", () => {
    getCardDetails.mockResolvedValue(MOCK_SUCCESS_RESPONSE);

    const element = createElement("c-card-details", {
      is: CardDetails
    });
    document.body.appendChild(element);

    return flushPromises().then(() => {
      let card = element.shadowRoot.querySelector(
        "lightning-card[data-id='card-details']"
      );
      let error = element.shadowRoot.querySelector("c-error");
      let span = element.shadowRoot.querySelector(
        "span[data-id='card-holder']"
      );

      expect(card).toBeTruthy();
      expect(error).toBeFalsy();
      expect(span.textContent).toEqual(accountHolder);
    });
  });

  it("displays error component", () => {
    getCardDetails.mockRejectedValue(MOCK_ERROR_RESPONSE);

    const element = createElement("c-card-details", {
      is: CardDetails
    });
    document.body.appendChild(element);

    return flushPromises().then(() => {
      let error = element.shadowRoot.querySelector("c-error");
      let card = element.shadowRoot.querySelector(
        "lightning-card[data-id='card-details']"
      );

      expect(error).toBeTruthy();
      expect(card).toBeFalsy();
    });
  });

  it("clicks block button", () => {
    getCardDetails.mockResolvedValue(MOCK_SUCCESS_RESPONSE);

    const element = createElement("c-card-details", {
      is: CardDetails
    });
    document.body.appendChild(element);

    return flushPromises()
      .then(() => {
        let button = element.shadowRoot.querySelector(
          "lightning-button[data-id='block-button']"
        );

        expect(button).toBeTruthy();
        button.click();
      })
      .then(() => {
        let blockComponent = element.shadowRoot.querySelector(
          "c-card-temp-block"
        );
        expect(blockComponent).toBeTruthy();
      });
  });
});
