import { createElement } from "lwc";
import PersonAccountFinancialDetails from "c/personAccountFinancialDetails";
import { getRecord } from "lightning/uiRecordApi";
import getFinancialAccountFabric from "@salesforce/apex/FinancialAccountController.getFinancialAccountFabric";
global.structuredClone = jest.fn((obj) => JSON.parse(JSON.stringify(obj)));
const getWiredRecord = require("./data/getWiredData.json");
const accountData = require("./data/accountData.json");

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
    const accounts = accountData.groupedAccounts[0].accounts;
    const isSavingAccount = accountData.groupedAccounts[0].isSaving;
    const savingAccountDetails = accounts[0];
    expect(accountData.groupedAccounts.length).toBe(3);
    expect(isSavingAccount).toBe(true);
    expect(savingAccountDetails.account_name).toBe("Mitch Grimes");
    expect(savingAccountDetails.account_number).toBe("111111111");
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
    const accounts = accountData.groupedAccounts[1].accounts;
    console.log("Account " + JSON.stringify(accounts));
    const isOthersAccount = accountData.groupedAccounts[1].isOthers;
    const otherAccountDetails = accounts[0];
    expect(isOthersAccount).toBe(true);
    expect(otherAccountDetails.account_name).toBe("John Smith");
    expect(otherAccountDetails.account_number).toBe("000000000");
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
    const accounts = accountData.groupedAccounts[2].accounts;
    console.log("Account " + JSON.stringify(accounts));
    const isHomeLoanAccount = accountData.groupedAccounts[2].isHomeLoan;
    const homeLoanAccountDetails = accounts[0];
    expect(isHomeLoanAccount).toBe(true);
    expect(homeLoanAccountDetails.account_name).toBe("David Smith");
    expect(homeLoanAccountDetails.account_number).toBe("0101010101");
  });
});
