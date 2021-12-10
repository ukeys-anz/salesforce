import financialAccount from "c/financialAccount";
import { createElement } from "lwc";

const APEX_FACCOUNTS_SUCCESS = [
  {
    Id: "a0c2O00000197sUQAA",
    FinServ__Balance__c: 50,
    FinServ__Status__c: "Closed",
    LastModifiedDate: "2021-01-05T04:56:48.000+0000"
  },
  {
    Id: "a0c2O00000197sUQAB",
    FinServ__Balance__c: 50,
    FinServ__Status__c: "Active",
    LastModifiedDate: "2021-01-05T04:56:48.000+0000"
  },
  {
    Id: "a0c2O00000197sUQAC",
    FinServ__Balance__c: 50,
    LastModifiedDate: "2021-01-05T04:56:48.000+0000"
  },
  {
    Id: "a0c2O00000197sUQAD",
    FinServ__Balance__c: 50,
    LastModifiedDate: "2021-01-05T04:56:48.000+0000"
  }
];

describe("c-financialAccount", () => {
  //clean the dom and mocks in between test runs
  afterEach(() => {
    while (document.body.firstChild) {
      document.body.removeChild(document.body.firstChild);
    }
    jest.clearAllMocks();
  });

  it("test fin account success", () => {
    const element = createElement("c-financialAccount", {
      is: financialAccount
    });
    element.accountType = "Checking";
    element.accountDetails = APEX_FACCOUNTS_SUCCESS;
    document.body.appendChild(element);
    let componentTitle = element.shadowRoot.querySelector(
      "h1[data-id='component-title']"
    );
    let finAccount = element.shadowRoot.querySelector(
      "div[data-id='fin-account']"
    );
    expect(componentTitle.textContent).toMatch("Everyday - ANZ Plus Account");
    expect(finAccount).toBeTruthy();
  });

  it("tests fin accounts not displayed", () => {
    const element = createElement("c-financialAccount", {
      is: financialAccount
    });
    element.accountType = "Savings";
    element.accountDetails = [];
    document.body.appendChild(element);
    let componentTitle = element.shadowRoot.querySelector(
      "h1[data-id='component-title']"
    );
    let finAccount = element.shadowRoot.querySelector(
      "div[data-id='fin-account']"
    );
    expect(componentTitle.textContent).toMatch("Savings - ANZ Save Account");
    expect(finAccount).toBeFalsy();
  });

  it("tests error showed", () => {
    const element = createElement("c-financialAccount", {
      is: financialAccount
    });
    element.accountType = "Savings";
    element.error = "An error has occurred";
    document.body.appendChild(element);
    let error = element.shadowRoot.querySelector("c-error[data-id='error']");
    let finAccount = element.shadowRoot.querySelector(
      "div[data-id='fin-account']"
    );
    expect(error).toBeTruthy();
    expect(finAccount).toBeFalsy();
  });
});
