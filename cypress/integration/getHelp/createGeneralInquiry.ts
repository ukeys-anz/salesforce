import * as faker from "faker";
import { createFinAccountList } from "../../objectStore/financialAccount";
var caseid: String;
var fsid: String;
var accOwnerId: String;
var recordType: String = "General_Inquiry";

describe("Anonymous Complaint Edit Page", function() {
  before(function() {
    cy.login();
    cy.loadApp("Coaches Workbench", "Standard");
    cy.loadTab("Cases", "Standard");
    cy.wait(3000);
  });

  it("Update case", function() {
    cy.get(".forceActionLink[title=New]", { timeout: 10000 })
      .should("be.visible")
      .click({ force: true });

    cy.get(".slds-form-element__label")
      .contains("General Inquiry")
      .click();
    cy.get(".uiButton", { timeout: 10000 })
      .contains("Next")
      .click({ force: true });
    //Add explicit wait for modal to show up as url doesnt change cypress doesnt wait for it.
    cy.wait(3000);

    cy.typeLabel("Description of Issue", "textarea", faker.lorem.text());

    cy.typeLabel("Account Name", "input", "Thomas Shelby").click();

    cy.selectDropdown("Status", "Open");

    cy.selectDropdown("Type", "Coaching");

    cy.selectDropdown("Channel Received", "Chat");

    cy.get(".uiButton")
      .last()
      .click();
  });
});
