import * as faker from "faker";
import { createCaseList } from "../../objectStore/case";
import { createFinAccountList } from "../../objectStore/financialAccount";
import { createAccountList } from "../../objectStore/Account";
var caseid: String;
var fsid: String;
var accOwnerId: String;
var recordType: String = "General_Inquiry";

describe("Anonymous Complaint Edit Page", function() {
  before(function() {
    cy.login();

    cy.connect().then((response: any) => {
      cy.log("Creating cases...");
      createCaseList(response, 1, recordType).then((cases: any) => {
        caseid = cases[0].CaseNumber;
        console.log(
          "case final",
          cases[0].Id,
          cases[0].AccountId,
          cases[0].FinServ__FinancialAccount__c
        );
      });
    });
    cy.wait(3000);
  });
  it("Update case", function() {
    //cy.loadApp("Coaches Workbench").then((response: any) => {
    //  if (response) {
    //  cy.loadTab("Cases", "Stanard");
    //   }
    //});
    //cy.loadTab("Cases", "Standard");
    cy.loadApp("coaches workbench").loadTab("cases");
    cy.wait(3000);
  });
});
