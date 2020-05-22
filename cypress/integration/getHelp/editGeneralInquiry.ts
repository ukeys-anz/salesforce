import * as faker from "faker";
import { getRecordTypeID } from "../../objectStore/util";
import {
  getParentCase,
  getFinAccount,
  createBlankCase
} from "../../objectStore/case";
var caseNumber: String;
var parentCaseNumber: String;
var accId: String;
var accName: String;
var finAccName: String;
var recordType: String = "General_Inquiry";
var recordTypeId: String;

describe("Edit General Inquiry Case", function() {
  before(function() {
    cy.login();

    cy.connect().then((connection: any) => {
      cy.log("Create New Blank Case...");
      createBlankCase(connection, 1, recordType).then((cases: any) => {
        caseNumber = cases[0].CaseNumber;
      });
      cy.wait(5000);
    });

    cy.connect().then((connection: any) => {
      cy.log("Get FS Account...");
      getFinAccount(connection).then((finAccounts: any) => {
        finAccName = finAccounts[0].Name;
        accId = finAccounts[0].FinServ__PrimaryOwner__c;
        connection.query(
          "SELECT Id, Name FROM Account WHERE Id = '" + accId + "' LIMIT 1",
          async function(err: any, result: any) {
            if (err) {
              return console.error(err);
            }

            if (result.records.length > 0) {
              accName = result.records[0].Name;
            }
          }
        );
      });
      cy.wait(5000);
    });

    cy.connect().then((connection: any) => {
      cy.log("Get Case General Inquiry Record Type...");
      getRecordTypeID(connection, "Case", recordType).then((result: any) => {
        recordTypeId = result;
      });
      cy.wait(2000);
    });

    cy.connect().then((connection: any) => {
      cy.log("Get Parent Case...");
      getParentCase(connection, recordTypeId, accId).then((cases: any) => {
        parentCaseNumber = cases[0].CaseNumber;
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

    cy.typeLabel("Description of Issue", "textarea", faker.lorem.text());

    cy.selectLookup("Account Name", "input", accName.toString());

    cy.selectDropdown(
      "Status",
      faker.random.arrayElement([
        "Open",
        "Under Investigation",
        "On Hold",
        "Escalated",
        "Re-opened"
      ])
    );

    cy.selectDropdown("Type", "App Support");

    cy.multiSelect("Sub Type", "App Guide");
    cy.multiSelect("Sub Type", "Device Support");

    cy.multiSelect(
      "Additional Type",
      faker.random.arrayElement([
        "Bug Report & Feature",
        "Card",
        "Coaching",
        "Customer Feedback (NPS)",
        "Customer Update & Details"
      ])
    );

    cy.multiSelect(
      "Additional Type",
      faker.random.arrayElement([
        "Dispute",
        "Join / KYC",
        "My Security",
        "Product Information",
        "Transaction & Savings enquiry "
      ])
    );

    cy.selectDropdown(
      "Channel Received",
      faker.random.arrayElement([
        "Chat",
        "Voice Call",
        "Video Call",
        "Appointment",
        "Store"
      ])
    );

    cy.selectLookup("Parent Case", "input", parentCaseNumber.toString());

    cy.selectDropdown(
      "Priority",
      faker.random.arrayElement(["Critical", "High", "Medium", "Low"])
    );

    cy.selectLookup("Financial Account", "input", finAccName.toString());

    cy.get(".uiButton")
      .last()
      .click();

    cy.get(".forceToastMessage")
      .contains("Case was saved.")
      .should("be.visible");
  });
});
