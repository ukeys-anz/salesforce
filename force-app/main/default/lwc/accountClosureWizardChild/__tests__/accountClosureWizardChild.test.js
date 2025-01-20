import { createElement } from "lwc";
import AccountClosureWizardChild from "c/accountClosureWizardChild";
import createCasesForAccounts from "@salesforce/apex/AccountClosureWizardController.createCasesForAccounts";

jest.mock(
  "@salesforce/apex/AccountClosureWizardController.createCasesForAccounts",
  () => {
    return {
      default: jest.fn()
    };
  },
  { virtual: true }
);

const apexCreateCasesResponse = [
  {
    Id: "5005g00001HZAAK",
    CaseNumber: "00012345",
    Product__c: "Savings",
    FinServ__FinancialAccount__r: {
      FinServ__FinancialAccountNumber__c: "12345678"
    },
    Account_Type__c: "Checking"
  }
];

const mockSelectedRows = [
  {
    id: "row1",
    productName: "Product1",
    accountType: "Savings",
    accountNumber: "12345",
    closureReason: "Reason A",
    intendedAccountName: "John Doe",
    intendedAccountBsb: "062000",
    intendedAccountNumber: "987654321"
  }
];

describe("c-account-closure-wizard-child", () => {
  afterEach(() => {
    while (document.body.firstChild) {
      document.body.removeChild(document.body.firstChild);
    }
    jest.clearAllMocks();
  });

  async function flushPromises() {
    return Promise.resolve();
  }

  it("1. renders copy to all checkbox", async () => {
    const element = createElement("c-account-closure-wizard-child", {
      is: AccountClosureWizardChild
    });
    document.body.appendChild(element);
    element.showCheckbox = true;
    await flushPromises();
    const checkbox = element.shadowRoot.querySelector(
      "lightning-input[data-id=copyToAll]"
    );
    expect(checkbox).not.toBeNull();
    expect(checkbox.label).toBe(
      "Tick to use the same details for all accounts"
    );
  });

  it("2. triggers handleCreateChildCases and calls apex method", async () => {
    createCasesForAccounts.mockResolvedValue(apexCreateCasesResponse);
    const element = createElement("c-account-closure-wizard-child", {
      is: AccountClosureWizardChild
    });
    document.body.appendChild(element);

    element.recordId = "0015g00000HJXYZ";
    element.accountId = "0015g00000HJACB";
    element._selectedRows = mockSelectedRows;
    await flushPromises();
    const button = element.shadowRoot.querySelector(
      "lightning-button[data-id=createChildCasesButton]"
    );
    button.click();
    await flushPromises();
    expect(createCasesForAccounts).toHaveBeenCalled();
  });

  it("3. renders datatable after cases are created", async () => {
    createCasesForAccounts.mockResolvedValue(apexCreateCasesResponse);
    const element = createElement("c-account-closure-wizard-child", {
      is: AccountClosureWizardChild
    });
    document.body.appendChild(element);

    element.recordId = "0015g00000HJXYZ";
    element.accountId = "0015g00000HJACB";
    element._selectedRows = mockSelectedRows;
    await flushPromises();
    const button = element.shadowRoot.querySelector(
      "lightning-button[data-id=createChildCasesButton]"
    );
    button.click();
    await flushPromises();

    element.casesData = apexCreateCasesResponse.map((row) => ({
      childCaseNumberUrl: "/" + row.Id,
      childCaseNumber: row.CaseNumber,
      product: row.Product__c,
      accountNumber:
        row.FinServ__FinancialAccount__r.FinServ__FinancialAccountNumber__c,
      accountType: row.Account_Type__c
    }));

    let caseCreatedTable = element.shadowRoot.querySelector(
      "lightning-datatable[data-id=casesDataTable]"
    );
    expect(caseCreatedTable).not.toBeNull();
  });

  it("4. dispatches cancel event when cancel button is clicked", async () => {
    const element = createElement("c-account-closure-wizard-child", {
      is: AccountClosureWizardChild
    });
    document.body.appendChild(element);
    await flushPromises();
    const handler = jest.fn();
    element.addEventListener("cancel", handler);
    const button = element.shadowRoot.querySelector(
      "lightning-button[data-id=cancel]"
    );
    button.click();
    expect(handler).toHaveBeenCalled();
  });
});
