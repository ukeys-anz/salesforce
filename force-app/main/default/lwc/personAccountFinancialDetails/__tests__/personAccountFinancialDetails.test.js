import { createElement } from "lwc";
import PersonAccountFinancialDetails from "c/personAccountFinancialDetails";
import { getRecord } from "lightning/uiRecordApi";
import getFinancialAccountFabric from "@salesforce/apex/FinancialAccountController.getFinancialAccountFabric";
import { json } from "stream/consumers";
const getWiredRecord = require("./data/getWiredData.json");
const accountData = require("./data/accountData.json");
global.structuredClone = jest.fn((obj) => JSON.parse(JSON.stringify(obj)));

jest.mock(
  "@salesforce/apex/FinancialAccountController.getFinancialAccountFabric",
  () => ({
    default: jest.fn()
  }),
  { virtual: true }
);

async function flushPromises() {
  return Promise.resolve();
}

describe("c-person-account-financial-details", () => {
  afterEach(() => {
    // The jsdom instance is shared across test cases in a single file so reset the DOM
    while (document.body.firstChild) {
      document.body.removeChild(document.body.firstChild);
    }
    jest.clearAllMocks();
  });

  it("to test savings account", async () => {
    getFinancialAccountFabric.mockResolvedValue(accountData);
    await flushPromises();
    const element = createElement("c-person-account-financial-details", {
      is: PersonAccountFinancialDetails
    });
    element.objectApiName = "FinServ__FinancialAccount__c";
    document.body.appendChild(element);
    getRecord.emit(getWiredRecord);
    await flushPromises();
    const isSavingAccount = accountData[0].isSaving;
    const savingAccountDetails = accountData[0].accounts;
    expect(isSavingAccount).toBe(true);
    expect(savingAccountDetails[0].account_name).toBe("Mitch Grimes");
    expect(savingAccountDetails[0].account_number).toBe("111111111");
  });

  it("to test checking account", async () => {
    getFinancialAccountFabric.mockResolvedValue(accountData);
    await flushPromises();
    const element = createElement("c-person-account-financial-details", {
      is: PersonAccountFinancialDetails
    });
    element.objectApiName = "FinServ__FinancialAccount__c";
    document.body.appendChild(element);
    getRecord.emit(getWiredRecord);
    await flushPromises();
    const isOthersAccount = accountData[1].isOthers;
    const otherAccountDetails = accountData[1].accounts;
    expect(isOthersAccount).toBe(true);
    expect(otherAccountDetails[0].account_name).toBe("John Smith");
    expect(otherAccountDetails[0].account_number).toBe("000000000");
  });

  it("to test home loan account", async () => {
    getFinancialAccountFabric.mockResolvedValue(accountData);
    await flushPromises();
    const element = createElement("c-person-account-financial-details", {
      is: PersonAccountFinancialDetails
    });
    element.objectApiName = "FinServ__FinancialAccount__c";
    document.body.appendChild(element);
    getRecord.emit(getWiredRecord);
    await flushPromises();
    const isHomeLoanAccount = accountData[2].isHomeLoan;
    const homeLoanAccountDetails = accountData[2].accounts;
    expect(isHomeLoanAccount).toBe(true);
    expect(homeLoanAccountDetails[0].account_name).toBe("David Smith");
    expect(homeLoanAccountDetails[0].account_number).toBe("0101010101");
  });
});
