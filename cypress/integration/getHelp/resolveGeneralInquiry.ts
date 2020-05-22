import * as faker from "faker";
import { createCaseList } from "../../objectStore/case";
var caseNumber: String;
var recordType: String = "General_Inquiry";

describe("Create New General Inquiry Case", function() {
  before(function() {
    cy.login();

    cy.connect().then((connection: any) => {
      cy.log("Create New Case...");
      createCaseList(connection, 1, recordType).then((cases: any) => {
        caseNumber = cases[0].CaseNumber;
      });
    });

    cy.loadApp("Coaches Workbench");
    cy.loadTab("Cases");
  });

  it("Update case", function() {
    cy.get('.forceOutputLookup[title="' + caseNumber + '"]', {
      timeout: 10000
    }).click({ force: true });

    cy.get(".forceActionLink[title=Edit]", { timeout: 10000 })
      .should("be.visible")
      .click({ force: true });

    //Add explicit wait for modal to show up as url doesnt change cypress doesnt wait for it.
    cy.wait(3000);

    cy.selectDropdown("Status", faker.random.arrayElement(["Closed"]));

    cy.get(".uiButton")
      .last()
      .click();

    cy.get(".forceToastMessage")
      .contains("Case was saved.")
      .should("be.visible");
  });
});
